import * as functions from "firebase-functions";
import { database, initializeApp } from "firebase-admin";
import * as https from "http";

// TODO Refactoring: reduce repetition && implement better error handlers.

/******************************************************************
||                         DECLARATIONS                          ||
******************************************************************/

interface Coordinates { latitude: number; longitude: number }
interface Location {
  cityName: string;
  coordinates: Coordinates;
}

const locationManagerServerHost = "localhost";

const getHttpsOptions = (method = "POST", path = "/add") => {
  return {
    hostname: locationManagerServerHost,
    port: 3000,//443,
    path: path,
    method: method,
    headers: {
      "Transfer-Encoding": "chunked"
    }
  };
};

const sendToLocationManager = (id: string, location: Location) => {
  return new Promise((resolve, reject) => {
    https
      .request(getHttpsOptions(), (response) => {
        if (response.statusCode == 200) return resolve(undefined);
        return reject(Error("unknown"));
      })
      .on("error", (error) => {
        reject(error);
      })
      .end(JSON.stringify({ id: id, location: location }));
  });
};

const deleteFromLocationManager = (id: string, cityName: string) => {
  return new Promise((resolve, reject) => {
    const request = https
      .request(getHttpsOptions("DELETE", "/delete"), (response) => {
        if (response.statusCode == 200) return resolve(undefined);
        if (response.statusCode == 404)
          return reject(Error("location-not-found"));
        return reject(Error("unknown"));
      })
      .on("error", (error) => {
        reject(error);
      });
      request.write(JSON.stringify({ id: id, cityName: cityName }))
      request.end();
  });
};

const coordinatesToString = (coordinates: Coordinates) =>
  coordinates.latitude + "_" + coordinates.longitude;

/******************************************************************
||                          FUNCTIONS                             ||
******************************************************************/

initializeApp();
const firebaseDatabase = database();

export const listenToDisconnectionEvents = functions.database
  .ref("online/{cityName}/{driverId}")
  .onDelete(async (_, context) => {
    const params = context.params;
    deleteFromLocationManager(params.driverId, params.cityName).catch((__) => {
      deleteFromLocationManager(params.driverId, params.cityName); //* Retry.
    });
  });

export const connectsDriver = functions.https.onCall(async (data, context) => {
  if (!context.auth || data.cityName.includes('/'))
    throw new functions.https.HttpsError("failed-precondition", "");
  const id = context.auth.uid;
  console.log("\n\n"+ data +'\n\n');
  sendToLocationManager(id, data);
  firebaseDatabase
    .ref("online/" + data.cityName + "/" + id)
    .set(coordinatesToString(data.coordinates));
});

export const disconnectsDriver = functions.https.onCall(
  async (data, context) => {
    //* Don't delete the coordinates from the realtime data base for do not trigger de onDelete listener function (listenToDisconnectionEvents), other a disconnection will trigger two functions. The coordinates will be updated in the next connection of the driver
    if (!context.auth || data.cityName.includes('/'))
      throw new functions.https.HttpsError("failed-precondition", "");
    console.log("\n\n City: "+ data.cityName +'\n\n');
    try {
      await deleteFromLocationManager(context.auth.uid, data.cityName);
    } catch (error) {
      if(error.message == "location-not-found")
        throw new functions.https.HttpsError('not-found', "");
      else throw new functions.https.HttpsError("internal", "")
    }
  }
);

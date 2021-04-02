import * as functions from "firebase-functions";
import * as https from "http";

const locationManagerServerHost = "localhost";
const port = 3000;//443,
const requestOptions = {
    hostname: locationManagerServerHost,
    port: port,
    path: "/delete",
    method: "DELETE",
    headers: {
      "Transfer-Encoding": "chunked"
    }
  };

const deleteFromLocationManager = (id: string, cityName: string) => {
  return new Promise((resolve, reject) => {
    const request = https
      .request(requestOptions, (response) => {
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

export const listenToDisconnectEvents = functions.database
  .ref("online/{cityName}/{driverId}")
  .onDelete(async (_, context) => {
    const params = context.params;
    deleteFromLocationManager(params.driverId, params.cityName).catch((__) => {
      deleteFromLocationManager(params.driverId, params.cityName); //* Retry.
    });
  });

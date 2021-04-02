import { IncomingMessage, ServerResponse } from "http";
import { Coordinates, CoordinatesWrapper } from "../data/dataModels";

const sendNotFoundResponse = (httpResponse: ServerResponse) =>
  httpResponse.writeHead(404).end();

const getRequestData = (
  request: IncomingMessage,
  parseData = true
): Promise<JsonType> => {
  return new Promise((resolve, reject) => {
    let data = "";
    request
      .on("data", (chunk) => (data += chunk))
      .on("end", () => {
        if (!data) return reject(Error("invalid-data"));
        try {
          resolve(JSON.parse(data));
        } catch (_) {
          reject(Error("invalid-data"));
        }
      })
      .on("error", (error) => reject(error));
  });
};

const distanceBetween = (first: Coordinates, second: Coordinates) => {
  const dLat = (second.lat * Math.PI) / 180 - (first.lat * Math.PI) / 180;
  const dLon = (second.lon * Math.PI) / 180 - (first.lon * Math.PI) / 180;
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos((first.lat * Math.PI) / 180) *
      Math.cos((second.lat * Math.PI) / 180) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);
  // [6378.137] Radius of earth in KM
  return 6378.137 * (2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a)));
};

const getSortedClosestCoordinates = (
  coordinatesList: Map<string, CoordinatesWrapper>,
  data: any
) => {
  let coordinates: Coordinates;
  const closestCoordinates: any = {};
  let distance: string;
  coordinatesList.forEach((coordinatesWrapper, id) => {
    coordinates = coordinatesWrapper.coordinates;
    distance = distanceBetween(data.coord, coordinates).toFixed(5);
    if (distance <= data.maxDistance){
      closestCoordinates[distance] = { [id]: coordinates }; 
      if (--data.count === 0) return null;
    }
  });
  return closestCoordinates;
};

type JsonType = {
  [key: string]: any;
};

export {
  sendNotFoundResponse,
  getRequestData,
  JsonType,
  getSortedClosestCoordinates,
};

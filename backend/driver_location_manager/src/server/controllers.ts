import { IncomingMessage, OutgoingMessage, ServerResponse } from "http";
import {
  sendNotFoundResponse,
  getRequestData,
  getSortedClosestCoordinates,
} from "./utils";
import InMemoryCoordinatesRepository from "../data/inMemoryCoordinatesRepository";
import { CoordinatesRepositoryExceptionType } from "../data/coordinatesRepository";

const coordinatesRepository = new InMemoryCoordinatesRepository();

const errorHandler = (error: any, response: ServerResponse) => {
  if (
    error.message == "invalid-data" ||
    error.exceptionType ==
      CoordinatesRepositoryExceptionType.CoordinatesNotFound
  )
    response.writeHead(404).end();
  else response.writeHead(500).end();
};

const addController = async (
  request: IncomingMessage,
  response: ServerResponse
) => {
  try {
    const data = await getRequestData(request);
    coordinatesRepository.saveCoordinates(data.city, data.id, data.coord);
    response.writeHead(200).end();
  } catch (error) {
    errorHandler(error, response);
  }
};

const updateController = async (
  request: IncomingMessage,
  response: ServerResponse
) => {
  try {
    const data = await getRequestData(request);
    if (!coordinatesRepository.contains(data.id, data.city)) {
      sendNotFoundResponse(response);
    }
    coordinatesRepository.saveCoordinates(data.city, data.id, data.coord);
    response.writeHead(200).end();
  } catch (error) {
    errorHandler(error, response);
  }
};

const removeController = async (
  request: IncomingMessage,
  response: ServerResponse
) => {
  try {
    const data = await getRequestData(request);
    coordinatesRepository.removeCoordinates(data.city, data.id);
    response.writeHead(200).end();
  } catch (error) {
    errorHandler(error, response);
  }
};

const findClosestLocationController = async (
  request: IncomingMessage,
  response: ServerResponse
) => {
  try {
    const data = await getRequestData(request);
    const coordinatesList = coordinatesRepository.getCoordinatesByCityName(
      data.city
    );
    const result = getSortedClosestCoordinates(coordinatesList, data);
    if (Object.keys(result).length != 0) {
      response.setHeader('Content-Type', 'application/json');
      response.writeHead(200).end(JSON.stringify(result));
    } else sendNotFoundResponse(response);
  } catch (error) {
    errorHandler(error, response);
  }
};

export {
  addController,
  removeController,
  updateController,
  findClosestLocationController,
};

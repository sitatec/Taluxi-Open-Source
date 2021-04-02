import { IncomingMessage, ServerResponse } from "http";
import {
  addController,
  findClosestLocationController,
  removeController,
  updateController,
} from "./controllers";
import { sendNotFoundResponse } from "./utils";

const router = (request: IncomingMessage, response: ServerResponse) => {
  if (request.url === "/add" && request.method === "POST") {
    addController(request, response);
  } else if (request.url === "/delete" && request.method === "DELETE") {
    removeController(request, response);
  } else if (request.url === "/update" && request.method === "PATCH") {
    updateController(request, response);
  } else if (request.url === "/findClosest" && request.method === "POST") {
    findClosestLocationController(request, response);
  } else if (process.env.NODE_ENV == "development" && request.url == "/test") {
    testController(request, response);
  } else sendNotFoundResponse(response);
};
export default router;

///////////////////////////////////////////////////////////////////////////////
///                             ONLY FOR TESTS                              ///
///////////////////////////////////////////////////////////////////////////////

const testController = (request: IncomingMessage, response: ServerResponse) => {
  const CoordinatesRepositoryClass = require("../data/inMemoryCoordinatesRepository")
    .default;
  const coordinatesRepository = new CoordinatesRepositoryClass();
  response
    .writeHead(200)
    .end(
      JSON.stringify(
        mapToObject(coordinatesRepository.getAllCoordinatesForTest())
      )
    );
};

function mapToObject(map: Map<string, any>) {
  const out = Object.create(null);
  map.forEach((value, key) => {
    if (value instanceof Map) {
      out[key] = mapToObject(value);
    } else {
      out[key] = value;
    }
  });
  return out;
}

import DriverLocationManager from "../../src/app/driverLocationManager";
import { LocationManagerException } from "../../src/app/locationManagerException";
import { CoordinatesRepositoryException } from "../../../src/data/coordinatesRepository";
import { Coordinates, Location } from "../../../src/data/dataModels";
import InMemoryCoordinatesRepository from "../../../src/data/inMemoryCoordinatesRepository";

jest.mock("../../src/data/inMemoryCoordinatesRepository");

const coordinatesRepository = new InMemoryCoordinatesRepository();
const driverLocationManager = new DriverLocationManager(coordinatesRepository);

const fakeCity = "fake_city";
const fakeId = "fake_id";
const fakeCoordinates: Coordinates = {
  latitude: -12.546466,
  longitude: 16.374324,
};
const fakeLocation: Location = {
  cityName: fakeCity,
  coordinates: fakeCoordinates,
};

describe("DriverLocationManager.", () => {
  test("addLocatioin() should add new Location", () => {
    driverLocationManager.addLocation(fakeId, fakeLocation);
    expect(coordinatesRepository.saveCoordinates).toBeCalledWith(
      fakeCity,
      fakeId,
      fakeCoordinates
    );
  });

  test("removeLocation() should remove the location", () => {
    driverLocationManager.removeLocation(fakeId, fakeCity);
    expect(coordinatesRepository.removeCoordinates).toBeCalledWith(
      fakeCity,
      fakeId
    );
  });

  test("removeLocation() throw a exception", () => {
    coordinatesRepository.removeCoordinates = jest.fn(() => {
      throw CoordinatesRepositoryException.coordinatesNotFound();
    });
    expect(() =>
      driverLocationManager.removeLocation(fakeId, fakeCity)
    ).toThrow(LocationManagerException.UnableToRemoveUnsavedLocation());
  });

  test("removeLocation() throw a unknown exception", () => {
    coordinatesRepository.removeCoordinates = jest.fn(() => {
      throw Error();
    });
    expect(() =>
      driverLocationManager.removeLocation(fakeId, fakeCity)
    ).toThrow(LocationManagerException.unknown());
  });

  test("updateLocation() should update the location", () => {
    coordinatesRepository.contains = jest.fn(() => true);
    driverLocationManager.updateLocation(fakeId, fakeLocation);
    expect(coordinatesRepository.saveCoordinates).toBeCalledWith(
      fakeCity,
      fakeId,
      fakeCoordinates
    );
  });

  test("updateLocation() should throw a exception", () => {
    coordinatesRepository.contains = jest.fn(() => false);
    expect(() =>
      driverLocationManager.updateLocation(fakeId, fakeLocation)
    ).toThrow(LocationManagerException.UnableToUpdateUnsavedLocation());
  });
});

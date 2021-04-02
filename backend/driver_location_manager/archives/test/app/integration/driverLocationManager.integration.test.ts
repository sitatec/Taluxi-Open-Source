import DriverLocationManager from "../../src/app/driverLocationManager";
import { LocationManagerException } from "../../src/app/locationManagerException";
import { Coordinates, Location } from "../../../../src/data/dataModels";
import InMemoryCoordinatesRepository from "../../../../src/data/inMemoryCoordinatesRepository";

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
  beforeEach(() => {
    coordinatesRepository.clearOldCoordinates(0); // remove all coordinates.
  });

  test("addLocatioin() should add new Location", () => {
    driverLocationManager.addLocation(fakeId, fakeLocation);
    expect(coordinatesRepository.contains(fakeId, fakeCity)).toBeTruthy();
  });

  test("removeLocation() should remove the location", () => {
    driverLocationManager.addLocation(fakeId, fakeLocation);
    expect(coordinatesRepository.contains(fakeId, fakeCity)).toBeTruthy();
    driverLocationManager.removeLocation(fakeId, fakeCity);
    expect(coordinatesRepository.contains(fakeId, fakeCity)).toBeFalsy();
  });

  test("removeLocation() throw a exception", () => {
    expect(() =>
      driverLocationManager.removeLocation("unsaved-Id", "unknown-city")
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
    const newCoordinates = new Coordinates(0, 0);
    const newLocation = new Location(fakeCity, newCoordinates);
    driverLocationManager.addLocation(fakeId, fakeLocation);
    driverLocationManager.updateLocation(fakeId, newLocation);
    expect(coordinatesRepository.getCoordinates(fakeCity, fakeId)).toBe(
      newCoordinates
    );
  });

  test("updateLocation() should throw a exception", () => {
    expect(() =>
      driverLocationManager.updateLocation("unsaved-Id", fakeLocation)
    ).toThrow(LocationManagerException.UnableToUpdateUnsavedLocation());
  });
});

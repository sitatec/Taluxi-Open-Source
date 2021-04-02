import {
  CoordinatesRepository,
  CoordinatesRepositoryExceptionType,
} from "../../src/data/coordinatesRepository";
import { Location } from "../../src/data/dataModels";
import InMemoryCoordinatesRepository from "../../src/data/inMemoryCoordinatesRepository";
import { LocationManagerException } from "./locationManagerException";

export default class DriverLocationManager {
  constructor(
    private coordinatesRepository: CoordinatesRepository = new InMemoryCoordinatesRepository()
  ) {}
  addLocation(driverId: string, location: Location) {
    this.coordinatesRepository.saveCoordinates(
      location.cityName,
      driverId,
      location.coordinates
    );
  }

  removeLocation(driverId: string, cityName: string) {
    try {
      this.coordinatesRepository.removeCoordinates(cityName, driverId);
    } catch (error) {
      if (
        error.exceptionType ==
        CoordinatesRepositoryExceptionType.CoordinatesNotFound
      ) {
        throw LocationManagerException.UnableToRemoveUnsavedLocation();
      } else throw LocationManagerException.unknown();
    }
  }

  updateLocation(driverId: string, newLocation: Location) {
    // TODO handle the case were the new location city doesn't match to the old.
    if (!this.coordinatesRepository.contains(driverId, newLocation.cityName))
      throw LocationManagerException.UnableToUpdateUnsavedLocation();
    this.coordinatesRepository.saveCoordinates(
      newLocation.cityName,
      driverId,
      newLocation.coordinates
    );
  }
}

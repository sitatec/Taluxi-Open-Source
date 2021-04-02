import {
  CoordinatesRepository,
  CoordinatesRepositoryException,
} from "./coordinatesRepository";
import { Coordinates, CoordinatesWrapper, InMemoryDatabaseStructure } from "./dataModels";

// TODO: Refactoring (create a class InMemoryDatabase wich will extends a Database class)

// TODO: faire en sorte que quelqu'un qui se trouve dans une ville differente de celle d'un taxi proche de lui puisse se trouver .

const inMemoryDatabase: InMemoryDatabaseStructure = new Map();

export default class InMemoryCoordinatesRepository
  implements CoordinatesRepository {
    
  getCoordinatesByCityName(cityName: string): Map<string, CoordinatesWrapper> {
    const coordinates = inMemoryDatabase.get(cityName);
    if(coordinates) return coordinates;
    throw CoordinatesRepositoryException.coordinatesNotFound();
  }

  saveCoordinates(
    cityName: string,
    id: string,
    coordinates: Coordinates
  ): void {
    const coordinatesWrapper = {
      lastWriteTime: Date.now(),
      coordinates: coordinates,
    };
    inMemoryDatabase.get(cityName)?.set(id, coordinatesWrapper) ??
      inMemoryDatabase.set(cityName, new Map([[id, coordinatesWrapper]]));
  }

  getCoordinates(cityName: string, id: string): Coordinates {
    const coordinates = inMemoryDatabase.get(cityName)?.get(id)?.coordinates;
    if (!coordinates) {
      throw CoordinatesRepositoryException.coordinatesNotFound();
    }
    return coordinates;
  }

  clearOldCoordinates(minLifeTime: number): string[] {
    let currentTime: number;
    let deletedCoordinateIds: string[] = [];
    inMemoryDatabase.forEach((cityCoordinatesList) => {
      currentTime = Date.now();
      cityCoordinatesList.forEach((coordinatesWrapper, id) => {
        if (currentTime - coordinatesWrapper.lastWriteTime >= minLifeTime) {
          cityCoordinatesList.delete(id);
          deletedCoordinateIds.push(id);
        }
      });
    });
    return deletedCoordinateIds;
  }

  getTotalCoordinatesCount(): number {
    let coordinatesCount = 0;
    inMemoryDatabase.forEach((cityCoordinatesList) => {
      coordinatesCount += cityCoordinatesList.size;
    });
    return coordinatesCount;
  }

  contains(id: string, cityName: string): boolean {
    return inMemoryDatabase.get(cityName)?.has(id) ?? false;
  }
  // TODO test
  removeCoordinates(cityName: string, id: string): void {
    const cityCoordinatesList = inMemoryDatabase.get(cityName);
    if (cityCoordinatesList?.has(id)) cityCoordinatesList.delete(id);
    else throw CoordinatesRepositoryException.coordinatesNotFound();
  }

  getAllCoordinatesForTest(): any {
    if (process.env.NODE_ENV !== "development") return null;
    return inMemoryDatabase;
  }
}

import { Coordinates, CoordinatesWrapper } from "./dataModels";

export interface CoordinatesRepository {
  getCoordinates(cityName: string, id: string): Coordinates;
  saveCoordinates(cityName: string, id: string, coordinates: Coordinates): void;
  clearOldCoordinates(minLifeTime: number): string[];
  getTotalCoordinatesCount(): number;
  contains(id: string, cityName: string): boolean;
  removeCoordinates(cityName: string, id: string): void;
  getCoordinatesByCityName(cityName: string): Map<string, CoordinatesWrapper>;
}

export class CoordinatesRepositoryException extends Error {
  constructor(
    public exceptionType: CoordinatesRepositoryExceptionType,
    description: string
  ) {
    super(description);
  }

  static coordinatesNotFound(): CoordinatesRepositoryException {
    return new this(
      CoordinatesRepositoryExceptionType.CoordinatesNotFound,
      "The given combination of city name and id does not match any Location."
    );
  }
}

export const enum CoordinatesRepositoryExceptionType {
  CoordinatesNotFound,
}

export class Coordinates {
  constructor(public lat: number, public lon: number) {}
}

export interface CoordinatesWrapper {
  lastWriteTime: number;
  coordinates: Coordinates;
}

export type InMemoryDatabaseStructure = Map<
  string,
  Map<string, CoordinatesWrapper>
>;
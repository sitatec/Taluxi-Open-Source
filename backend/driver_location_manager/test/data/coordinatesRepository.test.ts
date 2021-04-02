import {
  CoordinatesRepository,
  CoordinatesRepositoryException,
} from "../../src/data/coordinatesRepository";
import InMemoryCoordinatesRepository from "../../src/data/inMemoryCoordinatesRepository";
import { Coordinates } from "../../src/data/dataModels";

let coordinatesRepository: CoordinatesRepository;
const fakeCoordinates = new Coordinates(12.464433, -14.461556);
const otherCoordinates = new Coordinates(11.404643, -19.461556);
const fakeId = "ID";
const otherId = "__ID__";
const fakeCity = "city";

coordinatesRepository = new InMemoryCoordinatesRepository();

describe("CoordinatesRepository.", () => {
  beforeEach(() => {
    coordinatesRepository.clearOldCoordinates(0); // remove all coordinates.
  });
  test("getCoordinates() should get coordinates", () => {
    coordinatesRepository.saveCoordinates("city", "id", fakeCoordinates);
    const coordinates = coordinatesRepository.getCoordinates("city", "id");
    expect(coordinates).toBeInstanceOf(Coordinates);
    expect(coordinates).toBe(fakeCoordinates);
  });

  test("saveCoordinates() should set new coordinates", () => {
    expect(
      coordinatesRepository.saveCoordinates(fakeCity, fakeId, fakeCoordinates)
    ).not.toThrow;
    expect(coordinatesRepository.getCoordinates(fakeCity, fakeId)).toEqual(
      fakeCoordinates
    );
  });

  test("getCoordinates() should throw a exception if the given id doesn't exist", () => {
    expect(() =>
      coordinatesRepository.getCoordinates(fakeCity, "non-existent-id")
    ).toThrow(CoordinatesRepositoryException.coordinatesNotFound());
  });

  test("getCoordinates() should throw a exception if the given city name doesn't exist", () => {
    coordinatesRepository.saveCoordinates(fakeCity, fakeId, fakeCoordinates);
    expect(() =>
      coordinatesRepository.getCoordinates("non-existent-city-name", fakeId)
    ).toThrow(CoordinatesRepositoryException.coordinatesNotFound());
  });

  test("getTotalCoordinatesCount() should return 2", () => {
    coordinatesRepository.saveCoordinates(fakeCity, fakeId, fakeCoordinates);
    coordinatesRepository.saveCoordinates(fakeCity, otherId, otherCoordinates);
    expect(coordinatesRepository.getTotalCoordinatesCount()).toEqual(2);
  });

  test("saveCoordinates() should not duplicate identifiers (id)", () => {
    coordinatesRepository.saveCoordinates(fakeCity, fakeId, fakeCoordinates);
    coordinatesRepository.saveCoordinates(fakeCity, fakeId, otherCoordinates);
    expect(coordinatesRepository.getTotalCoordinatesCount()).toEqual(1);
    expect(coordinatesRepository.getCoordinates(fakeCity, fakeId)).toBe(
      otherCoordinates
    );
  });

  test("clearOldCoordinates() should clear old coordinates", (done) => {
    coordinatesRepository.saveCoordinates(fakeCity, fakeId, fakeCoordinates);
    try {
      setTimeout(() => {
        coordinatesRepository.saveCoordinates(
          fakeCity,
          otherId,
          otherCoordinates
        );
        expect(coordinatesRepository.getTotalCoordinatesCount()).toEqual(2);
        coordinatesRepository.clearOldCoordinates(1000);
        expect(coordinatesRepository.getTotalCoordinatesCount()).toEqual(1);
        done();
      }, 1000);
    } catch (error) {
      done(error);
    }
  });
  test("clearOldCoordinates() should return a array which contains the deleted coordinates ids", (done) => {
    coordinatesRepository.saveCoordinates(fakeCity, fakeId, fakeCoordinates);
    coordinatesRepository.saveCoordinates(fakeCity, otherId, otherCoordinates);
    let deletedCoordinateIds: string[];
    try {
      setTimeout(() => {
        coordinatesRepository.saveCoordinates(
          fakeCity,
          "thirdFaikeId",
          otherCoordinates
        );
        expect(coordinatesRepository.getTotalCoordinatesCount()).toEqual(3);
        deletedCoordinateIds = coordinatesRepository.clearOldCoordinates(1000);
        expect(coordinatesRepository.getTotalCoordinatesCount()).toEqual(1);
        expect(deletedCoordinateIds).toEqual([fakeId, otherId]);
        done();
      }, 1000);
    } catch (error) {
      done(error);
    }
  });

  test("clearOldCoordinates() should clear old coordinates regardless the city name", (done) => {
    coordinatesRepository.saveCoordinates(fakeCity, fakeId, fakeCoordinates);
    coordinatesRepository.saveCoordinates("otheCity", "-Id-", otherCoordinates);
    try {
      setTimeout(() => {
        coordinatesRepository.saveCoordinates(
          fakeCity,
          otherId,
          otherCoordinates
        );
        expect(coordinatesRepository.getTotalCoordinatesCount()).toEqual(3);
        coordinatesRepository.clearOldCoordinates(1000);
        expect(coordinatesRepository.getTotalCoordinatesCount()).toEqual(1);
        done();
      }, 1000);
    } catch (error) {
      done(error);
    }
  });

  test("contains() should return true if coordinates is in db else false", () => {
    expect(coordinatesRepository.contains(fakeId, fakeCity)).toBeFalsy();
    coordinatesRepository.saveCoordinates(fakeCity, fakeId, fakeCoordinates);
    expect(coordinatesRepository.contains(fakeId, fakeCity)).toBeTruthy();
  });

  test("getCoordinatesByCityName() should get all coordinates of a given city", () => {
    coordinatesRepository.saveCoordinates(fakeCity, fakeId, fakeCoordinates);
    coordinatesRepository.saveCoordinates(fakeCity, otherId, otherCoordinates);
    coordinatesRepository.saveCoordinates("otheCity", "-Id-", otherCoordinates);
    const cityCoordinates = coordinatesRepository.getCoordinatesByCityName(
      fakeCity
    );
    expect(cityCoordinates?.get(fakeId)?.coordinates).toBe(fakeCoordinates);
    expect(cityCoordinates?.get(otherId)?.coordinates).toBe(otherCoordinates);
  });

  test("removeCoordinates() should delete coordinates", () => {
    coordinatesRepository.saveCoordinates(fakeCity, fakeId, fakeCoordinates);
    coordinatesRepository.removeCoordinates(fakeCity, fakeId);
    expect(coordinatesRepository.getTotalCoordinatesCount()).toEqual(0);
  });

  test("removeCoordinates() should throw a exception (not found)", () => {
    coordinatesRepository.saveCoordinates(fakeCity, fakeId, fakeCoordinates);
    expect(() =>
      coordinatesRepository.removeCoordinates(fakeCity, "unregisteredID")
    ).toThrow(CoordinatesRepositoryException.coordinatesNotFound());

    expect(() =>
      coordinatesRepository.removeCoordinates("unregisteredCity", fakeId)
    ).toThrow(CoordinatesRepositoryException.coordinatesNotFound());
  });
});

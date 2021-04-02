import { CoordinatesWrapper } from "../src/data/dataModels";
import { getSortedClosestCoordinates } from "../src/server/utils";

const fakeCoordinatesList = new Map<string, CoordinatesWrapper>([
  [
    "1",
    {
      lastWriteTime: 35,
      coordinates: {
        lat: 11.309550998341876,
        lon: -12.319665762946318,
      },
    },
  ],
  [
    "2",
    {
      lastWriteTime: 35,
      coordinates: {
        lat: 11.31306089962555,
        lon: -12.310101317338793,
      },
    },
  ],
  [
    "3",
    {
      lastWriteTime: 35,
      coordinates: {
        lat: 11.509550998341876,
        lon: -12.519665762946318,
      },
    },
  ],
  [
    "4",
    {
      lastWriteTime: 35,
      coordinates: {
        lat: 11.609550998341876,
        lon: -12.619665762946318,
      },
    },
  ],
  [
    "5",
    {
      lastWriteTime: 35,
      coordinates: {
        lat: 11.709550998341876,
        lon: -12.719665762946318,
      },
    },
  ],
]);

const otherCoordinatesList = new Map<string, CoordinatesWrapper>([
  [
    "1",
    {
      lastWriteTime: 35,
      coordinates: {
        lat: 11.309550998341876,
        lon: -12.319665762946318,
      },
    },
  ],
  [
    "2",
    {
      lastWriteTime: 35,
      coordinates: {
        lat: 11.31306089962555,
        lon: -12.310101317338793,
      },
    },
  ],
  [
    "3",
    {
      lastWriteTime: 35,
      coordinates: {
        lat: 11.309550998341879,
        lon: -12.319665762946318,
      },
    },
  ],
  [
    "4",
    {
      lastWriteTime: 35,
      coordinates: {
        lat: 11.31306089962557,
        lon: -12.310101317338793,
      },
    },
  ],
  [
    "5",
    {
      lastWriteTime: 35,
      coordinates: {
        lat: 11.509550998341876,
        lon: -12.519665762946318,
      },
    },
  ],
  [
    "6",
    {
      lastWriteTime: 35,
      coordinates: {
        lat: 11.609550998341876,
        lon: -12.619665762946318,
      },
    },
  ],
  [
    "7",
    {
      lastWriteTime: 35,
      coordinates: {
        lat: 11.709550998341876,
        lon: -12.719665762946318,
      },
    },
  ],
]);

const fakeData = {
  maxDistance: 2,
  coord: {
    lat: 11.312665050338422,
    lon: -12.319215151855502,
  },
  count: 4,
};

test("getSortedCloestCoordinates() should return the closest coordinates", () => {
  const closestCoordinates = getSortedClosestCoordinates(
    fakeCoordinatesList,
    fakeData
  );
  expect(Object.keys(closestCoordinates).length).toEqual(2);
});

test("getSortedCloestCoordinates() should return the closest coordinates and the count of returned coordinates == to given count in the data param", () => {
  const count = fakeData.count;
  const closestCoordinates = getSortedClosestCoordinates(
    otherCoordinatesList,
    fakeData
  );
  expect(Object.keys(closestCoordinates).length).toEqual(count);
});

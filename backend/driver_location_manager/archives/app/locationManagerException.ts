export class LocationManagerException extends Error {
  constructor(
    public exceptionType: LocationManagerExceptionType,
    description: string
  ) {
    super(description);
  }
  static UnableToUpdateUnsavedLocation(): LocationManagerException {
    return new this(
      LocationManagerExceptionType.UnableToUpdateUnsavedLocation,
      "The given location is not  registred so it can't be updated."
    );
  }

  static UnableToRemoveUnsavedLocation(): LocationManagerException {
    return new this(
      LocationManagerExceptionType.UnableToUpdateUnsavedLocation,
      "The given location is not registred so it can't be removed."
    );
  }

  static unknown(): LocationManagerException {
    return new this(
      LocationManagerExceptionType.unknown,
      "Unknown exception reason."
    );
  }

}

export const enum LocationManagerExceptionType {
  UnableToUpdateUnsavedLocation,
  UnableToRemoveUnsavedLocation,
  unknown
}

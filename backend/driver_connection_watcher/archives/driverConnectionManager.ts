// import { Location } from "./dataModels";
// import { DriverLocationManager} from "./services";

// export class DriverConnectionManager {
//   constructor(public driverlocationManager = new DriverLocationManager()) {}

//   async connects(
//     driverId: string,
//     location: Location,
//   ): Promise<void> {
//       this.driverlocationManager.putLocation(
//         driverId,
//         location
//       ).catch ((error) => {
//       if (error.message === "validation-failed")
//         throw DriversConnectionManagerException.invalidIdToken();
//       else throw DriversConnectionManagerException.connectionFailed();
//     })
//   }

//   async disconnects(driverId: string, cityName: string): Promise<void> {
//     try {
//       await this.driverlocationManager.deleteLocation(driverId, cityName);
//     } catch (error) {
      
//     }
//   }
// }

// export class DriversConnectionManagerException extends Error {
//   constructor(
//     public exceptionType: DriversConnectionManagerExceptionType,
//     description: string
//   ) {
//     super(description);
//   }
//   static invalidIdToken(): DriversConnectionManagerException {
//     return new this(
//       DriversConnectionManagerExceptionType.invalidIdToken,
//       "invalid id token"
//     );
//   }
//   static driverIsNotConnected(): DriversConnectionManagerException {
//     return new this(
//       DriversConnectionManagerExceptionType.driverIsNotConnected,
//       "The driver whose uid is given is not connected"
//     );
//   }

//   static deconnectionFailed(): DriversConnectionManagerException {
//     return new this(
//       DriversConnectionManagerExceptionType.deconnectionFailed,
//       "Driver deconnection Failed"
//     );
//   }

//   static connectionFailed(): DriversConnectionManagerException {
//     return new this(
//       DriversConnectionManagerExceptionType.connectionFailed,
//       "Driver connection Failed"
//     );
//   }
// }

// const enum DriversConnectionManagerExceptionType {
//   invalidIdToken,
//   driverIsNotConnected,
//   deconnectionFailed,
//   connectionFailed,
// }

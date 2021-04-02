// import { Coordinates, Location } from "./dataModels";
// import https from "https";

// // let servicesInitialized = false;

// // const initializeServices = () => {
// //   if (!servicesInitialized) {
// //     initializeApp();
// //     servicesInitialized = true;
// //   }
// // };

// // export interface Authentication {
// //   validateToken(idToken: string): Promise<string>;
// // }

// // export class FirebaseAuthAdapter implements Authentication {
// //   constructor(private firebaseAuth: auth.Auth = auth()) {
// //     initializeServices();
// //   }

// //   async validateToken(idToken: string): Promise<string> {
// //     try {
// //       const decodedIdToken = await this.firebaseAuth.verifyIdToken(idToken);
// //       return decodedIdToken.uid;
// //     } catch (_) {
// //       throw Error("validation-failed");
// //     }
// //   }
// // }

// // class CoordinatesSynchronizer {
// //   constructor(private realtimeDatabase = database().ref("online")) {
// //     initializeServices();
// //   }

// //   setCoordinates(id: string, coordinates: Coordinates): Promise<void> {
// //     return this.realtimeDatabase.child(id).set(coordinates);
// //   }

// //   deleteCoordinates(id: string): Promise<void> {
// //     return this.realtimeDatabase.child(id).remove();
// //   }
// // }

// export class DriverLocationManager {
//   constructor(
//     private httpsClient = https,
//   ) {}

//   private readonly locationManagerServerHost = "";

//   private getHttpsOptions(method = "POST", path = "/add") {
//     return {
//       hostname: this.locationManagerServerHost,
//       port: 443,
//       path: path,
//       method: method,
//     };
//   }

//   // TODO Refactoring: reduce repetition && implement better error handlers.
//   async putLocation(id: string, location: Location): Promise<void> {
//     return new Promise((resolve, reject) => {
//       this.httpsClient
//         .request(this.getHttpsOptions(), (response) => {
//           if (response.statusCode == 200) return resolve();
//           return reject(Error("unknown"));
//         })
//         .on("error", (error) => {
//           reject(error);
//         })
//         .end(JSON.stringify({ id: id, location: location }));
//     });
//   }

//   async deleteLocation(id: string, cityName: string): Promise<void> {
//     return new Promise((resolve, reject) => {
//       this.httpsClient
//         .request(this.getHttpsOptions("DELETE", "/delete"), (response) => {
//           if (response.statusCode == 200) return resolve();
//           if (response.statusCode == 404)
//             return reject(Error("location-not-found"));
//           return reject(Error("unknown"));
//         })
//         .on("error", (error) => {
//           reject(error);
//         })
//         .end(JSON.stringify({ id: id, city: cityName }));
//     });
//   }
// }

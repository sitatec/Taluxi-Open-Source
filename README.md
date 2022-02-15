# Taluxi

This repository is the merge of my following repositories (I have created more packages since the merge):
 - [taluxi](https://github.com/sitatec/taluxi)
 - [network_communication](https://github.com/sitatec/network_communication)
 - [real_time_location](https://github.com/sitatec/real_time_location)
 - [user_manager](https://github.com/sitatec/user_manager)
 - [taluxi_shared_components](https://github.com/sitatec/taluxi_common)
<br>

> ⚠️ This project was created only for learning purposes. Using it in a production environment will not be a good idea for many reasons (the most important reason is that the `driver_location_manager` microservice find the closest driver using an algorithm that computes distances as the crow flies ([The Haversine Formula](https://en.wikipedia.org/wiki/Haversine_formula)), it doesn't take into account the roads network and the delay that may be caused by the traffic). To use it in a prod env you should create or use an existing routing engine (depending on your needs) that relies on map data and live traffic data.


![taluxi_screenshots](https://github.com/sitatec/Taluxi-X/blob/main/assets/screens.png)

Taluxi is a taxi finder solution with two mobile apps built with Flutter (Taluxi and Taluxi Driver) and two microservices (DriverLocationManager and DriverConnectionWatcher) built with Nodejs (TypeScript). DriverLocationManager is hosted by [Google Cloud App Engine](https://cloud.google.com/appengine) and DriverConnectionWatcher is running on [Firebase Cloud Functions](https://firebase.google.com/products/functions). 

I made the project fully modular, which make its modules easily and independently testable, maintainable as well as reusable, it also makes the overall project very flexible and easy to work on. The apps themselves don't depend on any external service or library (except for the UI related libraries) they are independent from even the backend microservices that are part of the project, they depend only on the [front-end packages](https://github.com/sitatec/Taluxi-Open-Source/tree/main/packages) that are part of the project, and those packages depend on services like firebase, agora, or the back-end services. All the packages expose a clean API and apply most of the SOLID principles, thus the packages themselves are not tightly coupled to external services.

> ⚠️ The project is tested only on Android, the Taluxi Passenger app may work on IOS but the UI is not IOS app-like. The Taluxi Driver app will not work on IOS for now because android native code 
> is used to implement a custom incoming call notification with a full-screen intent(I might implement that on IOS using the CallKit tool in the future). All the packages are fully tested but the apps themselves (the UIs) are not yet. 

## Requirements
To be able to use all the features of the apps, you will need an [Agora AppID](https://docs.agora.io/en/Agora%20Platform/token?platform=Android) and an [OneSignal AppID](https://documentation.onesignal.com/docs/accounts-and-keys) and put each in the appropriated constant (according to the constant name) in the [config file](https://github.com/sitatec/Taluxi-Open-Source/blob/main/packages/production/network_communication/lib/src/config.dart) of the [network_communication](https://github.com/sitatec/Taluxi-Open-Source/tree/main/packages/production/network_communication) package.

## Scenario
> ℹ️ The __Taluxi__ app is built for the Clients and the __Taluxi Driver__ app for the drivers. A Client is a person that is looking for a taxi and a Driver is... simply a taxi driver. 

A client launches the app and hits a button to search for a taxi, the app finds the closest taxi and calls the driver, the client discusses with the driver if they have found an agreement the driver pickup the client and drives him/her to the destination (the client can track the driver position on the map) otherwise the client call another taxi... (The app is built for some country where the taxis have not taxi meters, that is the reason why the client have to discusses with the driver through a voice call for the price depending on the destination).

## Relatively detailed scenario 
Both client and driver use the [user_manager](https://github.com/sitatec/Taluxi-Open-Source/tree/main/packages/production/user_manager) packages to authenticate.
A client launches the app and hits a button to search for a taxi, The client app sends a request to the DriverLocationManager with the client GPS coordinates, the maximum distance in meter (for the scope of the recherche), and the number of results to return ( If some taxis are in the scope but are not available, the client will contact others without sending again another request). The DriverLocationManager uses the Haversine formula to find the closest connected taxis (the coordinates of all of the connected taxis are in an in-memory database for the speed and some constraints detailed in the DriverLocationManager [README](https://github.com/sitatec/Taluxi-Open-Source/tree/main/backend/driver_location_manager)) and return their coordinates. When the client app Receives the result, it uses a VoIP service to calls the nearest taxi. For more detail about the call process, see the [network_communication](https://github.com/sitatec/Taluxi-Open-Source/tree/main/packages/production/network_communication) package's README. If the client and driver have found an agreement, the 2 apps use the [real_time_location](https://github.com/sitatec/Taluxi-Open-Source/tree/main/packages/production/real_time_location) package to share/track the driver position.

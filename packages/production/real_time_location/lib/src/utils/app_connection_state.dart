import 'package:firebase_database/firebase_database.dart';

Stream<AppConnectionState> getAppConnectionStateStream() {
  return FirebaseDatabase.instance
      .reference()
      .child('.info/connected')
      .onValue
      .map<AppConnectionState>((event) => event.snapshot.value
          ? AppConnectionState.connected
          : AppConnectionState.disconnected);
}

enum AppConnectionState { connected, disconnected }

/*
? The Combination of Firedart + Official Firebase Packages
const firebaseConfig = {
  apiKey: "AIzaSyAjaGYDdHvb0_vsG3JRS6ZVUegaicjn5Uo",
  authDomain: "freeproject-c8687.firebaseapp.com",
  projectId: "freeproject-c8687",
  storageBucket: "freeproject-c8687.appspot.com",
  messagingSenderId: "803703594987",
  appId: "1:803703594987:web:1eab5d874a2b50260783ae"
};
*/
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firedartextreme/firedart.dart';

class FireGlobal {
  static Future initialize({
    required String apiKey,
    required String projectId,
    required String appId,
    required String messagingSenderId,
  }) async {
    if (Platform.isWindows) {
      FireDartFirebaseAuth.initialize(apiKey, FireDartVolatileStore());
      FireDartFirestore.initialize(projectId);

      //Wait Until SignIn Ready?

      bool ready = false;

      var auth = FireDartFirebaseAuth.instance;
      auth.signInState.listen((state) {
        print("Signed ${state ? "in" : "out"}");
        ready = false;
      });

      while (ready == false) {
        print("Check Firebase Status..");
        await Future.delayed(Duration(milliseconds: 200));
      }
    } else {
      await Firebase.initializeApp(
        options: FirebaseOptions(
          appId: appId,
          apiKey: apiKey,
          messagingSenderId: messagingSenderId,
          projectId: projectId,
        ),
      );

      bool ready = false;
      FirebaseAuth.instance.authStateChanges().listen((event) {
        ready = true;
      });

      while (ready == false) {
        print("Check Firebase Status..");
        await Future.delayed(Duration(milliseconds: 200));
      }
    }
  }

  static Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    if (Platform.isWindows) {
      var auth = FireDartFirebaseAuth.instance;
      await auth.signIn(email, password);

      if (auth.isSignedIn) {
        var user = await auth.getUser();
        currentUser = GlobalUser(
          uid: user.id,
          displayName: user.displayName,
          email: user.email,
          phoneNumber: null,
          photoURL: user.photoUrl,
        );
        return true;
      }
    } else {
      var auth = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (auth.user != null) {
        currentUser = GlobalUser(
          uid: FirebaseAuth.instance.currentUser!.uid,
          displayName: FirebaseAuth.instance.currentUser!.displayName,
          email: FirebaseAuth.instance.currentUser!.email,
          phoneNumber: FirebaseAuth.instance.currentUser!.phoneNumber,
          photoURL: FirebaseAuth.instance.currentUser!.photoURL,
        );
        return true;
      }
    }
    return false;
  }

  static GlobalUser? currentUser;
}

class GlobalUser {
  final String uid;
  final String? displayName;
  final String? photoURL;
  final String? phoneNumber;
  final String? email;

  GlobalUser({
    required this.uid,
    this.displayName,
    this.photoURL,
    this.phoneNumber,
    this.email,
  });
}

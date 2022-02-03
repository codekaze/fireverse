import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:fireverse/generated/google/protobuf/timestamp.pb.dart' as fd;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fireverse/fireverse.dart';

class FireOrder {
  final String field;
  final bool descending;

  FireOrder({
    required this.field,
    this.descending = false,
  });
}

class FireWhereField {
  final String field;
  final String? isEqualTo;
  final String? isGreaterThan;
  final String? isGreaterThanOrEqualTo;
  final String? isLessThan;
  final String? isLessThanOrEqualTo;

  FireWhereField({
    required this.field,
    this.isEqualTo,
    this.isGreaterThan,
    this.isGreaterThanOrEqualTo,
    this.isLessThan,
    this.isLessThanOrEqualTo,
  });
}

class Fire {
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

      // bool ready = false;

      // var auth = FireDartFirebaseAuth.instance;
      // auth.signInState.listen((state) {
      //   print("Signed ${state ? "in" : "out"}");
      //   ready = false;
      // });

      // while (ready == false) {
      //   print("Check Firebase Status..");
      //   await Future.delayed(Duration(milliseconds: 200));
      // }
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

  static snapshot({
    required String collectionName,
  }) async {
    if (Platform.isWindows) {
      return await FireDartFirestore.instance.collection(collectionName).stream;
    } else {
      return await fs.FirebaseFirestore.instance
          .collection(collectionName)
          .snapshots();
    }
  }

  static get({
    required String collectionName,
    List<FireWhereField>? where,
    FireOrder? FireOrder,
  }) async {
    if (Platform.isWindows) {
      var refs = [];
      var ref = FireDartFirestore.instance.collection(collectionName);
      refs.add(ref);

      if (where != null) {
        for (var i = 0; i < where.length; i++) {
          if (where[i].isEqualTo != null) {
            var newref = ref.where(
              where[i].field,
              isEqualTo: where[i].isEqualTo,
            );
            refs.add(newref);
          } else if (where[i].isGreaterThan != null) {
            var newref = ref.where(
              where[i].field,
              isGreaterThan: where[i].isGreaterThan,
            );
            refs.add(newref);
          } else if (where[i].isGreaterThanOrEqualTo != null) {
            var newref = ref.where(
              where[i].field,
              isGreaterThanOrEqualTo: where[i].isGreaterThanOrEqualTo,
            );
            refs.add(newref);
          } else if (where[i].isLessThan != null) {
            var newref = ref.where(
              where[i].field,
              isLessThan: where[i].isLessThan,
            );
            refs.add(newref);
          } else if (where[i].isLessThanOrEqualTo != null) {
            var newref = ref.where(
              where[i].field,
              isLessThanOrEqualTo: where[i].isLessThanOrEqualTo,
            );
            refs.add(newref);
          }
        }
      }

      if (FireOrder != null) {
        var newref = ref.orderBy(
          FireOrder.field,
          descending: FireOrder.descending,
        );
        refs.add(newref);
      }

      var finalRef = refs.last;
      return await finalRef.get();
    } else {
      var ref = fs.FirebaseFirestore.instance.collection(collectionName);
      return await ref.get();
    }
  }

  static add({
    required String collectionName,
    required Map<String, dynamic> value,
  }) async {
    if (Platform.isWindows) {
      return await FireDartFirestore.instance
          .collection(collectionName)
          .add(value);
    } else {
      return await fs.FirebaseFirestore.instance
          .collection(collectionName)
          .add(value);
    }
  }

  static update({
    required String collectionName,
    required String docId,
    required Map<String, dynamic> value,
  }) async {
    if (Platform.isWindows) {
      return await FireDartFirestore.instance
          .collection(collectionName)
          .doc(docId)
          .update(value);
    } else {
      return await fs.FirebaseFirestore.instance
          .collection(collectionName)
          .doc(docId)
          .update(value);
    }
  }

  static delete({
    required String collectionName,
    required String docId,
  }) async {
    if (Platform.isWindows) {
      return await FireDartFirestore.instance
          .collection(collectionName)
          .doc(docId)
          .delete();
    } else {
      return await fs.FirebaseFirestore.instance
          .collection(collectionName)
          .doc(docId)
          .delete();
    }
  }

  static timestamp() {
    if (Platform.isWindows) {
      return DateTime.now();
    } else {
      // return fs.Timestamp.now();
      return DateTime.now();
    }
  }
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

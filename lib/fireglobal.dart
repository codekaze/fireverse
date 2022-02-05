import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart' as fs;
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
    bool useGoogleServicesJson = false,
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
      if (useGoogleServicesJson) {
        await Firebase.initializeApp();
      } else {
        await Firebase.initializeApp(
          options: FirebaseOptions(
            appId: appId,
            apiKey: apiKey,
            messagingSenderId: messagingSenderId,
            projectId: projectId,
          ),
        );
      }

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

  static Future signOut() async {
    if (Platform.isWindows) {
      FireDartFirebaseAuth.instance.signOut();
    } else {
      await FirebaseAuth.instance.signOut();
    }
  }

  static Future<bool> signInAnonymously() async {
    if (Platform.isWindows) {
      try {
        var auth = FireDartFirebaseAuth.instance;
        await auth.signInAnonymously();
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

        return true;
      } on Exception catch (_) {
        return false;
      }
    } else {
      try {
        var auth = await FirebaseAuth.instance.signInAnonymously();
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

        return true;
      } on Exception catch (_) {
        return false;
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

  static Future resetPassword({
    required String email,
  }) async {
    if (Platform.isWindows) {
      try {
        return await FireDartFirebaseAuth.instance.resetPassword(email);
      } on Exception catch (_) {
        //
      }
    } else {
      try {
        return await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      } on Exception catch (_) {
        //
      }
    }
  }

  static Future<bool> register({
    required String email,
    required String password,
  }) async {
    if (Platform.isWindows) {
      var auth = FireDartFirebaseAuth.instance;
      try {
        await auth.signUp(email, password);
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
      } on Exception catch (_) {
        return false;
      }
    } else {
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

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
      } on Exception catch (_) {
        return false;
      }
    }
    return false;
  }

  static GlobalUser? currentUser;

  static getRefFromWhereAndOrder({
    required String collectionName,
    List<FireWhereField>? where,
    FireOrder? orderBy,
  }) {
    var refs = [];
    if (Platform.isWindows) {
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

      if (orderBy != null) {
        var newref = ref.orderBy(
          orderBy.field,
          descending: orderBy.descending,
        );
        refs.add(newref);
      }

      var finalRef = refs.last;
      return finalRef;
    } else {
      var ref = fs.FirebaseFirestore.instance.collection(collectionName);
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

      if (orderBy != null) {
        var newref = ref.orderBy(
          orderBy.field,
          descending: orderBy.descending,
        );
        refs.add(newref);
      }

      var finalRef = refs.last;
      return finalRef;
    }
  }

  static snapshot({
    required String collectionName,
    List<FireWhereField>? where,
    FireOrder? orderBy,
  }) async {
    if (Platform.isWindows) {
      var ref = getRefFromWhereAndOrder(
        collectionName: collectionName,
        where: where,
        orderBy: orderBy,
      );
      return await ref.stream;
    } else {
      var ref = getRefFromWhereAndOrder(
        collectionName: collectionName,
        where: where,
        orderBy: orderBy,
      );
      return await ref.snapshot();
    }
  }

  static get({
    required String collectionName,
    List<FireWhereField>? where,
    FireOrder? orderBy,
  }) async {
    if (Platform.isWindows) {
      var ref = getRefFromWhereAndOrder(
        collectionName: collectionName,
        where: where,
        orderBy: orderBy,
      );
      return await ref.get();
    } else {
      var ref = getRefFromWhereAndOrder(
        collectionName: collectionName,
        where: where,
        orderBy: orderBy,
      );
      return await ref.get();
    }
  }

  static getDocRef({
    required String collectionName,
    required String docId,
  }) {
    if (Platform.isWindows) {
      var ref = getRefFromWhereAndOrder(
        collectionName: collectionName,
      ).doc(docId);
      return ref;
    } else {
      var ref = getRefFromWhereAndOrder(
        collectionName: collectionName,
      ).doc(docId);
      return ref;
    }
  }

  static getCollectionRef({
    required String collectionName,
  }) {
    if (Platform.isWindows) {
      var ref = getRefFromWhereAndOrder(
        collectionName: collectionName,
      );
      return ref;
    } else {
      var ref = getRefFromWhereAndOrder(
        collectionName: collectionName,
      );
      return ref;
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

import 'dart:io';

import 'package:firedartextreme/firedart.dart';

const apiKey = "AIzaSyAjaGYDdHvb0_vsG3JRS6ZVUegaicjn5Uo";
const projectId = "freeproject-c8687";
const email = 'demo@codekaze.com';
const password = '123456';

Future main() async {
  FireDartFirebaseAuth.initialize(apiKey, FireDartVolatileStore());
  FireDartFirestore.initialize(projectId); // Firestore reuses the auth client

  var auth = FireDartFirebaseAuth.instance;
  // Monitor sign-in state
  auth.signInState.listen((state) => print("Signed ${state ? "in" : "out"}"));

  // Sign in with user credentials
  await auth.signIn(email, password);

  // Get user object
  var user = await auth.getUser();
  print(user);

  // Instantiate a reference to a document - this happens offline
  var ref = FireDartFirestore.instance.collection('test').doc('doc');

  // Subscribe to changes to that document
  ref.stream.listen((document) => print('updated: $document'));

  // Update the document
  await ref.update({'value': 'test'});

  // Get a snapshot of the document
  var document = await ref.get();
  print('snapshot: ${document['value']}');

  auth.signOut();

  // Allow some time to get the signed out event
  await Future.delayed(Duration(seconds: 1));

  exit(0);
}

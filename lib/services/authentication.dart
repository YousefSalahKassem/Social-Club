import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Authentication with ChangeNotifier{
final FirebaseAuth firebaseauth=FirebaseAuth.instance;
final GoogleSignIn googleSignIn=GoogleSignIn();

late String userUid;
String get getUserUid=>userUid;


Future logIntoAccount(String email,String password)async{
  UserCredential userCredential=await firebaseauth.signInWithEmailAndPassword(email: email, password: password);
  User? user=userCredential.user;
  userUid=user!.uid;
  print(userUid);
  notifyListeners();
}

Future createAccount(String email,String password)async{
  UserCredential userCredential=await firebaseauth.createUserWithEmailAndPassword(email: email, password: password);
  User? user=userCredential.user;
  userUid=user!.uid;
  print(userUid);
  notifyListeners();
}

Future signInWithGoogle()async{
  final GoogleSignInAccount? googleSignInAccount=await googleSignIn.signIn();
  final GoogleSignInAuthentication googleSignInAuthentication=await googleSignInAccount!.authentication;
  final AuthCredential authCredential=GoogleAuthProvider.credential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken
  );
  final UserCredential userCredential=await firebaseauth.signInWithCredential(authCredential);
  final User? user=userCredential.user;
  userUid=user!.uid;
  print('Google User Uid: $userUid');
  notifyListeners();
}

Future signOut()async{
  return FirebaseAuth.instance.signOut();
}


}
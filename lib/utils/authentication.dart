import 'package:firebase_auth/firebase_auth.dart';

class Authentication {
  static Future<bool> isAuthenticated() async{
    return FirebaseAuth.instance.currentUser != null;
  }
}
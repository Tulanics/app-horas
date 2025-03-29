import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String?> enterUser({required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      switch(e.code) {
        case 'user-not-found':
          return "User not found";
        case 'wrong-password':
          return "Wrong Password";
      }

      return e.code;
    }

    return null;
  }

  Future<String?> registerUser({required String email, required String password, required String name})
  async {
    try{
      UserCredential userCredencial = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      await userCredencial.user!.updateDisplayName(name);
    } on FirebaseAuthException catch(e) {
      switch(e.code) {
          case 'email-already-in-use':
            return "Email already in use"; 
      }

      return e.code;
    }

    return null;
  }

  Future<String?> passwordReset({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email); 
    } on FirebaseAuthException catch(e) {
      switch(e.code) {
        case 'user-not-found':
         return "User not found";
      }
      return e.code;
    }

    return null;
  }

  Future<String?> logOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch(e){
      return e.code;
    }
    return null;
  }

  Future<String?> deleteAccount({required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: _firebaseAuth.currentUser!.email!, password: password);
      await _firebaseAuth.currentUser!.delete();
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return "User not found";
      }
      return e.code;
    }

    return null;
  }
}
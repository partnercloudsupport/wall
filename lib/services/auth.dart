import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class BaseAuth {
  Future<String> signInWithGoogle();
  Future<String> signInWithFacebook();
  Future<String> signIn(String email, String password);
  Future<String> signUp(String name, String email, String password, String confirmation);
  Future<FirebaseUser> getCurrentUser();
  UserInfo getCurrentUserInfo();
  Future<void> sendEmailVerification();
  Future<void> signOut();
  Future<bool> isEmailVerified();
  Future<void> sendPasswordResetEmail(String email);
}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  UserInfo _currentUserInfo;

  void _checkUserPreferences(FirebaseUser currentUser) async {
    var reference = Firestore.instance.collection('users').document(currentUser.uid);
    DocumentSnapshot snapshot = await reference.get();

    if(snapshot == null || snapshot.data == null || snapshot.data['walls'] == null)
    reference.setData({
        'walls': [],
    }, merge: true);
  }

  Future<String> signInWithGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final FirebaseUser user = await _firebaseAuth.signInWithCredential(credential);
    assert(user.email != null);
    assert(user.displayName != null);
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _firebaseAuth.currentUser();
    assert(user.uid == currentUser.uid);

    //Set User preferences in database
    _checkUserPreferences(currentUser);

    _currentUserInfo = currentUser;
    return user.uid;
  }

  Future<String> signInWithFacebook() async {
    //TODO
    return null;
  }

  Future<String> signIn(String email, String password) async {
    FirebaseUser user = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    return user.uid;
  }

  Future<String> signUp(String name, String email, String password, String confirmation) async {
    //TODO: implement username and confirmation checking
    FirebaseUser user = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);

    _checkUserPreferences(user);

    //Set display name
    var userUpdateInfo = new UserUpdateInfo();
    userUpdateInfo.displayName = name;
    await user.updateProfile(userUpdateInfo);
    await user.reload();

    return user.uid;
  }

  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user;
  }

  UserInfo getCurrentUserInfo() {
    return _currentUserInfo;
  }

  Future<String> getCurrentUserDisplayName() async {
    FirebaseUser user = await getCurrentUser();
    if (user != null) {
      return user?.displayName;
    }
    return null;
  }

  Future<String> getCurrentUserId() async {
    FirebaseUser user = await getCurrentUser();
    if (user != null) {
      return user?.uid;
    }
    return null;
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  Future<void> sendEmailVerification() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    user.sendEmailVerification();
  }

  Future<bool> isEmailVerified() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user.isEmailVerified;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    //TODO: Implement dialog
    _firebaseAuth.sendPasswordResetEmail(email: email);
  }
}

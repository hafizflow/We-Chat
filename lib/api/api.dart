import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:we_chat/models/chat_user.dart';

class APIs {
  // for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  // for accessing cloud firebase database
  static FirebaseFirestore fireStore = FirebaseFirestore.instance;

  static User get user => auth.currentUser!;

  // for checking user exists or not
  static Future<bool> userExists() async {
    return (await fireStore.collection("users").doc(user.uid).get()).exists;
  }

  // for creating new user
  static Future<void> createUser() async {
    final time = DateTime.now().microsecondsSinceEpoch.toString();

    final chatUser = ChatUser(
        image: user.photoURL.toString(),
        about: "Hey, I am using Asn Chat",
        name: user.displayName.toString(),
        createdAt: time,
        id: user.uid,
        lastActive: time,
        isOnline: false,
        pushToken: '',
        email: user.email.toString());

    return await fireStore
        .collection("users")
        .doc(user.uid)
        .set(chatUser.toJson());
  }
}

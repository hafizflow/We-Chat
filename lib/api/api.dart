import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:we_chat/models/chat_user.dart';
import 'package:we_chat/models/message.dart';

class APIs {
  // for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  // for accessing cloud firebase database
  static FirebaseFirestore fireStore = FirebaseFirestore.instance;

  // for accessing firebase storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  // to return current user
  static User get user => auth.currentUser!;

  // for storing self information
  static late ChatUser me;

  // for checking user exists or not
  static Future<bool> userExists() async {
    return (await fireStore.collection("users").doc(user.uid).get()).exists;
  }

  static Future<void> getSelfInfo() async {
    await fireStore.collection("users").doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        log("My Data: ${user.data()}");
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  // for creating new user
  static Future<void> createUser() async {
    final time = DateTime.now().microsecondsSinceEpoch.toString();

    final chatUser = ChatUser(
        image: user.photoURL.toString(),
        about: "Hey, I am using We Chat",
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

  // for getting all users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return fireStore
        .collection('users')
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  // for updating user information
  static Future<void> updateUserInfo() async {
    await fireStore.collection("users").doc(user.uid).update({
      'name': me.name,
      'about': me.about,
    });
  }

  // for update profile picture
  static Future<void> updateProfilePicture(File file) async {
    // getting image file extension
    final ext = file.path.split('.').last;
    log("Path: $ext");

    // storage file ref with path
    final ref = storage.ref().child('profile_picture/${user.uid}.$ext');

    // uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log("Data transferred ${p0.bytesTransferred / 1000} kb");
    });

    // uploading image to firestore database
    me.image = await ref.getDownloadURL();
    await fireStore.collection("users").doc(user.uid).update({
      'image': me.image,
    });
  }

  // chats (collection) --> conversation_id(doc) --> messages(collection) --> message(doc)

  // useful for getting conversation id
  static String getConversationId(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  // for getting all messages of a specific conversation from firebase database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return fireStore
        .collection('chats/${getConversationId(user.id)}/messages')
        .snapshots();
  }

  // for sending message
  static Future<void> sendMessage(
      ChatUser chatUser, String msg, Type type) async {
    // message sending time (also used as id)
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    // message to send
    Message message = Message(
      formId: user.uid,
      type: type,
      msg: msg,
      read: '',
      toId: chatUser.id,
      sent: time,
    );

    final ref = fireStore
        .collection('chats/${getConversationId(chatUser.id)}/messages');

    await ref.doc(time).set(message.toJson());
  }

  // update read status of message
  static Future<void> updateMessageReadStatus(Message message) async {
    fireStore
        .collection('chats/${getConversationId(message.formId)}/messages')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  // get only last message of specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return fireStore
        .collection('chats/${getConversationId(user.id)}/messages')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  // send chat image
  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    // getting image file extension
    final ext = file.path.split('.').last;

    // storage file ref with path
    final ref = storage.ref().child(
        'images/${user.uid}.${DateTime.now().millisecondsSinceEpoch}.$ext');

    // uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log("Data transferred ${p0.bytesTransferred / 1000} kb");
    });

    // uploading image to firestore database
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }
}

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';
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

  // for adding an chat for out conversation
  static Future<bool> addChatUser(String email) async {
    final data = await fireStore
        .collection("users")
        .where('email', isEqualTo: email)
        .get();

    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      fireStore
          .collection('users')
          .doc(user.uid)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({});
      return true;
    } else {
      return false;
    }
  }

  // for getting self info
  static Future<void> getSelfInfo() async {
    await fireStore.collection("users").doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        await getFirebaseMessagingToken();

        // for setting user status to active
        APIs.updateActiveStatus(true);
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

  // for accessing firebase messaging (push notification)
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  // for getting firebase messaging token
  static Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();

    await fMessaging.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;
        log('Push token: $t');
      }
    });

    // for handling foreground message
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   log('Got a message whilst in the foreground!');
    //   log('Message data: ${message.data}');
    //
    //   if (message.notification != null) {
    //     log('Message also contained a notification: ${message.notification}');
    //   }
    // });
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
        .orderBy('sent', descending: true)
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

    await ref.doc(time).set(message.toJson()).then((value) =>
        sendPushNotification(chatUser, type == Type.text ? msg : 'image'));
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

  // for getting specific user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return fireStore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  // update status or last active time of user
  static Future<void> updateActiveStatus(bool isOnline) async {
    fireStore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken,
    });
  }

  // for sending push notification
  static Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    try {
      final body = {
        "to": chatUser.pushToken,
        "notification": {
          "title": me.name, //our name should be send
          "body": msg,
          "android_channel_id": "chats",
        },
        "data": {
          "some_data": "User ID: ${me.id}",
        },
      };

      // var url = Uri.https('example.com', 'whatsit/create');
      var response =
          await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
              headers: {
                HttpHeaders.contentTypeHeader: 'application/json',
                HttpHeaders.authorizationHeader:
                    'key=AAAA9QIAvo0:APA91bGghkNp3gj2mLJYmaJGhttoz07ZOBx8T09AeLTObHR5whdK30SvaaHxrjz57_HHJ8Ks4hCJdZw0D6woIyWDQQtK-dH_EvhcxfjOlVNTt6TMLRj4izYW7CDRm3peXFakaZDWpu2H',
              },
              body: jsonEncode(body));

      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');
    } catch (e) {
      log('\nErrorMessage: $e');
    }
  }

  // delete message
  static Future<void> deleteMessage(Message message) async {
    await fireStore
        .collection('chats/${getConversationId(message.toId)}/messages')
        .doc(message.sent)
        .delete();

    if (message.type == Type.image) {
      await storage.refFromURL(message.msg).delete();
    }
  }

  // edit message
  static Future<void> editMessage(Message message, String updateMessage) async {
    await fireStore
        .collection('chats/${getConversationId(message.toId)}/messages')
        .doc(message.sent)
        .update({'msg': updateMessage});
  }
}

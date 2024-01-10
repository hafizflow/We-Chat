import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:we_chat/api/api.dart';
import 'package:we_chat/models/chat_user.dart';
import 'package:we_chat/widgets/chat_user_card.dart';

// home screen - where all available contracts are shown
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> userList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appbar
      appBar: AppBar(
        leading: const Icon(CupertinoIcons.home),
        title: const Text("Asn Chat"),
        actions: [
          // search user button
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),

          // user profile button
          IconButton(onPressed: () {}, icon: const Icon(Icons.person)),
        ],
      ),

      // floating button to add new user
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FloatingActionButton(
          onPressed: () async {
            await APIs.auth.signOut();
            await GoogleSignIn().signOut();
          },
          child: const Icon(Icons.add_comment_rounded),
        ),
      ),

      body: StreamBuilder(
          stream: APIs.fireStore.collection('users').snapshots(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              // if data is loading
              case ConnectionState.waiting:
              case ConnectionState.none:
                return const Center(child: CircularProgressIndicator());

              // if some or all data is loaded than show it
              case ConnectionState.active:
              case ConnectionState.done:
                final data = snapshot.data?.docs;
                userList =
                    data?.map((e) => ChatUser.fromJson(e.data())).toList() ??
                        [];

                if (userList.isNotEmpty) {
                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 6),
                    itemCount: userList.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: ((context, index) {
                      return ChatUserCard(user: userList[index]);
                      // return Text("Name: ${userList[index]}");
                    }),
                  );
                } else {
                  return const Center(
                    child: Text(
                      "No Connection Found!",
                      style: TextStyle(fontSize: 20),
                    ),
                  );
                }
            }
          }),
    );
  }
}

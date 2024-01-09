import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:we_chat/api/api.dart';

// home screen - where all available contracts are shown
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    );
  }
}

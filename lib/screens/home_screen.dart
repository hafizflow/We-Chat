import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:we_chat/api/api.dart';
import 'package:we_chat/models/chat_user.dart';
import 'package:we_chat/screens/profile_screen.dart';
import 'package:we_chat/widgets/chat_user_card.dart';

// home screen - where all available contracts are shown
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // for storing all users
  List<ChatUser> _userList = [];

  // for storing search users
  final List<ChatUser> _searchList = [];

  // for storing search status
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();

    // for update active status according to lifecycle events
    // resume -- active or online
    // pause -- offline
    SystemChannels.lifecycle.setMessageHandler((message) {
      log('Message: $message');

      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        }
        if (message.toString().contains('paused')) {
          APIs.updateActiveStatus(false);
        }
        if (message.toString().contains('inactive')) {
          APIs.updateActiveStatus(false);
        }
      }

      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // for hiding key board when a tap detected on the screen
      onTap: () => FocusScope.of(context).unfocus(),

      child: PopScope(
        canPop: _isSearching ? false : true,
        onPopInvoked: (_) {
          if (_isSearching) {
            _isSearching = !_isSearching;
            setState(() {});
          }
        },
        child: Scaffold(
          appBar: AppBar(
            leading: const Icon(CupertinoIcons.home),
            title: _isSearching
                ? TextField(
                    autofocus: true,
                    // where search list changed than updated search list
                    onChanged: (val) {
                      // search logic
                      _searchList.clear();
                      for (var i in _userList) {
                        if (i.name.toLowerCase().contains(val.toLowerCase()) ||
                            i.email.toLowerCase().contains(val.toLowerCase())) {
                          _searchList.add(i);
                          setState(() {});
                        }
                      }
                    },
                    style: const TextStyle(
                      color: Colors.white,
                      letterSpacing: 0.5,
                      fontSize: 17,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Name, Email...",
                      hintStyle: TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  )
                : const Text("We Chat"),
            actions: [
              // search user button
              IconButton(
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                  });
                },
                icon: Icon(
                  _isSearching
                      ? CupertinoIcons.clear_circled_solid
                      : Icons.search,
                ),
              ),

              // user profile button
              IconButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) {
                      return ProfileScreen(user: APIs.me);
                    }));
                  },
                  icon: const Icon(Icons.person)),
            ],
          ),

          // floating button to add new user
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton(
              onPressed: () {
                _addChatUserDialog(context);
              },
              child: const Icon(Icons.add_comment_rounded),
            ),
          ),

          body: StreamBuilder(
              stream: APIs.getAllUsers(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  // if data is loading
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return const Center(
                        child: SpinKitSpinningLines(color: Colors.teal));

                  // if some or all data is loaded than show it
                  case ConnectionState.active:
                  case ConnectionState.done:
                    final data = snapshot.data?.docs;
                    _userList = data
                            ?.map((e) => ChatUser.fromJson(e.data()))
                            .toList() ??
                        [];

                    if (_userList.isNotEmpty) {
                      return ListView.builder(
                        padding: const EdgeInsets.only(top: 6),
                        itemCount: _isSearching
                            ? _searchList.length
                            : _userList.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: ((context, index) {
                          return ChatUserCard(
                              user: _isSearching
                                  ? _searchList[index]
                                  : _userList[index]);
                        }),
                      );
                    } else {
                      // when no user found
                      return const Center(
                        child: Text(
                          "No Connection Found!",
                          style: TextStyle(fontSize: 20),
                        ),
                      );
                    }
                }
              }),
        ),
      ),
    );
  }

  void _addChatUserDialog(BuildContext context) {
    String email = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.only(
          bottom: 10,
          left: 24,
          right: 24,
          top: 20,
        ),
        title: const Row(
          children: [
            Icon(Icons.message, size: 28, color: Colors.teal),
            Text(
              '   Add User',
              style: TextStyle(
                color: Colors.black54,
                letterSpacing: .5,
              ),
            )
          ],
        ),
        content: TextFormField(
          maxLines: null,
          onChanged: (value) => email = value,
          decoration: InputDecoration(
            hintText: 'Email Id',
            hintStyle: const TextStyle(color: Colors.black54),
            prefixIcon: Icon(
              Icons.email_outlined,
              color: Colors.teal.shade400,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Colors.teal),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.teal),
            ),
          ),
        ),
        actions: [
          MaterialButton(
            padding: const EdgeInsets.only(right: 16),
            minWidth: 0,
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.red.shade900,
                fontSize: 16,
              ),
            ),
          ),
          MaterialButton(
            padding: const EdgeInsets.all(0),
            minWidth: 0,
            onPressed: () async {
              Navigator.pop(context);
              // if (email.isNotEmpty) {
              //   await APIs.addChatUser(email).then((value) {
              //     if (!value) {
              //       Dialogs.showSnackbar(context, 'User does not exists');
              //     }
              //   });
              // }
            },
            child: const Text(
              'Add',
              style: TextStyle(
                color: Colors.teal,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

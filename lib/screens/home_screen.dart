import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appbar
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
            : const Text("Asn Chat"),
        actions: [
          // search user button
          IconButton(
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
              });
            },
            icon: Icon(
              _isSearching ? CupertinoIcons.clear_circled_solid : Icons.search,
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
          onPressed: () async {},
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
                return const Center(child: CircularProgressIndicator());

              // if some or all data is loaded than show it
              case ConnectionState.active:
              case ConnectionState.done:
                final data = snapshot.data?.docs;
                _userList =
                    data?.map((e) => ChatUser.fromJson(e.data())).toList() ??
                        [];

                if (_userList.isNotEmpty) {
                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 6),
                    itemCount:
                        _isSearching ? _searchList.length : _userList.length,
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
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:we_chat/api/api.dart';
import 'package:we_chat/helper/my_date_util.dart';
import 'package:we_chat/models/chat_user.dart';
import 'package:we_chat/screens/chat_screen.dart';
import 'package:we_chat/widgets/profile_dialog.dart';

import '../models/message.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;

  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  late Size mq = MediaQuery.of(context).size;

  // last message info ( if null --> no message )
  Message? _message;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.teal.shade100,
      elevation: 5,
      child: StreamBuilder(
        stream: APIs.getLastMessage(widget.user),
        builder: (context, snapshot) {
          final data = snapshot.data?.docs;
          final list =
              data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
          if (list.isNotEmpty) _message = list[0];

          return ListTile(
            // user profile picture
            leading: InkWell(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (_) => ProfileDialog(
                          user: widget.user,
                        ));
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: CachedNetworkImage(
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                  imageUrl: widget.user.image,
                  errorWidget: (context, url, error) =>
                      const CircleAvatar(child: Icon(CupertinoIcons.person)),
                ),
              ),
            ),

            // user name
            title: Text(widget.user.name),

            // last message
            subtitle: Text(
              _message != null
                  ? _message!.type == Type.image
                      ? 'image'
                      : _message!.msg
                  : widget.user.about,
              maxLines: 1,
            ),

            // last message time
            trailing: _message == null
                ? null // show nothing when no message is sent
                : _message!.read.isEmpty && _message!.formId != APIs.user.uid
                    // show for unread message
                    ? Container(
                        height: 12,
                        width: 12,
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.shade700,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      )
                    // show message sent time
                    : Text(
                        MyDateUtil.getLastMessageTime(
                            context: context, time: _message!.sent),
                        style: const TextStyle(color: Colors.black54),
                      ),
            onTap: () {
              // for navigating to chat screen
              Navigator.push(context, MaterialPageRoute(
                builder: (_) {
                  return ChatScreen(
                    user: widget.user,
                  );
                },
              ));
            },
          );
        },
      ),
    );
  }
}

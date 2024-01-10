import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:we_chat/models/chat_user.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;

  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  late Size mq = MediaQuery.of(context).size;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.teal.shade100,
      elevation: 5,
      child: ListTile(
        // user profile picture
        // leading: const CircleAvatar(child: Icon(CupertinoIcons.person)),

        leading: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: CachedNetworkImage(
            height: 50,
            width: 50,
            imageUrl: widget.user.image,
            errorWidget: (context, url, error) =>
                const CircleAvatar(child: Icon(CupertinoIcons.person)),
          ),
        ),

        // user name
        title: Text(widget.user.name),

        // last message
        subtitle: Text(widget.user.about, maxLines: 1),

        // last message time
        trailing: Container(
          height: 12,
          width: 12,
          decoration: BoxDecoration(
            color: Colors.greenAccent.shade700,
            borderRadius: BorderRadius.circular(6),
          ),
        ),

        // trailing: const Text(
        //   "12:00 PM",
        //   style: TextStyle(color: Colors.black54),
        // ),
        onTap: () {},
      ),
    );
  }
}

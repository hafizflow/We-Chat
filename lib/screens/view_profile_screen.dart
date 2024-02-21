import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:we_chat/helper/my_date_util.dart';
import 'package:we_chat/models/chat_user.dart';

import '../main.dart';

// view profile screen - to view profile user
class ViewProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ViewProfileScreen({super.key, required this.user});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // for hiding keyboard
      onTap: () => FocusScope.of(context).unfocus(),

      child: Scaffold(
        // appbar
        appBar: AppBar(
          title: Text(widget.user.name),
        ),

        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Joined On: ',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontSize: 16),
            ),
            Text(
              MyDateUtil.getLastMessageTime(
                context: context,
                time: widget.user.createdAt,
                showYear: true,
              ),
              style: const TextStyle(color: Colors.black54, fontSize: 16),
            ),
          ],
        ),

        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * 0.05),
            child: Column(children: [
              // for adding some space
              SizedBox(
                width: mq.width,
                height: mq.height * 0.03,
              ),

              Stack(
                children: [
                  // profile picture
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      height: 200,
                      width: 200,
                      imageUrl: widget.user.image,
                      errorWidget: (context, url, error) => const CircleAvatar(
                          child: Icon(CupertinoIcons.person)),
                    ),
                  ),
                ],
              ),

              // for adding some space
              SizedBox(height: mq.height * 0.03),

              // user email
              Text(
                widget.user.email,
                style: const TextStyle(color: Colors.black87, fontSize: 16),
              ),

              // for adding some space
              SizedBox(height: mq.height * 0.02),

              // user about
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'About: ',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontSize: 16),
                  ),
                  Text(
                    widget.user.about,
                    style: const TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                ],
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

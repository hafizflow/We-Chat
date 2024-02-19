import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:we_chat/api/api.dart';
import 'package:we_chat/helper/my_date_util.dart';
import 'package:we_chat/main.dart';

import '../models/message.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});

  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    return APIs.user.uid == widget.message.formId
        ? _greenMessage()
        : _blueMessage();
  }

  Widget _blueMessage() {
    // update last send message if sender and receiver are different
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
    }

    // sender or another user message
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // message content
        Flexible(
          child: Container(
            padding: EdgeInsets.all(
              widget.message.type == Type.text
                  ? mq.width * .04
                  : mq.width * .03,
            ),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.width * .01),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 221, 245, 255),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
              border: Border.all(color: Colors.lightBlue),
            ),
            child: widget.message.type == Type.text
                // show text
                ? Text(
                    widget.message.msg,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  )
                // show text
                : ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      imageUrl: widget.message.msg,
                      errorWidget: (context, url, error) => const Icon(
                        Icons.image,
                        size: 70,
                      ),
                    ),
                  ),
          ),
        ),

        // message time
        Row(
          children: [
            const SizedBox(width: 4),

            // read time
            Text(
              MyDateUtil.getFormattedTime(
                  context: context, time: widget.message.sent),
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 13,
              ),
            ),

            SizedBox(width: mq.width * .04),
          ],
        ),
      ],
    );
  }

  Widget _greenMessage() {
    // update last send message if sender and receiver are different
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // message time
        Row(
          children: [
            SizedBox(width: mq.width * .04),

            // double tick blue icon for message read
            if (widget.message.read.isNotEmpty)
              const Icon(
                Icons.done_all_rounded,
                color: Colors.blue,
                size: 20,
              ),

            const SizedBox(width: 4),

            // read time
            Text(
              MyDateUtil.getFormattedTime(
                  context: context, time: widget.message.sent),
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 13,
              ),
            ),
          ],
        ),

        // message content
        Flexible(
          child: Container(
            padding: EdgeInsets.all(
              widget.message.type == Type.text
                  ? mq.width * .04
                  : mq.width * .03,
            ),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.width * .01),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 218, 255, 176),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
                bottomLeft: Radius.circular(25),
              ),
              border: Border.all(color: Colors.green),
            ),
            child: widget.message.type == Type.text
                // show text
                ? Text(
                    widget.message.msg,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  )
                // show text
                : ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      imageUrl: widget.message.msg,
                      errorWidget: (context, url, error) => const Icon(
                        Icons.image,
                        size: 70,
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

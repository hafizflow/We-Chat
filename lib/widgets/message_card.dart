import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver_updated/gallery_saver.dart';
import 'package:we_chat/api/api.dart';
import 'package:we_chat/helper/dialogs.dart';
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
    bool isMe = APIs.user.uid == widget.message.formId;
    return InkWell(
      onLongPress: () {
        _showBottomSheet(isMe);
      },
      child: isMe ? _greenMessage() : _blueMessage(),
    );
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

  // bottom sheet for modifying message details
  void _showBottomSheet(bool isMe) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        builder: (context) {
          return ListView(
            shrinkWrap: true,
            children: [
              // black divider
              Container(
                height: 4,
                margin: EdgeInsets.symmetric(
                  vertical: mq.height * .015,
                  horizontal: mq.width * .4,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),

              // copy option
              widget.message.type == Type.text
                  ? _OptionItem(
                      icon: const Icon(
                        Icons.copy_all_rounded,
                        color: Colors.teal,
                        size: 26,
                      ),
                      name: "Copy Text",
                      onTap: () async {
                        await Clipboard.setData(
                                ClipboardData(text: widget.message.msg))
                            .then(
                          (value) {
                            // for hiding bottom sheet
                            Navigator.pop(context);

                            Dialogs.showSnackbar(context, 'Text Coped!');
                          },
                        );
                      },
                    )
                  : _OptionItem(
                      icon: const Icon(
                        Icons.save_alt_rounded,
                        color: Colors.teal,
                        size: 26,
                      ),
                      name: "Save Image",
                      onTap: () async {
                        try {
                          log('Path: ${widget.message.msg}');
                          await GallerySaver.saveImage(
                            widget.message.msg,
                            albumName: 'We Chat',
                          ).then((success) {
                            // for hiding bottom sheet
                            Navigator.pop(context);

                            if (success != null && success) {
                              Dialogs.showSnackbar(context, 'Saved to gallery');
                            }
                          });
                        } catch (e) {
                          log('Error on saved image: $e');
                        }
                      },
                    ),
              if (isMe)
                Divider(
                  color: Colors.grey,
                  endIndent: mq.width * .04,
                  indent: mq.width * .04,
                ),

              // edit option
              if (widget.message.type == Type.text && isMe)
                _OptionItem(
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: Colors.teal,
                    size: 26,
                  ),
                  name: "Edit Message",
                  onTap: () {
                    Navigator.pop(context);

                    _showMessageDialog(context);
                  },
                ),

              // delete option
              if (isMe)
                _OptionItem(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.redAccent,
                    size: 26,
                  ),
                  name: "Delete Message",
                  onTap: () async {
                    await APIs.deleteMessage(widget.message).then((value) {
                      // for hiding bottom sheet
                      Navigator.pop(context);

                      Dialogs.showSnackbar(context, 'Message Deleted');
                    });
                  },
                ),

              Divider(
                color: Colors.grey,
                endIndent: mq.width * .04,
                indent: mq.width * .04,
              ),

              // sent time
              _OptionItem(
                icon: const Icon(
                  Icons.send_to_mobile_outlined,
                  color: Colors.teal,
                  size: 26,
                ),
                name: "Sent At: ${MyDateUtil.getMessageTime(
                  context: context,
                  time: widget.message.sent,
                )}",
                onTap: () {},
              ),

              // read time
              _OptionItem(
                icon: const Icon(
                  Icons.remove_red_eye,
                  color: Colors.blue,
                  size: 26,
                ),
                name: widget.message.read.isEmpty
                    ? "Read At: Not seen yet ☹️"
                    : "Read At: ${MyDateUtil.getMessageTime(
                        context: context,
                        time: widget.message.read,
                      )}",
                onTap: () {},
              ),
            ],
          );
        });
  }

  // dialog for updating message content
  void _showMessageDialog(BuildContext context) {
    String updatedMessage = widget.message.msg;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding:
            const EdgeInsets.only(bottom: 10, left: 24, right: 24, top: 20),
        title: const Row(
          children: [
            Icon(Icons.message, size: 28, color: Colors.teal),
            Text(
              '   Edit Message',
              style: TextStyle(
                color: Colors.black54,
                letterSpacing: .5,
              ),
            )
          ],
        ),
        content: TextFormField(
          initialValue: updatedMessage,
          maxLines: null,
          onChanged: (value) => updatedMessage = value,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
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
                color: Colors.red.shade700,
                fontSize: 16,
              ),
            ),
          ),
          MaterialButton(
            padding: const EdgeInsets.all(0),
            minWidth: 0,
            onPressed: () {
              Navigator.pop(context);
              APIs.editMessage(widget.message, updatedMessage);
            },
            child: const Text(
              'Update',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;

  const _OptionItem({
    required this.icon,
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(
          left: mq.width * .05,
          top: mq.height * .015,
          bottom: mq.height * .015,
        ),
        child: Row(
          children: [
            icon,
            Flexible(
                child: Text(
              '   $name',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black54,
                letterSpacing: 0.5,
              ),
            )),
          ],
        ),
      ),
    );
  }
}

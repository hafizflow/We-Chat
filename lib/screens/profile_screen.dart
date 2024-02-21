import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:we_chat/api/api.dart';
import 'package:we_chat/helper/dialogs.dart';
import 'package:we_chat/models/chat_user.dart';
import 'package:we_chat/screens/auth/login_screen.dart';

import '../main.dart';

// profile screen - to show sign in user info and more
class ProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // for hiding keyboard
      onTap: () => FocusScope.of(context).unfocus(),

      child: Scaffold(
        // appbar
        appBar: AppBar(
          title: const Text("Profile Screen"),
        ),

        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
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
                    _image != null
                        ?
                        // local image
                        ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Image.file(
                              File(_image!),
                              fit: BoxFit.cover,
                              height: 200,
                              width: 200,
                            ),
                          )
                        :

                        // image from server
                        ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              height: 200,
                              width: 200,
                              imageUrl: widget.user.image,
                              errorWidget: (context, url, error) =>
                                  const CircleAvatar(
                                      child: Icon(CupertinoIcons.person)),
                            ),
                          ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      // edit image button
                      child: MaterialButton(
                        elevation: 1,
                        color: Colors.white,
                        shape: const CircleBorder(),
                        onPressed: () {
                          _showBottomSheet();
                        },
                        child: const Icon(
                          Icons.edit,
                          color: Colors.teal,
                        ),
                      ),
                    )
                  ],
                ),

                // for adding some space
                SizedBox(height: mq.height * 0.03),

                Text(
                  widget.user.email,
                  style: const TextStyle(color: Colors.black54, fontSize: 16),
                ),

                // for adding some space
                SizedBox(height: mq.height * 0.05),

                TextFormField(
                  initialValue: widget.user.name,
                  onSaved: (val) => APIs.me.name = val ?? '',
                  validator: (val) =>
                      val != null && val.isNotEmpty ? null : "Required Field",
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person),
                    hintText: "eg: ASN Masum Khan",
                    label: const Text("Name"),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                // for adding some space
                SizedBox(height: mq.height * 0.03),

                TextFormField(
                  initialValue: widget.user.about,
                  onSaved: (val) => APIs.me.about = val ?? '',
                  validator: (val) =>
                      val != null && val.isNotEmpty ? null : "Required Field",
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.info_outline),
                    hintText: "eg: Felling happy",
                    label: const Text("About"),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                // for adding some space
                SizedBox(height: mq.height * 0.04),

                ElevatedButton.icon(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        APIs.updateUserInfo().then(
                          (value) => Dialogs.showSnackbar(
                              context, "Profile update successfully"),
                        );
                      }
                    },
                    icon: const Icon(Icons.update),
                    label: const Text("Update"))
              ]),
            ),
          ),
        ),

        // floating button to add new user
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FloatingActionButton.extended(
            backgroundColor: Colors.red.shade400,
            onPressed: () async {
              // for showing progress dialogs
              Dialogs.showProgressBar(context);

              //
              await APIs.updateActiveStatus(false);

              // sign out from app
              await APIs.auth.signOut().then(
                (value) async {
                  await GoogleSignIn().signOut().then((value) {
                    // for hiding progress dialogs
                    Navigator.pop(context);

                    // for moving to home screen
                    Navigator.pop(context);

                    APIs.auth = FirebaseAuth.instance;

                    // replacing home screen with login screen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                    );
                  });
                },
              );
            },
            label: const Text("Logout"),
            icon: const Icon(Icons.logout),
          ),
        ),
      ),
    );
  }

  // sheet for picking a profile picture for user
  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(
              top: mq.height * 0.03,
              bottom: mq.height * 0.05,
            ),
            children: [
              // pic profile pic label
              const Text(
                "Pick Profile Picture",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              // for adding some space
              SizedBox(height: mq.height * .02),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // pic from camera
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      backgroundColor: Colors.white,
                      fixedSize: Size(mq.width * .3, mq.height * .15),
                    ),
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();

                      // Capture a photo.
                      final XFile? photo =
                          await picker.pickImage(source: ImageSource.camera);

                      if (photo != null) {
                        _image = photo.path;
                        setState(() {});

                        APIs.updateProfilePicture(File(_image!));

                        // for hiding bottom sheet
                        if (mounted) {
                          Navigator.pop(context);
                        }
                      }
                    },
                    child: Image.asset("images/camera.png"),
                  ),
                  // pic from gallery
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      backgroundColor: Colors.white,
                      fixedSize: Size(mq.width * .3, mq.height * .15),
                    ),
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      // Pick an image.
                      final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery, imageQuality: 80);

                      if (image != null) {
                        _image = image.path;
                        setState(() {});

                        APIs.updateProfilePicture(File(_image!));
                        // for hiding bottom sheet
                        if (mounted) {
                          Navigator.pop(context);
                        }
                      }
                    },
                    child: Image.asset("images/add_image.png"),
                  ),
                ],
              )
            ],
          );
        });
  }
}

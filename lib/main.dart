import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:we_chat/screens/splash_screen.dart';
import 'firebase_options.dart';

// global object for accessing device screen size
late Size mq;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // enter full screen
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // for setting orientation to portrait only
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) {
    _initializeFireBase();
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ASN Chat',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          elevation: 10,
          shadowColor: Colors.black,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          backgroundColor: Colors.teal,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

_initializeFireBase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled/screens/AddBlogScreen.dart';
import 'package:untitled/screens/AuthScreen.dart';
import './screens/SplashScreen.dart';
import './screens/MainScreen.dart';
import './screens/ProfileScreen.dart';
import './screens/UserBlogsScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Colors.pinkAccent,
        accentColor: Colors.pinkAccent,
        textTheme: TextTheme(headline1: TextStyle(color: Colors.white))
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.onAuthStateChanged,
        builder: (ctx, snapShot){
//          if(snapShot.connectionState == ConnectionState.waiting){
//            return SplashScreen();
//          }
          if(snapShot.hasData){
            return MainScreen();
          }
          return AuthScreen();
        },),
      routes: {
        '/authScreen' : (ctx) => AuthScreen(),
        '/mainScreen' : (ctx) => MainScreen(),
        '/profileScreen' : (ctx) => ProfileScreen(),
        '/userBlogsScreen' : (ctx) => UserBlogsScreen(),
        '/addBlog' : (ctx) => AddBlogScreen()
      },
    );
  }
}



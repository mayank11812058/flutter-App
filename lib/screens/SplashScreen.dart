import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Social App'),),
      body: Center(
        child: CircularProgressIndicator(),
      )
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget{
  String imageUrl;
  BuildContext context;

  AppDrawer({Key key, this.context, this.imageUrl}) : super(key : key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
            Container(
              color: Colors.pinkAccent,
              padding: EdgeInsets.only(top: 30, bottom: 10, left: 0, right: 0),
              child: Row(
                children: <Widget>[
                  SizedBox(width: MediaQuery.of(context).size.width * 0.20,),
                  if(imageUrl != null)
                  CircleAvatar(
                      maxRadius: MediaQuery.of(context).size.width * 0.20,
                      backgroundImage: NetworkImage(imageUrl),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.20,)
                ],
              ),
            ),
          Divider(),
          FlatButton(
            child: Text('Home'),
            onPressed: (){
              Navigator.pushReplacementNamed(this.context, '/mainScreen');
            },
          ),
          Divider(),
          FlatButton(
            child: Text('My Blogs'),
            onPressed: (){
              Navigator.pushReplacementNamed(this.context, '/userBlogsScreen');
            },
          ),
          Divider(),
          FlatButton(
            child: Text('Profile'),
            onPressed: (){
              Navigator.pushReplacementNamed(this.context, '/profileScreen');
            },
          ),
          Divider(),
          FlatButton(
            child: Text('Logout'),
            onPressed: (){
              FirebaseAuth.instance.signOut();
            },
          ),
          Divider(),
        ],
      ),
    );
  }
}

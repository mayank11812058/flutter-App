import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled/widgets/AppDrawer.dart';
import 'package:untitled/widgets/Blog.dart';

class UserBlogsScreen extends StatefulWidget {
  UserBlogsScreen({Key key}): super(key : key);

  @override
  _UserBlogsScreenState createState() => _UserBlogsScreenState();
}

class _UserBlogsScreenState extends State<UserBlogsScreen> {
  final db = Firestore.instance.collection("users");
  String username = "", email = "", imageUrl = "", userId = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserCredentials();
  }

  void getUserCredentials() async{
    final currentUser = await FirebaseAuth.instance.currentUser();
    final userData = await db.document(currentUser.uid).get();
    setState(() {
      username = userData["username"];
      email = userData["email"];
      imageUrl = userData["imageUrl"];
      userId = currentUser.uid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Blogs'),),
      drawer: AppDrawer(context: context, imageUrl: imageUrl,),
      body: StreamBuilder(
          stream: Firestore.instance.collection("blogs").snapshots(),
          builder: (ctx, snapshot){
            if(snapshot.connectionState == ConnectionState.waiting){
              return Center(child: CircularProgressIndicator(),);
            }

            final documents = snapshot.data.documents;

            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (contxt, index) {
                if(documents[index]["creatorId"] == userId) {
                  return Blog(context: context,
                    title: documents[index]["title"],
                    imageUrl: documents[index]["imageUrl"],);
                }else{
                  return SizedBox(width: 0, height: 0,);
                }
              },
            );
          }
      ),
    );
  }
}

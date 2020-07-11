import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled/widgets/AppDrawer.dart';
import 'package:untitled/widgets/Blog.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
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

  void addBlog(BuildContext context){
    Navigator.pushNamed(context, '/addBlog');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Blogs'), actions: <Widget>[
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () => addBlog(context),
        )
      ],),
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
                return Blog(context: context,
                  title: documents[index]["title"],
                  imageUrl: documents[index]["imageUrl"],
                  text: documents[index]["text"],
                  creatorId: documents[index]["creatorId"],
                  blogId: documents[index].documentID,
                );
              },
          );
        }
      )
    );
  }
}

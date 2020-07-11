import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled/screens/AddBlogScreen.dart';
import 'package:untitled/widgets/AppDrawer.dart';

class BlogScreen extends StatefulWidget {
  String title;
  String imageUrl;
  String text;
  String creatorId;
  String blogId;

  BlogScreen({Key key, this.title, this.imageUrl, this.text, this.creatorId, this.blogId}): super(key : key);

  @override
  _BlogScreenState createState() => _BlogScreenState();
}

class _BlogScreenState extends State<BlogScreen> {
  String uid;
  bool isLoading;

  @override
  void initState() {
    super.initState();
    isLoading = false;
    initialise();
  }

  void initialise() async{
    final currentUser = await FirebaseAuth.instance.currentUser();
    setState(() {
      uid = currentUser.uid;
    });
  }

  void edit(){
    Navigator.push(context, MaterialPageRoute(builder: (context) => AddBlogScreen(
      title: widget.title,
      imageUrl: widget.imageUrl,
      blogText: widget.text,
      blogId: widget.blogId,
      isEdit: "true",
    )));
  }

  void delete(BuildContext context) async{
    setState(() {
      isLoading = true;
    });
    await Firestore.instance.collection("blogs").document(widget.blogId).delete();
    Navigator.pushReplacementNamed(context, '/mainScreen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Blog'),),
        body: Card(
          margin: EdgeInsets.all(10),
          elevation: 10,
          child: Container(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Image.network(widget.imageUrl),
                  Container(
                    padding: EdgeInsets.all(10),
                    alignment: Alignment.center,
                    child: Text(widget.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20,),),
                  ),
                  Divider(),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Text(widget.text,),
                  ),
                  if(uid == widget.creatorId && !isLoading)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        RaisedButton(
                          child: Text('Edit', style: TextStyle(color: Colors.white),),
                          color: Colors.pinkAccent,
                          onPressed: edit,
                        ),
                        SizedBox(width: 10,),
                        RaisedButton(
                          child: Text('Delete', style: TextStyle(color: Colors.white),),
                          color: Colors.pink,
                          onPressed: () => delete(context),
                        ),
                        SizedBox(width: 10,),
                      ],
                    )
                ],
              ),
            ),
          ),
        )
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:untitled/widgets/AppDrawer.dart';
import 'package:untitled/widgets/ImageSelector.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({Key key}): super(key : key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String username;
  String imageUrl;
  String userId;
  String email;
  final usernameController = TextEditingController();
  final _form = GlobalKey<FormState>();
  File userImage;
  final db = Firestore.instance;
  bool isLoading;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoading = false;
    initialise();
  }

  void initialise() async{
    final currentUser = await FirebaseAuth.instance.currentUser();
    final userData = await Firestore.instance.document(currentUser.uid).get();
    setState(() {
      username = userData["username"];
      imageUrl = userData["imageUrl"];
      email = userData["email"];
      userId = currentUser.uid;
    });
  }

  void setImage(File image){
    setState(() {
      this.userImage = image;
    });
  }

  void _submit(BuildContext context) async{
    final user = await FirebaseAuth.instance.currentUser();
    String url;

    setState(() {
      isLoading = true;
    });

    try {
      if (userImage != null) {
        final storageReference = FirebaseStorage.instance.ref().child(
            "images").child(user.uid + ".mpg");
        await storageReference
            .putFile(userImage)
            .onComplete;
        url = await storageReference.getDownloadURL();
      } else {
        url = imageUrl;
      }

      await db.collection("users").document(user.uid).setData({
        "username": username,
        "email": email,
        "imageUrl": url.toString()
      }).then((value) {
        print("Success");
      }).catchError((err) {
        print("Error" + err.toString());
      });
    }catch(err){

    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile'),),
      drawer: AppDrawer(context: context, imageUrl: imageUrl,),
      body: Container(
        padding: EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Form(
            key: _form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ImageSelector(setImage: setImage, imageUrl: imageUrl,),
                TextFormField(
                  decoration: InputDecoration(labelText: "Username"),
                  keyboardType: TextInputType.text,
                  controller: usernameController,
                  initialValue: username,
                  validator: (value) {
                    if(value.length < 3){
                      return "Username must be of length 3";
                    }
                    return null;
                  },
                  onSaved: (value){
                    username = value;
                  },
                ),
                SizedBox(height: 10,),
                isLoading ? SizedBox(width: 0, height: 0,) : RaisedButton(
                  child: Text('Save', style: TextStyle(color: Colors.white),),
                  color: Colors.pinkAccent,
                  onPressed: () => _submit(context),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

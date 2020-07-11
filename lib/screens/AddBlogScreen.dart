import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class AddBlogScreen extends StatefulWidget {
  String title = "";
  String imageUrl = "";
  String blogId = "";
  String blogText = "";
  String isEdit = "false";

  AddBlogScreen({Key key, this.title, this.imageUrl, this.blogText, this.isEdit, this.blogId}): super(key : key);

  @override
  _AddBlogScreenState createState() => _AddBlogScreenState();
}

class _AddBlogScreenState extends State<AddBlogScreen> {
  final _form = GlobalKey<FormState>();
  String title;
  String imageUrl;
  String blogText;
  File blogImage;

  bool isLoading;
  final blogReference = Firestore.instance.collection("blogs");
  String isEdit;
  String blogId;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoading = false;
    title = widget.title;
    imageUrl = widget.imageUrl;
    blogText = widget.blogText;
    blogId = widget.blogId;
    isEdit = widget.isEdit;
  }

  void _selectImage() async{
    try {
      final image = await ImagePicker.pickImage(source: ImageSource.gallery);
      setState(() {
        this.blogImage = image;
      });
    }catch(err){

    }
  }

  void _submit(BuildContext context) async{
    if(isEdit != "true" && blogImage == null){
      Scaffold.of(context).showSnackBar(SnackBar(content: Text("Please pick a Image"),));
      return;
    }

    if(_form.currentState.validate()){
      _form.currentState.save();

      setState(() {
        isLoading = true;
      });

      final currentUser = await FirebaseAuth.instance.currentUser();

      try {
        if(blogImage != null){
          final storageReference = FirebaseStorage.instance.ref().child(
              "images").child(DateTime.now().toIso8601String() + ".mpg");
          await storageReference
              .putFile(blogImage)
              .onComplete;
          imageUrl = await storageReference.getDownloadURL();
        }

        if (isEdit == "true") {
          await blogReference.document(blogId).setData({
            "title": title,
            "text": blogText,
            "imageUrl": imageUrl,
            "creatorId": currentUser.uid
          });
        } else {
          await blogReference.add({
            "title": title,
            "text": blogText,
            "imageUrl": imageUrl,
            "creatorId": currentUser.uid
          });
        }
        Navigator.pushReplacementNamed(context, '/mainScreen');
      }catch(err){
        setState(() {
          isLoading = false;
        });
        showDialog(context: context, builder: (ctx){
          return AlertDialog(
            title: Text('Error'),
            content: Text('Something wrong happened!'),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: (){
                  Navigator.of(ctx).pop();
                },
              )
            ],
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEdit == "true" ? "Edit Product" : "Add product"),),
      body: Container(
        padding: EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Form(
            key: _form,
            child: Column(
               mainAxisSize: MainAxisSize.min,
               mainAxisAlignment: MainAxisAlignment.start,
               children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: "Title"),
                  keyboardType: TextInputType.text,
                  initialValue: this.title,
                  validator: (value) {
                    if(value.length < 3){
                      return "Title must be of length 3";
                    }
                    return null;
                  },
                  onSaved: (value){
                    title = value;
                  },
                ),
                Row(
                 children: <Widget>[
                   Expanded(
                     child: Container(
                       child: blogImage != null ? Image.file(blogImage) : imageUrl != null ? Image.network(imageUrl) : SizedBox(width: 0,),
                     ),
                   ),
                   FlatButton(
                     child: Text('Choose Image from Gallery', style: TextStyle(color: Colors.white),),
                     onPressed: _selectImage,
                     color: Colors.pinkAccent,
                   )
                 ],
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: "Blog"),
                  keyboardType: TextInputType.text,
                  initialValue: this.blogText,
                  maxLines: 10,
                  validator: (value) {
                    if(value.length < 20){
                      return "Blog must be of length 20";
                    }
                    return null;
                  },
                  onSaved: (value){
                    blogText = value;
                  },
                ),
                SizedBox(height: 10,),
                isLoading ? CircularProgressIndicator() : RaisedButton(
                  color: Colors.pinkAccent,
                  child: Text(isEdit == 'true' ? 'Edit' : 'Add', style: TextStyle(color: Colors.white),),
                  onPressed: () => _submit(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

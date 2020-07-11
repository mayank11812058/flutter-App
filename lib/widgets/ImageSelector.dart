import 'package:flutter/cupertino.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageSelector extends StatefulWidget {
  Function (File image) setImage;
  String imageUrl;

  ImageSelector({Key key, this.setImage, this.imageUrl}) : super(key : key);

  @override
  _ImageSelectorState createState() => _ImageSelectorState();
}

class _ImageSelectorState extends State<ImageSelector> {
  File imageFile;
  
  void selectImage(bool fromGallery) async{
    var image;

    try {
      if (fromGallery) {
        image = await ImagePicker.pickImage(source: ImageSource.gallery);
      } else {
        image = await ImagePicker.pickImage(source: ImageSource.camera);
      }
    }catch(err){

    }

    if(image != null){
      setState(() {
        this.imageFile = image;
      });
      widget.setImage(image);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if(imageFile == null && widget.imageUrl == null){
      return Container(
        padding : EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            CircleAvatar(
              child: IconButton(icon: Icon(Icons.add_a_photo), onPressed: () => selectImage(false),),
              radius: 25,
            ),
            FlatButton(child: Text('Choose from Gallery', style: TextStyle(color: Colors.pinkAccent),), onPressed: () => this.selectImage(true),)
          ],
        ),
      );
    }

    return Container(
      padding : EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
          CircleAvatar(
            backgroundImage: widget.imageUrl != null ? NetworkImage(widget.imageUrl) : FileImage(imageFile),
            radius: 25
          ),
          FlatButton(child: Text('Choose from Gallery', style: TextStyle(color: Colors.pinkAccent),), onPressed: () => this.selectImage(true),)
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:untitled/screens/BlogScreen.dart';

class Blog extends StatelessWidget {
  String title;
  String imageUrl;
  String text;
  String creatorId;
  String blogId;
  BuildContext context;

  Blog({Key key, this.context, this.title, this.imageUrl, this.text, this.creatorId, this.blogId}): super(key : key);

  void showDetail(){
    Navigator.push(this.context, MaterialPageRoute(builder: (context) => BlogScreen(title: title,
      imageUrl: imageUrl,
      text: text,
      creatorId: creatorId,
      blogId: blogId,
    )));
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: showDetail,
      child: Card(
        key: UniqueKey(),
        margin: EdgeInsets.only(left : MediaQuery.of(this.context).size.width * 0.05,
            right: MediaQuery.of(this.context).size.width * 0.05,
            top: 10),
        elevation: 10,
        child: Container(
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Image.network(imageUrl, fit: BoxFit.cover, width: MediaQuery.of(this.context).size.width * 0.9, height: 200,),
              Positioned(
                bottom: 0,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(this.context).size.width * 0.9,
                      alignment: Alignment.center,
                      color: Colors.black54,
                      child: Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

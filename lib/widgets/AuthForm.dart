import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './ImageSelector.dart';
import 'package:email_validator/email_validator.dart';

class AuthForm extends StatefulWidget {
  BuildContext context;

  AuthForm({Key key, this.context}) : super(key : key);

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  bool isLogin, isLoading;
  String username;
  String email;
  String password;
  String confirmPassword;
  File userImage;
  TextEditingController usernameController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  TextEditingController confirmPasswordController = new TextEditingController();
  final db = Firestore.instance;
  final _form = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    isLogin = true;
    isLoading = false;
  }

  void setImage(File image){
    setState(() {
      this.userImage = image;
    });
  }

  void _changeMode(){
    bool temp = !isLogin;
    print(isLogin.toString() + " " + temp.toString());
    setState(() {
      this.isLogin = temp;
    });
  }

  void setUserDetails(String username, String email, String password, File image) async{
    if(username != null){
      final user = await FirebaseAuth.instance.currentUser();
      final storageReference = FirebaseStorage.instance.ref().child(
          "images").child(user.uid + ".mpg");
      await storageReference.putFile(image).onComplete;
      final url = await storageReference.getDownloadURL();
      await db.collection("users").document(user.uid).setData({
        "username" : username,
        "email" : email,
        "imageUrl" : url.toString()
      }).then((value) {
        print("Success");
      }).catchError((err){
        print("Error" + err.toString());
      });
    }

    Navigator.pushReplacementNamed(widget.context, '/mainScreen');
  }
  
  void _submit(context) async {
    if(userImage == null && usernameController.text.isNotEmpty){
      Scaffold.of(context).showSnackBar(SnackBar(content: Text('Please select a Image'),));
      return;
    }
    
    if(_form.currentState.validate()){
      _form.currentState.save();
      AuthResult authState;
      setState(() {
        this.isLoading = true;
      });
      try {
        if (isLogin) {
          authState = await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: email, password: password);
        } else {
          authState =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: email, password: password);
        }

        setUserDetails(username, email, password, userImage);
      }catch(err) {
        this.setState(() {
          this.isLoading = false;
        });
        String errorMessage;
        print(err.toString());

        if(err.message.contains('EMAIL_EXISTS')){
          errorMessage = 'Email address already exists';
        }else if(err.message.contains('INVALID_EMAIL')){
          errorMessage = 'Email address not valid';
        }else if(err.message.contains('WEAK_PASSWORD')){
          errorMessage = 'Password is weak';
        }else if(err.message.contains('EMAIL_NOT_FOUND')){
          errorMessage = 'Email address not Found';
        }else{
          errorMessage = 'Authentication Failed';
        }
        
        showDialog(context: context, builder: (ctx){
          return AlertDialog(
            title: Text('Error'),
            content: Text(errorMessage),
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
    return Container(
      child: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(
                width: 1,
                color: Colors.grey
              ),
              borderRadius: BorderRadius.all(Radius.circular(15.0))
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                if(!isLogin) ImageSelector(setImage: setImage,),
                if(!isLogin) TextFormField(
                  decoration: InputDecoration(labelText: "Username"),
                  keyboardType: TextInputType.text,
                  controller: usernameController,
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
                TextFormField(
                  decoration: InputDecoration(labelText: "Email"),
                  keyboardType: TextInputType.emailAddress,
                  controller: emailController,
                  validator: (value) {
                    if(!EmailValidator.validate(value)){
                      return "Must be valid Email Address";
                    }
                    return null;
                  },
                  onSaved: (value){
                    email = value;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: "Password"),
                  keyboardType: TextInputType.visiblePassword,
                  controller: passwordController,
                  obscureText: true,
                  validator: (value) {
                    if(value.length < 8){
                      return "Password must be of length 8";
                    }
                    return null;
                  },
                  onSaved: (value){
                    password = value;
                  },
                ),
                if(!isLogin) TextFormField(
                  decoration: InputDecoration(labelText: "Confirm Password"),
                  keyboardType: TextInputType.visiblePassword,
                  controller: confirmPasswordController,
                  obscureText: true,
                  validator: (value) {
                    if(value != passwordController.text){
                      return "Confirm Password must be equal to Password field";
                    }
                    return null;
                  },
                  onSaved: (value){
                    confirmPassword = value;
                  },
                ),
                SizedBox(height: 10,),
                isLoading ? CircularProgressIndicator() : RaisedButton(
                  color: Colors.pinkAccent,
                  child: Text(isLogin ? 'Login' : 'Sign up', style: TextStyle(color: Colors.white),),
                  onPressed: () => _submit(context),
                ),
                isLoading ? Container(width: 0, height: 0,) : FlatButton(
                  child: Text(isLogin ? 'or Sign up' : 'or Login', style: TextStyle(color: Colors.pinkAccent),),
                  onPressed: () => _changeMode(),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

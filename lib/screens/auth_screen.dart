// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../widgets/auth_form_widget.dart';

class AuthScreen extends StatefulWidget {
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  var _isLoading = false;

  void _submitAuthForm(
    String email,
    String password,
    String username,
    File image,
    bool isLogin,
    BuildContext formContext,
  ) async {
    UserCredential firebaseAuth;
    try {
      setState(() {
        _isLoading = true;
      });
      if (isLogin) {
        firebaseAuth = await _auth.signInWithEmailAndPassword(
            email: email, password: password);
      } else {
        firebaseAuth = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        final ref = FirebaseStorage.instance
            .ref()
            .child('user_image')
            .child(firebaseAuth.user.uid + '.jpg');
        await ref.putFile(image);

        final url=await ref.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseAuth.user.uid)
            .set({
          'username': username,
          'email': email,
          'image_url':url,
        });
      }
    } on FirebaseAuthException catch (err) {
      var message = 'An error occurred, please check your credential';
      if (err != null) {
        message = err.message;
      }

      Scaffold.of(formContext).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          backgroundColor: Theme.of(context).primaryColor,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    } catch (err) {
      print(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: AuthFormWidget(
        _isLoading,
        _submitAuthForm,
      ),
    );
  }
}

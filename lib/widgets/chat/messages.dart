import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'message_bubble.dart';

class Messages extends StatelessWidget {
  const Messages({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (ctx, chatSnapshot) {
        final user = FirebaseAuth.instance.currentUser;

        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        final document = chatSnapshot.data.docs;
        // final documentId=chatSnapshot.data.docs[]

        return ListView.builder(
          reverse: true,
          itemBuilder: (ctx, index) => MessageBubble(
            document[index]['text'],
            document[index]['userId'] == user.uid,
            ValueKey(document[index].id),
            document[index]['username'],
            document[index]['userImage'],
          ),
          itemCount: document.length,
        );
      },
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key, required this.userModel}) : super(key: key);
  final User userModel;
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: () {
              logOutDialogBox(context);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 16,
            ),
            chatListStreamBuilder(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Expanded chatListStreamBuilder() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: usersCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }
          final documents = snapshot.data!.docs;
          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final data = documents[index].data() as Map;
              final email = data['email'] as String?;
              if (userModel.uid == documents[index].id) {
                return const SizedBox();
              }
              return chatListItem(documents, index, context, email);
            },
          );
        },
      ),
    );
  }

  InkWell chatListItem(List<QueryDocumentSnapshot<Object?>> documents,
      int index, BuildContext context, String? email) {
    return InkWell(
      onTap: () {
        final chatRef = FirebaseFirestore.instance
            .collection('chats')
            .doc(getChatId(userModel.uid, documents[index].id));
        chatRef.get().then((value) {
          if (!value.exists) {
            chatRef.set({});
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                userModel: userModel,
                chatId: getChatId(userModel.uid, documents[index].id),
              ),
            ),
          );
        });
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.black26,
        ),
        child: Text(
          email ?? 'N/A',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  Future<dynamic> logOutDialogBox(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  String getChatId(String str1, String str2) {
    int compareResult = str1.compareTo(str2);
    String mergedString;
    if (compareResult < 0) {
      mergedString = '${str1}_$str2';
    } else {
      mergedString = '${str2}_$str1';
    }
    return mergedString;
  }
}

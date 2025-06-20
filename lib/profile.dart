import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_finalminiproject/home.dart';
import 'package:flutter_finalminiproject/login.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  Map<String, dynamic>? user;

  Future<void> fetchUser() async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
          .instance
          .collection("member")
          .doc(uid)
          .get();
      if (doc.exists) {
        user = doc.data();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("something went wrong")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("something went wrong")));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("profile"), centerTitle: true),
      body: Column(
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage("${user!['profile_picture']}"),
              ),
            ),
          ),
          Text("${user!["name"]}"),
        ],
      ), //name is key in map. call name of user.
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: "profile",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: "Log out"),
        ],
        currentIndex: 0,
        onTap: (value) async {
          if (value == 2) {
            await FirebaseAuth.instance.signOut();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Login()),
            );
          }
          if (value == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Profile()),
            );
          }
          if (value == 0) {
            //value is the position of icon. Home is positioned at 0.
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Home()),
            );
          }
        },
      ),
    );
  }
}

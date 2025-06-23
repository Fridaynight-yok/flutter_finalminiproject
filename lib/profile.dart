import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_finalminiproject/home.dart';
import 'package:flutter_finalminiproject/login.dart';
import 'package:get/get.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  Map<String, dynamic>? user;
  late TextEditingController nameController;
  late TextEditingController imageUrlController;
  late TextEditingController emailController;
  bool _isEdit = false;

  Future<void> fetchUser() async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
          .instance
          .collection("members")
          .doc(uid)
          .get();
      if (doc.exists) {
        setState(() {
          nameController.text = doc.data()?["name"] ?? 'no name';
          imageUrlController.text =
              doc.data()?["profile_picture"] ??
              "https://media.istockphoto.com/id/1935990338/photo/golden-retriever-relaxing.webp?a=1&b=1&s=612x612&w=0&k=20&c=VeEoFjpl9-NWUGikj5N84VgORmPSX8y9Ayr4qB_DfgA=";
          emailController.text = doc.data()?['email'] ?? "no email";
        });
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

  Future<void> updateData() async {
    final image = imageUrlController.text.trim();
    final name = nameController.text.trim();
    try {
      await FirebaseFirestore.instance.collection("members").doc(uid).update({
        'name': name,
        'profile_picture': image,
      });
      fetchUser();
    } catch (e) {
      Get.snackbar("warning", "something went wrong");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    nameController = TextEditingController();
    imageUrlController = TextEditingController();
    emailController = TextEditingController();
    fetchUser();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    nameController.dispose();
    imageUrlController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("profile"), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(imageUrlController.text),
                ),
              ),
            ),
            _isEdit
                ? Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: imageUrlController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: imageUrlController.text,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: nameController.text,
                          ),
                        ),
                      ),
                    ],
                  )
                : Text('name: ${nameController.text}'),
            Text('email: ${emailController.text}'),
            Text('uid: $uid'),
            _isEdit
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isEdit = !_isEdit;
                          });
                        },
                        child: Text("cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          updateData();
                        },
                        child: Text("Ok"),
                      ),
                    ],
                  )
                : ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isEdit = !_isEdit;
                      });
                    },
                    child: Text("edit"),
                  ),
          ],
        ),
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

//import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_finalminiproject/login.dart';
//import 'package:image_picker/image_picker.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
  late TextEditingController imageurlController;
  String _imageUrl =
      "https://media.istockphoto.com/id/2214811005/photo/cute-dog-waiting-patiently-during-walk-in-public-space.webp?a=1&b=1&s=612x612&w=0&k=20&c=jZ41upus2l8icw6JUycj0xad0tHRwvqQckGzFnQNWro=";
  //set up image picker
  // final ImagePicker _picker = ImagePicker();
  // File? _Image;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    imageurlController = TextEditingController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    nameController.dispose();
    passwordController.dispose();
    emailController.dispose();
    confirmPasswordController.dispose();
  }

  Future<void> registerUser() async {
    final inputName = nameController.text
        .trim(); //no space bar added when user input name
    final inputPassword = passwordController.text.trim();
    final inputEmail = emailController.text.trim();
    final inputConfirmpassoword = confirmPasswordController.text.trim();
    final inputImageUrl = imageurlController.text.trim();

    if (inputPassword != inputConfirmpassoword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("password and confirm password do not match")),
      );
      return;
    }
    try {
      UserCredential userInfo = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: inputEmail,
            password: inputPassword,
          );
      if (userInfo.user != null) {
        final String uid = userInfo.user!.uid; //! = รับประกันว่าจะไม่ null
        await FirebaseFirestore.instance.collection("members").doc(uid).set({
          "name": inputName,
          "email": inputEmail,
          "profile_picture": inputImageUrl,
          "createAt": FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Register complete")));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("something went wrong ${e}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(_imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: -4,
                right: -4,
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      _imageUrl = imageurlController.text;
                    });
                  },
                  icon: Icon(Icons.edit),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Name",
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: emailController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Email",
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: passwordController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Password",
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: confirmPasswordController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Comfirm password",
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: imageurlController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Image url",
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); //popคือกลับมา1อัน
                },
                child: Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  registerUser();
                },
                child: Text("OK"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

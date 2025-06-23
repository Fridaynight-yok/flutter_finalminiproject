import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_finalminiproject/login.dart';
import 'package:flutter_finalminiproject/profile.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static List<dynamic> cats =
      []; //static คือการคงค่านั้นไว้ กลับมาhome, it will not refresh
  static bool fetchCat = false;
  final Dio dio = Dio();
  bool isLoading =
      false; //ทำให้รู้ว่า something is laoding (มีของ = loading is false)

  Future<void> fetchCats() async {
    if (isLoading == true) {
      return; // Prevents the function from running again if a fetch is already in progress.
    }
    setState(() {
      isLoading = true;
    });
    try {
      final response = await dio.get(
        "https://api.thecatapi.com/v1/images/search?limit=10",
      );
      if (response.statusCode == 200) {
        final List<dynamic> responseCats = response.data;
        setState(() {
          cats.addAll(responseCats);
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to fetch data")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to fetch data")));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (!fetchCat) {
      fetchCats();
      fetchCat = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home"), centerTitle: true),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cats.length,
              itemBuilder: (context, index) {
                final img = cats[index]['url'];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(width: 500, child: Image.network(img)),
                );
              },
            ),
          ),
          SafeArea(
            child: isLoading
                ? CircularProgressIndicator() //ternary ถ้าใช่ทำที่ ? ถ้าไม่ใช่ทำที่ :
                : ElevatedButton(
                    onPressed: () {
                      fetchCats();
                    },
                    child: Text('more'),
                  ),
          ),
        ],
      ),
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
        },
      ),
    );
  }
}

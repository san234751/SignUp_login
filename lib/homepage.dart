import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  String? email;
  HomeScreen({Key? key, this.email}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? name, profilelink;
  bool isloading = false;
  @override
  void initState() {
    getdata();
    super.initState();
  }

  getdata() async {
    setState(() {
      isloading = true;
    });
    if (widget.email == null) {
      await FirebaseFirestore.instance
          .collection('User')
          .doc(FirebaseAuth.instance.currentUser!.email)
          .get()
          .then((value) {
        name = value.data()!['Email'];
        profilelink = value.data()!['ProfileUrl'];
      });
    } else {
      await FirebaseFirestore.instance
          .collection('User')
          .doc(widget.email)
          .get()
          .then((value) {
        name = value.data()!['Email'];
        profilelink = value.data()!['ProfileUrl'];
      });
    }
    setState(() {
      isloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: Drawer(),
      body: isloading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (profilelink != null)
                    Container(
                      height: 90,
                      width: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey),
                        image: DecorationImage(
                          image: NetworkImage(profilelink!),
                        ),
                      ),
                    ),
                  const SizedBox(height: 15),
                  if (name != null)
                    Text('Welcome: $name')
                  else
                    const Text('Welcome'),
                ],
              ),
            ),
    );
  }
}

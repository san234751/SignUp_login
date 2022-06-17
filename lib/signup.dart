import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:login_signup/homepage.dart';
import 'package:login_signup/utiity/snackbar.dart';

class SignUp extends StatefulWidget {
  const SignUp({
    Key? key,
  }) : super(key: key);
  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  late final TextEditingController emailcontroller,
      passwordcontroller,
      googlepasswordcontroller;
  final _formkey = GlobalKey<FormState>();
  final _dialogkey = GlobalKey<FormState>();
  final googleSignIn = GoogleSignIn();
  OAuthCredential? credential;
  String profilelink = "";
  bool isobsecure = true;
  File? image;
  String pass = "";
  @override
  void dispose() {
    emailcontroller.dispose();
    passwordcontroller.dispose();
    googlepasswordcontroller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    emailcontroller = TextEditingController();
    passwordcontroller = TextEditingController();
    googlepasswordcontroller = TextEditingController();
    super.initState();
  }

  pickimage(BuildContext context) => showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          children: [
            const SizedBox(height: 15),
            GestureDetector(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.camera),
                  SizedBox(width: 10),
                  Text('Gallery'),
                ],
              ),
              onTap: () => pickimageFromGalley(),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.camera),
                  SizedBox(width: 10),
                  Text('Camera'),
                ],
              ),
              onTap: () => pickimageFromCamera(),
            ),
            const SizedBox(height: 15),
          ],
          mainAxisSize: MainAxisSize.min,
        );
      });

  pickimageFromGalley() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null) {
      image = File(file.path);
      Navigator.pop(context);
      setState(() {});
    } else {
      showSnackBar(context, 'No Image is selected', null);
    }
  }

  pickimageFromCamera() async {
    final file = await ImagePicker().pickImage(source: ImageSource.camera);
    if (file != null) {
      image = File(file.path);
      Navigator.pop(context);
      setState(() {});
    } else {
      showSnackBar(context, 'No Image is Captured', null);
    }
  }

  getpassword(BuildContext context, var googleUser, var data) => showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.white70,
        builder: (context) {
          return Dialog(
            child: Container(
              padding: EdgeInsets.all(15),
              child: Form(
                key: _dialogkey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: googlepasswordcontroller,
                      onSaved: (val) {
                        pass = val!;
                      },
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Password must not be empty';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter Your Password',
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        final res = _dialogkey.currentState!.validate();
                        if (res) {
                          _dialogkey.currentState!.save();
                          data['Password'] = googlepasswordcontroller.text;
                          try {
                            FirebaseFirestore.instance
                                .collection('User')
                                .doc(googleUser.email)
                                .get()
                                .then((value) {
                              if (value.exists) {
                                showSnackBar(
                                    context, 'Email Aready in Use', null);
                                Navigator.pop(context);
                                return;
                              }
                            });
                            FirebaseAuth.instance
                                .createUserWithEmailAndPassword(
                                    email: googleUser.email,
                                    password: googlepasswordcontroller.text)
                                .then(
                              (value) {
                                if (value.user != null) {
                                  FirebaseFirestore.instance
                                      .collection('User')
                                      .doc(googleUser.email)
                                      .set(data);
                                  showSnackBar(context,
                                      'Signed Up Successfully', Colors.green);

                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HomeScreen(),
                                    ),
                                    (route) => false,
                                  );
                                } else {
                                  showSnackBar(context, 'Something Went Wrong',
                                      Colors.red);
                                }
                              },
                            );
                          } on FirebaseAuthException catch (e) {
                            showSnackBar(context, e.message!, null);
                            Navigator.pop(context);
                          } catch (error) {
                            if (error is PlatformException) {
                              if (error.code == 'ERROR_EMAIL_ALREADY_IN_USE') {
                                showSnackBar(
                                    context, 'Email Aready in use', null);
                              }
                            }
                          }
                        }
                        //Navigator.pop(context);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text('Submit'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orangeAccent,
      body: Center(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(12),
            ),
          ),
          child: Container(
            margin: const EdgeInsets.all(15),
            width: MediaQuery.of(context).size.width * 0.8,
            child: Form(
              key: _formkey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 15),
                    if (image != null)
                      GestureDetector(
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey,
                            image: DecorationImage(
                              image: FileImage(image!),
                            ),
                          ),
                          height: 90,
                          width: 90,
                        ),
                        onTap: () {
                          pickimage(context);
                          setState(() {});
                        },
                      )
                    else
                      GestureDetector(
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey),
                          ),
                          height: 90,
                          width: 90,
                          child: const Center(
                            child: Icon(
                              Icons.person,
                              size: 40,
                            ),
                          ),
                        ),
                        onTap: () {
                          pickimage(context);
                          setState(() {});
                        },
                      ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: emailcontroller,
                      decoration: InputDecoration(
                        hintText: 'Enter Your Email',
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Email Must be Provided';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: passwordcontroller,
                      obscureText: isobsecure,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: Icon(isobsecure
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              isobsecure = !isobsecure;
                            });
                          },
                        ),
                        hintText: 'Enter Your Password',
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Password is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () async {
                          bool res = _formkey.currentState!.validate();
                          if (res) {
                            _formkey.currentState!.save();
                            FirebaseFirestore.instance
                                .collection('User')
                                .doc(emailcontroller.text)
                                .get()
                                .then((value) {
                              if (value.exists) {
                                showSnackBar(
                                    context, 'Email Aready in Use', null);
                                return;
                              }
                            });
                            if (image != null) {
                              Reference ref = FirebaseStorage.instance
                                  .ref()
                                  .child("${emailcontroller.text}/image.jpg");
                              await ref.putFile(image!);
                              profilelink = await ref.getDownloadURL();
                            }
                            final data = {
                              'Email': emailcontroller.text,
                              'Password': passwordcontroller.text,
                              'Profile_Pic': profilelink,
                            };
                            try {
                              FirebaseAuth.instance
                                  .createUserWithEmailAndPassword(
                                      email: emailcontroller.text,
                                      password: passwordcontroller.text)
                                  .then(
                                (value) {
                                  if (value.user != null) {
                                    FirebaseFirestore.instance
                                        .collection('User')
                                        .doc(emailcontroller.text)
                                        .set(data);
                                    showSnackBar(
                                      context,
                                      'Signed Up Successfully',
                                      Colors.green,
                                    );

                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => HomeScreen(),
                                      ),
                                      (route) => false,
                                    );
                                  } else {
                                    showSnackBar(
                                      context,
                                      'Something Went Wrong',
                                      Colors.red,
                                    );
                                  }
                                },
                              );
                            } on FirebaseAuthException catch (e) {
                              showSnackBar(context, e.message!, null);
                            }
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text('SignUp'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey,
                            ),
                            height: 3,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text('or'),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey,
                            ),
                            height: 3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () async {
                          final googleUser = await googleSignIn.signIn();
                          if (googleUser == null) {
                            showSnackBar(context,
                                'No Google Account Has been Choosen', null);
                          } else {
                            final googleAuth = await googleUser.authentication;
                            credential = GoogleAuthProvider.credential(
                              accessToken: googleAuth.accessToken,
                              idToken: googleAuth.idToken,
                            );
                            final data = {
                              'Email': googleUser.email,
                              'ProfileUrl': googleUser.photoUrl
                            };
                            getpassword(context, googleUser, data);
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            FaIcon(FontAwesomeIcons.google),
                            SizedBox(width: 10),
                            Text('SignUp with Google'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

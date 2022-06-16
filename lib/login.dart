import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:login_signup/homepage.dart';
import 'package:login_signup/signup.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final googleSignIn = GoogleSignIn();
  late final OAuthCredential credential;
  late final TextEditingController emailcontroller, passwordcontroller;
  bool isobsecure = true;
  final _formkey = GlobalKey<FormState>();
  @override
  void dispose() {
    emailcontroller.dispose();
    passwordcontroller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    emailcontroller = TextEditingController();
    passwordcontroller = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final usewidth = MediaQuery.of(context).size.width * 0.85;
    return Scaffold(
      backgroundColor: Colors.orangeAccent,
      body: Center(
        child: Container(
          width: usewidth,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            margin: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Form(
                key: _formkey,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
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
                    const SizedBox(height: 20),
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
                                .then(
                                  (value) => {
                                    if (value.exists)
                                      {
                                        if (value.data()!['Password'] ==
                                            passwordcontroller.text)
                                          {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Signed In Successfully',
                                                ),
                                                backgroundColor: Colors.green,
                                              ),
                                            ),
                                            Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    HomeScreen(
                                                  email: emailcontroller.text,
                                                ),
                                              ),
                                              (route) => false,
                                            ),
                                          }
                                        else
                                          {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Password Didn\'t match',
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            ),
                                          }
                                      }
                                    else
                                      {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Your Account Doesn\'t exist Please SignUp first',
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        ),
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const SignUp(),
                                          ),
                                        ),
                                      }
                                  },
                                );
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text('Login'),
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
                    //const SizedBox(height: 15),
                    SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          backgroundColor: MaterialStateProperty.all<Color>(
                            const Color(0xffE78787),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            FaIcon(FontAwesomeIcons.google),
                            SizedBox(width: 10),
                            Text('Login with Google'),
                          ],
                        ),
                        onPressed: () async {
                          final googleUser = await googleSignIn.signIn();
                          if (googleUser == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('No Google Account Has been Choosen'),
                              ),
                            );
                          } else {
                            final googleAuth = await googleUser.authentication;
                            credential = GoogleAuthProvider.credential(
                              accessToken: googleAuth.accessToken,
                              idToken: googleAuth.idToken,
                            );
                            FirebaseFirestore.instance
                                .collection('User')
                                .doc(googleUser.email)
                                .get()
                                .then(
                                  (value) => {
                                    if (value.exists)
                                      {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            backgroundColor: Colors.green,
                                            content:
                                                Text('Signed In Successfully'),
                                          ),
                                        ),
                                        FirebaseAuth.instance
                                            .signInWithCredential(credential)
                                      }
                                    else
                                      {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            backgroundColor: Colors.red,
                                            content: Text(
                                                'Your Email Does not exsist'),
                                          ),
                                        ),
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const SignUp(),
                                          ),
                                        )
                                      }
                                  },
                                );
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 15),
                    GestureDetector(
                      child: const Text(
                        'Don\'t have Account?',
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUp(),
                          ),
                        );
                      },
                    )
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

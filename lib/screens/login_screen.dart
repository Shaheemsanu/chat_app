import 'package:chat_app_flutter/screens/sign_up_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String webClientId =
      '848910342802-uqppfqf513h5834s1kdsevjnahae20uf.apps.googleusercontent.com';
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Spacer(),
              userNameField(),
              const SizedBox(height: 16),
              passwordField(),
              TextButton(
                onPressed: () async {
                  await resetPassword(context);
                },
                child: const Text('Forgot Password?'),
              ),
              const SizedBox(height: 16),
              loginFooterBtn(),
              const SizedBox(height: 16),
              signWithGoogleBtn(),
              const Spacer(),
              signUpRow(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Row signUpRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text('Don\'t have an account?'),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SignUpScreen()),
            );
          },
          child: const Text('Sign up'),
        ),
      ],
    );
  }

  Center signWithGoogleBtn() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          googleSignIn();
        },
        icon: const Icon(Icons.g_mobiledata, size: 32),
        label: const Text('Sign in with Google'),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black87,
          backgroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          minimumSize: const Size(260, 48),
        ),
      ),
    );
  }

  StreamBuilder<User?> loginFooterBtn() {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasData && snapshot.data != null) {
          saveUserData(snapshot.data!);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => HomeScreen(userModel: snapshot.data!),
              ),
            );
          });
        }
        return Center(
          child: SizedBox(
            height: 60,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  try {
                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: _usernameController.text.trim(),
                      password: _passwordController.text.trim(),
                    );
                  } on FirebaseAuthException catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to sign in: ${e.message}'),
                        duration: const Duration(seconds: 5),
                      ),
                    );
                  }
                }
              },
              child: const Text('Login'),
            ),
          ),
        );
      },
    );
  }

  SizedBox userNameField() {
    return SizedBox(
      width: double.infinity,
      child: TextFormField(
        controller: _usernameController,
        decoration: const InputDecoration(
          labelText: 'Username',
          border: OutlineInputBorder(),
        ),
        validator: (String? value) {
          if (value!.isEmpty) {
            return 'Please enter your username';
          }
          return null;
        },
      ),
    );
  }

  SizedBox passwordField() {
    return SizedBox(
      width: double.infinity,
      child: TextFormField(
        controller: _passwordController,
        obscureText: true,
        decoration: const InputDecoration(
          labelText: 'Password',
          border: OutlineInputBorder(),
        ),
        validator: (String? value) {
          if (value!.isEmpty) {
            return 'Please enter your password';
          }
          return null;
        },
      ),
    );
  }

  Future<void> resetPassword(BuildContext context) async {
    if (_usernameController.text.trim() != '') {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(
          email: _usernameController.text.trim(),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to send email at this time '),
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> googleSignIn() async {
    try {
      await _googleSignIn.initialize(serverClientId: webClientId);
      GoogleSignInAccount account = await _googleSignIn.authenticate();
      GoogleSignInAuthentication googleSignInAuthentication =
          account.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
      );
      await _firebaseAuth.signInWithCredential(credential);

      //   GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();

      //   if (googleSignInAccount != null) {
      //     GoogleSignInAuthentication googleSignInAuthentication =
      //         await googleSignInAccount.authentication;
      //     AuthCredential credential = GoogleAuthProvider.credential(
      //       accessToken: googleSignInAuthentication.accessToken,
      //       idToken: googleSignInAuthentication.idToken,
      //     );
      //     try {
      //       UserCredential userCredential =
      //           await _firebaseAuth.signInWithCredential(credential);

      //       if (userCredential.user != null && context.mounted) {
      //         Navigator.of(context).pushAndRemoveUntil(
      //           MaterialPageRoute(
      //             builder: (context) =>
      //                 HomeScreen(userModel: userCredential.user!),
      //           ),
      //           (route) => false,
      //         );
      //       } else {
      //         ScaffoldMessenger.of(context).showSnackBar(
      //           const SnackBar(
      //             content: Text('Failed to sign in'),
      //             duration: Duration(seconds: 5),
      //           ),
      //         );
      //       }
      //     } catch (e) {
      //       if (context.mounted) {
      //         ScaffoldMessenger.of(context).showSnackBar(
      //           SnackBar(
      //             content: Text('Failed to sign in: $e'),
      //             duration: const Duration(seconds: 5),
      //           ),
      //         );
      //       }
      //     }
      //   }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sign in: $e'),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> saveUserData(User user) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    return users.doc(user.uid).set({
      'email': user.email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

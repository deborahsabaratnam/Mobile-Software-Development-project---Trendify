import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:fashion_app/homepage.dart';
import 'signup_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isLoading = false;

  // EMAIL LOGIN
  Future<void> login() async {

    try {

      setState(() {
        isLoading = true;
      });

      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );

    } on FirebaseAuthException catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? "Login failed",
          ),
        ),
      );

    } finally {

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // GOOGLE LOGIN
  Future<void> googleLogin() async {

    try {

      setState(() {
        isLoading = true;
      });

      final GoogleSignIn googleSignIn =
          GoogleSignIn();

      await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser =
          await googleSignIn.signIn();

      if (googleUser == null) {

        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }

        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential =
          GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(
        credential,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Google login failed",
          ),
        ),
      );

    } finally {

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {

    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(

          child: Padding(
            padding: const EdgeInsets.all(24),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,

              children: [

                const SizedBox(height: 60),

                // LOGO
                const Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  children: [

                    Text(
                      "Trendi",

                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    Text(
                      "f",
                      style: TextStyle(
                        fontSize: 28,
                        fontFamily: 'cursive',
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    Text(
                      "y",

                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // EMAIL
                TextField(
                  controller: emailController,

                  keyboardType:
                      TextInputType.emailAddress,

                  decoration:
                      const InputDecoration(
                    labelText: "Email",

                    prefixIcon:
                        Icon(Icons.email),

                    border:
                        OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 15),

                // PASSWORD
                TextField(
                  controller: passwordController,

                  obscureText: true,

                  decoration:
                      const InputDecoration(
                    labelText: "Password",

                    prefixIcon:
                        Icon(Icons.lock),

                    border:
                        OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                // LOGIN BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 50,

                  child: ElevatedButton(

                    onPressed:
                        isLoading ? null : login,

                    child: isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            "Login",
                          ),
                  ),
                ),

                const SizedBox(height: 15),

                // GOOGLE LOGIN
                SizedBox(
                  width: double.infinity,
                  height: 50,

                  child: OutlinedButton.icon(

                    onPressed:
                        isLoading
                            ? null
                            : googleLogin,

                    icon: const Icon(
                      Icons.g_mobiledata,
                    ),

                    label: const Text(
                      "Continue with Google",
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Row(
                  children: [

                    Expanded(
                      child: Divider(),
                    ),

                    Padding(
                      padding:
                          EdgeInsets.symmetric(
                        horizontal: 10,
                      ),

                      child: Text(
                        "OR",
                      ),
                    ),

                    Expanded(
                      child: Divider(),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // SIGN UP
                Center(
                  child: TextButton(

                    onPressed: () {

                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder: (_) =>
                              const SignUpScreen(),
                        ),
                      );
                    },

                    child: const Text(
                      "Create an account",
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
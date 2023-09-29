import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mass_qr/pages/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _phoneNumber = '';
  late String _verificationId;
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _saveAuthTokenToSharedPreferences(String authToken) async {
    SharedPreferences prefStorage = await SharedPreferences.getInstance();
    await prefStorage.setString('authToken', authToken);
  }

  Future _getAuthTokenFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([_initialization, _getAuthTokenFromSharedPreferences()]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final authToken = (snapshot.data as List<dynamic>)[1];
          if (authToken != null && authToken is String) {
            return HomePage();
          }
          return Scaffold(
            appBar: AppBar(
              title: Text('Login to Mass QR'),
              automaticallyImplyLeading: false,
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 0, 0, 150),
                        alignment: Alignment.topCenter,
                        child: Text(
                          "Welcome to MassQR",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Phone Number', prefixText: "+91"),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _phoneNumber = value!.trim();
                        },
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            _verifyPhoneNumber(context);
                          }
                        },
                        child: Text('Login'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          // If there's an error, display an error message
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else {
          // If Firebase is still initializing, show a loading spinner
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }

  Future<void> _verifyPhoneNumber(BuildContext context) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: "+91$_phoneNumber",
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _signInWithCredential(context, credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          print('Verification failed: $e');
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => VerifyOTPPage(
                verificationId: verificationId,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      print('Error sending OTP: $e');
    }
  }

  Future<void> _signInWithCredential(BuildContext context, PhoneAuthCredential credential) async {
    try {
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;
      String? authToken = await user!.getIdToken();
      print("Auth Token $authToken");

      await _saveAuthTokenToSharedPreferences(authToken!);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (e) {
      print('Error signing in: $e');
    }
  }
}

class VerifyOTPPage extends StatefulWidget {
  final String verificationId;

  VerifyOTPPage({required this.verificationId});

  @override
  _VerifyOTPPageState createState() => _VerifyOTPPageState();
}

class _VerifyOTPPageState extends State<VerifyOTPPage> {
  final _formKey = GlobalKey<FormState>();
  String _otp = '';
  FirebaseAuth _auth = FirebaseAuth.instance;
  Future<void> _saveAuthTokenToSharedPreferences(String authToken) async {
    SharedPreferences prefStorage = await SharedPreferences.getInstance();
    await prefStorage.setString('authToken', authToken);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify OTP'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'OTP',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the OTP';
                  }
                  return null;
                },
                onSaved: (value) {
                  _otp = value!;
                },
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      try {
                        PhoneAuthCredential credential =
                            PhoneAuthProvider.credential(verificationId: widget.verificationId, smsCode: _otp);
                        UserCredential userCredential = await _auth.signInWithCredential(credential);
                        User? user = userCredential.user;
                        final authToken = await user!.getIdToken();
                        print("Auth Token $authToken");
                        _saveAuthTokenToSharedPreferences(authToken!);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      } catch (e) {
                        print('Error verifying OTP: $e');
                        // Redirect back to the login page
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      }
                    }
                  },
                  child: Text('Verify'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

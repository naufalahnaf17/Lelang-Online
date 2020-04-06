import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Register extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          imageBackground(),
          registerForm(),
        ],
      ),
    );
  }
}

class registerForm extends StatefulWidget {
  @override
  _registerFormState createState() => _registerFormState();
}

class _registerFormState extends State<registerForm> {

  final formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _email , _password;
  String _error = "";
  bool isLoading = false;

  void validateForm(){
    setState(() {
      isLoading = true;
    });

    final form = formKey.currentState;
    if(form.validate()){
      registerAccount();
    }else{
      setState(() {
        isLoading = false;
      });
      print('masukan data');
    }

  }

  void registerAccount() async {
    try{

      final FirebaseUser user = (await _auth.createUserWithEmailAndPassword(
        email: _email,
        password: _password,
      )).user;

      UserUpdateInfo updateInfo = UserUpdateInfo();
      updateInfo.displayName = user.uid;
      user.updateProfile(updateInfo);


      Future.delayed(Duration(seconds: 2),(){
        Navigator.pushReplacementNamed(context, '/main-user');
      });

    }catch(e){
      setState(() {
        _error = "Email Atau Password Salah";
        isLoading = false;
      });
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 40),
              child: Text(
                'Register Akun',
                style: TextStyle( color: Colors.white , fontSize: 50 , fontWeight: FontWeight.w300 ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 40 , bottom: 60),
              child: Text(
                'Isi Data Diri Kamu',
                style: TextStyle( color: Colors.white , fontSize: 14 , fontWeight: FontWeight.w300 ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(left: 40 , right: 40 , bottom: 5),
                child: Container(
                  width: double.infinity,
                  height: 60,
                  child: Padding(
                    padding: EdgeInsets.only(left: 10 , right: 10),
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: "Email",
                      ),
                      validator: (value) => value.isEmpty ? "Email Tidak Boleh Kosong" : null,
                      onChanged: (value){
                        setState(() {
                          _email = value.toString().trim();
                        });
                      },
                    ),
                  ),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(3)
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(left: 40 , right: 40 , bottom: 20),
                child: Container(
                  width: double.infinity,
                  height: 60,
                  child: Padding(
                    padding: EdgeInsets.only(left: 10 , right: 10),
                    child: TextFormField(
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                      ),
                      validator: (value) => value.isEmpty || value.length <= 6 ? "Password Tidak Boleh Kosong / Harus Lebih Dari 6 karakter" : null,
                      onChanged: (value){
                        setState(() {
                          _password = value.toString().trim();
                        });
                      },
                    ),
                  ),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(3)
                  ),
                ),
              ),
            ),
            Container(
              child: isLoading ? Loading() : null,
            ),
            InkWell(
              onTap: (){
                FocusScopeNode currentFocus = FocusScope.of(context);
                if(!currentFocus.hasPrimaryFocus){
                  currentFocus.unfocus();
                  validateForm();
                }
              },
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(left: 40 , right: 40),
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    child: Center(
                      child: Text(
                        'Register',
                        style: TextStyle(
                            color: Colors.white
                        ),
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: (){
                Navigator.pushNamed(context, '/register');
              },
              child: Padding(
                padding: EdgeInsets.only(left: 40 , right: 40 , top: 8),
                child: Container(
                  width: double.infinity,
                  height: 50,
                  child: Center(
                    child: Text(
                      '${_error}',
                      style: TextStyle(
                        color: Colors.white
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.only(bottom: 15),
        child: SpinKitWave(
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}

class imageBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage(
              'assets/bg.png',
            ),
            fit: BoxFit.cover
        ),
      ),
    );
  }
}

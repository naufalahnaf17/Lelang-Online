import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Wrapper extends StatefulWidget {
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void checkUserIsLogin() async {

    final FirebaseUser user = await _auth.currentUser();

    if(user == null){
      Navigator.pushReplacementNamed(context, '/login');
    }else if(user.displayName == 'admin'){
      Navigator.pushReplacementNamed(context, '/main-admin');
    }else if(user.displayName == 'petugas'){
      Navigator.pushReplacementNamed(context, '/main-petugas');
    }else{
      Navigator.pushReplacementNamed(context, '/main-user');
    }

  }

  @override
  void initState() {
    super.initState();
    checkUserIsLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

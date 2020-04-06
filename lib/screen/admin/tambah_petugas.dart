import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TambahPetugas extends StatefulWidget {
  @override
  _TambahPetugasState createState() => _TambahPetugasState();
}

class _TambahPetugasState extends State<TambahPetugas> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final formKey = GlobalKey<FormState>();

  bool isLoading = false;
  String _email , _password;
  String _pesan = " ";

  void logoutAccount() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  Widget appBar = AppBar(
    backgroundColor: Colors.white,
    title: Text('Tambah Akun Petugas', style: TextStyle(color: Colors.black),),
    centerTitle: true,
    elevation: 0,
    iconTheme: IconThemeData(
        color: Colors.black
    ),
  );

  Future<void> _submitForm() async {

    setState(() {
      isLoading = true;
    });

    final form = formKey.currentState;
    if(form.validate()){
      _registerAccount();
    }else{
      Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi Kesalahan Saat Daftarkan Akun'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
      );
    }
  }

  Future<void> _registerAccount() async {
    try{

      final FirebaseUser user = (await _auth.createUserWithEmailAndPassword(
        email: _email,
        password: _password,
      )).user;

      setState(() {
        _pesan = "Berhasil Register Petugas Dengan Email ${_email}";
        isLoading = false;
      });


    }catch(e){
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar,

      body: Container(
        child: Form(
          key: formKey,
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Email Petugas",
                  ),
                  onChanged: (value){setState(() {_email = value.toString().trim();});},
                  validator: (value) => value.isEmpty ? "Email Tidak Boleh Kosong" : null,
                ),
                SizedBox(
                  height: 5,
                ),
                TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                      labelText: "Password Petugas"
                  ),
                  onChanged: (value){setState(() {_password = value.toString().trim();});},
                  validator: (value) => value.isEmpty || value.length < 6 ? "Passwordd Harus Lebih Dari 6 Karakter" : null,
                ),
                Container(
                  child: isLoading
                      ?
                  Container(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Container(
                        child: SpinKitWave(
                          size: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  )
                      :
                  Container(
                    child: SizedBox(height: 20,),
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    FocusScopeNode currentFocus = FocusScope.of(context);
                    if(!currentFocus.hasPrimaryFocus){
                      currentFocus.unfocus();
                      _submitForm();
                    }
                  },
                  child: Container(
                    color: Colors.redAccent,
                    height: 40,
                    child: Center(
                        child: Text('Register' , style: TextStyle(color: Colors.white , letterSpacing: 2),)
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Center(
                    child: Text(
                      '${_pesan}',
                      style: TextStyle(color: Colors.black) ,
                    ),
                ),
              ],
            ),
          ),
        ),
      ),

      drawer: Drawer(
        child: SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height * 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding : EdgeInsets.only(left: 15 , top: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Lelang',
                        style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w300
                        ),
                      ),
                      Text(
                        'Online',
                        style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w300
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                ListTile(
                  onTap: (){ Navigator.pushReplacementNamed(context, '/main-admin'); },
                  title: Text(
                    "Home",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
                ListTile(
                  onTap: (){ Navigator.pop(context); },
                  title: Text(
                    "Tambah Petugas",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ListTile(
                      onTap: (){
                        logoutAccount();
                      },
                      title: Text(
                        "Logout",
                        style: TextStyle(
                            fontSize: 20,
                            letterSpacing: 2,
                            color: Colors.redAccent
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

}

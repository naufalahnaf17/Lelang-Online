import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class MainUser extends StatefulWidget {
  @override
  _MainUserState createState() => _MainUserState();
}

class _MainUserState extends State<MainUser> {

  FirebaseAuth _auth = FirebaseAuth.instance;
  DatabaseReference dbRef = FirebaseDatabase.instance.reference().child("barang");
  Map dataBarang;

  Future<void> _initFirebase() async {
    final FirebaseApp app = await FirebaseApp.configure(
        name: 'Db_lelang',
        options: FirebaseOptions(
          googleAppID: '1:1054415775435:android:1642389c5f8cab763f1d4e',
          apiKey: 'AIzaSyDc4FByl7RdTk_WXx77tu1ptiB2C4lEgjM',
          databaseURL: 'https://lelang-aa2fa.firebaseio.com',
        ));
    _initDataBarang();
  }

  Future<void> _initDataBarang() async {
    try{
      await dbRef.once().then((DataSnapshot snapshot) {
        setState(() {
          dataBarang = snapshot.value;
        });
      });
    }catch(e){
      print('error' + e);
      return null;
    }
  }

  Future<void> _logoutAccount() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void initState() {
    super.initState();
    _initFirebase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Lelang Online', style: TextStyle(color: Colors.black),),
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(
            color: Colors.black
        ),
      ),
      body: Container(
        child: dataBarang!=null
            ?
        Container(
          child: mainContent(dataBarang: dataBarang,),
        )
            :
        Container(
          child: Center(
            child: SpinKitFoldingCube(
              color: Colors.redAccent,
              size: 30,
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
                  onTap: (){
                    Navigator.pop(context);
                  },
                  title: Text(
                    "Home",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
                ListTile(
                  onTap: (){Navigator.pushReplacementNamed(context, '/user-history');},
                  title: Text(
                    "History Lelang",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ListTile(
                      onTap: _logoutAccount,
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

class mainContent extends StatefulWidget {
  Map dataBarang;
  mainContent({ this.dataBarang });

  @override
  _mainContentState createState() => _mainContentState();
}

class _mainContentState extends State<mainContent> {

  final formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference dbBarang = FirebaseDatabase.instance.reference().child("barang");
  final DatabaseReference dbHistory = FirebaseDatabase.instance.reference().child("history");
  List<dynamic> listBarang;
  Map dataBarang;

  String _hargaPenawaran;
  DateTime _tanggal = DateTime.now();

  Future<void> _setBarangToList() async {
     listBarang = widget.dataBarang.values.toList();
  }

  Future<void> _submitFormPenawaran(int index) async {
    final form = formKey.currentState;
    if(form.validate() && _hargaPenawaran!= null){
      if(int.parse(_hargaPenawaran) >= int.parse(listBarang[index]['harga_akhir'])){
        inputDataToHistory(index);
      }else{
        Navigator.pop(context);
        Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text('Seseorang Telah Menawar Barang Ini Dengan Harga Yang lebih Tinggi'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            )
        );
      }
    }
  }

  Future<void> inputDataToHistory(int index) async {
    await dbBarang.child(listBarang[index]['id_barang']).update({
      'harga_akhir' : _hargaPenawaran,
    });

    final FirebaseUser user = await _auth.currentUser();
    String userId = user.uid.toString();
    String keyHistory = dbHistory.push().key;

    await dbHistory.child(userId).child(keyHistory).set({
      'id_user' : userId,
      'id_history' : keyHistory,
      'id_barang' : listBarang[index]['id_barang'],
      'nama_barang' : listBarang[index]['nama_barang'],
      'deskripsi_barang' : listBarang[index]['deskripsi_barang'],
      'pada_tanggal' : _tanggal.toString(),
      'url_image' : listBarang[index]['url_image'],
      'harga_tawar_saya' : _hargaPenawaran,
    });

    await _initDataBarang();

    Navigator.pop(context);
    Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('Penawaran Berhasil Di Ajukan'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        )
    );

  }

  Future<void> _tawarBarang(int index) async {
    if(listBarang[index]['status_lelang'] == 'tertutup'){
      Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text('Untuk Sementara Barang Ini Tidak Di Lelang'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          )
      );
    }else{
      showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset(
                'assets/modal.png',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Penawaran Anda Harus Diatas ${listBarang[index]["harga_akhir"]}',
                    style: TextStyle( letterSpacing: 2 , fontSize: 16 ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom , left: 8 , right: 8),
                child: Form(
                  key: formKey,
                  child: TextFormField(
                    keyboardType: TextInputType.numberWithOptions(),
                    decoration: InputDecoration(
                      labelText: "Harga Penawaran Anda",
                    ),
                    onChanged: (value){ setState(() {_hargaPenawaran = value.toString().trim();});},
                    validator: (value) => value.isEmpty ? "Masukan Harga Penawaran Anda" : null,
                    autofocus: true,
                  ),
                ),
              ),
              GestureDetector(
                onTap: (){ _submitFormPenawaran(index); },
                child: Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Center(
                    child: Container(
                      color: Colors.redAccent,
                      height: 40,
                      width: 200,
                      child: Center(
                        child: Text(
                          'Submit',
                          style: TextStyle(color: Colors.white , letterSpacing: 2),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
            ],
          ));
    }
  }

  Future<void> _viewDetailBarang(int index) async {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context){
          return Container(
            height: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Wrap(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        'Nama Barang : '+'${listBarang[index]['nama_barang']}',
                        style: TextStyle( fontSize: 16 ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        'Deskripsi Barang : '+'${listBarang[index]['deskripsi_barang']}',
                        style: TextStyle( fontSize: 16 ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        'Tanggal Barang : '+'${listBarang[index]['tgl_barang']}',
                        style: TextStyle( fontSize: 16 ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        'Harga Barang : RP. '+'${listBarang[index]['harga_awal']} (harga dapat berubah saat ada penawaran terbaru)',
                        style: TextStyle( fontSize: 16 ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Text(
                        'Status Lelang Barang : '+'${listBarang[index]['status_lelang']}',
                        style: TextStyle( fontSize: 16 ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
    );
  }

  Future<void> _initDataBarang() async {
    try{
      await dbBarang.once().then((DataSnapshot snapshot) {
        setState(() {
          dataBarang = snapshot.value;
          listBarang = dataBarang.values.toList();
        });
      });
    }catch(e){
      print('error' + e);
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _setBarangToList();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: listBarang.length,
      shrinkWrap: true,
      itemBuilder: (context,index){
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Flexible(
              flex: 1,
              child: Stack(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width * 1,
                    child: Center(
                      child: Text('Gambar Sedang Dimuat' , style: TextStyle(color: Colors.redAccent),)
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 1,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Image.network(
                        listBarang[index]['url_image'],
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.low,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              flex: 1,
              child: Container(
                width: MediaQuery.of(context).size.width * 1,
                child: Wrap(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '${listBarang[index]['nama_barang']}',
                            style: TextStyle(
                                fontSize: 25,
                                letterSpacing: 2
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            '${listBarang[index]['deskripsi_barang']}',
                            style: TextStyle(
                                fontSize: 18
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Text(
                            'Start From : RP. ${listBarang[index]['harga_awal']}',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.redAccent,
                                letterSpacing: 3
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          GestureDetector(
                            onTap: (){
                              _tawarBarang(index);
                            },
                            child: Center(
                              child: Container(
                                width: 300,
                                color: Colors.redAccent,
                                child: Padding(
                                  padding: EdgeInsets.all(15),
                                  child: Center(
                                    child: Text(
                                      'Tawar Barang',
                                      style: TextStyle(
                                        color: Colors.white,
                                        letterSpacing: 2
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: (){ _viewDetailBarang(index); },
                            child: Center(
                              child: Container(
                                width: 300,
                                child: Padding(
                                  padding: EdgeInsets.all(15),
                                  child: Center(
                                    child: Text(
                                      'Detail Barang',
                                      style: TextStyle(
                                          letterSpacing: 2
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Icon(Icons.arrow_back_ios)
                              ),
                              Align(
                                  alignment: Alignment.bottomRight,
                                  child: Icon(Icons.arrow_forward_ios)
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}



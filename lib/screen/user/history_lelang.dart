import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class HistoryLelang extends StatefulWidget {
  @override
  _HistoryLelangState createState() => _HistoryLelangState();
}

class _HistoryLelangState extends State<HistoryLelang> {

  FirebaseAuth _auth = FirebaseAuth.instance;
  DatabaseReference dbRef = FirebaseDatabase.instance.reference().child("history");
  Map dataHistory;
  bool isLoading = true;

  Future<void> _initFirebase() async {
    final FirebaseApp app = await FirebaseApp.configure(
        name: 'Db_lelang',
        options: FirebaseOptions(
          googleAppID: '1:1054415775435:android:1642389c5f8cab763f1d4e',
          apiKey: 'AIzaSyDc4FByl7RdTk_WXx77tu1ptiB2C4lEgjM',
          databaseURL: 'https://lelang-aa2fa.firebaseio.com',
        ));
    _initDataHistory();
  }

  Future<void> _initDataHistory() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    try{
      await dbRef.child(user.uid.toString()).once().then((DataSnapshot snapshot) {
        setState(() {
          dataHistory = snapshot.value;
          isLoading = false;
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
        title: Text('History Lelang', style: TextStyle(color: Colors.black),),
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(
            color: Colors.black
        ),
      ),
      body: Container(
        child: isLoading
            ?
        Container(
          child: Center(
            child: SpinKitFoldingCube(
              color: Colors.redAccent,
              size: 30,
            ),
          ),
        )
            :
        Container(
          child: _mainContent(dataHistory: dataHistory,),
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
                  onTap: (){Navigator.pushReplacementNamed(context, '/main-user');},
                  title: Text(
                    "Home",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
                ListTile(
                  onTap: (){Navigator.pop(context);},
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

class _mainContent extends StatefulWidget {

  Map dataHistory;
  _mainContent({ this.dataHistory });

  @override
  __mainContentState createState() => __mainContentState();
}

class __mainContentState extends State<_mainContent> {

  List<dynamic> listHistory;

  Future<void> _setMapToList(){
    listHistory = widget.dataHistory.values.toList();
  }

  @override
  void initState() {
    super.initState();
    _setMapToList();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: listHistory.length,
      shrinkWrap: true,
      itemBuilder: (context , index){
        return Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[

              Flexible(
                flex: 1,
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      '${listHistory[index]['url_image']}',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 150,
                    ),
                  ),
                ),
              ),

              Flexible(
                flex: 1,
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Wrap(
                        children: <Widget>[
                          Text('Nama barang : '),
                          Text(
                            '${listHistory[index]['nama_barang']}',
                            style: TextStyle( fontWeight: FontWeight.bold ) ,
                          )
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Wrap(
                        children: <Widget>[
                          Text('Deskripsi barang : '),
                          Text(
                            '${listHistory[index]['deskripsi_barang']}',
                            style: TextStyle( fontWeight: FontWeight.bold ) ,
                          )
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Wrap(
                        children: <Widget>[
                          Text('Tanggal Penawaran : '),
                          Text(
                            '${listHistory[index]['pada_tanggal']}',
                            style: TextStyle( fontWeight: FontWeight.bold ) ,
                          )
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Wrap(
                        children: <Widget>[
                          Text('Penawaran Saya : '),
                          Text(
                            'RP.${listHistory[index]['harga_tawar_saya']}',
                            style: TextStyle( fontWeight: FontWeight.bold ) ,
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            ],
          ),
        );
      },
    );
  }
}


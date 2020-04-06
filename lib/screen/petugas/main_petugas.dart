import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lelangonline/screen/petugas/edit_data_petugas.dart';

class MainPetugas extends StatefulWidget {
  @override
  _MainPetugasState createState() => _MainPetugasState();
}

class _MainPetugasState extends State<MainPetugas> {

  void initFirebase() async {
    final FirebaseApp app = await FirebaseApp.configure(
        name: 'Db_lelang',
        options: FirebaseOptions(
          googleAppID: '1:1054415775435:android:1642389c5f8cab763f1d4e',
          apiKey: 'AIzaSyDc4FByl7RdTk_WXx77tu1ptiB2C4lEgjM',
          databaseURL: 'https://lelang-aa2fa.firebaseio.com',
        ));
  }

  @override
  void initState() {
    super.initState();
    initFirebase();
  }

  void logoutAccount(){
    FirebaseAuth _auth = FirebaseAuth.instance;
    _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Pendataan Barang', style: TextStyle(color: Colors.black),),
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(
            color: Colors.black
        ),
      ),
      body: mainContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.pushNamed(context, '/admin-tambah');
        },
        backgroundColor: Colors.redAccent,
        child: Icon(Icons.add),
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

class mainContent extends StatefulWidget {
  @override
  _mainContentState createState() => _mainContentState();
}

class _mainContentState extends State<mainContent> {

  DatabaseReference dbRef = FirebaseDatabase.instance.reference().child("barang");
  Map dataBarang;
  List<dynamic> listBarang;
  bool isLoading = true;

  void setUpData() async {
    setState(() {
      isLoading = true;
    });
    await dbRef.once().then((DataSnapshot snapshot) {
      setState(() {
        dataBarang = snapshot.value;
        listBarang = dataBarang.values.toList();
      });
    });
    setState(() {
      isLoading = false;
    });
  }

  void editOrDelete(int index){
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context){
          return Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                InkWell(
                  onTap: (){
                    editBarang(index);
                  },
                  child: SizedBox(
                    height: 50,
                    child: Center(
                        child: Text(
                          'Edit Barang',
                          style: TextStyle(
                              fontSize: 20
                          ),
                        )
                    ),
                  ),
                ),
                InkWell(
                  onTap: (){
                    hapusBarang(index);
                    Navigator.pop(context);
                  },
                  child: SizedBox(
                    height: 50,
                    child: Center(
                      child: Text(
                        'Hapus Barang',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.redAccent
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
    );
  }

  void hapusBarang(int index){
    dbRef.child('${listBarang[index]['id_barang']}').remove();
    Scaffold.of(context).showSnackBar(SnackBar( content: Text('Hapus Data Berhasil'), ));
    setUpData();
  }

  void editBarang(int index){
    String id_barang = listBarang[index]['id_barang'];
    String deskripsi_barang = listBarang[index]['deskripsi_barang'];
    String harga_awal = listBarang[index]['harga_awal'];
    String nama_barang = listBarang[index]['nama_barang'];
    String status_lelang = listBarang[index]['status_lelang'];
    String tgl_barang = listBarang[index]['tgl_barang'];
    String url_image = listBarang[index]['url_image'];

    Navigator.push(context, MaterialPageRoute(
      builder: (context) => EditDataPetugas(
        id_barang: id_barang,
        deskripsi_barang: deskripsi_barang,
        harga_awal: harga_awal,
        nama_barang: nama_barang,
        status_lelang: status_lelang,
        tgl_barang: tgl_barang,
        url_image : url_image,
      ),
    ));

  }


  @override
  void initState() {
    super.initState();
    setUpData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: isLoading
            ?
        Container(
          child: Center(
            child: SpinKitFoldingCube(
              color: Colors.redAccent,
              size: 40,
            ),
          ),
        )
            :
        Container(
          child: ListView.builder(
            itemCount: listBarang.length,
            itemBuilder: (context,index){
              return Container(
                child: listBarang.length < 0 || listBarang.length == null
                    ?
                Container(
                  child: Center(
                    child: Text('Tidak Ada Data Barang Di Temukan'),
                  ),
                )
                    :
                Container(
                  child: InkWell(
                    onTap: (){
                      editOrDelete(index);
                    },
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
                                '${listBarang[index]['url_image']}',
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
                                  Padding(
                                    padding: EdgeInsets.only(top : 10),
                                    child: Wrap(
                                      children: <Widget>[
                                        Text(
                                          'Nama Barang : ',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                        Text(
                                          '${listBarang[index]['nama_barang']}',
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 10),
                                    child: Wrap(
                                      children: <Widget>[
                                        Text(
                                          'Deskripsi Barang : ',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                        Text(
                                          '${listBarang[index]['deskripsi_barang']}',
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 10),
                                    child: Wrap(
                                      children: <Widget>[
                                        Text(
                                          'Harga Barang : ',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                        Text(
                                          ' RP. ${listBarang[index]['harga_awal']}'.toUpperCase(),
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.redAccent
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 10),
                                    child: Wrap(
                                      children: <Widget>[
                                        Text(
                                          'Status Lelang : ',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                        Text(
                                          '${listBarang[index]['status_lelang']}'.toUpperCase(),
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: listBarang[index]['status_lelang'] == 'terbuka' ? Colors.green : Colors.redAccent
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                        ),

                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        )
    );
  }

  @override
  void didUpdateWidget(mainContent oldWidget) {
    setUpData();
  }

}


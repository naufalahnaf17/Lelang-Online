import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class TambahDataAdmin extends StatefulWidget {
  @override
  _TambahDataAdminState createState() => _TambahDataAdminState();
}

class _TambahDataAdminState extends State<TambahDataAdmin> {

  @override
  void initState() {
    super.initState();
    initFirebase();
  }

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        children: <Widget>[
          imageUploader(),
        ],
      ),
    );
  }
}

class imageUploader extends StatefulWidget {
  @override
  _imageUploaderState createState() => _imageUploaderState();
}

class _imageUploaderState extends State<imageUploader> {

  DatabaseReference dbBarang = FirebaseDatabase.instance.reference().child("barang");
  final formKey = GlobalKey<FormState>();
  String _namaBarang , _hargaAwal , _deskripsiBarang , _urlImage;
  DateTime _tanggal = DateTime.now();
  File _image;
  bool isLoading = false;

  final FirebaseStorage _storage = FirebaseStorage(storageBucket: 'gs://lelang-aa2fa.appspot.com');
  StorageUploadTask _uploadTask;

  void uploadImage() async {
    String namaFile = 'images/${_tanggal}.png';
    setState(() {
      _uploadTask = _storage.ref().child(namaFile).putFile(_image);
    });

    String url = await ( await _uploadTask.onComplete).ref.getDownloadURL();

    setState(() {
      _urlImage = url;
    });

  }

  void validationForm(){
    final form = formKey.currentState;
    if(form.validate() && _image!=null){
      inputDataToFirebase();
    }else{
      final snackBar = SnackBar(content: Text('Ups Masukan Gambar Terlebih Dahulu :)'));
      Scaffold.of(context).showSnackBar(snackBar);
    }
  }

  void inputDataToFirebase() async {
    setState(() {
      isLoading = true;
    });
    await(uploadImage());
    String key = dbBarang.push().key;
    dbBarang.child(key).set({
      'id_barang' : key,
      'nama_barang': _namaBarang,
      'harga_awal': _hargaAwal,
      'harga_akhir': _hargaAwal,
      'tgl_barang' : _tanggal.toString(),
      'deskripsi_barang' : _deskripsiBarang,
      'url_image' : _urlImage.toString(),
      'status_lelang' : 'terbuka',
    }).whenComplete((){
      Scaffold.of(context).showSnackBar(SnackBar( content: Text('Tambah Data Berhasil'), ));
      Future.delayed(Duration(seconds: 1),(){
        setState(() {
          isLoading = false;
        });
        Navigator.pop(context);
      });
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    File selected = await ImagePicker.pickImage(source: source);
    setState(() {
      _image = selected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 10 , right: 10),
      child: Container(
        child: Column(
          children: <Widget>[

            Container(
              height: 200,
              child: _image==null ?
              Container(
                child: Center(
                  child: RaisedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: Icon(Icons.add_a_photo , size: 30,),
                      label: Text('Tambah Gambar')
                  ),
                ),
              ) :
              Container(
                width: double.infinity,
                child: Image.file(
                  _image,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Nama Barang",
                    ),
                    onChanged: (value){setState(() {_namaBarang = value.toString().trim();});},
                    validator: (value) => value.isEmpty ? "Nama Barang Tidak Boleh Kosong" : null,
                  ),
                  Row(
                    children: <Widget>[
                      Flexible(
                        flex: 1,
                        child: RaisedButton.icon(
                            elevation: 0,
                            color: Colors.amber,
                            onPressed: (){
                              showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2019),
                                lastDate: DateTime(2030),
                              ).then((date){
                                setState(() {
                                  _tanggal = date;
                                });
                              });
                            },
                            icon: Icon(Icons.date_range),
                            label: Text('Tanggal Barang')
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Text('${_tanggal}')
                        ),
                      ),
                    ],
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                        labelText: "Harga Awal"
                    ),
                    onChanged: (value){setState(() {_hargaAwal = value.toString().trim();});},
                    validator: (value) => value.isEmpty ? "Harga Barang Tidak Boleh Kosong" : null,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                        labelText: "Deskripsi Barang"
                    ),
                    onChanged: (value){setState(() {_deskripsiBarang = value.toString().trim();});},
                    validator: (value) => value.isEmpty ? "Deskripsi Barang Tidak Boleh Kosong" : null,
                  ),

                  Container(
                    child: isLoading
                        ?
                    Container(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: SpinKitFoldingCube(
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    )
                        :
                    Container(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                      ),
                    )
                  ),

                  Container(
                    width: double.infinity,
                    child: RaisedButton(
                      color: Colors.redAccent,
                      onPressed: validationForm,
                      child: Text(
                        'Submit',
                        style: TextStyle(
                          color: Colors.white
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



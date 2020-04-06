import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class EditDataPetugas extends StatefulWidget {
  String id_barang , deskripsi_barang , harga_awal , nama_barang , status_lelang , tgl_barang , url_image;
  EditDataPetugas({ this.id_barang, this.deskripsi_barang, this.harga_awal, this.nama_barang, this.status_lelang, this.tgl_barang , this.url_image });

  @override
  _EditDataPetugasState createState() => _EditDataPetugasState();
}

class _EditDataPetugasState extends State<EditDataPetugas> {

  final formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final DatabaseReference dbBarang = FirebaseDatabase.instance.reference().child("barang");
  final FirebaseStorage _storage = FirebaseStorage(storageBucket: 'gs://lelang-aa2fa.appspot.com');
  StorageUploadTask _uploadTask;

  String _namaBarang , _hargaAwal , _deskripsiBarang , _urlImage , _statusLelang;
  DateTime _tanggal = DateTime.now();
  File _image;
  bool isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    File selected = await ImagePicker.pickImage(source: source);
    setState(() {
      _image = selected;
    });
  }

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

  void validationForm() async {
    final form = formKey.currentState;
    String status = _statusLelang;

    if(status == null){
      status = widget.status_lelang;
    }

    if(_image != null){
      await uploadImage();
    }

    if(form.validate() && status == 'terbuka' || form.validate() && status == 'tertutup'){
      editDataFromFirebase();
    }else{
      print('bad');
    }
  }

  void editDataFromFirebase() async {
    setState(() {
      isLoading = true;
    });
    dbBarang.child(widget.id_barang).update({
      'deskripsi_barang' : _deskripsiBarang == null ? widget.deskripsi_barang : _deskripsiBarang,
      'harga_awal' : _hargaAwal == null ? widget.harga_awal : _hargaAwal,
      'harga_akhir' : _hargaAwal == null ? widget.harga_awal : _hargaAwal,
      'nama_barang' : _namaBarang == null ? widget.nama_barang : _namaBarang,
      'status_lelang' : _statusLelang == null ? widget.status_lelang : _statusLelang,
      'tgl_barang' : _tanggal.toString(),
      'url_image' : _urlImage == null ? widget.url_image : _urlImage,
    }).whenComplete((){
      _scaffoldKey.currentState.showSnackBar(
          SnackBar(
            content: Text('Berhasil Edit Data'),
          ));
      Future.delayed(Duration(seconds: 1),(){
        setState(() {
          isLoading = false;
        });
        Navigator.pop(context);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
          Padding(
            padding: EdgeInsets.only(left: 10 , right: 10),
            child: Container(
              child: Column(
                children: <Widget>[

                  Container(
                    height: 200,
                    child: _image==null ?
                    InkWell(
                      onTap: () => _pickImage(ImageSource.camera),
                      child: Container(
                          width: double.infinity,
                          child: Image.network(
                            widget.url_image,
                            fit: BoxFit.cover,
                          )
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
                          initialValue : widget.nama_barang ,
                          decoration: InputDecoration(
                            labelText: "Nama Barang",
                          ),
                          onChanged: (value){setState(() {_namaBarang = value.toString().trim();});},
                          validator: (value) => value.isEmpty ? "Nama Barang Tidak Boleh Kosong" : null,
                        ),
                        Row(
                          children: <Widget>[
                            Flexible(
                              flex : 1,
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
                                child: Text(widget.tgl_barang),
                              ),
                            ),
                          ],
                        ),
                        TextFormField(
                          initialValue: widget.harga_awal,
                          decoration: InputDecoration(
                              labelText: "Harga Awal"
                          ),
                          onChanged: (value){setState(() {_hargaAwal = value.toString().trim();});},
                          validator: (value) => value.isEmpty ? "Harga Barang Tidak Boleh Kosong" : null,
                        ),
                        TextFormField(
                          initialValue: widget.deskripsi_barang,
                          decoration: InputDecoration(
                              labelText: "Deskripsi Barang"
                          ),
                          onChanged: (value){setState(() {_deskripsiBarang = value.toString().trim();});},
                          validator: (value) => value.isEmpty ? "Deskripsi Barang Tidak Boleh Kosong" : null,
                        ),
                        TextFormField(
                          initialValue: widget.status_lelang,
                          decoration: InputDecoration(
                              labelText: "Status Lelang (terbuka / tertutup)"
                          ),
                          onChanged: (value){setState(() {_statusLelang = value.toString().trim();});},
                          validator: (value) => value.isEmpty ? "Status Barang Tidak Boleh Kosong / Masukan kata terbuka / tertutup" : null,
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
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lelangonline/wrapper.dart';
import 'package:lelangonline/screen/login_screen.dart';
import 'package:lelangonline/screen/register_screen.dart';
import 'package:lelangonline/screen/admin/main_admin.dart';
import 'package:lelangonline/screen/admin/tambah_petugas.dart';
import 'package:lelangonline/screen/petugas/main_petugas.dart';
import 'package:lelangonline/screen/user/main_user.dart';
import 'package:lelangonline/screen/user/history_lelang.dart';
import 'package:lelangonline/screen/admin/tambah_data_admin.dart';

void main() => runApp(MaterialApp(
  initialRoute: '/',
  routes: {
    '/' : (context) => Wrapper(),
    '/login' : (context) => Login(),
    '/register' : (context) => Register(),
    '/main-admin' : (context) => MainAdmin(),
    '/main-petugas' : (context) => MainPetugas(),
    '/main-user' : (context) => MainUser(),
    '/admin-tambah' : (context) => TambahDataAdmin(),
    '/user-history' : (context) => HistoryLelang(),
    '/admin-tambah-petugas' : (context) => TambahPetugas(),
  },
));
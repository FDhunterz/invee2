import 'package:flutter/material.dart';

List<ListOpnameStok> listOpnameStockArray = [];
List<ListCircleTime> listCircleTimeArray = [];
GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();


class ListOpnameStok {
  String id;
  String ref;
  String date;
  String gudang;
  String status;
  String catatan;
  ListOpnameStok({
    @required this.id,
    @required this.ref,
    @required this.date,
    @required this.gudang,
    @required this.status,
    @required this.catatan,
  });
}

class ListCircleTime {
  String idOpname;
  String idProduk;
  String namaProduk;
  String stokSistem;
  String satuan;
  String gudang;
  String status;
  String nextCircle;
  String circleTime;
  String lastCircle;
  ListCircleTime({
    @required this.idOpname,
    @required this.idProduk,
    @required this.namaProduk,
    @required this.stokSistem,
    @required this.satuan,
    @required this.gudang,
    @required this.status,
    @required this.nextCircle,
    @required this.circleTime,
    @required this.lastCircle,
  });
}

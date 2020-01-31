import 'package:flutter/material.dart';

List<ListOffline> listOfflineArray = [];
GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
List<Liststock> listStockArray = [];
List<DetailStock> detailStockArray = [];
List<DataProduk> dataProdukArray = [];
List<PriceList> dataPriceList = [];

class ListOffline {
  final String id;
  final String nota;
  final String customer;
  final String status;
  final String bayar;
  final String idcustomer;

  ListOffline({this.id, this.nota, this.status, this.customer , this.bayar , this.idcustomer});
}

class Liststock {
  final String nama;
  final String code;

  Liststock({this.nama, this.code});
}

class DetailStock {
  final String nama;
  final String satuan;
  final String qty;
  final String codeproduk;

  DetailStock({this.nama, this.satuan, this.qty , this.codeproduk});
}

class DataProduk {
  final String namaproduk;
  final String code;
  bool check;

  DataProduk({this.namaproduk, this.code , this.check});
}

class PriceList {
  final String barang;
  final String harga1;
  final String harga2;
  final String harga3;
  final String satuan1;
  final String satuan2;
  final String satuan3;

  PriceList({this.barang, this.harga1,this.harga2,this.harga3, this.satuan1,this.satuan2,this.satuan3});
}
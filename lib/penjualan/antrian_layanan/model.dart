import 'package:flutter/material.dart';

class ListProdukArray {
  String namaProduk;
  String idProduk;
  String qtyProduk;
  ListProdukArray({this.namaProduk, this.idProduk, this.qtyProduk});
}

class ListLokasiGudang {
  String kodeGudang, namaGudang;
  ListLokasiGudang({this.kodeGudang, this.namaGudang});
}

class ListProduk {
  String kodeProduk, namaProduk;
  ListProduk({this.kodeProduk, this.namaProduk});
}

class ListProdukDiTambahkan {
  String kodeProduk, namaProduk, namaSatuan, kodeSatuan;
  int stokAdjustment, stokSistem;
  TextEditingController stokGudang;

  ListProdukDiTambahkan({
    @required this.kodeProduk,
    @required this.namaProduk,
    @required this.stokAdjustment,
    @required this.stokGudang,
    @required this.stokSistem,
    @required this.kodeSatuan,
    @required this.namaSatuan,
  });
}

class FormSerialize {
  String member;

  FormSerialize({
    this.member,
  });

  Map toJson() => {
    'member' : member,
  };
}

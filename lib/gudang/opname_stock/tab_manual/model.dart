import 'package:flutter/material.dart';

class KeteranganOpname {
  String value, nama;
  KeteranganOpname({
    this.value,
    this.nama,
  });

  bool operator == (Object other) => other is KeteranganOpname && other.value == value && other.nama == nama;

  int get hashCode => value.hashCode^nama.hashCode;
}

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
  List<KeteranganOpname> listKeteranganOpname;
  KeteranganOpname selectedKeteranganOpname;

  ListProdukDiTambahkan({
    @required this.listKeteranganOpname,
    @required this.selectedKeteranganOpname,
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
  String referensi, gudang, catatan, tanggal;
  List<dynamic> stokGudang, stokAdjustment, stokSistem, idSatuan, idProduk;

  FormSerialize({
    this.referensi,
    this.gudang,
    this.catatan,
    this.tanggal,
    this.stokAdjustment,
    this.stokGudang,
    this.stokSistem,
    this.idSatuan,
    this.idProduk,
  });

  Map toJson() => {
        'gudang': gudang,
        'referensi': referensi,
        'catatan': catatan,
        'tanggal': tanggal,
        'id_produk': idProduk,
        'id_satuan': idSatuan,
        'stok_adjustment': stokAdjustment,
        'stok_sistem': stokSistem,
        'stok_gudang': stokGudang,
      };
}

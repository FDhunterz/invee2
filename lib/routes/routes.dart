import 'package:flutter/material.dart';
import 'package:invee2/gudang/layanan_penjualan/layanan_nota/layanan_nota.dart';
import 'package:invee2/home.dart';
import 'package:invee2/login.dart';
import 'package:invee2/master/customer/customer.dart';
import 'package:invee2/penjualan/kasir/kasir.dart';
import 'package:invee2/penjualan/kasir/tambah_penjualan.dart';
import 'package:invee2/penjualan/antrian_layanan/antrian_layanan.dart';
import 'package:invee2/gudang/layanan_penjualan/penjualan_offline/penjualan_offline.dart';
import 'package:invee2/gudang/layanan_penjualan/penjualan_online/penjualan_online.dart';
import 'package:invee2/gudang/mutasi/barang_keluar/barang_keluar.dart';
import 'package:invee2/gudang/mutasi/barang_masuk/barang_masuk.dart';
import 'package:invee2/gudang/opname_stock/opname_stock.dart';
import 'package:invee2/gudang/penerimaan_barang/penerimaan_barang.dart';
import 'package:invee2/gudang/opname_stock/tab_manual/tambah_opname_manual.dart';
import 'package:invee2/penjualan/online/wishlist/wishlist.dart';
import 'package:invee2/penjualan/online/keranjang/keranjang.dart';
import 'package:invee2/penjualan/kasir/detail_cekstock.dart';

var routeX = <String, WidgetBuilder> {
  '/home' : (BuildContext context) => Home(),
  '/kasir' : (BuildContext context) => Kasir(),
  '/kasir/create_penjualan' : (BuildContext context) => TambahPenjualan(),
  '/login' : (BuildContext context) => LoginView(),
  '/antrian' : (BuildContext context) => AntrianLayanan(),
  '/penjualan_offline' : (BuildContext context) => PenjualanOffline(),
  '/penjualan_online' : (BuildContext context) => PenjualanOnline(),
  '/barang_keluar' : (BuildContext context) => BarangKeluar(),
  '/barang_masuk' : (BuildContext context) => BarangMasuk(),
  '/opname_stock' : (BuildContext context) => OpnameStock(),
  '/tambah_opname_manual' : (BuildContext context) => TambahOpnameManual(),
  '/penerimaan_barang' : (BuildContext context) => PenerimaanBarang(),
  '/wishlist' : (BuildContext context) => Wishlist(),
  '/keranjang' : (BuildContext context) => Keranjang(),
  '/detailetalase' : (BuildContext context) => DetailCek(),
  '/layanan_nota' : (BuildContext context) => LayananNota(),
  '/master_customer' : (BuildContext context) => MasterCustomer(),
};
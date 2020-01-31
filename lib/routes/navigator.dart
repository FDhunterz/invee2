import 'package:flutter/material.dart';

class MyNavigator {
  // Home
  static void goHome(BuildContext context) {
    
    Navigator.pushNamed(context, "/home");
  }
  
  // Kasir
  static void goKasir(BuildContext context) {
    
    Navigator.pushNamed(context, "/kasir");
  }
  static void goTambahPenjualan(BuildContext context) {
    
    Navigator.pushNamed(context, "/kasir/create_penjualan");
  }
  // End Kasir
  static void goLogin(BuildContext context) {
    
    Navigator.pushNamed(context, "/login");
  }
  static void goAntrian(BuildContext context) {
    
    Navigator.pushNamed(context, "/antrian");
  }
  static void goPenjualanOffline(BuildContext context) {
    
    Navigator.pushNamed(context, "/penjualan_offline");
  }
  static void goPenjualanOnline(BuildContext context) {
    
    Navigator.pushNamed(context, "/penjualan_online");
  }
  static void goBarangMasuk(BuildContext context) {
    
    Navigator.pushNamed(context, "/barang_masuk");
  }
  static void goBarangKeluar(BuildContext context) {
    
    Navigator.pushNamed(context, "/barang_keluar");
  }
  static void goOpnameStock(BuildContext context) {
    
    Navigator.pushNamed(context, "/opname_stock");
  }
  static void goPenerimaanBarang(BuildContext context) {
    
    Navigator.pushNamed(context, "/penerimaan_barang");
  }
  static void goTambahPenerimaan(BuildContext context) {

    Navigator.pushNamed(context, "/create_penerimaan");
  }
  static void goToWishlist(BuildContext context) {
    Navigator.pushNamed(context, "/wishlist");
  }
  static void goToKeranjang(BuildContext context) {
    Navigator.pushNamed(context, "/keranjang");
  }


}
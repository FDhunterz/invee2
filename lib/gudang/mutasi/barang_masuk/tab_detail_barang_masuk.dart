import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TabDetailBarangMasuk extends StatelessWidget {
  final String reffBarangKeluar,
      reffBarangMasuk,
      noResi,
      tglBarangMasuk,
      gudangPengirim,
      tanggalPengiriman,
      catatan;
  TabDetailBarangMasuk({
    @required this.reffBarangKeluar,
    @required this.reffBarangMasuk,
    @required this.noResi,
    @required this.catatan,
    @required this.gudangPengirim,
    @required this.tanggalPengiriman,
    @required this.tglBarangMasuk,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        child: Card(
          child: Container(
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: Text('No. Referensi Barang Keluar'),
                    ),
                    Expanded(
                      flex: 5,
                      child: reffBarangKeluar == null
                          ? Text('Belum ada')
                          : Text(reffBarangKeluar),
                    ),
                  ],
                ),
                Divider(),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: Text('No. Referensi Barang Masuk'),
                    ),
                    Expanded(
                      flex: 5,
                      child: reffBarangMasuk == null
                          ? Text('Belum ada')
                          : Text(reffBarangMasuk),
                    ),
                  ],
                ),
                Divider(),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: Text('No. Resi Pengiriman'),
                    ),
                    Expanded(
                      flex: 5,
                      child: Text(noResi),
                    ),
                  ],
                ),
                Divider(),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: Text('Tanggal Barang Masuk'),
                    ),
                    Expanded(
                      flex: 5,
                      child: tglBarangMasuk == null
                          ? Text('Proses Pengiriman', style: TextStyle(color: Colors.blue[700]),)
                          : Text(DateFormat('dd MMMM yyyy').format(DateTime.parse(tglBarangMasuk))),
                    ),
                  ],
                ),
                Divider(),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: Text('Gudang Pengirim'),
                    ),
                    Expanded(
                      flex: 5,
                      child: Text(gudangPengirim),
                    ),
                  ],
                ),
                Divider(),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: Text('Tanggal Pengiriman'),
                    ),
                    Expanded(
                      flex: 5,
                      child: Text(DateFormat('dd MMMM yyyy').format(DateTime.parse(tanggalPengiriman))),
                    ),
                  ],
                ),
                Divider(),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: Text('Catatan Pengiriman'),
                    ),
                    Expanded(
                      flex: 5,
                      child: Text(catatan),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

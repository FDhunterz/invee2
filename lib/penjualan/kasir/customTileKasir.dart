// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image/network.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:invee2/routes/env.dart';
import 'package:intl/intl.dart';

// ======================== Tile Detail Kasir ========================
class TileDetailKasir extends StatelessWidget {
  final String namaBarang,
      qty,
      namaSatuan,
      hargaBarang,
      totalHargaBarang,
      diskonPersen,
      diskonNilai,
      gambar;

  TileDetailKasir({
    this.gambar,
    this.hargaBarang,
    this.namaBarang,
    this.namaSatuan,
    this.qty,
    this.totalHargaBarang,
    this.diskonNilai,
    this.diskonPersen,
  });

  final NumberFormat numberFormat =
      NumberFormat.simpleCurrency(decimalDigits: 2, name: 'Rp. ');

  Widget cekHargaDiskon({
    String hargaBarang,
    String qtyBarang,
    String totalHargaBarang,
    String diskonPersen,
    String diskonNilai,
  }) {
    double hargaSetelahDiskonNilai,
        hargaSetelahDiskonPersen,
        hargaSebelumDiskon;

    hargaSebelumDiskon = double.parse(hargaBarang) * int.parse(qtyBarang);

    if (diskonPersen != "null") {
      if (int.parse(diskonPersen) != 0) {
        hargaSetelahDiskonPersen = hargaSebelumDiskon -
            (double.parse(totalHargaBarang) * (int.parse(diskonPersen) / 100));

        double diskonPersenX =
            hargaSebelumDiskon * (int.parse(diskonPersen) / 100);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(
              numberFormat.format(
                hargaSebelumDiskon,
              ),
              style: TextStyle(
                // decoration: TextDecoration.lineThrough,
                color: Colors.black54,
              ),
            ),
            Text('- ${numberFormat.format(diskonPersenX)}'),
            Text(
              numberFormat.format(double.parse(totalHargaBarang)),
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ],
        );
      }
    } else if (double.parse(diskonNilai) != 0) {
      hargaSetelahDiskonNilai = hargaSebelumDiskon - double.parse(diskonNilai);
      return Column(
        children: <Widget>[
          Text(
            numberFormat.format(
              hargaSebelumDiskon,
            ),
            style: TextStyle(
              // decoration: TextDecoration.lineThrough,
              color: Colors.black54,
            ),
          ),
          Text('- ${numberFormat.format(double.parse(diskonNilai))}'),
          Text(
            numberFormat.format(double.parse(totalHargaBarang)),
            style: TextStyle(
              color: Colors.red,
            ),
          ),
        ],
      );
    }
    return Text(
      numberFormat.format(double.parse(totalHargaBarang)),
      style: TextStyle(
        color: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.black54,
          width: 0.3,
        ),
        borderRadius: BorderRadius.circular(5.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[350],
            blurRadius: 1.0,
            offset: Offset(1.0, 1.0),
            spreadRadius: 1.0,
          ),
        ],
      ),
      margin: EdgeInsets.only(bottom: 5.0),
      child: ListTile(
        leading: CircleAvatar(
          radius: 20.0,
          backgroundColor: Colors.grey,
          // child:CachedNetworkImage(
          //   imageUrl: url('storage/image/master/produk/$gambar'),
          //   placeholder: (context, url) => CircularProgressIndicator(),
          //   errorWidget: (context, url, error) => Icon(Icons.error),
          // ),
          backgroundImage: NetworkImageWithRetry(
            url('storage/image/master/produk/$gambar'),
          ),
        ),
        title: Text(namaBarang),
        subtitle: Row(
          children: <Widget>[
            Text('$qty $namaSatuan '),
            Text(
              numberFormat.format(double.parse(hargaBarang)),
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ],
        ),
        trailing: cekHargaDiskon(
          diskonNilai: diskonNilai,
          diskonPersen: diskonPersen,
          totalHargaBarang: totalHargaBarang,
          hargaBarang: hargaBarang,
          qtyBarang: qty,
        ),
      ),
    );
  }
}

// =============================== Tambah Kasir Tile Daftar Produk ===============================

class TileTambahProdukKasir extends StatefulWidget {
  final String namaProduk, namaSatuan, hargaProduk, kodeProduk,errorText;
  final double totalHargaProduk;

  final Function onDelete;

  final Function(String) onQtyChange, onDiskonPersenChange, onDiskonNilaiChange;

  final TextEditingController diskonPersenController,
      diskonNilaiController,
      qtyController;

  final bool isDiskonPersen, isDiskonFilled;

  TileTambahProdukKasir({
    @required this.isDiskonFilled,
    @required this.isDiskonPersen,
    @required this.onDelete,
    @required this.hargaProduk,
    @required this.namaProduk,
    @required this.namaSatuan,
    @required this.totalHargaProduk,
    @required this.diskonNilaiController,
    @required this.diskonPersenController,
    @required this.qtyController,
    @required this.onDiskonNilaiChange,
    @required this.onDiskonPersenChange,
    @required this.onQtyChange,
    @required this.kodeProduk,
    @required this.errorText,
  });

  @override
  _TileTambahProdukKasirState createState() => _TileTambahProdukKasirState();
}

class _TileTambahProdukKasirState extends State<TileTambahProdukKasir> {
  NumberFormat numberFormat =
      NumberFormat.simpleCurrency(decimalDigits: 2, name: 'Rp. ');

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 2.0,
            right: 10.0,
            child: Semantics(
              child: Container(
                width: 40.0,
                child: RaisedButton(
                    padding: EdgeInsets.all(5.0),
                    color: Colors.red,
                    textColor: Colors.white,
                    child: Icon(
                      FontAwesomeIcons.times,
                      size: 20.0,
                    ),
                    onPressed: () {
                      widget.onDelete();
                    }),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(15.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Nama Produk',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Container(
                        // color: Colors.orange,
                        margin: EdgeInsets.only(
                          right: 50.0,
                        ),
                        child: Text(
                            '${widget.kodeProduk} - ${widget.namaProduk} (${widget.namaSatuan})'),
                      ),
                    ),
                  ],
                ),
                Divider(),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Harga',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Text(
                        numberFormat.format(
                          double.parse(widget.hargaProduk),
                        ),
                        textAlign: TextAlign.right,
                      ),
                    )
                  ],
                ),
                Divider(),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Diskon',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: '%',
                        ),
                        inputFormatters: <TextInputFormatter>[
                          WhitelistingTextInputFormatter.digitsOnly,
                        ],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        enabled: widget.isDiskonFilled == false
                            ? null
                            : widget.isDiskonPersen == true ? true : false,
                        controller: widget.diskonPersenController,
                        onChanged: (ini) {
                          widget.onDiskonPersenChange(ini);
                        },
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Diskon Nilai',
                        ),
                        inputFormatters: <TextInputFormatter>[
                          WhitelistingTextInputFormatter.digitsOnly,
                        ],
                        enabled: widget.isDiskonFilled == false
                            ? null
                            : widget.isDiskonPersen == false ? true : false,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.right,
                        controller: widget.diskonNilaiController,
                        onChanged: (ini) {
                          widget.onDiskonNilaiChange(ini);
                        },
                      ),
                    ),
                  ],
                ),
                Divider(),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Qty',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Qty',
                          errorText: widget.errorText,
                        ),
                        inputFormatters: <TextInputFormatter>[
                          WhitelistingTextInputFormatter.digitsOnly,
                        ],
                        textAlign: TextAlign.center,
                        controller: widget.qtyController,
                        keyboardType: TextInputType.number,
                        onChanged: (ini) {
                          widget.onQtyChange(ini);
                        },
                        
                      ),
                    ),
                  ],
                ),
                Divider(),
                Container(
                  height: 25.0,
                )
              ],
            ),
          ),
          Positioned(
            bottom: 15.0,
            right: 15.0,
            child: Container(
              // width: MediaQuery.of(context).size.width / 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(right: 5.0),
                    child: Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    numberFormat.format(widget.totalHargaProduk),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.red,
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

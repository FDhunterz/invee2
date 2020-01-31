import 'package:flutter/material.dart';
import 'package:invee2/error/error.dart';
import 'package:invee2/localStorage/localStorage.dart';
import 'package:invee2/penjualan/kasir/customTileKasir.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:invee2/penjualan/kasir/environment/model.dart';
import 'package:invee2/routes/env.dart';
import 'package:flutter/services.dart';

Map<String, String> requestHeaders = Map();
var tokenType, accessToken;

GlobalKey<ScaffoldState> _scaffoldKeyDP;

List<DetailProdukKasir> listProdukKasir;
String totalBelanja;

bool isLoading, isError;

int totalQty = 0;
double biayaOngkir, totalHarga;

showInSnackbarDP(String content) {
  _scaffoldKeyDP.currentState.showSnackBar(
    SnackBar(
      content: Text(content),
    ),
  );
}

class DetailPenjualan extends StatefulWidget {
  final String tanggalPembelian,
      namaCustomer,
      nota,
      statusPembayaran,
      statusPacking,
      statusDeliver,
      statusSetuju,
      metodePembayaran,
      provinsi,
      kabupatenKota,
      kodePos,
      alamat,
      tipePenjualan,
      biayaPengiriman,
      namaBank,
      noRekening,
      kecamatan,
      createAt,
      durasi,
      tanggalConfirmPacking,
      tanggalSelesaiPacking,
      userProsesPacking,
      userSelesaiPacking;

  DetailPenjualan({
    this.noRekening,
    this.namaBank,
    this.biayaPengiriman,
    this.tipePenjualan,
    this.metodePembayaran,
    this.tanggalPembelian,
    this.namaCustomer,
    this.nota,
    this.statusDeliver,
    this.statusPacking,
    this.statusPembayaran,
    this.statusSetuju,
    this.alamat,
    this.kabupatenKota,
    this.kecamatan,
    this.provinsi,
    this.kodePos,
    this.createAt,
    this.durasi,
    this.tanggalConfirmPacking,
    this.tanggalSelesaiPacking,
    this.userProsesPacking,
    this.userSelesaiPacking,
  });

  @override
  State<StatefulWidget> createState() {
    return _DetailPenjualanState();
  }
}

class _DetailPenjualanState extends State<DetailPenjualan> {
  NumberFormat numberFormat =
      NumberFormat.simpleCurrency(decimalDigits: 2, name: 'Rp. ');

  Future<Null> getHeaderHTTP() async {
    var storage = new DataStore();

    var tokenTypeStorage = await storage.getDataString('token_type');
    var accessTokenStorage = await storage.getDataString('access_token');

    tokenType = tokenTypeStorage;
    accessToken = accessTokenStorage;
    requestHeaders['Authorization'] = '$tokenType $accessToken';

    detailKasir();
  }

  detailKasir() async {
    setState(() {
      isLoading = true;
      isError = false;
    });
    try {
      final response = await http.post(
        url('api/detailKasir'),
        headers: requestHeaders,
        body: {
          'nota': widget.nota,
        },
      );

      if (response.statusCode == 200) {
        dynamic responseJson = jsonDecode(response.body);

        listProdukKasir = List<DetailProdukKasir>();
        totalBelanja = '';

        totalQty = 0;

        for (var data in responseJson) {
          double hargaDiskonPersen, hargaDiskonNilai, hargaX;
          int qty = data['sd_qty'] is int
              ? data['sd_qty']
              : int.tryParse(data['sd_qty']) ?? 0;
          totalQty += qty;
          hargaX = double.parse(data['sd_price']) * qty;
          print('hargaX $hargaX');
          if (double.parse(data['sd_discvalue']) != 0) {
            hargaDiskonNilai = double.parse(data['sd_discvalue']);
          } else {
            hargaDiskonNilai = 0;
          }
          print('hargaDiskonNilai $hargaDiskonNilai');

          int diskonPersen = data['sd_discpercent'] == null ? 0 : data['sd_discpercent'] is int
              ? data['sd_discpercent']
              : int.tryParse(data['sd_discpercent']) ?? 0;

          if (diskonPersen != 0) {
            hargaDiskonPersen = (hargaX * (diskonPersen / 100));
          } else {
            hargaDiskonPersen = 0;
          }
          print('hargaDiskonPersen $hargaDiskonPersen');

          totalHarga += hargaX - (hargaDiskonNilai + hargaDiskonPersen);

          listProdukKasir.add(
            DetailProdukKasir(
              hargaProduk: data['sd_price'],
              namaProduk: data['i_name'],
              namaSatuan: data['iu_name'],
              qty: qty.toString(),
              gambar: data['ip_path'],
              diskonPersen: data['sd_discpercent'].toString(),
              diskonNilai: data['sd_discvalue'],
              totalHarga: data['sd_total'],
            ),
          );
        }

        setState(() {
          totalBelanja = (totalHarga + biayaOngkir).toString();
          isLoading = false;
          isError = false;
          return listProdukKasir;
        });

        print('decoded $responseJson');
      } else {
        showInSnackbarDP('Error Code : ${response.statusCode}');
        Map responseJson = jsonDecode(response.body);

        if (responseJson.containsKey('message')) {
          showInSnackbarDP(responseJson['message']);
        }
        print(jsonDecode(response.body));
        setState(() {
          isLoading = false;
          isError = true;
        });
      }
    } on SocketException catch (_) {
      showInSnackbarDP('Host not found, check your connection');
      setState(() {
        isLoading = false;
        isError = true;
      });
    } on TimeoutException catch (_) {
      showInSnackbarDP('Request Timeout, try again');
      setState(() {
        isLoading = false;
        isError = true;
      });
    } catch (e, stacktrace) {
      print('Error = $e || StackTrace = $stacktrace');
      _scaffoldKeyDP.currentState.showBottomSheet(
        (BuildContext context) => Scrollbar(
          child: SingleChildScrollView(
            child: Container(
              child: Text(stacktrace.toString()),
            ),
          ),
        ),
      );
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  _print() async {
  }

  Widget _status({
    String statusPembayaran,
    String statusDeliver,
    String statusPacking,
    String statusSetuju,
    String metodePembayaran,
  }) {
    if (statusSetuju == 'C') {
      return Text(
        'Menunggu Konfirmasi',
        style: TextStyle(
          color: Colors.white,
          backgroundColor: Colors.orange,
        ),
      );
    }

    if (statusSetuju == 'N') {
      return Text(
        'Dibatalkan',
        style: TextStyle(
          color: Colors.white,
          backgroundColor: Colors.red,
        ),
      );
    }

    if (statusDeliver == 'Y') {
      return Text(
        'Transaksi Selesai',
        style: TextStyle(
          color: Colors.white,
          backgroundColor: Colors.green,
        ),
      );
    }

    if (statusDeliver == 'A' && statusPacking == 'Y') {
      return Text(
        'Ambil Sendiri',
        style: TextStyle(
          color: Colors.white,
          backgroundColor: Colors.cyan,
        ),
      );
    }

    if (statusDeliver == 'L') {
      return Text(
        'Pengiriman Terhambat',
        style: TextStyle(
          color: Colors.white,
          backgroundColor: Colors.red,
        ),
      );
    }

    if (statusDeliver == 'P') {
      return Text(
        'Sedang Dikirim',
        style: TextStyle(
          color: Colors.white,
          backgroundColor: Colors.cyan,
        ),
      );
    }

    if (statusPacking == 'Y') {
      return Text(
        'Packing Selesai',
        style: TextStyle(
          color: Colors.white,
          backgroundColor: Colors.blue,
        ),
      );
    }

    if (statusSetuju == 'Y') {
      return Text(
        'Proses Packing',
        style: TextStyle(
          color: Colors.white,
          backgroundColor: Colors.cyan,
        ),
      );
    }

    if (statusPembayaran == 'Y') {
      return Text(
        'Sudah Bayar',
        style: TextStyle(
          color: Colors.white,
          backgroundColor: Colors.cyan,
        ),
      );
    }

    if (statusPembayaran == 'N' &&
        statusSetuju == 'P' &&
        metodePembayaran == 'N') {
      return Text(
        'Sudah Pembayaran Tempo',
        style: TextStyle(
          color: Colors.white,
          backgroundColor: Colors.orange,
        ),
      );
    }

    if (statusPembayaran == 'N' &&
        statusSetuju == 'T' &&
        metodePembayaran == 'N') {
      return Text(
        'Pembayaran Tempo',
        style: TextStyle(
          color: Colors.white,
          backgroundColor: Colors.orange,
        ),
      );
    }

    if (statusPembayaran == 'N' && metodePembayaran == 'T') {
      return Text(
        'Pembayaran',
        style: TextStyle(
          color: Colors.white,
          backgroundColor: Colors.orange,
        ),
      );
    }
    return Text(
      'Ada yang salah',
      style: TextStyle(
        color: Colors.white,
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget tipePenjualan(String tipe) {
    if (tipe == 'ON') {
      return Text('Online');
    } else if (tipe == 'OFF') {
      return Text('Offline');
    }
    return Text('jenis Penjualan tidak Di ketahui');
  }

  Widget metodePembayaran({
    String statusPembayaran,
    String metodePembayaran,
    String namaBank,
    String noRekening,
    String statusSetuju,
  }) {
    if (statusPembayaran == 'N' && statusSetuju != 'P') {
      return Text('Belum melakukan pembayaran');
    } else if (metodePembayaran == 'N' &&
        namaBank == null &&
        noRekening == null &&
        statusPembayaran == 'Y') {
      return Text('Transfer');
    } else if (metodePembayaran == 'T') {
      return Text('Tunai');
    } else if (metodePembayaran == "N") {
      return Text('Tempo');
    } else if (metodePembayaran == "G") {
      return Text('Giro');
    }
    return Container();
  }

  @override
  void initState() {
    _scaffoldKeyDP = GlobalKey<ScaffoldState>();

    biayaOngkir = 0.0;

    biayaOngkir = widget.biayaPengiriman != null
        ? double.parse(widget.biayaPengiriman)
        : 0.0;

    print('nota ${widget.nota}');
    totalBelanja = '0';
    totalHarga = 0.0;

    listProdukKasir = List<DetailProdukKasir>();
    isLoading = true;
    isError = false;

    getHeaderHTTP();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      key: _scaffoldKeyDP,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.print),
        label: Text('Print ESC/POS'),
        onPressed: isLoading
            ? null
            : isError
                ? null
                : () {
                    _print();
                  },
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(15.0, 35.0, 15.0, 15.0),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.black54,
              width: 1,
            ),
          ),
          color: Colors.white,
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Total Belanja',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      numberFormat.format(
                        totalBelanja is double
                            ? totalBelanja
                            : double.tryParse(totalBelanja) ?? 0.00,
                      ),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 20.0,
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
      appBar: AppBar(
        title: Text('Detail Transaksi'),
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black54,
                        offset: Offset(1.0, 1.0),
                        blurRadius: 5.0,
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(15.0),
                  margin: EdgeInsets.only(
                    bottom: 10.0,
                  ),
                  child: Container(
                    padding: EdgeInsets.all(5.0),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Tanggal Pembelian',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Text(widget.tanggalPembelian != 'null'
                                  ? DateFormat('dd MMMM yyyy').format(
                                      DateTime.parse(widget.tanggalPembelian),
                                    )
                                  : 'Kosong'),
                            ),
                          ],
                        ),
                        Divider(),
                        Row(
                          children: <Widget>[
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Nomor Nota',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Text(widget.nota),
                            ),
                          ],
                        ),
                        Divider(),
                        Row(
                          children: <Widget>[
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Jenis Transaksi',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: tipePenjualan(widget.tipePenjualan),
                            ),
                          ],
                        ),
                        Divider(),
                        Row(
                          children: <Widget>[
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Metode Pembayaran',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: metodePembayaran(
                                metodePembayaran: widget.metodePembayaran,
                                namaBank: widget.namaBank,
                                noRekening: widget.noRekening,
                                statusPembayaran: widget.statusPembayaran,
                              ),
                            ),
                          ],
                        ),
                        Divider(),
                        Row(
                          children: <Widget>[
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Tanggal Transaksi dibuat',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Text(widget.createAt != 'null'
                                  ? DateFormat('dd MMMM yyyy hh:mm:ss').format(
                                      DateTime.parse(widget.createAt),
                                    )
                                  : 'Kosong'),
                            ),
                          ],
                        ),
                        Divider(),
                        Row(
                          children: <Widget>[
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Durasi Proses Packing',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Text(widget.durasi != 'null'
                                  ? '${widget.durasi} Menit'
                                  : 'Belum diproses'),
                            ),
                          ],
                        ),
                        Divider(),
                        Row(
                          children: <Widget>[
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Tanggal Proses Packing',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Text(widget.durasi != 'null'
                                  ? DateFormat('dd MMMM yyyy hh:mm:ss').format(
                                      DateTime.parse(
                                        widget.tanggalConfirmPacking,
                                      ),
                                    )
                                  : 'Belum diproses'),
                            ),
                          ],
                        ),
                        Divider(),
                        Row(
                          children: <Widget>[
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Perkiraan Packing selesai',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Text(widget.durasi != 'null'
                                  ? DateFormat('dd MMMM yyyy hh:mm:ss').format(
                                      DateTime.parse(
                                              widget.tanggalConfirmPacking)
                                          .add(
                                        Duration(
                                          minutes: int.parse(widget.durasi),
                                        ),
                                      ),
                                    )
                                  : 'Belum diproses'),
                            ),
                          ],
                        ),
                        Divider(),
                        Row(
                          children: <Widget>[
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Selesai proses packing',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Text(widget.tanggalSelesaiPacking != null
                                  ? DateFormat('dd MMMM yyyy hh:mm:ss').format(
                                      DateTime.parse(
                                          widget.tanggalSelesaiPacking),
                                    )
                                  : 'Belum Selesai'),
                            ),
                          ],
                        ),
                        Divider(),
                        Row(
                          children: <Widget>[
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Status Transaksi',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: _status(
                                statusDeliver: widget.statusDeliver,
                                statusPacking: widget.statusPacking,
                                statusPembayaran: widget.statusPembayaran,
                                statusSetuju: widget.statusSetuju,
                                metodePembayaran: widget.metodePembayaran,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                    bottom: 10.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black54,
                        offset: Offset(1.0, 1.0),
                        blurRadius: 3.0,
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(15.0),
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Text(
                          'Data Customer',
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        padding: EdgeInsets.only(
                          bottom: 20.0,
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 3,
                            child: Text(
                              'Nama Customer',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Text(widget.namaCustomer),
                          ),
                        ],
                      ),
                      Divider(),
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 3,
                            child: Text(
                              'Provinsi',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Text(widget.provinsi != null
                                ? widget.provinsi
                                : 'Kosong'),
                          ),
                        ],
                      ),
                      Divider(),
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 3,
                            child: Text(
                              'Kabupaten/Kota',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                              flex: 5,
                              child: Text(widget.kabupatenKota != null
                                  ? widget.kabupatenKota
                                  : 'Kosong')),
                        ],
                      ),
                      Divider(),
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 3,
                            child: Text(
                              'Kecamatan',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Text(widget.kecamatan != null
                                ? widget.kecamatan
                                : 'Kosong'),
                          ),
                        ],
                      ),
                      Divider(),
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 3,
                            child: Text(
                              'Kode Pos',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Text(widget.kodePos != null
                                ? widget.kodePos
                                : 'Kosong'),
                          ),
                        ],
                      ),
                      Divider(),
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 3,
                            child: Text(
                              'Alamat',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Text(widget.alamat != null
                                ? widget.alamat
                                : 'Kosong'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 3.0,
                        color: Colors.black54,
                        offset: Offset(1.0, 1.0),
                      )
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.all(15.0),
                        child: Text(
                          'Daftar Produk',
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Divider(),
                      isLoading == true
                          ? Container(
                              color: Colors.white,
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : isError == true
                              ? ErrorCobalLagi(
                                  onPress: getHeaderHTTP,
                                )
                              : Column(
                                  children: listProdukKasir.map((f) {
                                    return TileDetailKasir(
                                      namaBarang: f.namaProduk,
                                      hargaBarang: f.hargaProduk,
                                      namaSatuan: f.namaSatuan,
                                      qty: f.qty,
                                      totalHargaBarang: f.totalHarga,
                                      gambar: f.gambar,
                                      diskonNilai: f.diskonNilai,
                                      diskonPersen: f.diskonPersen,
                                    );
                                  }).toList(),
                                ),
                    ],
                  ),
                  margin: EdgeInsets.only(
                    bottom: 10.0,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(15.0),
                  margin: EdgeInsets.only(bottom: 70.0),
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(
                      blurRadius: 3.0,
                      color: Colors.black54,
                      offset: Offset(1.0, 1.0),
                    )
                  ]),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 3,
                            child: Text(
                              'Biaya Ongkir',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Text(
                              numberFormat.format(biayaOngkir),
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.all(7.0),
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 3,
                            child: Text(
                              'Total Harga ($totalQty Qty)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Text(
                              numberFormat.format(totalHarga),
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Divider(),
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 3,
                            child: Text(
                              'Total Belanja',
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Text(
                              numberFormat.format(
                                double.parse(totalBelanja),
                              ),
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 20.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

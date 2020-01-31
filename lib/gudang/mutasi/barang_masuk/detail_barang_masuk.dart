import 'package:flutter/material.dart';
import 'package:invee2/error/error.dart';
import 'package:invee2/gudang/mutasi/barang_masuk/customTileBarangMasuk.dart';
import 'package:invee2/gudang/mutasi/barang_masuk/model.dart';
import 'package:invee2/gudang/mutasi/barang_masuk/proses_barang_masuk.dart';
import 'package:invee2/gudang/mutasi/barang_masuk/tab_detail_barang_masuk.dart';
import 'package:invee2/localStorage/localStorage.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
// import 'dart:io';

import 'package:invee2/routes/env.dart';

GlobalKey<ScaffoldState> _scaffoldBM;
TabController _tabController;

String tokenType, accessToken;
Map<String, String> requestHeaders = Map();

List<Produk> listProduk;
bool isLoading, isError;

bool userAksesMenuBarangMasuk, userGroupAksesMenuBarangMasuk;

showInSnackbarBM(String title) {
  _scaffoldBM.currentState.showSnackBar(
    SnackBar(
      content: Text(title),
    ),
  );
}

class DetailBarangMasuk extends StatefulWidget {
  final String reffBarangKeluar,
      reffBarangMasuk,
      resi,
      tglBarangMasuk,
      gudangPengirim,
      tglPengiriman,
      status,
      catatanPengiriman;

  DetailBarangMasuk({
    @required this.catatanPengiriman,
    @required this.gudangPengirim,
    @required this.reffBarangKeluar,
    @required this.reffBarangMasuk,
    @required this.resi,
    @required this.tglBarangMasuk,
    @required this.tglPengiriman,
    @required this.status,
  });

  @override
  _DetailBarangMasukState createState() => _DetailBarangMasukState();
}

class _DetailBarangMasukState extends State<DetailBarangMasuk>
    with SingleTickerProviderStateMixin {
  Widget floatingActionButton(status) {
    if (userAksesMenuBarangMasuk || userGroupAksesMenuBarangMasuk) {
      if (status == 'true') {
        return FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                settings: RouteSettings(name: '/proses_barang_masuk'),
                builder: (BuildContext context) => ProsesBarangMasuk(
                  catatanPengiriman: widget.catatanPengiriman,
                  gudangPengirim: widget.gudangPengirim,
                  reffBarangKeluar: widget.reffBarangKeluar,
                  reffBarangMasuk: widget.reffBarangMasuk,
                  resi: widget.resi,
                  tglPengiriman: widget.tglPengiriman,
                ),
              ),
            );
          },
          child: Icon(Icons.input),
        );
      }
      return Container();
    }
    return Container();
  }

  Future<Null> getHeaderHTTP() async {
    var storage = new DataStore();

    var tokenTypeStorage = await storage.getDataString('token_type');
    var accessTokenStorage = await storage.getDataString('access_token');

    // setState(() {
    tokenType = tokenTypeStorage;
    accessToken = accessTokenStorage;

    requestHeaders['Accept'] = 'application/json';
    requestHeaders['Authorization'] = '$tokenType $accessToken';
    print(requestHeaders);
    // });

    detailBarangMasukAndroid();
  }

  Future<Null> detailBarangMasukAndroid() async {
    setState(() {
      isLoading = true;
      isError = false;
    });
    try {
      final response = await http.post(
        url('api/detailBarangMasukAndroid'),
        headers: requestHeaders,
        body: {
          'ref': widget.reffBarangMasuk,
        },
      );

      if (response.statusCode == 200) {
        dynamic responseJson = jsonDecode(response.body);

        print(responseJson);

        listProduk = List<Produk>();

        for (int i = 0; i < responseJson.length; i++) {
          listProduk.add(
            Produk(
              namaProduk: responseJson[i]['i_name'],
              namaSatuan: responseJson[i]['iu_name'],
              namaGudangPeminta: responseJson[i]['w_name'],
              jumlahDisetujui: "${responseJson[i]['om_qtyconfirm']}",
              stokGudang: "${responseJson[i]['rm_laststock']}",
              jumlahDiterima: "${responseJson[i]['im_instock']}",
              informasiKekurangan: responseJson[i]['im_lessinfo'],
              jumlahDiminta: "${responseJson[i]['rm_requestqty']}",
            ),
          );
        }

        setState(() {
          isLoading = false;
          isError = false;
        });
      } else if (response.statusCode == 401) {
        showInSnackbarBM(
            'Token kedaluwarsa, silahkan logout dan login kembali');
      } else {
        showInSnackbarBM('Error Code: ${response.statusCode}');
        Map responseJson = jsonDecode(response.body);

        if(responseJson.containsKey('message')){
          showInSnackbarBM(responseJson['message']);
        }
        print('print response.body ${jsonDecode(response.body)}');
        setState(() {
          isLoading = false;
          isError = true;
        });
      }
    } on TimeoutException catch (_) {
      showInSnackbarBM('Timedout, try again');
      setState(() {
        isLoading = false;
        isError = true;
      });
    } catch (e, stacktrace) {
      print('Error : $e || Stactrace : $stacktrace');
      showInSnackbarBM('Error Hubungi Pengembang Aplikasi');
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  getUserAksesDanGroupAkses() async {
    DataStore store = new DataStore();

    userAksesMenuBarangMasuk = await store
        .getDataBool('Barang Masuk dari Mutasi Antar Gudang Edit (Akses)');
    userGroupAksesMenuBarangMasuk = await store
        .getDataBool('Barang Masuk dari Mutasi Antar Gudang Edit (Group)');

    setState(() {
      userAksesMenuBarangMasuk = userAksesMenuBarangMasuk;
      userGroupAksesMenuBarangMasuk = userGroupAksesMenuBarangMasuk;
    });
  }

  @override
  void initState() {
    isLoading = true;
    isError = false;
    _tabController = TabController(vsync: this, length: 2);
    _scaffoldBM = GlobalKey<ScaffoldState>();
    userAksesMenuBarangMasuk = false;
    userGroupAksesMenuBarangMasuk = false;

    getUserAksesDanGroupAkses();
    getHeaderHTTP();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      floatingActionButton: floatingActionButton(widget.status),
      appBar: AppBar(
        title: Text('Detail Barang Masuk'),
        bottom: TabBar(
          isScrollable: true,
          controller: _tabController,
          tabs: <Widget>[
            Tab(
              icon: Icon(Icons.input),
              text: 'Detail Barang Masuk',
            ),
            Tab(
              icon: Icon(Icons.list),
              text: 'Daftar Barang Masuk',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          isLoading == true
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : isError == true
                  ? ErrorCobalLagi(
                      onPress: detailBarangMasukAndroid,
                    )
                  : TabDetailBarangMasuk(
                      catatan: widget.catatanPengiriman,
                      gudangPengirim: widget.gudangPengirim,
                      noResi: widget.resi,
                      reffBarangKeluar: widget.reffBarangKeluar,
                      reffBarangMasuk: widget.reffBarangMasuk,
                      tanggalPengiriman: widget.tglPengiriman,
                      tglBarangMasuk: widget.tglBarangMasuk,
                    ),
          isLoading == true
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : isError == true
                  ? ErrorCobalLagi(
                      onPress: detailBarangMasukAndroid,
                    )
                  : ListView.builder(
                      itemCount: listProduk.length,
                      itemBuilder: (BuildContext context, int i) {
                        // print('builder');
                        // print('${listProduk[i].jumlahDiterima}');
                        int hitungKurang;
                        if (listProduk[i].jumlahDiterima != 'null') {
                          hitungKurang =
                              int.parse(listProduk[i].jumlahDisetujui) -
                                  int.parse(listProduk[i].jumlahDiterima);
                        }
                        // print('builder 22');

                        return TileDetailBarangMasuk(
                          namaProduk: listProduk[i].namaProduk,
                          gudangPeminta: listProduk[i].namaGudangPeminta,
                          informasiKekurangan:
                              listProduk[i].jumlahDiterima != 'null'
                                  ? listProduk[i].informasiKekurangan
                                  : '(Belum ada)',
                          namaSatuan: listProduk[i].namaSatuan,
                          jumlahDisetujui: listProduk[i].jumlahDisetujui,
                          jumlahDiterima: listProduk[i].jumlahDiterima != 'null'
                              ? listProduk[i].jumlahDiterima
                              : '0',
                          kurang: listProduk[i].jumlahDiterima != 'null'
                              ? hitungKurang.toString()
                              : listProduk[i].jumlahDisetujui,
                          stokGudang: listProduk[i].stokGudang,
                          jumlahDiminta: listProduk[i].jumlahDiminta,
                        );
                      },
                    ),
        ],
      ),
    );
  }
}

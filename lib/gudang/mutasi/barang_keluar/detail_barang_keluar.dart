import 'package:flutter/material.dart';
import 'package:invee2/error/error.dart';
import 'package:invee2/gudang/mutasi/barang_keluar/customtile_barangkeluar.dart';
import 'package:invee2/gudang/mutasi/barang_keluar/model.dart';
import 'package:invee2/gudang/mutasi/barang_keluar/proses_barang_keluar.dart';
import 'package:invee2/localStorage/localStorage.dart';
import 'package:http/http.dart' as http;
import 'package:invee2/routes/env.dart';
import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
// import 'dart:io';

String tokenType, accessToken;
Map<String, String> requestHeaders = Map();

List<Produk> listProduk;
bool isLoading, isError;

String gudangDiminta;
GlobalKey<ScaffoldState> _scaffoldKeyBK;

bool userAksesMenuBarangKeluar, userGroupAksesMenuBarangKeluar;

showInSnackBarBK(String content) {
  _scaffoldKeyBK.currentState.showSnackBar(
    SnackBar(
      content: Text(content),
    ),
  );
}

class DetailBarangKeluar extends StatefulWidget {
  final String ref, tanggal, gudang, idGudang, statusData;
  DetailBarangKeluar({
    @required this.ref,
    @required this.tanggal,
    @required this.gudang,
    @required this.idGudang,
    @required this.statusData,
  });
  @override
  _DetailBarangKeluarState createState() => _DetailBarangKeluarState();
}

class _DetailBarangKeluarState extends State<DetailBarangKeluar> {
  Widget floatingActionButton(String statusData) {
    if (userAksesMenuBarangKeluar || userGroupAksesMenuBarangKeluar) {
      if (statusData == 'true') {
        return FloatingActionButton(
          child: Icon(Icons.input),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  settings: RouteSettings(name: '/proses_barang_keluar'),
                  builder: (BuildContext context) => ProsesBarangKeluar(
                    ref: widget.ref,
                    gudang: widget.gudang,
                    idGudang: widget.idGudang,
                  ),
                ));
          },
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
    detailBarangKeluar();
  }

  void detailBarangKeluar() async {
    setState(() {
      isLoading = true;
      isError = false;
    });
    try {
      final response = await http.post(
        url('api/detailBarangKeluar'),
        headers: requestHeaders,
        body: {
          "ref": widget.ref,
        },
      );

      if (response.statusCode == 200) {
        dynamic responseJson = jsonDecode(response.body);
        listProduk = List<Produk>();

        for (int i = 0; i < responseJson['data'].length; i++) {
          Produk produk = Produk(
            idRequestMutasi: '${responseJson['data'][i]['rm_id']}',
            namaProduk: responseJson['data'][i]['i_name'],
            namaSatuan: responseJson['data'][i]['iu_name'],
            kodeSatuan: responseJson['data'][i]['iu_code'],
            gudangPeminta: responseJson['data'][i]['w_name'],
            idGudangPeminta: responseJson['data'][i]['w_code'],
            idGudangDiminta: widget.idGudang,
            gudangDiminta: widget.gudang,
            codeProduk: responseJson['data'][i]['i_code'],
            stokDiminta: '${responseJson['data'][i]['rm_requestqty']}',
            stokGudangDiminta: '${responseJson['data'][i]['st_qty']}',
            statusData: responseJson['data'][i]['status_data'],
          );
          listProduk.add(produk);
        }
        print('listProduk $listProduk');
        setState(() {
          gudangDiminta = responseJson['data'][0]['w_name'];
          isLoading = false;
          isError = false;
        });
      } else if (response.statusCode == 401) {
        showInSnackBarBK(
            'Token kedaluwarsa, silahkan logout dan login kembali');
      } else {
        setState(() {
          isLoading = false;
          isError = true;
        });
        print('Error Code : ${response.statusCode}');
        showInSnackBarBK('Error Code : ${response.statusCode}');
        Map responseJson = jsonDecode(response.body);

        if(responseJson.containsKey('message')){
          showInSnackBarBK(responseJson['message']);
        }
      }
    } catch (e, stacktrace) {
      setState(() {
        isLoading = false;
        isError = true;
      });
      print("Error code : $e || StackTrace : $stacktrace");
    }
  }

  getUserAksesDanGroupAkses() async {
    DataStore store = new DataStore();

    userAksesMenuBarangKeluar = await store
        .getDataBool('Barang Keluar untuk Mutasi Antar Gudang Edit (Akses)');
    userGroupAksesMenuBarangKeluar = await store
        .getDataBool('Barang Keluar untuk Mutasi Antar Gudang Edit (Group)');

    setState(() {
      userAksesMenuBarangKeluar = userAksesMenuBarangKeluar;
      userGroupAksesMenuBarangKeluar = userGroupAksesMenuBarangKeluar;
    });
  }

  @override
  void initState() {
    isLoading = false;
    isError = false;
    gudangDiminta = '- Loading -';
    userAksesMenuBarangKeluar = false;
    userGroupAksesMenuBarangKeluar = false;

    listProduk = List<Produk>();

    getUserAksesDanGroupAkses();
    getHeaderHTTP();
    _scaffoldKeyBK = GlobalKey<ScaffoldState>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKeyBK,
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text('Detail Request Mutasi Antar Gudang'),
      ),
      floatingActionButton: floatingActionButton(widget.statusData),
      body: Column(
        children: <Widget>[
          Container(
            child: Card(
              child: Container(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          flex: 3,
                          child: Container(
                            child: Text(
                              'No. Request Mutasi',
                              style: TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Container(
                            child: Text(widget.ref),
                          ),
                        ),
                      ],
                    ),
                    Divider(),
                    Row(
                      children: <Widget>[
                        Expanded(
                          flex: 3,
                          child: Container(
                            child: Text(
                              'Gudang diminta',
                              style: TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Container(
                            child: Text(widget.gudang),
                          ),
                        ),
                      ],
                    ),
                    Divider(),
                    Row(
                      children: <Widget>[
                        Expanded(
                          flex: 3,
                          child: Container(
                            child: Text(
                              'Gudang peminta',
                              style: TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Container(
                            child: Text(gudangDiminta),
                          ),
                        ),
                      ],
                    ),
                    Divider(),
                    Row(
                      children: <Widget>[
                        Expanded(
                          flex: 3,
                          child: Container(
                            child: Text(
                              'Tanggal Pengiriman',
                              style: TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Container(
                            child: widget.tanggal != null
                                ? Text(
                                    DateFormat('dd MMMM yyyy')
                                        .format(DateTime.parse(widget.tanggal)),
                                    style: TextStyle(color: Colors.blue[700]),
                                  )
                                : Text(
                                    'Belum dikirim',
                                    style: TextStyle(color: Colors.orange),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(10.0),
            color: Colors.green,
            width: MediaQuery.of(context).size.width,
            child: Text(
              'Daftar Produk',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
              ),
            ),
          ),
          Expanded(
            child: isLoading == true
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : isError == true
                    ? Center(
                        child: Card(
                          child: ErrorCobalLagi(
                            onPress: () {
                              detailBarangKeluar();
                            },
                          ),
                        ),
                      )
                    : Scrollbar(
                        child: ListView.builder(
                          itemCount: listProduk.length,
                          padding: EdgeInsets.only(
                            bottom: 100.0,
                          ),
                          itemBuilder: (BuildContext context, int i) {
                            return TileDetailBarangKeluar(
                              namaProduk: listProduk[i].namaProduk,
                              satuan: listProduk[i].namaSatuan,
                              stokDiminta: listProduk[i].stokDiminta,
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

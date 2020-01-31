import 'dart:convert';
import 'dart:io';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:invee2/localStorage/localStorage.dart';
import 'package:invee2/penjualan/kasir/environment/model.dart';
import 'package:invee2/penjualan/kasir/tambah_penjualan.dart';
import 'package:invee2/routes/env.dart';
import 'dart:async';
// import 'package:invee2/routes/navigator.dart';
import '../../shimmer_loading.dart';
import 'package:http/http.dart' as http;
import './detail_penjualan.dart';

String tokenType, accessToken;
Map<String, String> requestHeaders = Map();
bool isLoading;
GlobalKey<ScaffoldState> _scaffoldKeyK;
int pageSize;

List<ListKasir> listKasirX;
PagewiseLoadController pagewiseKasirController;

bool userAksesMenuKasirCreate,
    userGroupAksesMenuKasirCreate,
    userAksesMenuKasirDelete,
    userGroupAksesMenuKasirDelete,
    userGroupAksesMenuKasirEdit,
    userAksesMenuKasirEdit;

showInSnackbarK(String title) {
  _scaffoldKeyK.currentState.showSnackBar(
    SnackBar(
      content: Text(title),
    ),
  );
}

class TabPenjualan extends StatefulWidget {
  final bool userAksesMenuKasirCreate,
      userGroupAksesMenuKasirCreate,
      userAksesMenuKasirDelete,
      userGroupAksesMenuKasirDelete,
      userGroupAksesMenuKasirEdit,
      userAksesMenuKasirEdit;

  TabPenjualan({
    this.userAksesMenuKasirCreate,
    this.userAksesMenuKasirDelete,
    this.userGroupAksesMenuKasirCreate,
    this.userGroupAksesMenuKasirDelete,
    this.userAksesMenuKasirEdit,
    this.userGroupAksesMenuKasirEdit,
  });

  @override
  State<StatefulWidget> createState() {
    return _TabPenjualanState();
  }
}

class _TabPenjualanState extends State<TabPenjualan> {
  List<String> items;
  String filter;
  TextEditingController searchInput = TextEditingController();

  Future<List<ListKasir>> listKasir({index}) async {
    DataStore store = new DataStore();

    String tokenTypeStorage = await store.getDataString('token_type');
    String accessTokenStorage = await store.getDataString('access_token');

    tokenType = tokenTypeStorage;
    accessToken = accessTokenStorage;

    requestHeaders['Accept'] = 'application/json';
    requestHeaders['Authorization'] = '$tokenType $accessToken';

    userAksesMenuKasirCreate = await store.getDataBool('Kasir Create (Akses)');
    userGroupAksesMenuKasirCreate =
        await store.getDataBool('Kasir Create (Group)');

    userAksesMenuKasirDelete = await store.getDataBool('Kasir Delete (Akses)');
    userGroupAksesMenuKasirDelete =
        await store.getDataBool('Kasir Delete (Group)');

    userAksesMenuKasirEdit = await store.getDataBool('Kasir Edit (Akses)');
    userGroupAksesMenuKasirEdit = await store.getDataBool('Kasir Edit (Group)');

    setState(() {
      userAksesMenuKasirCreate = userAksesMenuKasirCreate;
      userGroupAksesMenuKasirCreate = userGroupAksesMenuKasirCreate;
      userAksesMenuKasirEdit = userAksesMenuKasirEdit;
      userGroupAksesMenuKasirEdit = userGroupAksesMenuKasirEdit;
      userAksesMenuKasirDelete = userAksesMenuKasirDelete;
      userGroupAksesMenuKasirDelete = userGroupAksesMenuKasirDelete;
    });

    // print(requestHeaders);
    Map<String, String> requestBody = Map();
    requestBody['index'] = index.toString();
    requestBody['size'] = pageSize.toString();
    try {
      final response = await http.post(
        url('api/listKasir'),
        headers: requestHeaders,
        body: requestBody,
      );

      if (response.statusCode == 200) {
        dynamic responseJson = jsonDecode(response.body);

        listKasirX = List<ListKasir>();

        for (var data in responseJson) {
          listKasirX.add(
            ListKasir(
              idNota: data['s_id'].toString(),
              kodeNota: data['s_nota'],
              namaCustomer: data['cm_name'],
              statusDeliver: data['s_delivered'],
              statusPacking: data['s_packing'],
              statusPembayaran: data['s_paystatus'],
              statusSetuju: data['s_isapprove'],
              metodePembayaran: data['s_paymethod'],
              kabupatenKota: data['c_nama'],
              kecamatan: data['d_nama'],
              provinsi: data['p_nama'],
              tanggalPembelian: data['s_date'],
              kodePos: data['s_postalcode'],
              alamat: data['s_address'],
              tipePenjualan: data['s_category'],
              biayaPengiriman: data['s_payexpedition'],
              namaBank: data['s_detailpay'],
              noRekening: data['s_bankcode'],
              createAt: data['s_created_at'],
              durasi: data['s_duration'].toString(),
              tanggalConfirmPacking: data['s_prosespacking_at'],
              tanggalSelesaiPacking: data['s_selesaipacking_at'],
              confirmPackingBy: data['user_confirm_packing'],
              donePackingBy: data['user_done_packing'],
            ),
          );
        }
        print(responseJson);
        return listKasirX;
      } else if (response.statusCode == 401) {
        showInSnackbarK('Token kedaluwarsa, silahkan logout dan login kembali');
      } else {
        showInSnackbarK('Error Code : ${response.statusCode}');
        Map responseJson = jsonDecode(response.body);

        if (responseJson.containsKey('message')) {
          showInSnackbarK(responseJson['message']);
        }
        print(jsonDecode(response.body));
        // showModalBottomSheet(
        //   context: context,
        //   builder: (BuildContext context) => Scrollbar(
        //     child: SingleChildScrollView(
        //       child: Container(
        //         child: Text(jsonDecode(response.body)),
        //       ),
        //     ),
        //   ),
        // );

      }
    } on SocketException catch (_) {
      showInSnackbarK('Host not found, check your connection');
    } on TimeoutException catch (_) {
      showInSnackbarK('Request Timeout, try again');
    } catch (e, stacktrace) {
      print('Error : $e || Stacktrace : $stacktrace');
      showInSnackbarK('Error : ${e.toString()}');
      // showModalBottomSheet(
      //   context: context,
      //   builder: (BuildContext context) => Scrollbar(
      //     child: SingleChildScrollView(
      //       child: Container(
      //         child: Text(stacktrace.toString()),
      //       ),
      //     ),
      //   ),
      // );

    }
    return null;
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

  Widget floatingActionButton() {
    if (userAksesMenuKasirCreate || userGroupAksesMenuKasirCreate) {
      return FloatingActionButton(
        onPressed: () async {
          // MyNavigator.goTambahPenjualan(context);
          dynamic fromCreatePenjualan = await Navigator.push(
            context,
            MaterialPageRoute(
              settings: RouteSettings(
                name: '/kasir/create_penjualan',
              ),
              builder: (BuildContext context) => TambahPenjualan(),
            ),
          );

          if (fromCreatePenjualan == null || fromCreatePenjualan != null) {
            swipDownToRefresh();
          }
        },
        child: Icon(Icons.add),
      );
    }
    return Container();
  }

  tolakPenjualan(String idPenjualan) async {
    try {
      final response = await http.post(
        url('api/tolakPenjualan'),
        body: {
          'id': idPenjualan,
        },
        headers: requestHeaders,
      );

      if (response.statusCode == 200) {
        dynamic responseJson = jsonDecode(response.body);

        print(responseJson);

        if (responseJson['status'] == 'sukses') {
          swipDownToRefresh();
          showInSnackbarK('Sukses, data berhasil diupdate');
        } else if (responseJson['status'] == 'gagal') {
          showInSnackbarK('Gagal, ${responseJson['message']}');
        }
      } else if (response.statusCode == 401) {
        showInSnackbarK('Token kedaluwarsa, silahkan logout dan login kembali');
      } else {
        showInSnackbarK('Error Code : ${response.statusCode}');
        Map responseJson = jsonDecode(response.body);

        if (responseJson.containsKey('message')) {
          showInSnackbarK(responseJson['message']);
        }
        print(jsonDecode(response.body));
      }
    } catch (e) {
      print('Error : ${e.toString()}');
      showInSnackbarK('Error : ${e.toString()}');
    }
  }

  konfirmPenjualan(String idPenjualan) async {
    try {
      final response = await http.post(
        url('api/confirmKasir'),
        body: {
          'id': idPenjualan,
        },
        headers: requestHeaders,
      );

      if (response.statusCode == 200) {
        dynamic responseJson = jsonDecode(response.body);

        print(responseJson);

        if (responseJson['status'] == 'sukses') {
          swipDownToRefresh();
          showInSnackbarK('Sukses, data berhasil diupdate');
        } else if (responseJson['status'] == 'gagal') {
          showInSnackbarK('Gagal, ${responseJson['message']}');
        }
      } else if (response.statusCode == 401) {
        showInSnackbarK('Token kedaluwarsa, silahkan logout dan login kembali');
      } else {
        showInSnackbarK('Error Code : ${response.statusCode}');
        Map responseJson = jsonDecode(response.body);

        if (responseJson.containsKey('message')) {
          showInSnackbarK(responseJson['message']);
        }
        print(jsonDecode(response.body));
      }
    } catch (e) {
      print('Error : ${e.toString()}');
      showInSnackbarK('Error : ${e.toString()}');
    }
  }

  penjualanSelesai(String idPenjualan) async {
    try {
      final response = await http.post(
        url('api/penjualanSelesai'),
        body: {
          'id': idPenjualan,
        },
        headers: requestHeaders,
      );

      if (response.statusCode == 200) {
        dynamic responseJson = jsonDecode(response.body);

        print(responseJson);

        if (responseJson['status'] == 'sukses') {
          swipDownToRefresh();
          showInSnackbarK('Sukses, data berhasil diupdate');
        } else if (responseJson['status'] == 'gagal') {
          showInSnackbarK('Gagal, ${responseJson['message']}');
        }
      } else if (response.statusCode == 401) {
        showInSnackbarK('Token kedaluwarsa, silahkan logout dan login kembali');
      } else {
        showInSnackbarK('Error Code : ${response.statusCode}');
        Map responseJson = jsonDecode(response.body);

        if (responseJson.containsKey('message')) {
          showInSnackbarK(responseJson['message']);
        }
        print(jsonDecode(response.body));
      }
    } catch (e) {
      print('Error : ${e.toString()}');
      showInSnackbarK('Error : ${e.toString()}');
    }
  }

  int totalRefresh = 0;
  swipDownToRefresh() async {
    pagewiseKasirController.reset();
    Future.value({});
  }

  @override
  initState() {
    userAksesMenuKasirCreate = false;
    userGroupAksesMenuKasirCreate = false;
    userAksesMenuKasirEdit = false;
    userGroupAksesMenuKasirEdit = false;
    userAksesMenuKasirDelete = false;
    userGroupAksesMenuKasirDelete = false;

    pageSize = 12;
    _scaffoldKeyK = GlobalKey<ScaffoldState>();
    isLoading = false;
    pagewiseKasirController = PagewiseLoadController(
      pageSize: pageSize,
      pageFuture: (index) {
        return listKasir(index: index);
      },
    );

    super.initState();
  }

  @override
  void dispose() {
    searchInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKeyK,
      body: RefreshIndicator(
        onRefresh: () => swipDownToRefresh(),
        child: Scrollbar(
          child: PagewiseListView(
            pageLoadController: pagewiseKasirController,
            noItemsFoundBuilder: (BuildContext context) => ListTile(
              title: Text(
                'Tidak ada data',
                textAlign: TextAlign.center,
              ),
            ),
            loadingBuilder: (BuildContext context) {
              return ShimmerLoadingList();
            },
            itemBuilder: (BuildContext context, dynamic listKasir, int i) {
              return Card(
                child: ListTile(
                  title: Text(listKasir.kodeNota),
                  subtitle: Text(listKasir.namaCustomer),
                  leading: Icon(Icons.note),
                  trailing: Column(
                    children: <Widget>[
                      _status(
                        statusDeliver: listKasir.statusDeliver,
                        statusPacking: listKasir.statusPacking,
                        statusPembayaran: listKasir.statusPembayaran,
                        statusSetuju: listKasir.statusSetuju,
                        metodePembayaran: listKasir.metodePembayaran,
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
                        child: Column(
                          children: <Widget>[
                            Text(
                              DateFormat('dd MMMM y').format(
                                DateTime.parse(
                                    '${listKasir.tanggalPembelian} 00:00:00.000'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Aksi'),
                          actions: <Widget>[
                            FlatButton(
                              // color: Colors.orange,
                              textColor: Colors.cyan,
                              onPressed: () async {
                                Navigator.pop(context);
                                dynamic keDetailPenjualan = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    settings: RouteSettings(
                                        name: '/detail_penjualan'),
                                    builder: (BuildContext context) =>
                                        DetailPenjualan(
                                      namaCustomer: listKasir.namaCustomer,
                                      nota: listKasir.kodeNota,
                                      statusDeliver: listKasir.statusDeliver,
                                      statusPacking: listKasir.statusPacking,
                                      statusPembayaran:
                                          listKasir.statusPembayaran,
                                      statusSetuju: listKasir.statusSetuju,
                                      tanggalPembelian:
                                          listKasir.tanggalPembelian,
                                      alamat: listKasir.alamat,
                                      kabupatenKota: listKasir.kabupatenKota,
                                      kecamatan: listKasir.kecamatan,
                                      kodePos: listKasir.kodePos,
                                      provinsi: listKasir.provinsi,
                                      metodePembayaran:
                                          listKasir.metodePembayaran,
                                      biayaPengiriman:
                                          listKasir.biayaPengiriman,
                                      tipePenjualan: listKasir.tipePenjualan,
                                      createAt: listKasir.createAt,
                                      durasi: listKasir.durasi,
                                      tanggalConfirmPacking:
                                          listKasir.tanggalConfirmPacking,
                                      tanggalSelesaiPacking:
                                          listKasir.tanggalSelesaiPacking,
                                      userProsesPacking: listKasir.confirmPackingBy,
                                      userSelesaiPacking: listKasir.donePackingBy,
                                    ),
                                  ),
                                );

                                if(keDetailPenjualan == null || keDetailPenjualan != null){
                                  swipDownToRefresh();
                                }
                              },
                              child: Text('Detail'),
                            ),
                            if (userAksesMenuKasirDelete ||
                                userGroupAksesMenuKasirDelete)
                              if (listKasir.statusSetuju == 'C')
                                RaisedButton(
                                  color: Colors.red,
                                  textColor: Colors.white,
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          AlertDialog(
                                        title: Text('Peringatan'),
                                        content: Text(
                                            'Apa anda yakin membatalkan transaksi ini?'),
                                        actions: <Widget>[
                                          FlatButton(
                                            child: Text(
                                              'Tidak',
                                              style: TextStyle(
                                                color: Colors.black54,
                                              ),
                                            ),
                                            onPressed: () {
                                              Navigator.popUntil(
                                                  context,
                                                  ModalRoute.withName(
                                                      '/kasir'));
                                            },
                                          ),
                                          FlatButton(
                                            child: Text('Ya'),
                                            onPressed: () {
                                              Navigator.popUntil(
                                                  context,
                                                  ModalRoute.withName(
                                                      '/kasir'));
                                              tolakPenjualan(listKasir.idNota);
                                            },
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                  child: Text('Batalkan'),
                                ),
                            if (userAksesMenuKasirEdit ||
                                userGroupAksesMenuKasirEdit)
                              if (userAksesMenuKasirEdit ||
                                  userGroupAksesMenuKasirEdit)
                                if (listKasir.statusSetuju == 'C')
                                  FlatButton(
                                    textColor: Colors.green,
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            AlertDialog(
                                          title: Text('Peringatan'),
                                          content: Text(
                                              'Apa anda yakin menkonfirmasi transaksi ini?'),
                                          actions: <Widget>[
                                            FlatButton(
                                              onPressed: () {
                                                Navigator.popUntil(
                                                  context,
                                                  ModalRoute.withName('/kasir'),
                                                );
                                              },
                                              child: Text(
                                                'Tidak',
                                                style: TextStyle(
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ),
                                            FlatButton(
                                              onPressed: () {
                                                Navigator.popUntil(
                                                  context,
                                                  ModalRoute.withName('/kasir'),
                                                );
                                                konfirmPenjualan(
                                                    listKasir.idNota);

                                                showInSnackbarK(
                                                    'Sedang memproses');
                                              },
                                              child: Text('Ya'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    child: Text('Konfirm'),
                                  ),
                            if (listKasir.statusDeliver == 'A' &&
                                listKasir.statusPacking == 'Y')
                              FlatButton(
                                child: Text('Sudah Diambil?'),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                      title: Text('Peringtan!'),
                                      content: Text(
                                          'Apa anda ingin mengakhiri transaksi ini?'),
                                      actions: <Widget>[
                                        FlatButton(
                                          child: Text(
                                            'Tidak',
                                            style: TextStyle(
                                              color: Colors.black54,
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                        FlatButton(
                                          child: Text('Ya'),
                                          onPressed: () {
                                            Navigator.popUntil(
                                              context,
                                              ModalRoute.withName('/kasir'),
                                            );
                                            penjualanSelesai(listKasir.idNota);
                                          },
                                        )
                                      ],
                                    ),
                                  );
                                },
                              )
                          ],
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: floatingActionButton(),
    );
  }
}

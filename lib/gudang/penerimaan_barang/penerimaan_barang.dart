import 'dart:io';

// import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:invee2/gudang/penerimaan_barang/cari_penerimaan_barang.dart';
import 'package:invee2/gudang/penerimaan_barang/customTilePenerimaan.dart';
import 'package:invee2/gudang/penerimaan_barang/filter.dart';
import 'package:invee2/gudang/penerimaan_barang/model.dart';
import 'package:invee2/shimmer_loading.dart';
import 'package:invee2/localStorage/localStorage.dart';
import 'package:http/http.dart' as http;
import 'package:invee2/routes/env.dart';
// import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:convert';
// import 'package:intl/intl.dart';

import './detail_penerimaan.dart';

GlobalKey<ScaffoldState> _scaffoldKeyPenerimaanBarangIndex;
List<NotaPembelian> listNota = [];
String tokenType, accessToken;
Map<String, String> requestHeaders = Map();
bool isLoading;
int totalDragRefresh;
DateTime tanggal1, tanggal2;

void showInSnackBar(String value, {SnackBarAction action}) {
  _scaffoldKeyPenerimaanBarangIndex.currentState.showSnackBar(new SnackBar(
    content: new Text(value),
    action: action,
  ));
}

Future<List<NotaPembelian>> listNotaAndroid() async {
  var storage = new DataStore();

  var tokenTypeStorage = await storage.getDataString('token_type');
  var accessTokenStorage = await storage.getDataString('access_token');

  tokenType = tokenTypeStorage;
  accessToken = accessTokenStorage;

  requestHeaders['Accept'] = 'application/json';
  requestHeaders['Authorization'] = '$tokenType $accessToken';
  print(requestHeaders);
  isLoading = false;
  Map requestBody;
  requestBody = Map();
  if (tanggal1 != null && tanggal2 != null) {
    requestBody['tanggal1'] = tanggal1.toString();
    requestBody['tanggal2'] = tanggal2.toString();
  }

  if (isLoading == false) {
    try {
      final nota = await http.post(
        url('api/listPerimaanBarangSupplierAndroid'),
        headers: requestHeaders,
        body: tanggal1 != null && tanggal2 != null ? requestBody : null,
      );

      if (nota.statusCode == 200) {
        // return nota;

        dynamic notaJson = json.decode(nota.body);

        // if (notaJson['error'] == 'Unauthenticated') {
        //   showInSnackBar(
        //       'Token kedaluwarsa, silahkan logout dan login kembali');
        // }
        print('notaJson $notaJson');

        listNota = [];
        for (var i in notaJson) {
          NotaPembelian notax = NotaPembelian(
            id: i['pp_id'].toString(),
            nota: i['po_nota'],
            tglRencana: i['pp_plandate'],
            tglOrder: i['po_orderdate'],
            tglTerima: i['pp_accdate'],
            staff: i['u_name'] == null ? i['pp_staff'] : i['u_name'],
            notaPlan: i['pp_code'],
            status: i['pp_status'],
          );
          listNota.add(notax);
        }

        print('listnota $listNota');
        print('listnota length ${listNota.length}');
        return listNota;
      } else if (nota.statusCode == 401) {
        showInSnackBar('Token kedaluwarsa, silahkan logout dan login kembali');
      } else {
        showInSnackBar(
          'Request failed with status: ${nota.statusCode}',
          action: SnackBarAction(
            label: 'Close',
            onPressed: () {
              _scaffoldKeyPenerimaanBarangIndex.currentState
                  .hideCurrentSnackBar();
            },
          ),
        );
        print('Error : ${jsonDecode(nota.body)}');
        Map responseJson = jsonDecode(nota.body);

        if(responseJson.containsKey('message')){
          showInSnackBar(responseJson['message']);
        }
        return null;
      }
    } on TimeoutException catch (_) {
      showInSnackBar(
        'Timed out, Try again',
        action: SnackBarAction(
          label: 'Close',
          onPressed: () {
            _scaffoldKeyPenerimaanBarangIndex.currentState
                .hideCurrentSnackBar();
          },
        ),
      );
    } on SocketException catch (_) {
      showInSnackBar(
        'Hosting not found, check your connection',
        action: SnackBarAction(
          label: 'Close',
          onPressed: () {
            _scaffoldKeyPenerimaanBarangIndex.currentState
                .hideCurrentSnackBar();
          },
        ),
      );
    } catch (e) {
      debugPrint('$e');
    }
  }
  return null;
}

class PenerimaanBarang extends StatefulWidget {
  PenerimaanBarang({Key key, this.title}) : super(key: key);
  final String title;
  @override
  State<StatefulWidget> createState() {
    return _PenerimaanBarangState();
  }
}

class _PenerimaanBarangState extends State<PenerimaanBarang> {
  @override
  void initState() {
    _scaffoldKeyPenerimaanBarangIndex = new GlobalKey<ScaffoldState>();
    tanggal1 = null;
    tanggal2 = null;

    totalDragRefresh = 0;
    // print(requestHeaders);
    super.initState();
  }

  refreshFunction() async {
    setState(() {
      totalDragRefresh += 1;
    });

    return await Future.delayed(
      Duration(
        milliseconds: 100,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKeyPenerimaanBarangIndex,
      appBar: AppBar(
        title: Text('Penerimaan Barang dari Supplier'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  settings: RouteSettings(name: '/cari_penerimaan_barang'),
                  builder: (BuildContext context) => CariPenerimaanBarang(),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: RaisedButton(
        color: Colors.cyan,
        onPressed: () async {
          Map<String, DateTime> filter = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => FilterPenerimaanBarang(
                tanggalX: tanggal1,
                tanggal2X: tanggal2,
              ),
            ),
          );

          if (filter != null) {
            tanggal1 = filter['tanggal1'];
            tanggal2 = filter['tanggal2'];
          }
        },
        child: Text(
          'Filter',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => refreshFunction(),
        child: Scrollbar(
          child: FutureBuilder(
            future: listNotaAndroid(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return ListTile(
                    title: Text('Tekan Tombol Mulai.'),
                  );
                case ConnectionState.active:
                case ConnectionState.waiting:
                  return ShimmerLoadingList();
                case ConnectionState.done:
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  if (snapshot.data == null ||
                      snapshot.data == 0 ||
                      snapshot.data.length == null ||
                      snapshot.data.length == 0) {
                    return ListView(
                      children: <Widget>[
                        ListTile(
                          title: Text(
                            'Tidak ada data',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    );
                  } else if (snapshot.data != null || snapshot.data != 0) {
                    return ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        return CustomTilePenerimaan(
                          leading: Icon(
                            FontAwesomeIcons.cubes,
                            size: 20.0,
                          ),
                          title: snapshot.data[index].nota,
                          subtitle: snapshot.data[index].tglOrder,
                          subtitle2: snapshot.data[index].staff,
                          trailing: snapshot.data[index].tglTerima,
                          status: snapshot.data[index].status,
                          onTab: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                settings: RouteSettings(
                                    name: '/detail_penerimaan_barang'),
                                builder: (BuildContext context) {
                                  return DetailPenerimaan(
                                    status: snapshot.data[index].status,
                                    nota: snapshot.data[index].nota,
                                    staff: snapshot.data[index].staff,
                                    tglRencana: snapshot.data[index].tglRencana,
                                    tglTerima: snapshot.data[index].tglTerima,
                                    notaPlan: snapshot.data[index].notaPlan,
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    );
                  }
              }
              return null; // unreachable
            },
          ),
        ),
      ),
    );
  }
}

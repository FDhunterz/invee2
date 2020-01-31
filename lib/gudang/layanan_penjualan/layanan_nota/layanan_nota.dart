import 'package:flutter/material.dart';
import 'package:invee2/error/error.dart';
import 'package:invee2/gudang/layanan_penjualan/layanan_nota/cariLayananNota.dart';
import 'package:invee2/gudang/layanan_penjualan/layanan_nota/model.dart';
import 'package:invee2/localStorage/localStorage.dart';
import 'package:invee2/routes/env.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
// import 'dart:io';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:invee2/shimmer_loading.dart';

GlobalKey<ScaffoldState> _scaffoldKeyX;
List<ListNota> listNota = List<ListNota>();
List<CheckedNota> listChecked = List<CheckedNota>();
String tokenType, accessToken;
Map<String, String> requestHeaders = Map();
bool isLoading, isError;

bool userAksesMenu, userGroupAksesMenu;

void showInSnackBarLN(String value) {
  _scaffoldKeyX.currentState
      .showSnackBar(new SnackBar(content: new Text(value)));
}

Widget statusNota(status) {
  if (status == 'Y') {
    return Text(
      'Proses',
      style: TextStyle(backgroundColor: Colors.cyan, color: Colors.white),
    );
  } else if (status == 'N') {
    return Text(
      'Belum diproses',
      style: TextStyle(backgroundColor: Colors.orange, color: Colors.white),
    );
  }
  return null;
}

class LayananNota extends StatefulWidget {
  @override
  _LayananNotaState createState() => _LayananNotaState();
}

class _LayananNotaState extends State<LayananNota> {
  Future<Null> listNotaAndroid() async {
    var storage = new DataStore();

    var tokenTypeStorage = await storage.getDataString('token_type');
    var accessTokenStorage = await storage.getDataString('access_token');

    tokenType = tokenTypeStorage;
    accessToken = accessTokenStorage;

    requestHeaders['Accept'] = 'application/json';
    requestHeaders['Authorization'] = '$tokenType $accessToken';
    print(requestHeaders);

    setState(() {
      isLoading = true;
      isError = false;
    });

    try {
      final nota = await http.get(
        url('api/indexLayananNota'),
        headers: requestHeaders,
      );

      if (nota.statusCode == 200) {
        // return nota;
        var notaJson = json.decode(nota.body);

        print('notaJson $notaJson');

        listNota = List<ListNota>();
        listChecked = List<CheckedNota>();
        for (var i in notaJson['data']) {
          ListNota notax = ListNota(
            id: i['sln_id'].toString(),
            barang: i['i_name'],
            kodeBarang: i['sln_cproduct'],
            status: i['sln_status'],
            namaSatuan: i['iu_name'],
            qty: i['sln_qty'].toString(),
            idGudang: i['w_id'].toString(),
            namaGudang: i['w_name'],
            confirmBy: i['confirm_name'],
            doneBy: i['done_name'],
          );
          listNota.add(notax);
          listChecked.add(
            CheckedNota(
              checked: false,
              kodeBarang: i['sln_cproduct'],
              idLayananNota: i['sln_id'].toString(),
              status: i['sln_status'],
              qty: i['sln_qty'].toString(),
              idGudang: i['w_id'].toString(),
              namaGudang: i['w_name'],
            ),
          );
        }

        print('listnota $listNota');
        print('listnota length ${listNota.length}');

        setState(() {
          isLoading = false;
          isError = false;
        });
        // return listNota;
      } else {
        showInSnackBarLN('Request failed with status: ${nota.statusCode}');
        print(jsonDecode(nota.body));
        setState(() {
          isLoading = false;
          isError = true;
        });
      }
    } on TimeoutException catch (_) {
      showInSnackBarLN('Timed out, Try again');
      setState(() {
        isLoading = false;
        isError = true;
      });
    } catch (e, stacktrace) {
      print('Error = $e || Stacktrace = $stacktrace');
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
    // return null;
  }

  void simpan(List<CheckedNota> list) async {
    Map<String, dynamic> formSerialize = Map<String, dynamic>();
    Map<String, String> requestHeadersX = Map<String, String>();

    requestHeadersX = requestHeaders;

    requestHeadersX['Content-Type'] = 'application/x-www-form-urlencoded';

    formSerialize['id_stock_layanan_nota'] = List<String>();
    formSerialize['status_stock_layanan_nota'] = List<String>();
    formSerialize['bool_stock_layanan_nota'] = List<String>();
    formSerialize['kode_produk'] = List<String>();
    formSerialize['qty'] = List<String>();
    formSerialize['gudang'] = List<String>();

    for (CheckedNota data in list) {
      print(data.checked);
      print(data.kodeBarang);
      print(data.idLayananNota);
      print(data.status);

      formSerialize['id_stock_layanan_nota'].add(data.idLayananNota);
      formSerialize['status_stock_layanan_nota'].add(data.status);
      formSerialize['bool_stock_layanan_nota'].add(data.checked.toString());
      formSerialize['kode_produk'].add(data.kodeBarang);
      formSerialize['qty'].add(data.qty);
      formSerialize['gudang'].add(data.idGudang);
    }
    print('asw');
    try {
      final response = await http.post(
        url('api/prosesLayananNota'),
        headers: requestHeadersX,
        body: {
          'data': jsonEncode(formSerialize),
        },
      );
      print('asw 2');

      if (response.statusCode == 200) {
        dynamic responseJson = jsonDecode(response.body);
        print('decoded $responseJson');
        print('asw3 ');

        Navigator.pop(context);
        listNotaAndroid();
      } else {
        showInSnackBarLN('Error Code : ${response.statusCode}');

        Map responseJson = jsonDecode(response.body);

        if (responseJson.containsKey('message')) {
          showInSnackBarLN(responseJson['message']);
        }
        print('decoded $responseJson');
      }
    } catch (e, stacktrace) {
      print('Error = $e || Stacktrace = $stacktrace');
      showInSnackBarLN('Error, hubungi pengembang aplikasi');
    }
  }

  Widget floatingActionButton(BuildContext context, List<CheckedNota> list) {
    if (userAksesMenu || userGroupAksesMenu) {
      if (list
              .where(
                  (list) => list.checked.toString().contains(true.toString()))
              .length !=
          0) {
        return FloatingActionButton(
          child: Icon(Icons.input),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: Text('Peringatan!'),
                content: Text('Apa anda yakin memproses/mengakhiri data ini?'),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Tidak',
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  FlatButton(
                    onPressed: () async {
                      if (isLoading == false) {
                        simpan(list);
                      }
                    },
                    child: Text('Ya'),
                  )
                ],
              ),
            );
          },
        );
      }
      return Container();
    }
    return Container();
  }

  int totalRefresh = 0;
  refreshFunction() async {
    setState(() {
      totalRefresh += 1;
    });
  }

  getUserAksesDanGroupAkses() async {
    DataStore store = new DataStore();

    userAksesMenu = await store
        .getDataBool('Layanan Item dari Nota Penjualan Edit (Akses)');
    userGroupAksesMenu = await store
        .getDataBool('Layanan Item dari Nota Penjualan Edit (Group)');

    setState(() {
      userAksesMenu = userAksesMenu;
      userGroupAksesMenu = userGroupAksesMenu;
    });
  }

  @override
  void initState() {
    _scaffoldKeyX = GlobalKey<ScaffoldState>();
    getUserAksesDanGroupAkses();

    listNotaAndroid();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKeyX,
      appBar: AppBar(
        title: Text('Layanan Item dari Nota Penjualan'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  settings: RouteSettings(name: '/cari_layanan_nota'),
                  builder: (BuildContext context) => CariLayananNota(),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: floatingActionButton(context, listChecked),
      body: RefreshIndicator(
        onRefresh: () => listNotaAndroid(),
        child: Scrollbar(
          child: isLoading == true
              ? ShimmerLoadingList()
              : isError == true
                  ? ErrorCobalLagi(
                      onPress: () => listNotaAndroid(),
                    )
                  : listNota.length == 0
                      ? ListView(
                          children: <Widget>[
                            Card(
                              child: ListTile(
                                title: Text(
                                  'Tidak ada data',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          itemCount: listNota.length,
                          itemBuilder: (BuildContext context, int i) => Card(
                            child: ListTile(
                              leading: Checkbox(
                                value: listChecked[i].checked,
                                onChanged: (ini) {
                                  setState(() {
                                    listChecked[i].checked = ini;
                                  });
                                },
                              ),
                              title: Text(
                                  '${listNota[i].kodeBarang} - ${listNota[i].barang}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.only(
                                      top: 5.0,
                                    ),
                                    child: Text(
                                      '${listNota[i].qty} (${listNota[i].namaSatuan}) - ${listNota[i].namaGudang}',
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(
                                      top: 5.0,
                                    ),
                                    child: Text(
                                        'Confirm By : ${listNota[i].confirmBy == null ? 'Belum ada' : listNota[i].confirmBy}'),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(
                                      top: 5.0,
                                      bottom: 5.0,
                                    ),
                                    child: Text(
                                        'Done By : ${listNota[i].doneBy == null ? 'Belum ada' : listNota[i].doneBy}'),
                                  ),
                                ],
                              ),
                              trailing: statusNota(listNota[i].status),
                              onTap: () {
                                if (listChecked[i].checked) {
                                  setState(() {
                                    listChecked[i].checked = false;
                                  });
                                } else {
                                  setState(() {
                                    listChecked[i].checked = true;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
        ),
      ),
    );
  }
}

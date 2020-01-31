import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:invee2/error/error.dart';
import 'package:invee2/gudang/layanan_penjualan/layanan_nota/model.dart';
import 'package:invee2/localStorage/localStorage.dart';
import 'dart:convert';
import 'package:invee2/routes/env.dart';

GlobalKey<ScaffoldState> _scaffoldKeyCariLayananNota;
TextEditingController cariController;
FocusNode cariFocus;

bool isLoading, isError;
String tokenType, accessToken;
Map<String, String> requestHeaders = Map();

bool userAksesMenu, userGroupAksesMenu;

List<ListNota> listNota = List<ListNota>();
List<CheckedNota> listChecked = List<CheckedNota>();

showInSnackbarCariLayananNota(String content) {
  _scaffoldKeyCariLayananNota.currentState.showSnackBar(
    SnackBar(
      content: Text(content),
    ),
  );
}

class CariLayananNota extends StatefulWidget {
  @override
  _CariLayananNotaState createState() => _CariLayananNotaState();
}

class _CariLayananNotaState extends State<CariLayananNota> {
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

  Future<Null> cariLayananNota() async {
    setState(() {
      isLoading = true;
      isError = false;
    });
    DataStore storage = new DataStore();

    String tokenTypeStorage = await storage.getDataString('token_type');
    String accessTokenStorage = await storage.getDataString('access_token');

    tokenType = tokenTypeStorage;
    accessToken = accessTokenStorage;

    requestHeaders['Accept'] = 'application/json';
    requestHeaders['Authorization'] = '$tokenType $accessToken';

    try {
      final response = await http.post(
        url('api/cariLayananNota'),
        headers: requestHeaders,
        body: {
          'cari': cariController.text,
        },
      );

      if (response.statusCode == 200) {
        dynamic responseJson = jsonDecode(response.body);

        listNota = List<ListNota>();
        listChecked = List<CheckedNota>();
        for (var i in responseJson) {
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
        setState(() {
          isLoading = false;
          isError = false;
        });
      } else if (response.statusCode == 401) {
        showInSnackbarCariLayananNota(
            'Token kedaluwarsa, silahkan login kembali');

        setState(() {
          isLoading = false;
          isError = true;
        });
      } else {
        showInSnackbarCariLayananNota('Error Code : ${response.statusCode}');

        Map responseJson = jsonDecode(response.body);

        if(responseJson.containsKey('message')){
          showInSnackbarCariLayananNota(responseJson['message']);
        }
        print(responseJson);
        setState(() {
          isLoading = false;
          isError = true;
        });
      }
    } catch (e) {
      showInSnackbarCariLayananNota('Error : ${e.toString()}');
      print('Error : $e');
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
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
        cariLayananNota();
      } else {
        showInSnackbarCariLayananNota('Error Code : ${response.statusCode}');

        Map responseJson = jsonDecode(response.body);

        if(responseJson.containsKey('message')){
          showInSnackbarCariLayananNota(responseJson['message']);
        }
        print('decoded $responseJson');
      }
    } catch (e, stacktrace) {
      print('Error = $e || Stacktrace = $stacktrace');
      showInSnackbarCariLayananNota('Error, hubungi pengembang aplikasi');
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
    getUserAksesDanGroupAkses();
    isLoading = true;
    isError = false;
    _scaffoldKeyCariLayananNota = GlobalKey<ScaffoldState>();
    cariController = TextEditingController();
    cariFocus = FocusNode();

    cariLayananNota();
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKeyCariLayananNota,
      appBar: AppBar(
        backgroundColor: Colors.white,
        textTheme: TextTheme(
          title: TextStyle(
            color: Colors.black,
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        title: Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: TextField(
            autofocus: true,
            focusNode: cariFocus,
            controller: cariController,
            decoration: InputDecoration(
                border: InputBorder.none, hintText: 'Cari Nama'),
            onChanged: (ini) {
              cariController.value = TextEditingValue(
                selection: cariController.selection,
                text: ini,
              );
              Future.delayed(
                Duration(milliseconds: 200),
                cariLayananNota,
              );
            },
          ),
        ),
      ),
      floatingActionButton: floatingActionButton(context, listChecked),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : isError
              ? ErrorCobalLagi(
                  onPress: cariLayananNota,
                )
              : ListView.builder(
                  itemCount: listNota.length,
                  itemBuilder: (BuildContext context, int i) => Card(
                    child: ListTile(
                      leading: Checkbox(
                        key:Key(listNota[i].kodeBarang),
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
    );
  }
}

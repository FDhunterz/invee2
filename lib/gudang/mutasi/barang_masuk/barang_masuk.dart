import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:invee2/gudang/mutasi/barang_masuk/detail_barang_masuk.dart';
import 'package:invee2/gudang/mutasi/barang_masuk/model.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:invee2/localStorage/localStorage.dart';
import 'package:invee2/routes/env.dart';
import 'package:invee2/shimmer_loading.dart';

GlobalKey<ScaffoldState> _scaffoldKeyBM;

String tokenType, accessToken;
Map<String, String> requestHeaders = Map();

List<ListNota> listNota;

void showInSnackBarBM(String value) {
  _scaffoldKeyBM.currentState
      .showSnackBar(new SnackBar(content: new Text(value)));
}

class BarangMasuk extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BarangMasukState();
  }
}

class _BarangMasukState extends State<BarangMasuk> {
  Future<List<ListNota>> indexBarangKeluar() async {
    var storage = new DataStore();

    var tokenTypeStorage = await storage.getDataString('token_type');
    var accessTokenStorage = await storage.getDataString('access_token');

    tokenType = tokenTypeStorage;
    accessToken = accessTokenStorage;

    requestHeaders['Accept'] = 'application/json';
    requestHeaders['Authorization'] = '$tokenType $accessToken';
    print(requestHeaders);

    try {
      final nota = await http.get(
        url('api/indexBarangMasukAndroid'),
        headers: requestHeaders,
      );

      if (nota.statusCode == 200) {
        // return nota;
        var notaJson = json.decode(nota.body);

        // if (notaJson['error'] == 'Unauthenticated') {
        //   showInSnackbarBM(
        //       'Token kedaluwarsa, silahkan logout dan login kembali');
        // }

        print('notaJson $notaJson');

        listNota = [];
        for (int i = 0; i < notaJson.length; i++) {
          ListNota notax = ListNota(
            id: '${notaJson[i]['rm_id']}',
            reffKeluar: notaJson[i]['rm_ref'],
            reffMasuk: notaJson[i]['om_ref'],
            tglKirim: notaJson[i]['om_datesend'],
            tglTerima: notaJson[i]['im_datein'],
            gudang: notaJson[i]['w_name'],
            catatan: notaJson[i]['om_note'],
            tglRequestMutasi: notaJson[i]['rm_date'],
            idGudang: notaJson[i]['w_code'],
            statusData: notaJson[i]['om_status_data'],
            resi: notaJson[i]['om_resi'],
          );
          listNota.add(notax);
        }

        print('listnota $listNota');
        print('listnota length ${listNota.length}');
        return listNota;
      } else if (nota.statusCode == 401) {
        showInSnackbarBM(
            'Token kedaluwarsa, silahkan logout dan login kembali');
      } else {
        showInSnackBarBM('Request failed with status: ${nota.statusCode}');
        Map responseJson = jsonDecode(nota.body);

        if(responseJson.containsKey('message')){
          showInSnackBarBM(responseJson['message']);
        }
        print(json.decode(nota.body));
        return null;
      }
    } on TimeoutException catch (_) {
      showInSnackBarBM('Timed out, Try again');
    } catch (e) {
      debugPrint('$e');
    }
    return null;
  }

  int totalRefresh = 0;
  refreshFunction() async {
    setState(() {
      totalRefresh += 1;
    });
    Future.delayed(
      Duration(
        milliseconds: 100,
      ),
    );
  }

  @override
  void initState() {
    _scaffoldKeyBM = new GlobalKey<ScaffoldState>();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKeyBM,
      appBar: AppBar(
        title: Text('Barang Masuk dari Mutasi Antar Gudang'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: NotaSearch());
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => refreshFunction(),
        child: Scrollbar(
          child: FutureBuilder(
            future: indexBarangKeluar(),
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
                        Card(
                          child: ListTile(
                            title: Text(
                              'Tidak ada data',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    );
                  } else if (snapshot.data != null || snapshot.data != 0) {
                    return ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          child: ListTile(
                            leading: Icon(Icons.note),
                            title: Text(snapshot.data[index].resi == null
                                ? 'Belum dikirim'
                                : snapshot.data[index].resi),
                            subtitle: Text(
                              'Gudang request = ${snapshot.data[index].gudang}',
                            ),
                            trailing: snapshot.data[index].tglTerima == null
                                ? Text(
                                    'Belum diterima',
                                    style: TextStyle(color: Colors.orange),
                                  )
                                : Text(
                                    DateFormat('dd MMMM yyyy').format(
                                        DateTime.parse(
                                            snapshot.data[index].tglTerima)),
                                    style: TextStyle(color: Colors.blue[700]),
                                  ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  settings: RouteSettings(
                                    name: '/detail_barang_masuk',
                                  ),
                                  builder: (BuildContext context) =>
                                      DetailBarangMasuk(
                                    status: snapshot.data[index].statusData,
                                    catatanPengiriman:
                                        snapshot.data[index].catatan,
                                    gudangPengirim: snapshot.data[index].gudang,
                                    reffBarangKeluar:
                                        snapshot.data[index].reffKeluar,
                                    reffBarangMasuk:
                                        snapshot.data[index].reffMasuk,
                                    resi: snapshot.data[index].resi,
                                    tglBarangMasuk:
                                        snapshot.data[index].tglTerima,
                                    tglPengiriman:
                                        snapshot.data[index].tglKirim,
                                  ),
                                ),
                              );
                            },
                          ),
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

List<String> _filterBy = ['Gudang', 'Nota'];
String _selectedFilterBy = 'Nota';

class FilterDropDown extends StatefulWidget {
  @override
  _FilterDropDownState createState() => _FilterDropDownState();
}

class _FilterDropDownState extends State<FilterDropDown> {
  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      items: _filterBy.map((f) {
        return DropdownMenuItem(
          child: Text(f),
          value: f,
        );
      }).toList(),
      value: _selectedFilterBy,
      hint: Text('Filter By'),
      onChanged: (thisValue) {
        setState(() {
          _selectedFilterBy = thisValue;
        });
      },
    );
  }
}

class NotaSearch extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      FilterDropDown(),
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Text('BuildResult');
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<ListNota> filteredNota = listNota;
    if (_selectedFilterBy == 'No. Referensi') {
      filteredNota = listNota.where((i) {
        return i.reffKeluar.toLowerCase().contains(query);
      }).toList();
    } else if (_selectedFilterBy == 'Gudang') {
      filteredNota = listNota.where((i) {
        return i.gudang.toLowerCase().contains(query);
      }).toList();
    }

    return ListView.builder(
        itemCount: filteredNota.length,
        itemBuilder: (BuildContext context, int j) {
          return ListTile(
            leading: Icon(Icons.note),
            title: Text(filteredNota[j].reffKeluar),
            subtitle: Text(filteredNota[j].gudang),
            trailing: Text(filteredNota[j].tglKirim == null
                ? 'Belum diterima'
                : filteredNota[j].tglKirim),
            // onTap: () {
            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       builder: (context) => ProsesPacking(
            //           id: filteredNota[j].id,
            //           nota: filteredNota[j].nota,
            //           gudang: filteredNota[j].gudang,
            //           status: filteredNota[j].status),
            //     ),
            //   );
            // },
          );
        });
  }
}

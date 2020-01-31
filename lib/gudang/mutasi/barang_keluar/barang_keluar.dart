import 'package:flutter/material.dart';
import 'package:invee2/gudang/mutasi/barang_keluar/detail_barang_keluar.dart';
import 'package:invee2/shimmer_loading.dart';
import 'package:invee2/localStorage/localStorage.dart';
import 'package:http/http.dart' as http;
import 'package:invee2/routes/env.dart';
import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';

GlobalKey<ScaffoldState> _scaffoldKeyX = new GlobalKey<ScaffoldState>();
List<ListNota> listNota = [];
String tokenType, accessToken;
Map<String, String> requestHeaders = Map();
String cabang;
void showInSnackBar(String value) {
  _scaffoldKeyX.currentState
      .showSnackBar(new SnackBar(content: new Text(value)));
}

class BarangKeluar extends StatefulWidget {
  BarangKeluar({Key key, this.title}) : super(key: key);
  final String title;
  @override
  State<StatefulWidget> createState() {
    return _BarangKeluarState();
  }
}

class _BarangKeluarState extends State<BarangKeluar> {
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
        url('api/indexBarangKeluar'),
        headers: requestHeaders,
      );

      if (nota.statusCode == 200) {
        // return nota;
        var notaJson = json.decode(nota.body);

        print('notaJson ${notaJson['data']}');

        listNota = [];
        for (int i = 0; i < notaJson['data'].length; i++) {
          ListNota notax = ListNota(
            id: '${notaJson['data'][i]['rm_id']}',
            nota: notaJson['data'][i]['rm_ref'],
            tanggal: notaJson['data'][i]['om_datesend'],
            gudang: notaJson['data'][i]['w_name'],
            catatan: notaJson['data'][i]['om_note'],
            idGudang: notaJson['data'][i]['w_code'],
            statusData: notaJson['data'][i]['rm_status_data'],
          );
          listNota.add(notax);
        }
        // setState(() {
        cabang = notaJson['cabang']['b_name'];
        // });

        print('listnota $listNota');
        print('listnota length ${listNota.length}');
        return listNota;
      } else if (nota.statusCode == 401) {
        showInSnackBar('Token kedaluwarsa, silahkan logout dan login kembali');
      } else {
        showInSnackBar('Request failed with status: ${nota.statusCode}');
        Map responseJson = jsonDecode(nota.body);

        if(responseJson.containsKey('message')){
          showInSnackBar(responseJson['message']);
        }
        print(json.decode(nota.body));
        return null;
      }
    } on TimeoutException catch (_) {
      showInSnackBar('Timed out, Try again');
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
    cabang = '- Loading -';
    print(requestHeaders);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKeyX,
      appBar: AppBar(
        title: Text('Barang Keluar dari Mutasi Antar Gudang'),
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
                              title: Text(snapshot.data[index].nota),
                              subtitle: Text(
                                'Gudang yang diminta = ${snapshot.data[index].gudang}',
                              ),
                              trailing: snapshot.data[index].tanggal == null
                                  ? Text(
                                      'Belum dikirim',
                                      style: TextStyle(color: Colors.orange),
                                    )
                                  : Text(
                                      DateFormat('dd MMMM yyyy').format(DateTime.parse(snapshot.data[index].tanggal)),
                                      style: TextStyle(color: Colors.blue[700]),
                                    ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    settings: RouteSettings(
                                      name: '/detail_barang_keluar',
                                    ),
                                    builder: (BuildContext context) =>
                                        DetailBarangKeluar(
                                      ref: snapshot.data[index].nota,
                                      tanggal: snapshot.data[index].tanggal,
                                      gudang: snapshot.data[index].gudang,
                                      idGudang: snapshot.data[index].idGudang,
                                      statusData:
                                          snapshot.data[index].statusData,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        });
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

class ListNota {
  String id, nota, gudang, idGudang, tanggal, catatan, statusData;

  ListNota({
    @required this.id,
    @required this.nota,
    @required this.tanggal,
    @required this.gudang,
    @required this.catatan,
    @required this.idGudang,
    @required this.statusData,
  });
}

List<String> _filterBy = ['Gudang', 'Nota'];
String _selectedFilterBy;

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
          _selectedFilterBy = null;
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
    if (_selectedFilterBy == 'Nota') {
      filteredNota = listNota.where((i) {
        return i.nota.toLowerCase().contains(query);
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
            title: Text(filteredNota[j].nota),
            subtitle: Text(filteredNota[j].gudang),
            trailing: Text(filteredNota[j].tanggal),
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

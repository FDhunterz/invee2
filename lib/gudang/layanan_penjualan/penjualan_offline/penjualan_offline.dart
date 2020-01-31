import 'package:flutter/material.dart';
import 'package:invee2/gudang/layanan_penjualan/penjualan_offline/model.dart';
import 'package:invee2/shimmer_loading.dart';
// import 'package:invee2/shimmer_loading.dart';
import './proses_packing.dart';
import 'package:invee2/localStorage/localStorage.dart';
import 'package:http/http.dart' as http;
import 'package:invee2/routes/env.dart';
import 'dart:async';
import 'dart:convert';

GlobalKey<ScaffoldState> _scaffoldKeyX;
List<ListNotaOff> listNota = [];
String tokenType, accessToken;
Map<String, String> requestHeaders = Map();

void showInSnackBar(String value) {
  _scaffoldKeyX.currentState
      .showSnackBar(new SnackBar(content: new Text(value)));
}

Future<List<ListNotaOff>> listNotaAndroid() async {
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
      url('api/listNotaAndroidoff'),
      headers: requestHeaders,
    );

    if (nota.statusCode == 200) {
      // return nota;
      var notaJson = json.decode(nota.body);

      print('notaJson $notaJson');

      listNota = [];
      for (var i in notaJson) {
        ListNotaOff notax = ListNotaOff(
          id: '${i['s_id']}',
          nota: i['s_nota'],
          status: i['s_isapprove'],
          customer: i['cm_name'],
          userDone: i['user_proses_done'],
          userProses: i['user_proses'],
          durasi: i['s_duration'].toString(),
          tanggalProses: i['s_prosespacking_at'],
          createAt: i['s_created_at'],
        );
        listNota.add(notax);
      }

      print('listnota $listNota');
      print('listnota length ${listNota.length}');
      return listNota;
    } else {
      showInSnackBar('Request failed with status: ${nota.statusCode}');
      Map responseJson = jsonDecode(nota.body);

      if (responseJson.containsKey('message')) {
        showInSnackBar(responseJson['message']);
      }
      print(jsonEncode(nota.body));
      return null;
    }
  } on TimeoutException catch (_) {
    showInSnackBar('Timed out, Try again');
  } catch (e) {
    debugPrint('$e');
  }
  return null;
}

Widget statusNota(status) {
  if (status == 'P') {
    return Text(
      'Sudah Bayar',
      style: TextStyle(backgroundColor: Colors.cyan, color: Colors.white),
    );
  } else if (status == 'Y') {
    return Text(
      'Proses Packing',
      style: TextStyle(backgroundColor: Colors.orange, color: Colors.white),
    );
  }
  return null;
}

class PenjualanOffline extends StatefulWidget {
  PenjualanOffline({Key key, this.title}) : super(key: key);
  final String title;
  @override
  State<StatefulWidget> createState() {
    return _PenjualanOfflineState();
  }
}

class _PenjualanOfflineState extends State<PenjualanOffline> {
  int totalRefresh = 0;
  refreshFunction() async {
    setState(() {
      totalRefresh += 1;
    });
  }

  @override
  void initState() {
    _scaffoldKeyX = new GlobalKey<ScaffoldState>();

    print(requestHeaders);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKeyX,
      appBar: AppBar(
        title: Text('Layanan Penjualan Offline'),
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
            future: listNotaAndroid(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return ListTile(
                    title: Text('Tekan Tombol Mulai.'),
                  );
                case ConnectionState.active:
                case ConnectionState.waiting:
                  // return Center(
                  //   child: CircularProgressIndicator(),
                  // );
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
                            subtitle: Text(snapshot.data[index].customer),
                            trailing: statusNota(snapshot.data[index].status),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProsesPacking(
                                    id: snapshot.data[index].id,
                                    nota: snapshot.data[index].nota,
                                    customer: snapshot.data[index].customer,
                                    status: snapshot.data[index].status,
                                    userDone: snapshot.data[index].userDone,
                                    userProses: snapshot.data[index].userProses,
                                    durasi: snapshot.data[index].durasi,
                                    tanggalProses:
                                        snapshot.data[index].tanggalProses,
                                    createAt: snapshot.data[index].createAt,
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

List<String> _filterBy = ['Customer', 'Nota'];
String _selectedFilterBy = 'Customer';

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
    List<ListNotaOff> filteredNota = listNota;
    if (_selectedFilterBy == 'Nota') {
      filteredNota = listNota.where((i) {
        return i.nota.toLowerCase().contains(query);
      }).toList();
    } else if (_selectedFilterBy == 'Customer') {
      filteredNota = listNota.where((i) {
        return i.customer.toLowerCase().contains(query);
      }).toList();
    }

    return Scrollbar(
      child: ListView.builder(
        itemCount: filteredNota.length,
        itemBuilder: (BuildContext context, int j) {
          return ListTile(
            leading: Icon(Icons.note),
            title: Text(filteredNota[j].nota),
            subtitle: Text(filteredNota[j].customer),
            trailing: statusNota(filteredNota[j].status),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProsesPacking(
                    id: filteredNota[j].id,
                    nota: filteredNota[j].nota,
                    customer: filteredNota[j].customer,
                    status: filteredNota[j].status,
                    userDone: filteredNota[j].userDone,
                    userProses: filteredNota[j].userProses,
                    durasi: filteredNota[j].durasi,
                    tanggalProses: filteredNota[j].tanggalProses,
                    createAt: filteredNota[j].createAt,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

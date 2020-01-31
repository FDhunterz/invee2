import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:invee2/penjualan/antrian_layanan/historyAntrian.dart';
// import 'package:invee2/penjualan/antrian_layanan/listTileAntrian.dart';
import 'package:intl/intl.dart';
import 'secondary/model.dart';
import 'dart:async';
import 'package:invee2/localStorage/localStorage.dart';
import 'package:http/http.dart' as http;
import 'package:invee2/routes/env.dart';
import 'package:invee2/shimmer_loading.dart';

import 'create.dart';
import 'detail.dart';

String tokenType, accessToken;
Map<String, String> requestHeaders = Map();
GlobalKey<ScaffoldState> _scaffoldKeyX = new GlobalKey<ScaffoldState>();

List<ListAntrian> listAntrian;
bool isLoading;

void showInSnackBarM(String value) {
  _scaffoldKeyX.currentState.showSnackBar(
    SnackBar(
      content: new Text(value),
    ),
  );
}

class AntrianLayanan extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AntrianLayananState();
  }
}

class _AntrianLayananState extends State<AntrianLayanan> {
  Future<List<ListAntrian>> listresponseStockAndroid() async {
    var storage = new DataStore();

    var tokenTypeStorage = await storage.getDataString('token_type');
    var accessTokenStorage = await storage.getDataString('access_token');

    tokenType = tokenTypeStorage;
    accessToken = accessTokenStorage;

    requestHeaders['Accept'] = 'application/json';
    requestHeaders['Authorization'] = '$tokenType $accessToken';
    print(requestHeaders);

    try {
      final response = await http.get(
        url('api/listAntrianAndroid'),
        headers: requestHeaders,
      );

      if (response.statusCode == 200) {
        var responseJson = jsonDecode(response.body);

        // print('responseJson $responseJson');
        listAntrian = [];
        for (var i in responseJson) {
          ListAntrian responsex = ListAntrian(
            id: '${i['sq_id']}',
            nomor: '${i['sq_nomor']}',
            name: i['cm_name'],
            tanggalDiBuat: i['sq_create_at'],
            status: i['sq_status'],
            email: i['cm_email'],
            noTelp: i['cm_nphone'],
          );
          listAntrian.add(responsex);
        }

        print('listnota $listAntrian');
        print('listnota length ${listAntrian.length}');

        return listAntrian;
      } else if (response.statusCode == 401) {
        showInSnackBarM('Token kedaluwarsa, silahkan logout dan login kembali');
      } else {
        showInSnackBarM('Request failed with status: ${response.statusCode}');
        Map responseJson = jsonDecode(response.body);

        if (responseJson.containsKey('message')) {
          showInSnackBarM(responseJson['message']);
        }
        return null;
      }
    } on TimeoutException catch (_) {
      showInSnackBarM('Timed out, Try again');
    } on SocketException catch (_) {
      showInSnackBarM('Host not found');
    } catch (e, stacktrace) {
      print('Error = $e || Stacktrace = $stacktrace');
    }

    return null;
  }

  Widget statusAntrian(String status) {
    if (status == 'O') {
      return Container(
        padding: EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          color: Colors.cyan,
        ),
        child: Text(
          'Menunggu Antrian',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      );
    } else if (status == 'P') {
      return Container(
        padding: EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          color: Colors.orange,
        ),
        child: Text(
          'Proses',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      );
    } else if (status == 'C') {
      return Container(
        padding: EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          color: Colors.red,
        ),
        child: Text(
          'Batal',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      );
    } else if (status == 'D') {
      return Container(
        padding: EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          color: Colors.green,
        ),
        child: Text(
          'Selesai',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      );
    } else if (status == 'S') {
      return Container(
        padding: EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          color: Colors.yellow,
        ),
        child: Text(
          'Di Tunda',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      );
    }
    return Container();
  }

  @override
  void initState() {
    listAntrian = List();
    super.initState();
  }

  void dispose() {
    super.dispose();
  }

  int totalRefresh = 0;
  refreshFunction() async {
    setState(() {
      totalRefresh += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Antrian Layanan"),
        actions: <Widget>[
          FlatButton(
            textColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => HistoryAntrianLayanan(),
                ),
              );
            },
            child: Text(
              'History',
            ),
          )
        ],
      ),
      key: _scaffoldKeyX,
      body: Scrollbar(
        child: RefreshIndicator(
          onRefresh: () => refreshFunction(),
          child: FutureBuilder(
            future: listresponseStockAndroid(),
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
                    return ListView(children: <Widget>[
                      ListTile(
                        title: Text(
                          'Tidak ada data',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ]);
                  } else if (snapshot.data != null || snapshot.data != 0) {
                    return ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          child: ListTile(
                            leading: Icon(FontAwesomeIcons.listOl),
                            title: Text("Nomor " + snapshot.data[index].nomor),
                            subtitle: Text('${snapshot.data[index].name}'),
                            trailing: Column(
                              children: <Widget>[
                                statusAntrian(snapshot.data[index].status),
                                Container(
                                  padding: EdgeInsets.only(
                                    top: 5.0,
                                    bottom: 5.0,
                                  ),
                                  child: Text(
                                    DateFormat('dd MMMM yyyy H:mm:ss').format(
                                      DateTime.parse(
                                          snapshot.data[index].tanggalDiBuat),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      DetailAntrian(
                                    id: snapshot.data[index].id,
                                    nomor: snapshot.data[index].nomor,
                                    name: snapshot.data[index].name,
                                    tanggalDibuat:
                                        snapshot.data[index].tanggalDiBuat,
                                    status: snapshot.data[index].status,
                                    email: snapshot.data[index].email,
                                    noTelp: snapshot.data[index].noTelp,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                        // return ListTileAntrianLayanan(
                        //   nomor: snapshot.data[index].nomor,
                        //   status: statusAntrian(snapshot.data[index].status),
                        // );
                      },
                    );
                  }
              }
              return null; // unreachable
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateAntrian(),
            ),
          );
        },
      ),
    );
  }
}

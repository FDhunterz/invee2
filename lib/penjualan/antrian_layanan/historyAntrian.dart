import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:invee2/error/error.dart';
import 'package:invee2/localStorage/localStorage.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:invee2/penjualan/antrian_layanan/cariHistoryAntrian.dart';
import 'package:invee2/penjualan/antrian_layanan/detail.dart';
import 'package:invee2/penjualan/antrian_layanan/secondary/model.dart';
import 'package:invee2/routes/env.dart';
import 'package:intl/intl.dart';

GlobalKey<ScaffoldState> _scaffoldKeyAntrianLayanan;

String tokenType, accessToken;
Map<String, String> requestHeaders = Map();

List<ListAntrian> listAntrian;
bool isLoading, isError;

void showInSnackBarAntrianLayanan(String value, {SnackBarAction action}) {
  _scaffoldKeyAntrianLayanan.currentState.showSnackBar(new SnackBar(
    content: new Text(value),
    action: action,
  ));
}

class HistoryAntrianLayanan extends StatefulWidget {
  @override
  _HistoryAntrianLayananState createState() => _HistoryAntrianLayananState();
}

class _HistoryAntrianLayananState extends State<HistoryAntrianLayanan> {
  Future<Null> getHistoryAntrianLayanan() async {
    DataStore storage = new DataStore();

    String tokenTypeStorage = await storage.getDataString('token_type');
    String accessTokenStorage = await storage.getDataString('access_token');

    tokenType = tokenTypeStorage;
    accessToken = accessTokenStorage;

    requestHeaders['Accept'] = 'application/json';
    requestHeaders['Authorization'] = '$tokenType $accessToken';
    // print(requestHeaders);
    setState(() {
      isError = false;
      isLoading = true;
    });

    try {
      final response = await http.get(
        url('api/historyAntrian'),
        headers: requestHeaders,
      );

      if (response.statusCode == 200) {
        dynamic responseJson = jsonDecode(response.body);

        // print('responseJson $responseJson');
        listAntrian = [];
        for (var i in responseJson) {
          ListAntrian responsex = ListAntrian(
            id: i['sq_id'].toString(),
            nomor: '${i['sq_nomor']}',
            name: i['cm_name'],
            tanggalDiBuat: i['sq_create_at'],
            status: i['sq_status'],
            email: i['cm_email'],
            noTelp: i['cm_nphone'],
          );
          listAntrian.add(responsex);
        }
        setState(() {
          isError = false;
          isLoading = false;
        });
      } else if (response.statusCode == 401) {
        showInSnackBarAntrianLayanan(
            'Token kedaluwarsa, silahkan logout dan login kembali');
        setState(() {
          isError = true;
          isLoading = false;
        });
      } else {
        showInSnackBarAntrianLayanan(
            'Request failed with status: ${response.statusCode}');

        Map responseJson = jsonDecode(response.body);

        if (responseJson.containsKey('message')) {
          showInSnackBarAntrianLayanan(responseJson['message']);
        }

        print(jsonDecode(response.body));
        setState(() {
          isError = true;
          isLoading = false;
        });
      }
    } on TimeoutException catch (_) {
      showInSnackBarAntrianLayanan('Timed out, Try again');
      setState(() {
        isError = true;
        isLoading = false;
      });
    } on SocketException catch (_) {
      showInSnackBarAntrianLayanan('Host not found');
      setState(() {
        isError = true;
        isLoading = false;
      });
    } catch (e, stacktrace) {
      print('Error = $e || Stacktrace = $stacktrace');
      showInSnackBarAntrianLayanan('Error : ${e.toString()}');
      setState(() {
        isError = true;
        isLoading = false;
      });
    }
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
    }
    return Container();
  }

  @override
  void initState() {
    _scaffoldKeyAntrianLayanan = GlobalKey<ScaffoldState>();
    isError = false;
    isLoading = true;
    getHistoryAntrianLayanan();
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
      key: _scaffoldKeyAntrianLayanan,
      appBar: AppBar(
        title: Text('History Antrian'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  settings: RouteSettings(
                    name: '/cari_history_antrian',
                  ),
                  builder: (BuildContext context) => CariHistoryAntrian(),
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : isError
              ? ErrorCobalLagi(
                  onPress: getHistoryAntrianLayanan,
                )
              : Scrollbar(
                  child: RefreshIndicator(
                    onRefresh: getHistoryAntrianLayanan,
                    child: ListView.builder(
                      itemCount: listAntrian.length,
                      itemBuilder: (BuildContext context, int i) => Card(
                        child: ListTile(
                          leading: Icon(FontAwesomeIcons.listOl),
                          title: Text("Nomor " + listAntrian[i].nomor),
                          subtitle: Text('${listAntrian[i].name}'),
                          trailing: Column(
                            children: <Widget>[
                              statusAntrian(listAntrian[i].status),
                              Container(
                                padding: EdgeInsets.only(
                                  top: 5.0,
                                  bottom: 5.0,
                                ),
                                child: Text(
                                  DateFormat('dd MMMM yyyy H:mm:ss').format(
                                    DateTime.parse(
                                        listAntrian[i].tanggalDiBuat),
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
                                  id: listAntrian[i].id,
                                  nomor: listAntrian[i].nomor,
                                  name: listAntrian[i].name,
                                  tanggalDibuat: listAntrian[i].tanggalDiBuat,
                                  status: listAntrian[i].status,
                                  cumanHistory: true,
                                  email: listAntrian[i].email,
                                  noTelp: listAntrian[i].noTelp,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }
}

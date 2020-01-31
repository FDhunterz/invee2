import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import '../../localStorage/localStorage.dart';
import '../../routes/env.dart';
import '../../shimmer_loading.dart';
import 'secondary/modal.dart';
import './proses_bayar.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

String tokenType, accessToken;
Map<String, String> requestHeaders = Map();
GlobalKey<ScaffoldState> _scaffoldKeyP = new GlobalKey<ScaffoldState>();
bool isLoading;

class TabPembayaran extends StatefulWidget {
  final bool loading;
  TabPembayaran({this.loading});
  @override
  State<StatefulWidget> createState() {
    return _TabPembayaranState();
  }
}

class _TabPembayaranState extends State<TabPembayaran> {
  TextEditingController searchInput = TextEditingController();

  void showInSnackBarM(String value) {
    _scaffoldKeyP.currentState.showSnackBar(
      SnackBar(
        content: new Text(value),
      ),
    );
  }

  Future<List<ListOffline>> listOffline() async {
    try {
      final offline = await http.get(
        url('api/listpembayaranoffline'),
        headers: requestHeaders,
      );

      if (offline.statusCode == 200) {
        print(offline.body);

        var offlineJson = jsonDecode(offline.body);

        print('offlineJson $offlineJson');
        listOfflineArray = [];
        for (var i in offlineJson) {
          ListOffline offlinex = ListOffline(
            id: i['s_id'].toString(),
            nota: i['s_nota'],
            customer: i['cm_name'],
            status: i['s_paystatus'],
            bayar: i['s_total'].toString(),
            idcustomer: i['s_member'].toString(),
          );
          listOfflineArray.add(offlinex);
        }

        print('listnota $listOfflineArray');
        print('listnota length ${listOfflineArray.length}');

        return listOfflineArray;
      } else {
        showInSnackBarM('Request failed with status: ${offline.statusCode}');
        Map responseJson = jsonDecode(offline.body);

        if (responseJson.containsKey('message')) {
          showInSnackBarM(responseJson['message']);
        }

        return null;
      }
    } on TimeoutException catch (_) {
      showInSnackBarM('Timed out, Try again');
    } on SocketException catch (_) {
      showInSnackBarM('Host not found');
    } catch (e) {}

    return null;
  }

  Future<Null> getHeaderHTTP() async {
    try {
      var storage = new DataStore();

      var tokenTypeStorage = await storage.getDataString('token_type');
      var accessTokenStorage = await storage.getDataString('access_token');

      setState(() {
        tokenType = tokenTypeStorage;
        accessToken = accessTokenStorage;

        requestHeaders['Accept'] = 'application/json';
        requestHeaders['Authorization'] = '$tokenType $accessToken';
        print(requestHeaders);
      });
    } catch (e) {
      print(e);
    }
  }

  Widget statusNota(status) {
    if (status == 'N') {
      return Text(
        'Belum Bayar',
        style: TextStyle(backgroundColor: Colors.orange, color: Colors.white),
      );
    }
    return null;
  }

  @override
  void initState() {
    isLoading = widget.loading;
    getHeaderHTTP();
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
    await Future.delayed(
      Duration(
        milliseconds: 100,
      ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKeyP,
      body: RefreshIndicator(
        onRefresh: () => refreshFunction(),
        child: Scrollbar(
          child: FutureBuilder(
            future: listOffline(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return ListTile(
                    title: Text('Tekan Tombol Mulai'),
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
                            'Tidak Ada Data',
                            textAlign: TextAlign.center,
                          ),
                        )
                      ],
                    );
                  } else if (snapshot.data != null || snapshot.data != 0) {
                    return ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          leading: Icon(Icons.note),
                          title: Text(snapshot.data[index].nota),
                          subtitle: Text(snapshot.data[index].customer),
                          trailing: statusNota(snapshot.data[index].status),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProsesBayar(
                                  id: snapshot.data[index].id,
                                  nota: snapshot.data[index].nota,
                                  customer: snapshot.data[index].customer,
                                  status: snapshot.data[index].status,
                                  bayar:
                                      double.parse(snapshot.data[index].bayar),
                                  idcustomer: snapshot.data[index].idcustomer,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }
              }
              return null;
            },
          ),
        ),
      ),
    );
  }
}

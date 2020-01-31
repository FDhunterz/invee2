import 'dart:convert';
import 'dart:io';
// import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:invee2/gudang/opname_stock/model.dart';
import 'dart:async';
import 'package:invee2/localStorage/localStorage.dart';
import 'package:http/http.dart' as http;
import 'package:invee2/routes/env.dart';
import 'package:invee2/shimmer_loading.dart';
// import 'package:invee2/shimmer_loading.dart';
import './tambah_opname_manual.dart';
import './tab_detail_manual.dart';

String tokenType, accessToken;
Map<String, String> requestHeaders = Map();
GlobalKey<ScaffoldState> _scaffoldKeyX;
// final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
//     new GlobalKey<RefreshIndicatorState>();
bool isLoading;

bool userAksesMenuOpnameManualX, userGroupAksesMenuOpnameManualX;

Widget statusOpname(status) {
  if (status == 'waiting') {
    return Text(
      'Belum disetujui',
      style: TextStyle(backgroundColor: Colors.orange, color: Colors.white),
    );
  }
  return null;
}

void showInSnackBarM(String value) {
  _scaffoldKeyX.currentState.showSnackBar(
    SnackBar(
      content: new Text(value),
    ),
  );
}

class TabManual extends StatefulWidget {
  final bool userAksesMenuOpnameManual, userGroupAksesMenuOpnameManual;

  TabManual({
    this.userAksesMenuOpnameManual,
    this.userGroupAksesMenuOpnameManual,
  });
  @override
  State<StatefulWidget> createState() {
    return _TabManualState();
  }
}

class _TabManualState extends State<TabManual> {
  Future<List<ListOpnameStok>> listOpnameStockAndroid() async {
    // setState(() {
    //   isLoading = true;
    // });
    DataStore store = new DataStore();

    userAksesMenuOpnameManualX =
        await store.getDataBool('Opname Stock Create (Akses)');
    userGroupAksesMenuOpnameManualX =
        await store.getDataBool('Opname Stock Create (Group)');

    userAksesMenuOpnameManualX = userAksesMenuOpnameManualX;
    userGroupAksesMenuOpnameManualX = userGroupAksesMenuOpnameManualX;

    var storage = new DataStore();

    var tokenTypeStorage = await storage.getDataString('token_type');
    var accessTokenStorage = await storage.getDataString('access_token');

    tokenType = tokenTypeStorage;
    accessToken = accessTokenStorage;

    requestHeaders['Accept'] = 'application/json';
    requestHeaders['Authorization'] = '$tokenType $accessToken';
    // print(requestHeaders);

    try {
      final opname = await http.get(
        url('api/listOpnameStockAndroid'),
        headers: requestHeaders,
      );

      // Dio dio = new Dio();

      // Response opname = await dio.get(
      //   url('api/listOpnameStockAndroid'),
      //   options: Options(
      //     headers: requestHeaders,
      //   ),
      // );

      if (opname.statusCode == 200) {
        // return nota;
        // var opnameJson = opname.data;
        var opnameJson = jsonDecode(opname.body);

        // print('opnameJson $opnameJson');
        listOpnameStockArray = [];
        for (var i in opnameJson) {
          ListOpnameStok opnamex = ListOpnameStok(
            id: i['os_id'].toString(),
            ref: i['os_ref'],
            date: i['os_date'],
            gudang: i['w_name'],
            status: i['os_statusadjust'],
            catatan: i['os_note'],
          );
          listOpnameStockArray.add(opnamex);
        }

        // print('listnota $listOpnameStockArray');
        // print('listnota length ${listOpnameStockArray.length}');
        // setState(() {
        //   isLoading = false;
        // });
        return listOpnameStockArray;
      } else if (opname.statusCode == 401) {
        showInSnackBarM('Token kedaluwarsa, silahkan logout dan login kembali');
      } else {
        showInSnackBarM('Request failed with status: ${opname.statusCode}');
        Map responseJson = jsonDecode(opname.body);

        if(responseJson.containsKey('message')){
          showInSnackBarM(responseJson['message']);
        }
        print(jsonDecode(opname.body));
        // setState(() {
        //   isLoading = false;
        // });
        return null;
      }
    } on TimeoutException catch (_) {
      showInSnackBarM('Timed out, Try again');
      // setState(() {
      //   isLoading = false;
      // });
    } on SocketException catch (_) {
      showInSnackBarM('Host not found');
      // setState(() {
      //   isLoading = false;
      // });
      // } on DioError catch (e) {
      //   // The request was made and the server responded with a status code
      //   // that falls out of the range of 2xx and is also not 304.
      //   print("error ${e.type}");
      //   if (e.response != null) {
      //     print(e.response.data);
      //     print(e.response.headers);
      //     print(e.response.request);
      //   } else {
      //     // Something happened in setting up or sending the request that triggered an Error
      //     print(e.request);
      //     print(e.message);
      //   }
      //   // throw (e);
    } catch (e, stacktrace) {
      debugPrint('unknownError : $e ,$stacktrace');
      // setState(() {
      //   isLoading = false;
      // });
    }
    // setState(() {
    //   isLoading = false;
    // });
    return null;
  }

  Widget floatingActionButton() {
    if (userAksesMenuOpnameManualX || userGroupAksesMenuOpnameManualX) {
      return FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TambahOpnameManual(),
            ),
          );
        },
      );
    }
    return Container();
  }

  @override
  void initState() {
    _scaffoldKeyX = new GlobalKey<ScaffoldState>();
    userAksesMenuOpnameManualX = false;
    userGroupAksesMenuOpnameManualX = false;
    userAksesMenuOpnameManualX = widget.userAksesMenuOpnameManual;
    userGroupAksesMenuOpnameManualX = widget.userGroupAksesMenuOpnameManual;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKeyX,
      body: Scrollbar(
        child: RefreshIndicator(
          onRefresh: () => refreshFunction(),
          child: FutureBuilder(
            future: listOpnameStockAndroid(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return ListTile(
                    title: Text('Tekan Tombol Mulai.'),
                  );
                case ConnectionState.active:
                case ConnectionState.waiting:
                  return ShimmerLoadingList();
                // return Center(
                //   child: CircularProgressIndicator(),
                // );
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
                            title: Text(snapshot.data[index].ref),
                            subtitle: Text('${snapshot.data[index].gudang}'),
                            trailing: Column(
                              children: <Widget>[
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.all(5.0),
                                    child: Text(snapshot.data[index].date),
                                  ),
                                ),
                                Expanded(
                                  child:
                                      statusOpname(snapshot.data[index].status),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      TabDetailOpnameManual(
                                    id: snapshot.data[index].id,
                                    ref: snapshot.data[index].ref,
                                    date: snapshot.data[index].date,
                                    gudang: snapshot.data[index].gudang,
                                    status: snapshot.data[index].status,
                                    catatan: snapshot.data[index].catatan,
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
      floatingActionButton: floatingActionButton(),
    );
  }
}

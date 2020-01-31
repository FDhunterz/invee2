import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:invee2/master/customer/detailCustomer.dart';
import 'package:invee2/master/customer/editCustomer.dart';
import 'package:invee2/master/customer/tambahCustomer.dart';
import 'cariCustomer.dart';
import 'customerModel.dart';
import 'package:invee2/shimmer_loading.dart';
import 'package:invee2/localStorage/localStorage.dart';
import 'package:http/http.dart' as http;
import 'package:invee2/routes/env.dart';
import 'dart:async';
import 'dart:convert';

GlobalKey<ScaffoldState> _scaffoldKeyCustomer;
List<Customer> listNota = [];
String tokenType, accessToken;
Map<String, String> requestHeaders = Map();
bool isGroupAksesEdit,
    isUserAksesEdit,
    isGroupAksesCreate,
    isUserAksesCreate,
    isGroupAksesDelete,
    isUserAksesDelete;

void showInSnackBarCustomer(String value) {
  _scaffoldKeyCustomer.currentState
      .showSnackBar(new SnackBar(content: new Text(value)));
}

Future<List<Customer>> listMasterCustomer() async {
  DataStore storage = new DataStore();

  String tokenTypeStorage = await storage.getDataString('token_type');
  String accessTokenStorage = await storage.getDataString('access_token');

  tokenType = tokenTypeStorage;
  accessToken = accessTokenStorage;

  requestHeaders['Accept'] = 'application/json';
  requestHeaders['Authorization'] = '$tokenType $accessToken';
  // print(requestHeaders);

  try {
    final nota = await http.get(
      url('api/customerAndroid'),
      headers: requestHeaders,
    );

    if (nota.statusCode == 200) {
      // return nota;
      dynamic notaJson = json.decode(nota.body);

      // print('notaJson $notaJson');

      listNota = [];
      for (var i in notaJson) {
        Customer notax = Customer(
          idCustomer: i['cm_id'].toString(),
          kodeCustomer: i['cm_code'],
          namaCustomer: i['cm_name'],
          email: i['cm_email'],
          telpon: i['cm_nphone'],
          statusData: i['status_data'],
        );
        listNota.add(notax);
      }

      // print('listnota $listNota');
      // print('listnota length ${listNota.length}');
      return listNota;
    } else {
      showInSnackBarCustomer('Request failed with status: ${nota.statusCode}');
      Map responseJson = jsonDecode(nota.body);

        if(responseJson.containsKey('message')){
          showInSnackBarCustomer(responseJson['message']);
        }
      print(jsonDecode(nota.body));
      return null;
    }
  } on TimeoutException catch (_) {
    showInSnackBarCustomer('Timed out, Try again');
  } catch (e) {
    showInSnackBarCustomer('Error : ${e.toString()}');
    print('Error : $e');
  }
  return null;
}

class MasterCustomer extends StatefulWidget {
  MasterCustomer({Key key, this.title}) : super(key: key);
  final String title;
  @override
  State<StatefulWidget> createState() {
    return _MasterCustomerState();
  }
}

class _MasterCustomerState extends State<MasterCustomer> {
  int totalRefresh = 0;
  refreshFunction() async {
    setState(() {
      totalRefresh += 1;
    });
  }

  nonAktifkanCustomer({
    String id,
    String statusData,
  }) async {
    if (statusData == 'false') {
      statusData = 'true';
    } else if (statusData == 'true') {
      statusData = 'false';
    }
    try {
      final response = await http.post(
        url('api/remove_customer'),
        headers: requestHeaders,
        body: {
          'id': id,
          'active': statusData,
        },
      );

      if (response.statusCode == 200) {
        dynamic responseJson = jsonDecode(response.body);

        if (responseJson['success'] == 'berhasil') {
          showInSnackBarCustomer('Sukses! data berhasil diubah');
          refreshFunction();
        } else if (responseJson['status'] == 'gagal') {
          showInSnackBarCustomer('Error : ${responseJson['message']}');
        }
      } else if(response.statusCode == 401){
        showInSnackBarCustomer('Token kedaluwarsa, silahkan login kembali');
      } else {
        showInSnackBarCustomer('Error Code : ${response.statusCode}');
        print('Error Code : ${response.statusCode}');
        Map responseJson = jsonDecode(response.body);

        if(responseJson.containsKey('message')){
          showInSnackBarCustomer(responseJson['message']);
        }
        print(responseJson);
      }
    } catch (e) {
      print('Error : $e');
      showInSnackBarCustomer('Error : ${e.toString()}');
    }
  }

  Widget floatingActionButton() {
    if (isGroupAksesCreate || isUserAksesCreate) {
      return FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              settings: RouteSettings(name: '/tambah_customer'),
              builder: (BuildContext context) => TambahCustomer(),
            ),
          );
        },
        child: Icon(Icons.add),
      );
    } else {
      return Container();
    }
  }

  getGroupUserAkses() async {
    DataStore store = DataStore();

    bool groupAksesEdit = await store.getDataBool('Customer Edit (Group)');
    bool userAksesEdit = await store.getDataBool('Customer Edit (Akses)');
    bool groupAksesCreate = await store.getDataBool('Customer Create (Group)');
    bool userAksesCreate = await store.getDataBool('Customer Create (Akses)');
    bool groupAksesDelete = await store.getDataBool('Customer Delete (Group)');
    bool userAksesDelete = await store.getDataBool('Customer Delete (Akses)');

    setState(() {
      isGroupAksesCreate = groupAksesCreate;
      isGroupAksesDelete = groupAksesDelete;
      isGroupAksesEdit = groupAksesEdit;
      isUserAksesCreate = userAksesCreate;
      isUserAksesDelete = userAksesDelete;
      isUserAksesEdit = userAksesEdit;
    });
  }

  @override
  void initState() {
    _scaffoldKeyCustomer = new GlobalKey<ScaffoldState>();
    isGroupAksesEdit = false;
    isUserAksesEdit = false;
    isGroupAksesCreate = false;
    isUserAksesCreate = false;
    isGroupAksesDelete = false;
    isUserAksesDelete = false;
    getGroupUserAkses();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKeyCustomer,
      appBar: AppBar(
        title: Text('Master Customer'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  settings: RouteSettings(name: '/cari_customer'),
                  builder: (BuildContext context) => CariMasterCustomer(),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: floatingActionButton(),
      body: RefreshIndicator(
        onRefresh: () => refreshFunction(),
        child: Scrollbar(
          child: FutureBuilder(
            future: listMasterCustomer(),
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
                        return Container(
                          margin: EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                            color: snapshot.data[index].statusData == 'true'
                                ? Colors.green[100].withOpacity(0.5)
                                : Colors.red[100].withOpacity(0.5),
                            borderRadius: BorderRadius.circular(5.0),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: Colors.grey[300].withOpacity(0.5),
                                blurRadius: 1.0,
                                spreadRadius: 1.0,
                                offset: Offset(1.0, 1.0),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: Icon(FontAwesomeIcons.userAlt),
                            title: Text(
                                '( ${snapshot.data[index].kodeCustomer} ) ${snapshot.data[index].namaCustomer}'),
                            subtitle: Text(snapshot.data[index].email != null
                                ? snapshot.data[index].email
                                : '-'),
                            trailing: Text(snapshot.data[index].telpon != null
                                ? snapshot.data[index].telpon
                                : '-'),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: Text('Aksi'),
                                  actions: <Widget>[
                                    isGroupAksesDelete || isUserAksesDelete
                                        ? snapshot.data[index].statusData ==
                                                'true'
                                            ? RaisedButton(
                                                color: Colors.red,
                                                child: Text(
                                                  'Nonaktifkan',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (BuildContext
                                                            context) =>
                                                        AlertDialog(
                                                      title:
                                                          Text('Peringatan!'),
                                                      content: Text(
                                                        'Customer akan dinonaktifkan, apa anda yakin?',
                                                      ),
                                                      actions: <Widget>[
                                                        FlatButton(
                                                          child: Text('Tidak'),
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                        ),
                                                        FlatButton(
                                                          child: Text(
                                                            'Ya',
                                                            style: TextStyle(
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                          onPressed: () {
                                                            Navigator.popUntil(
                                                                context,
                                                                ModalRoute.withName(
                                                                    '/master_customer'));
                                                            nonAktifkanCustomer(
                                                              id: snapshot
                                                                  .data[index]
                                                                  .idCustomer,
                                                              statusData: snapshot
                                                                  .data[index]
                                                                  .statusData,
                                                            );
                                                          },
                                                        )
                                                      ],
                                                    ),
                                                  );
                                                },
                                              )
                                            : RaisedButton(
                                                color: Colors.green,
                                                child: Text(
                                                  'Aktifkan',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (BuildContext
                                                            context) =>
                                                        AlertDialog(
                                                      title:
                                                          Text('Peringatan!'),
                                                      content: Text(
                                                        'Customer akan diaktifkan, apa anda yakin?',
                                                      ),
                                                      actions: <Widget>[
                                                        FlatButton(
                                                          child: Text('Tidak'),
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                        ),
                                                        FlatButton(
                                                          child: Text(
                                                            'Ya',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.green,
                                                            ),
                                                          ),
                                                          onPressed: () {
                                                            Navigator.popUntil(
                                                                context,
                                                                ModalRoute.withName(
                                                                    '/master_customer'));
                                                            nonAktifkanCustomer(
                                                              id: snapshot
                                                                  .data[index]
                                                                  .idCustomer,
                                                              statusData: snapshot
                                                                  .data[index]
                                                                  .statusData,
                                                            );
                                                          },
                                                        )
                                                      ],
                                                    ),
                                                  );
                                                },
                                              )
                                        : Container(),
                                    isGroupAksesEdit || isUserAksesEdit
                                        ? RaisedButton(
                                            color: Colors.orange,
                                            child: Text(
                                              'Edit',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            onPressed: () {
                                              Navigator.pop(context);
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  settings: RouteSettings(
                                                      name: '/edit_customer'),
                                                  builder:
                                                      (BuildContext context) =>
                                                          EditCustomer(
                                                    id: snapshot
                                                        .data[index].idCustomer,
                                                  ),
                                                ),
                                              );
                                            },
                                          )
                                        : Container(),
                                    FlatButton(
                                      child: Text(
                                        'Detail',
                                        style: TextStyle(
                                          color: Colors.cyan,
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            settings: RouteSettings(
                                              name: '/detail_customer',
                                            ),
                                            builder: (BuildContext context) =>
                                                DetailCustomer(
                                              id: snapshot
                                                  .data[index].idCustomer,
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  ],
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

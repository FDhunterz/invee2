import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:invee2/error/error.dart';
import 'package:invee2/localStorage/localStorage.dart';
import 'package:invee2/master/customer/detailCustomer.dart';
import 'package:invee2/master/customer/editCustomer.dart';
import 'customerModel.dart';
import 'dart:convert';
import 'package:invee2/routes/env.dart';
import 'dart:async';

GlobalKey<ScaffoldState> _scaffoldKeyCariWishlist;
TextEditingController cariController;
FocusNode cariFocus;

bool isLoading, isError;
String tokenType, accessToken;
Map<String, String> requestHeaders = Map();

List<Customer> listWishlist = List<Customer>();
bool isGroupAksesEdit,
    isUserAksesEdit,
    isGroupAksesCreate,
    isUserAksesCreate,
    isGroupAksesDelete,
    isUserAksesDelete;

Timer timer;
int delayRequest;

showInSnackbar(String content) {
  _scaffoldKeyCariWishlist.currentState.showSnackBar(
    SnackBar(
      content: Text(content),
    ),
  );
}

class CariMasterCustomer extends StatefulWidget {
  @override
  _CariMasterCustomerState createState() => _CariMasterCustomerState();
}

class _CariMasterCustomerState extends State<CariMasterCustomer> {
  nonAktifkanCustomer({
    String id,
    String statusData,
  }) async {
    try {
      final response = await http.post(
        url('api/remove_customer'),
        headers: requestHeaders,
        body: {
          'id': id,
        },
      );

      if (response.statusCode == 200) {
        dynamic responseJson = jsonDecode(response.body);

        if (responseJson['success'] == 'berhasil') {
          showInSnackbar('Sukses! data berhasil diubah');
          cariCustomer();
        } else if (responseJson['status'] == 'gagal') {
          showInSnackbar('Error : ${responseJson['message']}');
        }
      } else if(response.statusCode == 401){
        showInSnackbar('Token kedaluwarsa, silahkan login kembali');
      } else {
        showInSnackbar('Error Code : ${response.statusCode}');
        print('Error Code : ${response.statusCode}');
        Map responseJson = jsonDecode(response.body);

        if(responseJson.containsKey('message')){
          showInSnackbar(responseJson['message']);
        }
        print(responseJson);
      }
    } catch (e) {
      print('Error : $e');
      showInSnackbar('Error : ${e.toString()}');
    }
  }

  Future<Null> cariCustomer() async {
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
        url('api/cariCustomerAndroid'),
        headers: requestHeaders,
        body: {
          'cari': cariController.text,
        },
      );

      if (response.statusCode == 200) {
        dynamic responseJson = jsonDecode(response.body);

        listWishlist = List<Customer>();

        for (var i in responseJson) {
          Customer wishlistLoop = Customer(
            idCustomer: i['cm_id'].toString(),
            namaCustomer: i['cm_name'],
            email: i['cm_email'],
            kodeCustomer: i['cm_code'],
            telpon: i['cm_nphone'],
            statusData: i['status_data'],
          );
          listWishlist.add(wishlistLoop);
        }
        setState(() {
          isLoading = false;
          isError = false;
        });
      } else if (response.statusCode == 401) {
        showInSnackbar('Token kedaluwarsa, silahkan login kembali');

        setState(() {
          isLoading = false;
          isError = true;
        });
      } else {
        showInSnackbar('Error Code : ${response.statusCode}');
        print(jsonDecode(response.body));
        Map responseJson = jsonDecode(response.body);

        if(responseJson.containsKey('message')){
          showInSnackbar(responseJson['message']);
        }
        setState(() {
          isLoading = false;
          isError = true;
        });
      }
    } catch (e) {
      showInSnackbar('Error : ${e.toString()}');
      print('Error : $e');
      setState(() {
        isLoading = false;
        isError = true;
      });
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

  timerUntukRequest() async {
    timer = Timer.periodic(
      Duration(
        seconds: 1,
      ),
      (Timer timerX) {
        if (delayRequest < 1) {
          cariCustomer();
          timer.cancel();
        } else {
          delayRequest -= 1;
        }
      },
    );
  }

  @override
  void initState() {
    isLoading = true;
    isError = false;
    _scaffoldKeyCariWishlist = GlobalKey<ScaffoldState>();
    cariController = TextEditingController();
    cariFocus = FocusNode();
    delayRequest = 0;

    isGroupAksesEdit = false;
    isUserAksesEdit = false;
    isGroupAksesCreate = false;
    isUserAksesCreate = false;
    isGroupAksesDelete = false;
    isUserAksesDelete = false;
    getGroupUserAkses();

    cariCustomer();
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
      key: _scaffoldKeyCariWishlist,
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
                border: InputBorder.none, hintText: 'Cari Nama/Email/Kode/HP'),
            onChanged: (ini) {
              cariController.value = TextEditingValue(
                selection: cariController.selection,
                text: ini,
              );
              if (delayRequest <= 2 && delayRequest != 0) {
                timer.cancel();
              }
              delayRequest = 2;
              timerUntukRequest();
            },
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : isError
              ? ErrorCobalLagi(
                  onPress: cariCustomer,
                )
              : ListView.builder(
                  itemCount: listWishlist.length,
                  itemBuilder: (BuildContext context, int i) => Container(
                    margin: EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                      color: listWishlist[i].statusData == 'true'
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
                          '( ${listWishlist[i].kodeCustomer} ) ${listWishlist[i].namaCustomer}'),
                      subtitle: Text(listWishlist[i].email != null
                          ? listWishlist[i].email
                          : '-'),
                      trailing: Text(listWishlist[i].telpon != null
                          ? listWishlist[i].telpon
                          : '-'),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: Text('Aksi'),
                            actions: <Widget>[
                              isGroupAksesDelete || isUserAksesDelete
                                  ? listWishlist[i].statusData == 'true'
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
                                              builder: (BuildContext context) =>
                                                  AlertDialog(
                                                title: Text('Peringatan!'),
                                                content: Text(
                                                  'Customer akan dinonaktifkan, apa anda yakin?',
                                                ),
                                                actions: <Widget>[
                                                  FlatButton(
                                                    child: Text('Tidak'),
                                                    onPressed: () {
                                                      Navigator.pop(context);
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
                                                              '/cari_customer'));
                                                      nonAktifkanCustomer(
                                                        id: listWishlist[i]
                                                            .idCustomer,
                                                        statusData:
                                                            listWishlist[i]
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
                                              builder: (BuildContext context) =>
                                                  AlertDialog(
                                                title: Text('Peringatan!'),
                                                content: Text(
                                                  'Customer akan diaktifkan, apa anda yakin?',
                                                ),
                                                actions: <Widget>[
                                                  FlatButton(
                                                    child: Text('Tidak'),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                  FlatButton(
                                                    child: Text(
                                                      'Ya',
                                                      style: TextStyle(
                                                        color: Colors.green,
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      Navigator.popUntil(
                                                          context,
                                                          ModalRoute.withName(
                                                              '/cari_customer'));
                                                      nonAktifkanCustomer(
                                                        id: listWishlist[i]
                                                            .idCustomer,
                                                        statusData:
                                                            listWishlist[i]
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
                                            builder: (BuildContext context) =>
                                                EditCustomer(
                                              id: listWishlist[i].idCustomer,
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
                                        id: listWishlist[i].idCustomer,
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
                  ),
                ),
    );
  }
}

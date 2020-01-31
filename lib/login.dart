import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
// import 'dart:async';
import 'dart:convert';
import 'package:invee2/localStorage/localStorage.dart';
import 'package:invee2/routes/env.dart';

class LoginView extends StatefulWidget {
  _LoginViewState createState() => _LoginViewState();
}

final focusNode = FocusNode();
Map<String, String> requestHeaders = Map();

class _LoginViewState extends State<LoginView> {
  TextEditingController user = new TextEditingController();
  TextEditingController pass = new TextEditingController();
  final userFocus = FocusNode();
  final passFocus = FocusNode();
  String msg = '';
  String username = '';
  bool _isLoading;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void showInSnackBar(String value, {SnackBarAction action}) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(value),
      action: action,
    ));
  }

  final _formKey = GlobalKey<FormState>();

  void initState() {
    _isLoading = false;
    super.initState();
  }

  void dispose() {
    userFocus.dispose();
    passFocus.dispose();
    super.dispose();
  }

  _login() async {
    setState(() {
      _isLoading = true;
    });
    HttpClient client = new HttpClient();
    client.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
    final getToken = await http.post(url('oauth/token'), body: {
        'grant_type': grantType,
        'client_id': clientId,
        'client_secret': clientSecret,
        "username": user.text,
        "password": pass.text,
      }, headers: {
        'Accept': 'application/json',
      });
      print('getToken ' + getToken.body);
    try {
      


      dynamic getTokenDecode = json.decode(getToken.body);

      if (getToken.statusCode == 200) {
        if (getTokenDecode['error'] == 'invalid_credentials') {
          showInSnackBar(getTokenDecode['message']);
          msg = getTokenDecode['message'];
          setState(() {
            _isLoading = false;
          });
        } else if (getTokenDecode['error'] == 'invalid_request') {
          showInSnackBar(getTokenDecode['hint']);
          msg = getTokenDecode['hint'];
          setState(() {
            _isLoading = false;
          });
        } else if (getTokenDecode['token_type'] == 'Bearer') {
          DataStore()
              .setDataString('access_token', getTokenDecode['access_token']);
          DataStore().setDataString('token_type', getTokenDecode['token_type']);
        }
        dynamic tokenType = getTokenDecode['token_type'];
        dynamic accessToken = getTokenDecode['access_token'];
        requestHeaders['Accept'] = 'application/json';
        requestHeaders['Authorization'] = '$tokenType $accessToken';
        try {
          final getUser =
              await http.post(url("api/user"), headers: requestHeaders);
          // print('getUser ' + getUser.body);

          if (getUser.statusCode == 200) {
            Map datauser = json.decode(getUser.body);

            if (datauser["error"] == "Unauthenticated") {
              showInSnackBar(
                  'token kedaluwarsa, silahkan logout dan login kembali');
              setState(() {
                _isLoading = false;
              });
            } else if (datauser['error'] == 'invalid_credentials') {
              showInSnackBar(datauser['error_description']);
              setState(() {
                _isLoading = false;
              });
            } else if (datauser['status'] == 'sukses') {
              DataStore store = new DataStore();

              // store.setDataInteger("user_id", int.parse(datajson['user']["u_id"]));

              store.setDataString(
                "username",
                datauser['user']["u_username"],
              );
              store.setDataString(
                "name",
                datauser['user']["u_name"],
              );
              store.setDataString(
                "email",
                datauser['user']["u_email"],
              );
              store.setDataBool(
                'u_typeuser',
                datauser['superuser'],
              );
              store.setDataString(
                'idCabang',
                datauser['cabang']['b_code'],
              );
              store.setDataString(
                'namaCabang',
                datauser['cabang']['b_name'],
              );
              store.setDataString(
                'alamatCabang',
                datauser['cabang']['b_address'],
              );
              store.setDataString(
                'telponCabang',
                datauser['cabang']['b_nphone'],
              );
              if (datauser['gudang'] != null) {
                store.setDataString(
                  'idGudang',
                  datauser['gudang']['w_code'],
                );
                store.setDataString(
                  'namaGudang',
                  datauser['gudang']['w_name'],
                );
              } else {}
              store.setDataString(
                'gambarUser',
                datauser['user']['ed_path'],
              );
              store.setDataString(
                "sudah_login",
                'sudah',
              );

              print(datauser);

              for (var data in datauser['groupAkses']) {
                setGroupAkses(
                  menu: data['namamenu'],
                  read: data['read'],
                  create: data['create'],
                  edit: data['edit'],
                  delete: data['delete'],
                );
              }
              for (var data in datauser['aksesMenu']) {
                setAksesMenu(
                  menu: data['namamenu'],
                  read: data['read'],
                  create: data['create'],
                  edit: data['edit'],
                  delete: data['delete'],
                );
              }
              setState(() {
                _isLoading = false;
              });

              Navigator.pushReplacementNamed(context, "/home");
              // print('statement else is true');
              // print(datauser);
            }
          } else if (getUser.statusCode == 401) {
            showInSnackBar(
                'Token kedaluwarsa, silahkan logout dan login kembali');
          } else {
            showInSnackBar('Request failed with status: ${getUser.statusCode}');
            Map responseJson = jsonDecode(getUser.body);

            if (responseJson.containsKey('message')) {
              showInSnackBar(responseJson['message']);
            }
            setState(() {
              _isLoading = false;
            });
          }
        } on SocketException catch (_) {
          showInSnackBar('Connection Timed Out');
          setState(() {
            _isLoading = false;
          });
        } on TimeoutException catch (_) {
          showInSnackBar('Request Timeout, try again');
          print('Request Timeout, try again');
        } catch (e) {
          print(e);
          // showInSnackBar(e);
          setState(() {
            _isLoading = false;
          });
        }
      } else if (getToken.statusCode == 401) {
        showInSnackBar('Username atau Password Salah');
        setState(() {
          _isLoading = false;
        });
      } else {
        showInSnackBar('Request failed with status: ${getToken.statusCode}');
        Map responseJson = jsonDecode(getToken.body);

        if (responseJson.containsKey('message')) {
          showInSnackBar(responseJson['message']);
        }
        setState(() {
          _isLoading = false;
        });
      }
      // print(datajson.toString());

    } 
    on SocketException catch (_) {
      showInSnackBar('Connection Timed Out');
      setState(() {
        _isLoading = false;
      });
    }
     on TimeoutException catch (_) {
      showInSnackBar('Request Timeout, try again');
      print('Request Timeout, try again');
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print(e);
      showInSnackBar(e.toString());
      setState(() {
        _isLoading = false;
      });
    }
  }

  void setGroupAkses({
    @required String menu,
    @required bool read,
    @required bool create,
    @required bool edit,
    @required bool delete,
  }) async {
    // print('$menu $getGroupJson');
    DataStore store = new DataStore();

    store.setDataBool('$menu Read (Group)', read);
    store.setDataBool('$menu Create (Group)', create);
    store.setDataBool('$menu Edit (Group)', edit);
    store.setDataBool('$menu Delete (Group)', delete);
  }

  void setAksesMenu({
    @required String menu,
    @required bool read,
    @required bool create,
    @required bool edit,
    @required bool delete,
  }) async {
    var store = new DataStore();

    store.setDataBool('$menu Read (Akses)', read);
    store.setDataBool('$menu Create (Akses)', create);
    store.setDataBool('$menu Edit (Akses)', edit);
    store.setDataBool('$menu Delete (Akses)', delete);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: _scaffoldKey,
        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            // color: Colors.red,
            padding: EdgeInsets.all(15.0),
            child: Center(
              child: Form(
                key: _formKey,
                child: Container(
                  // padding: EdgeInsets.only(
                  //   bottom: 15.0,
                  // ),
                  // color: Colors.blue,
                  child: IntrinsicHeight(
                    child: Column(
                      children: <Widget>[
                        Container(
                          height:100,
                          margin: EdgeInsets.only(bottom: 10.0),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 20.0),
                          child: Text(
                            'Invee',
                            style: TextStyle(
                              fontSize: 30.0,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Text(
                          msg,
                          style: new TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                              color: Colors.red),
                        ),
                        Container(
                          child: TextFormField(
                            obscureText: false,
                            autofocus: true,
                            controller: user,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Username tidak boleh kosong!';
                              }
                              return null;
                            },
                            focusNode: userFocus,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (thisValue) {
                              FocusScope.of(context).requestFocus(passFocus);
                            },
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(10.0),
                              // labelText: 'Username',
                              hintText: 'Username',
                              border: UnderlineInputBorder(),
                            ),
                            style: TextStyle(
                              fontSize: 20.0,
                            ),
                          ),
                          margin: EdgeInsets.only(bottom: 10.0),
                        ),
                        Container(
                          child: TextFormField(
                            obscureText: true,
                            autofocus: false,
                            controller: pass,
                            focusNode: passFocus,
                            textInputAction: TextInputAction.go,
                            onFieldSubmitted: (thisValue) {
                              FocusScope.of(context).unfocus();
                              if (_isLoading) {
                                return null;
                              } else {
                                if (_formKey.currentState.validate()) {
                                  _login();
                                }
                              }
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Password tidak boleh kosong!';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(10.0),
                              // labelText: 'Password',
                              hintText: 'Password',
                              border: UnderlineInputBorder(),
                            ),
                            style: TextStyle(
                              fontSize: 20.0,
                            ),
                          ),
                          margin: EdgeInsets.only(bottom: 10.0),
                        ),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(
                              top: 25.0,
                            ),
                            width: MediaQuery.of(context).size.width,
                            child: RaisedButton(
                              color: Colors.green,
                              child: Text(
                                _isLoading ? 'Memuat..' : 'Login',
                                style: TextStyle(
                                  color: Colors.yellow,
                                  fontSize: 30.0,
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  5.0,
                                ),
                              ),
                              onPressed: () async {
                                FocusScope.of(context).unfocus();
                                if (_isLoading) {
                                  return null;
                                } else {
                                  if (_formKey.currentState.validate()) {
                                    _login();
                                  }
                                }
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

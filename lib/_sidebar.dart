import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:invee2/gudang/mutasi/barang_masuk/barang_masuk.dart';
import 'package:invee2/routes/env.dart';
import 'package:invee2/routes/navigator.dart';
import 'package:invee2/localStorage/localStorage.dart';
import 'package:invee2/error/error.dart';
import 'dart:async';
import 'package:invee2/homeModel.dart';
import 'package:invee2/notification/notification_service.dart';
import 'package:http/http.dart' as http;

Map<String, bool> listMenu = Map();
String tokenType, accessToken;
bool isLoading, isError, superuser;
Map<String, String> requestHeaders = Map();

String errorMessage;
List<Cabang> listCabang = List();
List<Gudang> listGudang = List();

String idCabang, namaCabang, idGudang, namaGudang;
Cabang selectedCabang;
Gudang selectedGudang;

String name;
String fChar;
String email;
String nameStorage;
String emailStorage, gambar;

class Sidebar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SidebarState();
  }
}

class _SidebarState extends State<Sidebar> {
  Future<Null> initFunction() async {
    setState(() {
      isError = false;
      isLoading = true;
      errorMessage = '';
    });
    DataStore dataStore = new DataStore();
    nameStorage = await dataStore.getDataString('name');
    emailStorage = await dataStore.getDataString('email');
    superuser = await dataStore.getDataBool('u_typeuser');
    idCabang = await dataStore.getDataString('idCabang');
    namaCabang = await dataStore.getDataString('namaCabang');
    idGudang = await dataStore.getDataString('idGudang');
    namaGudang = await dataStore.getDataString('namaGudang');
    gambar = await dataStore.getDataString('gambarUser');

    setState(() {
      nameStorage = nameStorage;
      emailStorage = emailStorage;
      superuser = superuser;
      idCabang = idCabang;
      namaCabang = namaCabang;
      idGudang = idGudang;
      namaGudang = namaGudang;
      gambar = gambar;
    });

    var tokenTypeStorage = await dataStore.getDataString('token_type');
    var accessTokenStorage = await dataStore.getDataString('access_token');

    tokenType = tokenTypeStorage;
    accessToken = accessTokenStorage;

    requestHeaders['Accept'] = 'application/json';
    requestHeaders['Authorization'] = '$tokenType $accessToken';

    try {
      final getUser = await http.post(
        url("api/user"),
        headers: requestHeaders,
      );
      // print('getUser ' + getUser.body);

      if (getUser.statusCode == 200) {
        dynamic datauser = json.decode(getUser.body);

        if (datauser['status'] == 'sukses') {
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

          idCabang = await dataStore.getDataString('idCabang');
          namaCabang = await dataStore.getDataString('namaCabang');
          idGudang = await dataStore.getDataString('idGudang');
          namaGudang = await dataStore.getDataString('namaGudang');

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
          listCabang = List<Cabang>();
          for (var data in datauser['list_cabang']) {
            listCabang.add(
              Cabang(id: data['b_code'], namaCabang: data['b_name']),
            );
          }

          listGudang = List<Gudang>();
          for (var data in datauser['list_gudang']) {
            listGudang.add(
              Gudang(
                idGudang: data['w_code'],
                namaGudang: data['w_name'],
              ),
            );
          }
          if (datauser['gudang'] != null) {
            setState(() {
              selectedCabang = new Cabang(
                id: idCabang,
                namaCabang: namaCabang,
              );
              selectedGudang = Gudang(
                idGudang: idGudang,
                namaGudang: namaGudang,
              );
            });
          } else {
            setState(() {
              selectedCabang = new Cabang(
                id: idCabang,
                namaCabang: namaCabang,
              );
              selectedGudang = null;
            });
          }

          // setState(() {
          //   isLoading = false;
          // });
        }
      } else if (getUser.statusCode == 401) {
        setState(() {
          isLoading = false;
          isError = true;
          errorMessage = 'Token kedaluwarsa, silahkan logout dan login kembali';
        });
        // showInSnackBar('Token kedaluwarsa, silahkan logout dan login kembali');
      } else {
        // showInSnackBar('Request failed with status: ${getUser.statusCode}');
        setState(() {
          isLoading = false;
          isError = true;
          errorMessage = 'Request failed with status: ${getUser.statusCode}';
        });
      }
    } on SocketException catch (_) {
      setState(() {
        isLoading = false;
        isError = true;
        errorMessage = 'Host not found';
      });
    } on TimeoutException catch (_) {
      setState(() {
        isLoading = false;
        isError = true;
        errorMessage = 'Request timeout, try again';
      });
    } catch (e) {
      print(e);
      // showInSnackBar(e);
      setState(() {
        isLoading = false;
        isError = true;
        errorMessage = 'Error : ${e.toString()}';
      });
    }

    groupAksesMenu(
        menu: 'Manajemen Layanan Penjualan Offline Read (Group)',
        variable: 'mlpo');
    groupAksesMenu(menu: 'Kasir Read (Group)', variable: 'kasir');
    groupAksesMenu(menu: 'Antrian Layanan Read (Group)', variable: 'antrian');
    groupAksesMenu(menu: 'Gudang Read (Group)', variable: 'gudang');
    groupAksesMenu(
        menu: 'Layanan Penjualan Read (Group)', variable: 'penjualan');
    groupAksesMenu(
        menu: 'Layanan Penjualan Offline Read (Group)',
        variable: 'penjualan_off');
    groupAksesMenu(
        menu: 'Layanan Penjualan Online Read (Group)',
        variable: 'penjualan_on');
    groupAksesMenu(
        menu: 'Layanan Item dari Nota Penjualan Read (Group)',
        variable: 'layanan_nota');
    groupAksesMenu(
        menu: 'Penerimaan Barang Masuk dari Supplier Read (Group)',
        variable: 'penerimaan_barang');
    groupAksesMenu(
        menu: 'Mutasi Barang Antar Gudang Read (Group)', variable: 'mutasi');
    groupAksesMenu(
        menu: 'Barang Keluar untuk Mutasi Antar Gudang Read (Group)',
        variable: 'barang_kel');
    groupAksesMenu(
        menu: 'Barang Masuk dari Mutasi Antar Gudang Read (Group)',
        variable: 'barang_mas');
    groupAksesMenu(menu: 'Opname Stock Read (Group)', variable: 'opname');

    groupAksesMenu(
        menu: 'Manajemen Layanan Penjualan Offline Read (Akses)',
        variable: 'mlpo_akses');
    groupAksesMenu(menu: 'Kasir Read (Akses)', variable: 'kasir_akses');
    groupAksesMenu(
        menu: 'Antrian Layanan Read (Akses)', variable: 'antrian_akses');
    groupAksesMenu(menu: 'Gudang Read (Akses)', variable: 'gudang_akses');
    groupAksesMenu(
        menu: 'Layanan Penjualan Read (Akses)', variable: 'penjualan_akses');
    groupAksesMenu(
        menu: 'Layanan Penjualan Offline Read (Akses)',
        variable: 'penjualan_off_akses');
    groupAksesMenu(
        menu: 'Layanan Penjualan Online Read (Akses)',
        variable: 'penjualan_on_akses');
    groupAksesMenu(
        menu: 'Layanan Item dari Nota Penjualan Read (Akses)',
        variable: 'layanan_nota_akses');
    groupAksesMenu(
        menu: 'Penerimaan Barang Masuk dari Supplier Read (Akses)',
        variable: 'penerimaan_barang_akses');
    groupAksesMenu(
        menu: 'Mutasi Barang Antar Gudang Read (Akses)',
        variable: 'mutasi_akses');
    groupAksesMenu(
        menu: 'Barang Keluar untuk Mutasi Antar Gudang Read (Akses)',
        variable: 'barang_kel_akses');
    groupAksesMenu(
        menu: 'Barang Masuk dari Mutasi Antar Gudang Read (Akses)',
        variable: 'barang_mas_akses');
    groupAksesMenu(menu: 'Opname Stock Read (Akses)', variable: 'opname_akses');
    groupAksesMenu(menu: 'Wishlist Read (Akses)', variable: 'wishlist_akses');
    groupAksesMenu(menu: 'Wishlist Read (Group)', variable: 'wishlist_group');
    groupAksesMenu(menu: 'Keranjang Read (Akses)', variable: 'keranjang_akses');
    groupAksesMenu(menu: 'Keranjang Read (Group)', variable: 'keranjang_group');
    groupAksesMenu(
        menu: 'Rencana Penjualan Online Read (Akses)',
        variable: 'rencana_penjualan_online_akses');
    groupAksesMenu(
        menu: 'Rencana Penjualan Online Read (Group)',
        variable: 'rencana_penjualan_online_group');
    groupAksesMenu(menu: 'Master Read (Akses)', variable: 'master_akses');
    groupAksesMenu(menu: 'Master Read (Group)', variable: 'master_group');
    groupAksesMenu(menu: 'Customer Read (Akses)', variable: 'customer_akses');
    groupAksesMenu(menu: 'Customer Read (Group)', variable: 'customer_group');

    print(idCabang);
    print(namaCabang);

    setState(() {
      name = nameStorage;
      email = emailStorage;
      isLoading = false;
      fChar = name.substring(0, 1).toUpperCase();
    });
  }

  @override
  void initState() {
    isLoading = false;
    isError = false;
    selectedCabang = null;
    selectedGudang = null;

    superuser = false;
    name = '';
    fChar = '';
    email = '';

    nameStorage = '';
    emailStorage = '';
    gambar = '';

    print(listCabang);
    initFunction();

    print(listMenu);
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
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

  void groupAksesMenu({menu, variable}) async {
    DataStore storage = new DataStore();

    bool menuStorage = await storage.getDataBool(menu);
    setState(() {
      listMenu[variable] = menuStorage;
    });
  }

  Widget selectCabang(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(
        left: 10.0,
        right: 10.0,
      ),
      child: Center(
        child: DropdownButton(
          isExpanded: true,
          items: listCabang
              .map((Cabang f) => DropdownMenuItem(
                    value: f,
                    child: Text(f.namaCabang),
                  ))
              .toList(),
          value: selectedCabang,
          onChanged: (Cabang thisValue) async {
            setState(() {
              selectedCabang = thisValue;
              isLoading = true;
              isError = false;
            });
            try {
              final response = await http.post(
                url('api/gantiCabang'),
                headers: requestHeaders,
                body: {
                  'cabang': thisValue.id,
                },
              );

              if (response.statusCode == 200) {
                dynamic responseJson = jsonDecode(response.body);
                if (responseJson['status'] == 'sukses') {
                  Navigator.pushReplacementNamed(context, '/home');
                }
              } else if (response.statusCode == 401) {
                setState(() {
                  isLoading = false;
                  isError = true;
                  errorMessage =
                      'Token kedaluwarsa, silahkan logout dan login kembali';
                });
              } else {
                setState(() {
                  isLoading = false;
                  isError = true;
                  errorMessage = 'Error Code : ${response.statusCode}';
                });
              }
            } catch (e) {
              setState(() {
                isLoading = false;
                isError = true;
                errorMessage = e.toString();
              });
            }
          },
        ),
      ),
    );
  }

  Widget selectGudang(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(
        left: 10.0,
        right: 10.0,
      ),
      child: Center(
        child: DropdownButton(
          isExpanded: true,
          items: listGudang
              .map((Gudang f) => DropdownMenuItem(
                    value: f,
                    child: Text(f.namaGudang),
                  ))
              .toList(),
          value: selectedGudang,
          onChanged: (Gudang thisValue) async {
            setState(() {
              selectedGudang = thisValue;
              isLoading = true;
              isError = false;
            });
            try {
              final response = await http.post(
                url('api/gantiGudang'),
                headers: requestHeaders,
                body: {
                  'gudang': thisValue.idGudang,
                },
              );

              if (response.statusCode == 200) {
                dynamic responseJson = jsonDecode(response.body);
                if (responseJson['status'] == 'sukses') {
                  Navigator.pushReplacementNamed(context, '/home');
                }
              } else if (response.statusCode == 401) {
                setState(() {
                  isLoading = false;
                  isError = true;
                  errorMessage =
                      'Token kedaluwarsa, silahkan logout dan login kembali';
                });
              } else {
                Map responseJson = jsonDecode(response.body);

                if (responseJson.containsKey('message')) {
                  setState(() {
                    isLoading = false;
                    isError = true;
                    errorMessage = responseJson['message'];
                  });
                } else {
                  setState(() {
                    isLoading = false;
                    isError = true;
                    errorMessage = 'Error Code : ${response.statusCode}';
                  });
                }
              }
            } catch (e) {
              setState(() {
                isLoading = false;
                isError = true;
                errorMessage = e.toString();
              });
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          Column(
            children: <Widget>[
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(-1, 0),
                    end: Alignment(1, 1),
                    stops: [
                      0.1,
                      0.4,
                      0.5,
                      0.9,
                    ],
                    colors: [
                      Colors.green,
                      Colors.green[700],
                      Colors.green[700],
                      Colors.green,
                    ],
                  ),
                ),
                accountName: Text(
                  '$name',
                  style: TextStyle(color: Colors.white),
                ),
                accountEmail: Text(
                  '$email',
                  style: TextStyle(color: Colors.white70),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor:
                      Theme.of(context).platform == TargetPlatform.iOS
                          ? Colors.blue
                          : Colors.white,
                  child: Text(
                    "$fChar",
                    style: TextStyle(fontSize: 40.0, color: Colors.orange),
                  ),
                ),
              ),
            ],
          ),
          isLoading
              ? Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : isError
                  ? Expanded(
                      child: Center(
                        child: ErrorOutputWidget(
                          errorMessage: errorMessage,
                          onPress: () => initFunction(),
                        ),
                      ),
                    )
                  : Expanded(
                      child: ListView(
                        children: <Widget>[
                          superuser ? selectCabang(context) : Container(),
                          superuser ? selectGudang(context) : Container(),
                          Master(),
                          ManajemenLayananPenjualanOnline(),
                          ManajemenLayananPenjualanOflline(),
                          GudangMenu(),
                        ],
                      ),
                    ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(width: 1.0, color: Colors.grey[300]),
              ),
            ),
            child: ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Log Out'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Peringatan!'),
                      content: Text('Apa anda yakin ingin logout?'),
                      actions: <Widget>[
                        FlatButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Tidak',
                          ),
                        ),
                        FlatButton(
                          child: Text(
                            'Ya',
                            style: TextStyle(color: Colors.grey),
                          ),
                          onPressed: () async {
                            setState(() {
                              isLoading = true;
                            });
                            flutterLocalNotificationsPlugin.cancelAll();
                            try {
                              final response = await http.get(
                                url('api/logoutAndroid'),
                                headers: requestHeaders,
                              );
                              if (response.statusCode == 200) {
                                dynamic responseJson =
                                    jsonDecode(response.body);

                                setState(() {
                                  isLoading = false;
                                });

                                if (responseJson['status'] == 'sukses') {
                                  DataStore().clearData();
                                  Navigator.pushReplacementNamed(
                                      context, "/login");
                                }
                              } else {
                                print('Error Code : ${response.statusCode}');
                                print(jsonDecode(response.body));
                                DataStore().clearData();
                                Navigator.pushReplacementNamed(
                                    context, "/login");

                                setState(() {
                                  isLoading = false;
                                });
                              }
                            } on TimeoutException catch (_) {
                              setState(() {
                                isLoading = false;
                              });
                            } catch (e, stacktrace) {
                              print('Error = $e || Stacktrace = $stacktrace');

                              setState(() {
                                isLoading = false;
                              });
                              DataStore().clearData();
                              Navigator.pushReplacementNamed(context, "/login");
                            }
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Master extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (listMenu['master_akses'] == true || listMenu['master_group'] == true) {
      return ExpansionTile(
        key: UniqueKey(),
        leading: Icon(
          FontAwesomeIcons.crown,
          size: 20.0,
        ),
        title: Text(
          'Master',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16.0,
          ),
        ),
        children: <Widget>[
          Customer(),
        ],
      );
    } else {
      return Container();
    }
  }
}

class Customer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (listMenu['customer_akses'] == true ||
        listMenu['customer_group'] == true) {
      return ListTile(
        leading: Padding(
          padding: EdgeInsets.only(left: 7.0),
          child: Icon(Icons.label),
        ),
        title: Text('Customer'),
        onTap: () {
          Navigator.pushNamed(context, '/master_customer');
        },
      );
    } else {
      return Container();
    }
  }
}

class ManajemenLayananPenjualanOnline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (listMenu['rencana_penjualan_online_akses'] == true ||
        listMenu['rencana_penjualan_online_group'] == true) {
      return ExpansionTile(
        key: UniqueKey(),
        leading: Icon(Icons.shopping_cart),
        title: Text(
          'Rencana Penjualan Online',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16.0,
          ),
        ),
        children: <Widget>[
          Wishlist(),
          Keranjang(),
        ],
      );
    } else {
      return Container();
    }
  }
}

class Wishlist extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (listMenu['wishlist_akses'] == true ||
        listMenu['wishlist_group'] == true) {
      return ListTile(
        leading: Padding(
          padding: EdgeInsets.only(left: 7.0),
          child: Icon(Icons.label),
        ),
        title: Text('Wishlist'),
        onTap: () {
          MyNavigator.goToWishlist(context);
        },
      );
    } else {
      return Container();
    }
  }
}

class Keranjang extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (listMenu['keranjang_akses'] == true ||
        listMenu['keranjang_group'] == true) {
      return ListTile(
        leading: Padding(
          padding: EdgeInsets.only(left: 7.0),
          child: Icon(Icons.label),
        ),
        title: Text('Keranjang'),
        onTap: () {
          MyNavigator.goToKeranjang(context);
        },
      );
    } else {
      return Container();
    }
  }
}

class ManajemenLayananPenjualanOflline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (listMenu['mlpo'] == true || listMenu['mlpo_akses'] == true) {
      return ExpansionTile(
        key: UniqueKey(),
        leading: Icon(Icons.shopping_cart),
        title: Text(
          'Layanan Penjualan Offline',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16.0,
          ),
        ),
        children: <Widget>[
          Kasir(),
          AntrianLayanan(),
        ],
      );
    } else {
      return Container();
    }
  }
}

class Kasir extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (listMenu['kasir'] == true || listMenu['kasir_akses'] == true) {
      return ListTile(
        leading: Padding(
          padding: EdgeInsets.only(left: 7.0),
          child: Icon(Icons.label),
        ),
        title: Text('Kasir'),
        onTap: () {
          MyNavigator.goKasir(context);
        },
      );
    } else {
      return Container();
    }
  }
}

class AntrianLayanan extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (listMenu['antrian'] == true || listMenu['antrian_akses'] == true) {
      return ListTile(
        leading: Padding(
          padding: EdgeInsets.only(left: 7.0),
          child: Icon(Icons.label),
        ),
        title: Text('Antrian Layanan'),
        onTap: () {
          MyNavigator.goAntrian(context);
        },
      );
    } else {
      return Container();
    }
  }
}

class GudangMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (listMenu['gudang'] == true || listMenu['gudang_akses'] == true) {
      return ExpansionTile(
        key: UniqueKey(),
        leading: Icon(Icons.home),
        title: Text(
          'Gudang',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16.0,
          ),
        ),
        children: <Widget>[
          LayananPenjualan(),
          PenerimaanBarang(),
          Mutasi(),
          OpnameStock(),
        ],
      );
    } else {
      return Container();
    }
  }
}

class LayananPenjualan extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (listMenu['penjualan'] == true || listMenu['penjualan_akses'] == true) {
      return ExpansionTile(
        key: UniqueKey(),
        leading: Padding(
          padding: EdgeInsets.only(left: 7.0),
          child: Icon(Icons.home),
        ),
        title: Text('Layanan Penjualan'),
        children: <Widget>[
          PenjualanOffline(),
          PenjualanOnline(),
          LayananNota(),
        ],
      );
    } else {
      return Container();
    }
  }
}

class PenjualanOffline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (listMenu['penjualan_off'] == true ||
        listMenu['penjualan_off_akses'] == true) {
      return ListTile(
        leading: Padding(
          padding: EdgeInsets.only(left: 15.0),
          child: Icon(Icons.label),
        ),
        title: Text('Layanan Penjualan Offline'),
        onTap: () {
          MyNavigator.goPenjualanOffline(context);
        },
      );
    } else {
      return Container();
    }
  }
}

class PenjualanOnline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (listMenu['penjualan_on'] == true ||
        listMenu['penjualan_on_akses'] == true) {
      return ListTile(
        leading: Padding(
          padding: EdgeInsets.only(left: 15.0),
          child: Icon(Icons.label),
        ),
        title: Text('Layanan Penjualan Online'),
        onTap: () {
          MyNavigator.goPenjualanOnline(context);
        },
      );
    } else {
      return Container();
    }
  }
}

class LayananNota extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (listMenu['layanan_nota'] == true ||
        listMenu['layanan_nota_akses'] == true) {
      return ListTile(
        leading: Padding(
          padding: EdgeInsets.only(left: 15.0),
          child: Icon(Icons.label),
        ),
        title: Text('Layanan Item dari Nota Penjualan'),
        onTap: () {
          Navigator.pushNamed(context, '/layanan_nota');
        },
      );
    } else {
      return Container();
    }
  }
}

class PenerimaanBarang extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (listMenu['penerimaan_barang'] == true ||
        listMenu['penerimaan_barang_akses'] == true) {
      return ListTile(
        leading: Padding(
          padding: EdgeInsets.only(left: 7.0),
          child: Icon(Icons.label),
        ),
        title: Text('Penerimaan Barang Masuk dari Supplier'),
        onTap: () {
          MyNavigator.goPenerimaanBarang(context);
        },
      );
    } else {
      return Container();
    }
  }
}

class Mutasi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (listMenu['mutasi'] == true || listMenu['mutasi_akses'] == true) {
      return ExpansionTile(
        key: UniqueKey(),
        leading: Padding(
          padding: EdgeInsets.only(left: 7.0),
          child: Icon(Icons.home),
        ),
        title: Text('Mutasi Barang Antar Gudang'),
        children: <Widget>[
          BarangKeluar(),
          BarangMasukSidebar(),
        ],
      );
    } else {
      return Container();
    }
  }
}

class BarangKeluar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (listMenu['barang_kel'] == true ||
        listMenu['barang_kel_akses'] == true) {
      return ListTile(
        leading: Padding(
          padding: EdgeInsets.only(left: 15.0),
          child: Icon(Icons.label),
        ),
        title: Text('Barang Keluar untuk Mutasi Antar Gudang'),
        onTap: () {
          MyNavigator.goBarangKeluar(context);
        },
      );
    } else {
      return Container();
    }
  }
}

class BarangMasukSidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (listMenu['barang_mas'] == true ||
        listMenu['barang_mas_akses'] == true) {
      return ListTile(
        leading: Padding(
          padding: EdgeInsets.only(left: 15.0),
          child: Icon(Icons.label),
        ),
        title: Text('Barang Masuk dari Mutasi Antar Gudang'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              settings: RouteSettings(name: '/barang_masuk'),
              builder: (BuildContext context) => BarangMasuk(),
            ),
          );
        },
      );
    } else {
      return Container();
    }
  }
}

class OpnameStock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (listMenu['opname'] == true || listMenu['opname_akses'] == true) {
      return ListTile(
        leading: Padding(
          padding: EdgeInsets.only(left: 7.0),
          child: Icon(Icons.label),
        ),
        title: Text('Opname Stock'),
        onTap: () {
          MyNavigator.goOpnameStock(context);
        },
      );
    } else {
      return Container();
    }
  }
}

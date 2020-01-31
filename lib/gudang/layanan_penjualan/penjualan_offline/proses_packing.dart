import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:invee2/gudang/layanan_penjualan/penjualan_offline/model.dart';
import 'package:invee2/routes/env.dart';
import 'dart:async';
import 'dart:convert';
import 'package:invee2/localStorage/localStorage.dart';

String accessToken, tokenType;
Map<String, String> requestHeaders = Map();
List<ListItem> listItem;
bool isLoading, isStokKurangDiRuangPengemasan, isSimpan;
GlobalKey<ScaffoldState> _scaffoldKey;

bool userAksesMenuLayananPenjualanOffline,
    userGroupAksesMenuLayananPenjualanOffline;
TextEditingController durasiController;
GlobalKey<FormState> formKey;

class ProsesPacking extends StatefulWidget {
  final String id,
      nota,
      customer,
      status,
      userProses,
      userDone,
      durasi,
      tanggalProses,
      createAt;
  ProsesPacking({
    Key key,
    @required this.id,
    @required this.nota,
    @required this.customer,
    @required this.status,
    @required this.userDone,
    @required this.userProses,
    @required this.durasi,
    @required this.tanggalProses,
    @required this.createAt,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ProsesPackingState();
  }
}

class _ProsesPackingState extends State<ProsesPacking> {
  Future<Null> getHeaderHTTP() async {
    var storage = new DataStore();

    var tokenTypeStorage = await storage.getDataString('token_type');
    var accessTokenStorage = await storage.getDataString('access_token');

    tokenType = tokenTypeStorage;
    accessToken = accessTokenStorage;

    requestHeaders['Accept'] = 'application/json';
    requestHeaders['Authorization'] = '$tokenType $accessToken';
    print(requestHeaders);

    listItemNotaAndroid();
  }

  bool _checkbox = false;

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  void _dialogUbahStatusSelesai(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'Tidak',
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Ya'),
              onPressed: isSimpan
                  ? null
                  : () async {
                      // print('aws');

                      setState(() {
                        isSimpan = true;
                      });
                      try {
                        final ubahStatusProses = await http.post(
                          url('api/updateStatusPackingSelesai'),
                          headers: requestHeaders,
                          body: {
                            'nota': widget.nota,
                          },
                        );

                        if (ubahStatusProses.statusCode == 200) {
                          var ubahStatusProsesJson =
                              json.decode(ubahStatusProses.body);
                          if (ubahStatusProsesJson['status'] == 'sukses') {
                            setState(() {
                              isSimpan = false;
                            });
                            Navigator.popUntil(
                              context,
                              ModalRoute.withName('/penjualan_offline'),
                            );
                          } else if (ubahStatusProsesJson['status'] ==
                              'gagal') {
                            showInSnackBar(
                                'Gagal! Hubungi pengembang software!');
                            setState(() {
                              isSimpan = false;
                            });
                          }
                        } else if (ubahStatusProses.statusCode == 401) {
                          showInSnackBar(
                              'Token kedaluwarsa, silahkan logout dan login kembali');
                          setState(() {
                            isSimpan = false;
                          });
                        } else {
                          showInSnackBar(
                              'Request failed with status: ${ubahStatusProses.statusCode}');
                          print(jsonDecode(ubahStatusProses.body));
                        }
                      } on TimeoutException catch (_) {
                        showInSnackBar('Timed out, Try again');
                        setState(() {
                          isSimpan = false;
                        });
                      } catch (e) {
                        print(e);
                        setState(() {
                          isSimpan = false;
                        });
                      }
                    },
            )
          ],
        );
      },
    );
  }

  void _dialogUbahStatusProses(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'Tidak',
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Ya'),
              onPressed: isSimpan
                  ? null
                  : () async {
                      setState(() {
                        isSimpan = true;
                      });
                      try {
                        final ubahStatusProses = await http.post(
                          url('api/updateStatusProsesPacking'),
                          headers: requestHeaders,
                          body: {
                            'nota': widget.nota,
                            'durasi': durasiController.text,
                          },
                        );

                        if (ubahStatusProses.statusCode == 200) {
                          Map ubahStatusProsesJson =
                              json.decode(ubahStatusProses.body);
                          if (ubahStatusProsesJson.containsKey('status')) {
                            if (ubahStatusProsesJson['status'] == 'sukses') {
                              Navigator.popUntil(context,
                                  ModalRoute.withName('/penjualan_offline'));
                            } else if (ubahStatusProsesJson['status'] ==
                                'gagal') {
                              showInSnackBar(
                                  'Gagal! Hubungi pengembang software!');
                            }
                          } else {
                            print(ubahStatusProsesJson);
                          }
                          setState(() {
                            isSimpan = false;
                          });
                        } else {
                          showInSnackBar(
                              'Request failed with status: ${ubahStatusProses.statusCode}');
                          print(jsonDecode(ubahStatusProses.body));
                          setState(() {
                            isSimpan = false;
                          });
                        }
                      } on TimeoutException catch (_) {
                        showInSnackBar('Timed out, Try again');
                        setState(() {
                          isSimpan = false;
                        });
                      } catch (e) {
                        print(e);
                        showInSnackBar('Error : ${e.toString()}');
                        setState(() {
                          isSimpan = false;
                        });
                      }
                    },
            )
          ],
        );
      },
    );
  }

  Future<List<ListItem>> listItemNotaAndroid() async {
    setState(() {
      isLoading = true;
      isSimpan = true;
    });
    try {
      final item = await http.get(
        url('api/listItemNotaAndroidoff?nota=${widget.nota}'),
        headers: requestHeaders,
      );

      if (item.statusCode == 200) {
        // return nota;
        var itemJson = json.decode(item.body);
        // print(itemJson);
        listItem = [];
        for (var i in itemJson) {
          ListItem notax = ListItem(
            nama: i['i_name'],
            satuan: i['iu_name'],
            qty: i['sd_qty'].toString(),
            idGudang: i['w_id'].toString(),
            gudang: i['w_name'],
            kodeBarang: i['sp_cproduct'],
            stokPacking:
                i['sp_stock'] == null ? 0.toString() : i['sp_stock'].toString(),
          );
          listItem.add(notax);
        }

        // print('listItem $listItem');
        // print('length listItem ${listItem.length}');
        setState(() {
          isLoading = false;
          isSimpan = false;
        });
        return listItem;
      } else {
        showInSnackBar('Request failed with status: ${item.statusCode}');
        Map responseJson = jsonDecode(item.body);

        if (responseJson.containsKey('message')) {
          showInSnackBar(responseJson['message']);
        }
        setState(() {
          isLoading = false;
          isSimpan = false;
        });
      }
    } on TimeoutException catch (_) {
      showInSnackBar('Timed out, Try again');
      setState(() {
        isSimpan = false;
        isLoading = false;
      });
    } catch (e) {
      print(e);
      showInSnackBar('Error : ${e.toString()}');
      setState(() {
        isLoading = false;
        isSimpan = false;
      });
    }
    setState(() {
      isLoading = false;
      isSimpan = false;
    });
    return null;
  }

  getUserAksesDanGroupAkses() async {
    DataStore store = new DataStore();

    userAksesMenuLayananPenjualanOffline =
        await store.getDataBool('Layanan Penjualan Offline Edit (Akses)');
    userGroupAksesMenuLayananPenjualanOffline =
        await store.getDataBool('Layanan Penjualan Offline Edit (Group)');

    setState(() {
      userAksesMenuLayananPenjualanOffline =
          userAksesMenuLayananPenjualanOffline;
      userGroupAksesMenuLayananPenjualanOffline =
          userGroupAksesMenuLayananPenjualanOffline;
    });
  }

  Widget checkboxStatus(status) {
    if (userAksesMenuLayananPenjualanOffline ||
        userGroupAksesMenuLayananPenjualanOffline) {
      if (status == 'Y') {
        return Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  flex: 4,
                  child: Container(
                    width: double.infinity,
                    child: Text(
                      'Ubah Status',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                Expanded(
                    flex: 5,
                    child: InkWell(
                      onTap: () {
                        if (_checkbox) {
                          setState(() {
                            _checkbox = false;
                          });
                        } else {
                          setState(() {
                            _checkbox = true;
                          });
                        }
                      },
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 35.0,
                            child: Checkbox(
                              value: _checkbox,
                              onChanged: (thisValue) {},
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Text('Packing Selesai'),
                            ),
                          )
                        ],
                      ),
                    ))
              ],
            ),
          ],
        );
      } else if (status == 'P') {
        return Container();
      }
    }
    return Container();
  }

  Widget appBarText(status) {
    if (status == 'Y') {
      return Text('Proses Packing');
    } else if (status == 'P') {
      return Text('Detail Nota Penjualan Offline');
    }
    return null;
  }

  Widget actionButton(status) {
    if (userAksesMenuLayananPenjualanOffline ||
        userGroupAksesMenuLayananPenjualanOffline) {
      if (status == 'Y') {
        return FloatingActionButton(
          child: Icon(Icons.check),
          onPressed: () {
            for (ListItem i in listItem) {
              print('ya');
              if (int.parse(i.qty) > int.parse(i.stokPacking)) {
                isStokKurangDiRuangPengemasan = true;
                print('true');
                break;
              } else {
                print('false');
                isStokKurangDiRuangPengemasan = false;
              }
            }
            if (isStokKurangDiRuangPengemasan == false) {
              if (_checkbox == true) {
                if (isLoading == false) {
                  _dialogUbahStatusSelesai(
                      'Peringatan', 'Apa anda yakin mengakhiri proses ini?');
                } else {
                  showInSnackBar('Loading');
                }
              } else {
                showInSnackBar('Centang status packing terlebih dahulu!');
              }
            } else {
              showInSnackBar('Stok kurang di ruang pengemasan');
            }
          },
        );
      } else if (status == 'P') {
        return FloatingActionButton(
          child: Icon(Icons.input),
          onPressed: () {
            if (formKey.currentState.validate()) {
              _dialogUbahStatusProses(
                  'Peringatan!', 'Apa anda yakin memproses nota ini?');
            } else {
              showInSnackBar('Cek field input');
            }
          },
        );
      }
      return Container();
    }
    return Container();
  }

  Widget durasiPacking(String status) {
    if (status == 'P') {
      return Form(
        key: formKey,
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 4,
              child: Text(
                'Durasi Proses Packing',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: TextFormField(
                controller: durasiController,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  WhitelistingTextInputFormatter.digitsOnly
                ],
                decoration: InputDecoration(
                  hintText: 'Durasi proses packing',
                  suffixIcon: Icon(
                    FontAwesomeIcons.clock,
                    size: 19.0,
                  ),
                ),
                onChanged: (ini) {
                  durasiController.value = TextEditingValue(
                    selection: durasiController.selection,
                    text: ini,
                  );
                },
                validator: (ini) {
                  if (ini.isEmpty) {
                    return 'Input tidak boleh kosong';
                  } else if (int.parse(ini) < 1) {
                    return 'Durasi packing tidak boleh 0';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      );
    }
    return Container();
  }

  Widget tilePerkiraanDurasiPacking() {
    if (widget.status == 'Y') {
      String perkiraanTanggal = DateFormat('dd MMMM yyyy hh:mm:ss').format(
        DateTime.parse(widget.tanggalProses).add(
          Duration(
            minutes: int.parse(widget.durasi),
          ),
        ),
      );
      return Container(
        child: Column(
          children: <Widget>[
            Divider(),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 4,
                  child: Text(
                    'Durasi',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Text('${widget.durasi} Menit'),
                ),
              ],
            ),
            Divider(),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 4,
                  child: Text(
                    'Tanggal Konfirm',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Text(
                    DateFormat('dd MMMM yyyy hh:mm:ss').format(
                      DateTime.parse(widget.tanggalProses),
                    ),
                  ),
                )
              ],
            ),
            Divider(),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 4,
                  child: Text(
                    'Perkiraan Selesai',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Text(perkiraanTanggal),
                ),
              ],
            ),
            Divider(),
          ],
        ),
      );
    }
    return Container();
  }

  @override
  void initState() {
    _scaffoldKey = new GlobalKey<ScaffoldState>();
    listItem = [];
    isLoading = true;
    isSimpan = false;

    isStokKurangDiRuangPengemasan = false;
    durasiController = TextEditingController();
    formKey = GlobalKey<FormState>();

    getUserAksesDanGroupAkses();
    getHeaderHTTP();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          title: appBarText(widget.status),
        ),
        floatingActionButton: actionButton(widget.status),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : RefreshIndicator(
                onRefresh: listItemNotaAndroid,
                child: Scrollbar(
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Container(
                          color: Colors.white,
                          padding: EdgeInsets.all(15.0),
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      'Nota',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 5,
                                    child: Text(
                                      widget.nota,
                                      style: TextStyle(
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Divider(),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      'Customer',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 5,
                                    child: Text(
                                      widget.customer,
                                      style: TextStyle(
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Divider(),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      'Tanggal Penjualan Dibuat',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 5,
                                    child: Text(
                                      widget.createAt != 'null' ||
                                              widget.createAt != null
                                          ? DateFormat('dd MMMM yyyy hh:mm:ss')
                                              .format(
                                              DateTime.parse(widget.createAt),
                                            )
                                          : 'Kosong',
                                      style: TextStyle(
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Divider(),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      'Di Proses Oleh',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  widget.userProses != null
                                      ? Expanded(
                                          flex: 5,
                                          child: Text(
                                            widget.userProses,
                                            style: TextStyle(
                                              color: Colors.green,
                                            ),
                                          ),
                                        )
                                      : Expanded(
                                          flex: 5,
                                          child: Text(
                                            'Belum Di Proses',
                                            style: TextStyle(
                                              color: Colors.orange,
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                              tilePerkiraanDurasiPacking(),
                              checkboxStatus(widget.status),
                              widget.status == 'P' ? Divider() : Container(),
                              durasiPacking(widget.status),
                            ],
                          ),
                        ),
                        listItem.length == 0
                            ? Card(
                                child: ListTile(
                                  title: Text(
                                    'Tidak ada data',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            : Container(
                                margin: EdgeInsets.only(
                                  bottom: 55.0,
                                ),
                                child: Column(
                                  children: listItem.map(
                                    (ListItem listItem) {
                                      return Card(
                                        child: ListTile(
                                          title: Text(listItem.nama),
                                          subtitle: Text(listItem.gudang),
                                          trailing: IntrinsicHeight(
                                            child: Column(
                                              children: <Widget>[
                                                Text(
                                                    '${listItem.qty} / ${listItem.stokPacking}'),
                                                Text(listItem.satuan)
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ).toList(),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

Widget statusNota(status) {
  if (status == 'P') {
    return Text(
      '',
      style: TextStyle(backgroundColor: Colors.cyan, color: Colors.white),
    );
  } else if (status == 'Y') {
    return Text(
      "Proses Packing",
      style: TextStyle(backgroundColor: Colors.orange, color: Colors.white),
    );
  }
  return null;
}

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:invee2/gudang/opname_stock/tab_manual/customListTileOpnameManual.dart';
import 'package:invee2/localStorage/localStorage.dart';
import 'package:invee2/routes/env.dart';
import './model.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';

// ========================= Variable Opname Stok Manual
List<ListLokasiGudang> _lokasiOpname;
ListLokasiGudang _lokasiOpnameSelected;
String tokenType, accessToken;
Map<String, String> requestHeaders = Map();
Map<String, dynamic> _formSerialize = Map();

TextEditingController _catatanOpname;
TextEditingController _satuanProduk;
TextEditingController _stokSysProduk;
TextEditingController _stokGdgProduk;
TextEditingController _stokAdjustment;
TextEditingController _datepicker;
DateTime dateNow = new DateTime.now();
String _kodeSatuanProduk;
DateTime date1;
bool isLoading;
bool _validasiTambahProdukSudahAda /*, _validasiGudang*/;

GlobalKey<ScaffoldState> _scaffoldKey;
GlobalKey<AutoCompleteTextFieldState<ListProduk>> autoCompleteKey;
AutoCompleteTextField autoCompleteProdukField;
List<ListProduk> listProduk;
String ref;
GlobalKey<FormState> _form = GlobalKey<FormState>();
GlobalKey<FormState> _formTambahProduk = GlobalKey<FormState>();

List<ListProdukDiTambahkan> listProdukDiTambahkan;
String kodeProdukField;
FocusNode _catatanOpnameFokus;
FocusNode _stokGdgProdukFokus;
FocusNode _autoCompleteProdukFokus;
int tabControllerIndex;

FocusNode focusDatePicker;

// ==================== End Variable Stok Opname Manual ==================== //

// =============================== Snackbar
void showInSnackBarO(String value, {SnackBarAction action}) {
  _scaffoldKey.currentState.showSnackBar(new SnackBar(
    content: new Text(value),
    action: action,
  ));
}

class TambahOpnameManual extends StatefulWidget {
  TambahOpnameManual({
    Key key,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _TambahOpnameManualState();
  }
}

class _TambahOpnameManualState extends State<TambahOpnameManual>
    with TickerProviderStateMixin {
  // ======================== function getHeaderHTTP untuk header request http

// ========================== function get PRODUK dan GUDANG
  Future<Null> tambahOpnameStockAndroid() async {
    DataStore storage = new DataStore();

    String tokenTypeStorage = await storage.getDataString('token_type');
    String accessTokenStorage = await storage.getDataString('access_token');

    tokenType = tokenTypeStorage;
    accessToken = accessTokenStorage;

    requestHeaders['Accept'] = 'application/json';
    requestHeaders['Authorization'] = '$tokenType $accessToken';
    print(requestHeaders);

    try {
      final dataForm = await http.get(
        url('api/tambah_opname_stock_android'),
        headers: requestHeaders,
      );
      // Dio dio = new Dio();

      // Response dataForm = await dio.get(
      //   url('api/tambah_opname_stock_android'),
      //   options: Options(
      //     headers: requestHeaders,
      //   ),
      // );

      if (dataForm.statusCode == 200) {
        // dynamic dataFormJson = dataForm.data;
        dynamic dataFormJson = jsonDecode(dataForm.body);
        print("produk length ${dataFormJson['produk'].length}");

        _lokasiOpnameSelected = ListLokasiGudang(
            kodeGudang: dataFormJson['gudang']['w_id'].toString(),
            namaGudang: dataFormJson['gudang']['w_name']);

        print('b');
        for (dynamic j in dataFormJson['produk']) {
          ListProduk _produkFormJson =
              ListProduk(kodeProduk: j['i_code'], namaProduk: j['i_name']);
          listProduk.add(_produkFormJson);
        }

        print(_lokasiOpname);
        print("produk length ${listProduk.length}");
        print(listProduk);

        setState(() {
          ref = "${dataFormJson['ref']}";
          _formSerialize['referensi'] = dataFormJson['ref'];
          isLoading = false;
        });
      } else if (dataForm.statusCode == 401) {
        showInSnackBarO('Token kedaluwarsa, silahkan logout dan login kembali');
      } else {
        showInSnackBarO('Error Code = ${dataForm.statusCode}');
        Map responseJson = jsonDecode(dataForm.body);

        if (responseJson.containsKey('message')) {
          showInSnackBarO(responseJson['message']);
        }
      }
      // } on DioError catch (e) {
      //   // if(e.response) {
      //   print(e.response.data);
      //   print(e.response.headers);
      //   print(e.response.request);
      //   // } else{
      //   // Something happened in setting up or sending the request that triggered an Error
      //   print(e.request);
      //   print(e.message);
      //   // }
    } on TimeoutException catch (_) {
      showInSnackBarO('Timeout, try again later');
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }
// ================================== end get produk untuk autocomplete ==================================

// ======================== function GETSTOK setelah pilih produk di autocomplete
  void getStok({String kodeProduk, String kodeGudang}) async {
    if (kodeProduk.isEmpty || kodeGudang.isEmpty) {
      if (kodeProduk.isEmpty) {
        kodeProduk = '';
      }
      if (kodeGudang.isEmpty) {
        kodeGudang = '';
      }
    }
    try {
      final response = await http.post(
        url('api/get_stock'),
        headers: requestHeaders,
        body: {
          'produk': kodeProduk,
          'gudang': kodeGudang,
        },
      );

      // Dio dio = new Dio();

      // Response response = await dio.post(
      //   url('api/get_stock'),
      //   options: Options(
      //     headers: requestHeaders,
      //   ),
      //   data: {
      //     'produk': kodeProduk,
      //     'gudang': kodeGudang,
      //   },
      // );

      if (response.statusCode == 200) {
        // dynamic responseJson = response.data;
        dynamic responseJson = jsonDecode(response.body);
        print(responseJson);
        print('a');
        setState(() {
          _satuanProduk.text = responseJson['satuan']['iu_name'];
          _kodeSatuanProduk = responseJson['satuan']['iu_code'];
          _stokSysProduk.text = "${responseJson['stock']}";
        });
        FocusScope.of(context).requestFocus(_stokGdgProdukFokus);
        print('b');
      } else if (response.statusCode == 401) {
        showInSnackBarO('Token kedaluwarsa, silahkan logout dan login kembali');
      } else {
        print('Error code : ${response.statusCode}');
        showInSnackBarO('Error Code = ${response.statusCode}');
        Map responseJson = jsonDecode(response.body);

        if (responseJson.containsKey('message')) {
          showInSnackBarO(responseJson['message']);
        }
      }
    } on Exception catch (e) {
      print(e);
    } catch (e, stacktrace) {
      print("Error : $e, Stacktrace : $stacktrace");
    }
  }

  TabController _tabController;
  void currentTabIndex() {
    setState(() {
      tabControllerIndex = _tabController.index;
    });
  }

  @override
  void initState() {
    // =============================== initState() Tambah Opname Stok Manual
    tabControllerIndex = 0;
    focusDatePicker = FocusNode();

    isLoading = true;
    _validasiTambahProdukSudahAda = false;
    // _validasiGudang = false;
    ref = '- Loading -';
    _lokasiOpname = <ListLokasiGudang>[];
    listProduk = <ListProduk>[]; // list produk autocomplete !important

    _lokasiOpname = [];
    _lokasiOpnameSelected = null;
    _kodeSatuanProduk = null;
    listProdukDiTambahkan = []; // list produk yg ditambahkan ke daftar
    kodeProdukField = null;
    autoCompleteKey = GlobalKey();
    _scaffoldKey = new GlobalKey<ScaffoldState>();
    date1 = null;

    tambahOpnameStockAndroid();

    _catatanOpname = TextEditingController();
    _satuanProduk = TextEditingController();
    _stokSysProduk = TextEditingController();
    _stokGdgProduk = TextEditingController();
    _stokAdjustment = TextEditingController();
    _datepicker = TextEditingController();

    _catatanOpnameFokus = FocusNode();
    _stokGdgProdukFokus = FocusNode();
    _autoCompleteProdukFokus = FocusNode();
    _tabController = new TabController(vsync: this, length: 2);
    _tabController.addListener(currentTabIndex);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

// ================================ function TAMBAH PRODUK ke DAFTAR
  void appendToDaftarProduk() {
    if (_formTambahProduk.currentState.validate()) {
      if (listProdukDiTambahkan
              .where((test) => test.kodeProduk.contains(kodeProdukField))
              .length !=
          0) {
        setState(() {
          _validasiTambahProdukSudahAda = true;
        });
        print('if');
      } else if (listProdukDiTambahkan
              .where((test) => test.kodeProduk.contains(kodeProdukField))
              .length ==
          0) {
        List<KeteranganOpname> listKeteranganOpname = List<KeteranganOpname>();
        KeteranganOpname selectedKeteranganOpname;
        if (int.parse(_stokGdgProduk.text) != int.parse(_stokSysProduk.text)) {
          listKeteranganOpname.add(
            KeteranganOpname(
              value: 'hilang',
              nama: 'Barang Hilang',
            ),
          );
          listKeteranganOpname.add(
            KeteranganOpname(
              value: 'rusak',
              nama: 'Barang Rusak',
            ),
          );
          listKeteranganOpname.add(
            KeteranganOpname(
              value: 'new',
              nama: 'Opname Pertama Kali',
            ),
          );
          listKeteranganOpname.add(
            KeteranganOpname(
              value: 'temuan',
              nama: 'Barang Temuan',
            ),
          );

          selectedKeteranganOpname = KeteranganOpname(
            value: 'hilang',
            nama: 'Barang Hilang',
          );
        } else {
          listKeteranganOpname.add(
            KeteranganOpname(
              value: 'sama',
              nama: 'Tidak ada Kekuarangan',
            ),
          );
          selectedKeteranganOpname = KeteranganOpname(
            value: 'sama',
            nama: 'Tidak ada Kekuarangan',
          );
        }
        setState(() {
          TextEditingController stokGdgInput =
              new TextEditingController(text: _stokGdgProduk.text);

          listProdukDiTambahkan.add(
            ListProdukDiTambahkan(
              kodeProduk: kodeProdukField,
              namaProduk: autoCompleteProdukField.textField.controller.text,
              stokAdjustment: int.parse(_stokAdjustment.text),
              stokGudang: stokGdgInput,
              stokSistem: int.parse(_stokSysProduk.text),
              kodeSatuan: _kodeSatuanProduk,
              namaSatuan: _satuanProduk.text,
              listKeteranganOpname: listKeteranganOpname,
              selectedKeteranganOpname: selectedKeteranganOpname,
            ),
          );

          autoCompleteProdukField.clear();
          kodeProdukField = null;
          _kodeSatuanProduk = null;
          _satuanProduk.clear();
          _stokSysProduk.clear();
          _stokAdjustment.clear();
          _stokGdgProduk.clear();
          _validasiTambahProdukSudahAda = false;
        });
        _formTambahProduk.currentState.save();
        FocusScope.of(context).requestFocus(_autoCompleteProdukFokus);

        print('else');
      }
    }
  }

// ========================== end tambah function ke daftar ================================
  @override
  Widget build(BuildContext context) {
    if (isLoading == false) {
      return DefaultTabController(
        length: 2,
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: Colors.grey[300],
            appBar: AppBar(
              title: Text('Tambah Opname Manual'),
              bottom: TabBar(
                controller: _tabController,
                tabs: <Widget>[
                  Tab(
                    icon: Icon(Icons.add),
                    text: 'Form Tambah',
                  ),
                  Tab(
                    icon: Icon(Icons.list),
                    text: 'Daftar Produk',
                  )
                ],
              ),
            ),
            body: Padding(
              padding: EdgeInsets.all(3.0),
              child: TabBarView(
                controller: _tabController,
                children: <Widget>[
                  SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: 100.0),
                    child: Column(
                      children: <Widget>[
                        Card(
                          child: Container(
                            padding: EdgeInsets.all(15.0),
                            child: Form(
                              key: _form,
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          'No. Referensi',
                                          style: TextStyle(
                                            fontSize: 17.0,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 5,
                                        child: Text(
                                          ref,
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  Divider(),
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          'Posisi Gudang Pengguna',
                                          style: TextStyle(
                                            fontSize: 17.0,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 5,
                                        child: Text(
                                          _lokasiOpnameSelected.namaGudang,
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  Divider(),
                                  // datepicker
                                  DateTimeField(
                                    maxLength: 10,
                                    focusNode: focusDatePicker,
                                    format: DateFormat('dd-MM-yyyy'),
                                    initialValue: date1,
                                    controller: _datepicker,
                                    onShowPicker: (context, currentValue) {
                                      return showDatePicker(
                                        firstDate: DateTime(
                                          DateTime.now().year,
                                        ),
                                        initialDate:
                                            currentValue ?? DateTime.now(),
                                        context: context,
                                        lastDate: DateTime.now(),
                                      );
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'Tanggal opname',
                                    ),
                                    validator: (thisValue) {
                                      print(thisValue.toString());
                                      if (thisValue == null) {
                                        return 'Tanggal Opname tidak boleh kosong';
                                      }
                                      return null;
                                    },
                                    readOnly: true,
                                    onChanged: (ini) {
                                      setState(() {
                                        date1 = ini;
                                      });
                                    },
                                  ),
                                  Divider(),
                                  TextFormField(
                                    maxLines: 3,
                                    controller: _catatanOpname,
                                    focusNode: _catatanOpnameFokus,
                                    decoration: InputDecoration(
                                      hintText: 'Catatan Opname',
                                    ),
                                    validator: (thisValue) {
                                      if (thisValue.isEmpty) {
                                        return 'Catatan tidak boleh kosong';
                                      }
                                      return null;
                                    },
                                    onChanged: (thisValue) {
                                      _catatanOpname.value = TextEditingValue(
                                          selection: _catatanOpname.selection,
                                          text: thisValue);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Card(
                          child: Container(
                            padding: EdgeInsets.all(10.0),
                            child: Form(
                              key: _formTambahProduk,
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.only(
                                      top: 5.0,
                                      bottom: 5.0,
                                    ),
                                    child: Text(
                                      'Tambah Produk',
                                      style: TextStyle(fontSize: 25.0),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(bottom: 5.0),
                                    // field autocomplete
                                    child: autoCompleteProdukField =
                                        AutoCompleteTextField<ListProduk>(
                                      focusNode: _autoCompleteProdukFokus,
                                      suggestions: listProduk,
                                      key: autoCompleteKey,
                                      submitOnSuggestionTap: true,
                                      clearOnSubmit: false,
                                      itemBuilder: (context, suggestion) =>
                                          Container(
                                              padding: EdgeInsets.all(7.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  Text(
                                                    suggestion.namaProduk,
                                                    style: TextStyle(
                                                      fontSize: 18.0,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 10.0,
                                                  ),
                                                  Text(
                                                    suggestion.kodeProduk,
                                                    style: TextStyle(
                                                      fontSize: 17.0,
                                                    ),
                                                  ),
                                                ],
                                              )),
                                      itemFilter: (suggestion, input) =>
                                          suggestion.namaProduk
                                              .toLowerCase()
                                              .startsWith(input.toLowerCase()),
                                      itemSorter: (a, b) {
                                        return a.namaProduk
                                            .compareTo(b.namaProduk);
                                      },
                                      itemSubmitted: (iniVal) {
                                        print(iniVal.kodeProduk);
                                        if (listProdukDiTambahkan
                                                .where((test) => test.kodeProduk
                                                    .contains(
                                                        iniVal.kodeProduk))
                                                .length !=
                                            0) {
                                          print('if');
                                          setState(() {
                                            _validasiTambahProdukSudahAda =
                                                true;
                                            autoCompleteProdukField
                                                .textField
                                                .controller
                                                .text = iniVal.namaProduk;
                                          });
                                        } else if (listProdukDiTambahkan
                                                .where((test) => test.kodeProduk
                                                    .contains(
                                                        iniVal.kodeProduk))
                                                .length ==
                                            0) {
                                          print('else');
                                          setState(() {
                                            kodeProdukField = iniVal.kodeProduk;
                                            _validasiTambahProdukSudahAda =
                                                false;
                                            autoCompleteProdukField
                                                .textField
                                                .controller
                                                .text = iniVal.namaProduk;
                                          });

                                          getStok(
                                            kodeProduk: iniVal.kodeProduk,
                                            kodeGudang: _lokasiOpnameSelected
                                                .kodeGudang,
                                          );
                                        }
                                        print(
                                            'autocomplete ${autoCompleteProdukField.textField.controller.text}');
                                        print(
                                            'field controller $kodeProdukField');
                                      },
                                      decoration: InputDecoration(
                                        errorText: _validasiTambahProdukSudahAda
                                            ? 'Produk sudah ada!'
                                            : null,
                                        hintText: 'Pilih Produk',
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: TextFormField(
                                          readOnly: true,
                                          enableInteractiveSelection: false,
                                          controller: _satuanProduk,
                                          decoration: InputDecoration(
                                            hintText: 'Satuan (Otomatis)',
                                            hintStyle: TextStyle(
                                              color: Colors.black,
                                            ),
                                            fillColor: Colors.grey[300],
                                            filled: true,
                                          ),
                                          validator: (thisValue) {
                                            if (thisValue.isEmpty) {
                                              return 'Produk tidak sesuai';
                                            }
                                            return null;
                                          },
                                          style: TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          margin: EdgeInsets.only(
                                            left: 5.0,
                                          ),
                                          child: TextFormField(
                                            readOnly: true,
                                            enableInteractiveSelection: false,
                                            controller: _stokSysProduk,
                                            decoration: InputDecoration(
                                              hintText:
                                                  'Stok Sistem (Otomatis)',
                                              hintStyle: TextStyle(
                                                color: Colors.black,
                                              ),
                                              fillColor: Colors.grey[300],
                                              filled: true,
                                            ),
                                            validator: (thisValue) {
                                              if (thisValue.isEmpty) {
                                                return 'Produk tidak sesuai';
                                              }
                                              return null;
                                            },
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.only(
                                            top: 5.0,
                                          ),
                                          child: TextField(
                                            controller: _stokAdjustment,
                                            readOnly: true,
                                            decoration: InputDecoration(
                                              hintText: 'Stok Adjustment',
                                              hintStyle: TextStyle(
                                                color: Colors.black,
                                              ),
                                              fillColor: Colors.grey[300],
                                              filled: true,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          margin: EdgeInsets.only(
                                            top: 5.0,
                                            left: 5.0,
                                          ),
                                          child: TextFormField(
                                            keyboardType: TextInputType.number,
                                            inputFormatters: <
                                                TextInputFormatter>[
                                              WhitelistingTextInputFormatter
                                                  .digitsOnly
                                            ],
                                            controller: _stokGdgProduk,
                                            focusNode: _stokGdgProdukFokus,
                                            textInputAction:
                                                TextInputAction.send,
                                            decoration: InputDecoration(
                                              hintText: 'Stok Gudang',
                                            ),
                                            validator: (thisValue) {
                                              if (thisValue.isEmpty) {
                                                return 'Input Stok gudang tidak boleh kosong';
                                              }
                                              return null;
                                            },
                                            onChanged: (thisValue) {
                                              int stokAdjustment =
                                                  int.parse(thisValue) -
                                                      int.parse(
                                                          _stokSysProduk.text);
                                              setState(() {
                                                _stokAdjustment.text =
                                                    '$stokAdjustment';
                                              });
                                            },
                                            onFieldSubmitted: (thisValue) {
                                              int stokAdjustment =
                                                  int.parse(thisValue) -
                                                      int.parse(
                                                          _stokSysProduk.text);
                                              setState(() {
                                                _stokAdjustment.text =
                                                    '$stokAdjustment';
                                              });
                                              appendToDaftarProduk();
                                              print(
                                                  'autocomplete ${autoCompleteProdukField.textField.controller.text}');
                                              print(
                                                  'field controller $kodeProdukField');
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  RaisedButton(
                                    child: Text(
                                      'Tambah ke daftar',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    onPressed: () {
                                      appendToDaftarProduk();
                                      print(_formSerialize);
                                      print(
                                          'autocomplete ${autoCompleteProdukField.textField.controller.text}');
                                      print(
                                          'field controller $kodeProdukField');
                                    },
                                    color: Colors.cyan,
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  TabDaftarProduk(),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.check),
              onPressed: () {
                // function SIMPAN OPNAME STOK MANUAL
                _tabController.animateTo(0);
                if (listProdukDiTambahkan.length == 0) {
                  showInSnackBarO('Tambah produk minimal 1');
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext build) {
                      return AlertDialog(
                        title: Text('Apa anda yakin?'),
                        content: Text('Data akan disimpan'),
                        actions: <Widget>[
                          FlatButton(
                            child: Text(
                              'Tidak',
                              style: TextStyle(color: Colors.black54),
                            ),
                            onPressed: () {
                              _formSerialize['id_produk'] = [];
                              _formSerialize['id_satuan'] = [];
                              _formSerialize['gudang'] = null;
                              _formSerialize['catatan'] = null;
                              _formSerialize['tanggal'] = null;
                              _formSerialize['referensi'] = null;
                              _formSerialize['stok_adjustment'] = [];
                              _formSerialize['stok_gudang'] = [];
                              _formSerialize['stok_sistem'] = [];
                              _formSerialize['opsi'] = List<String>();
                              print(_formSerialize);
                              Navigator.pop(context);
                            },
                          ),
                          FlatButton(
                            child: Text('Ya'),
                            onPressed: () {
                              if (_lokasiOpnameSelected == null) {
                                // setState(() {
                                //   _validasiGudang = true;
                                // });
                              } else if (_form.currentState.validate()) {
                                print('validate true');
                                _formSerialize['id_produk'] = [];
                                _formSerialize['id_satuan'] = [];
                                _formSerialize['gudang'] = null;
                                _formSerialize['catatan'] = null;
                                _formSerialize['tanggal'] = null;
                                _formSerialize['referensi'] = null;
                                _formSerialize['stok_adjustment'] = [];
                                _formSerialize['stok_gudang'] = [];
                                _formSerialize['stok_sistem'] = [];
                                _formSerialize['opsi'] = List<String>();

                                for (int i = 0;
                                    i < listProdukDiTambahkan.length;
                                    i++) {
                                  _formSerialize['id_produk']
                                      .add(listProdukDiTambahkan[i].kodeProduk);
                                  _formSerialize['id_satuan']
                                      .add(listProdukDiTambahkan[i].kodeSatuan);
                                  _formSerialize['stok_adjustment'].add(
                                      listProdukDiTambahkan[i].stokAdjustment);
                                  _formSerialize['stok_sistem']
                                      .add(listProdukDiTambahkan[i].stokSistem);
                                  _formSerialize['stok_gudang'].add(
                                      listProdukDiTambahkan[i].stokGudang.text);
                                  _formSerialize['opsi'].add(
                                      listProdukDiTambahkan[i]
                                          .selectedKeteranganOpname
                                          .value);
                                }
                                _formSerialize['gudang'] =
                                    _lokasiOpnameSelected.kodeGudang;
                                _formSerialize['catatan'] = _catatanOpname.text;
                                _formSerialize['referensi'] = ref;
                                _formSerialize['tanggal'] = _datepicker.text;

                                print("formSerialize $_formSerialize");
                                showInSnackBarO('Memproses data');
                                Navigator.pop(context);
                                // print('coeg 1');
                                simpanOpnameStock(context);
                                // setState(() {
                                //   _validasiGudang = false;
                                // });
                              }
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }
}

void simpanOpnameStock(BuildContext context) async {
  try {
    // requestHeaders['Content-Type'] = 'application/x-www-form-urlencoded';
    // final response = await http.post(
    //   url('api/opname_add'),
    //   headers: requestHeaders,
    //   body: jsonEncode(_formSerialize),
    // );

    Dio dio = new Dio();

    final response = await dio.post(
      url('api/opname_add'),
      options: Options(
        headers: requestHeaders,
      ),
      data: FormData.fromMap(_formSerialize),
    );

    // print('coeg 2');
    print(_formSerialize);
    print("decoded ${response.data}");
    if (response.statusCode == 200) {
      var responseJson = response.data;
      print(responseJson);
      // print('coeg 3');
      if (responseJson['status'] == 'sukses') {
        // print('coeg if');
        showInSnackBarO('Request opname berhasil dibuat');
        Navigator.popUntil(context, ModalRoute.withName('/opname_stock'));
      } else if (responseJson['status'] == 'gagal') {
        // print('coeg else');
        showInSnackBarO(
            'Request opname gagal dibuat, hubungi pengembang software');
        Navigator.pop(context);
      } else {
        print(responseJson);
      }
    } else if (response.statusCode == 401) {
      showInSnackBarO('Token kedaluwarsa, silahkan logout dan login kembali');
    } else {
      print('Error code : ${response.statusCode}');
      showInSnackBarO('Error Code : ${response.statusCode}');
    }
  } catch (e, stacktrace) {
    print("Error: $e, Stacktrace : $stacktrace");
  }
}

// ===================================== DAFTAR PRODUK OPNAME & beberapa function
class TabDaftarProduk extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TabDaftarProdukState();
  }
}

class _TabDaftarProdukState extends State<TabDaftarProduk> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Container(
        child: listProdukDiTambahkan.length != 0
            ? Scrollbar(
                child: ListView.builder(
                  padding: EdgeInsets.only(bottom: 100.0),
                  itemCount: listProdukDiTambahkan.length,
                  itemBuilder: (BuildContext context, int i) {
                    // ================================ CustomListTileOpnameManual custom widget dari file customListTileManualOpname.dart
                    return CustomListTileOpnameManual(
                      kodeProduk: listProdukDiTambahkan[i].kodeProduk,
                      namaProduk: listProdukDiTambahkan[i].namaProduk,
                      stokAdjustment: listProdukDiTambahkan[i].stokAdjustment,
                      stokGudang: listProdukDiTambahkan[i].stokGudang,
                      stokSistem: listProdukDiTambahkan[i].stokSistem,
                      namaSatuan: listProdukDiTambahkan[i].namaSatuan,
                      stokGudangOnChange: (ini) {
                        int stokAdjustment = int.parse(ini) -
                            listProdukDiTambahkan[i].stokSistem;
                        setState(() {
                          listProdukDiTambahkan[i].stokGudang.value =
                              TextEditingValue(
                            selection:
                                listProdukDiTambahkan[i].stokGudang.selection,
                            text: ini,
                          );
                          listProdukDiTambahkan[i].stokAdjustment =
                              stokAdjustment;
                        });
                        List<KeteranganOpname> listKeteranganOpname =
                            List<KeteranganOpname>();
                        KeteranganOpname selectedKeteranganOpname;
                        if (listProdukDiTambahkan[i].stokSistem !=
                            int.parse(
                                listProdukDiTambahkan[i].stokGudang.text)) {
                          listKeteranganOpname.add(
                            KeteranganOpname(
                              value: 'hilang',
                              nama: 'Barang Hilang',
                            ),
                          );
                          listKeteranganOpname.add(
                            KeteranganOpname(
                              value: 'rusak',
                              nama: 'Barang Rusak',
                            ),
                          );
                          listKeteranganOpname.add(
                            KeteranganOpname(
                              value: 'new',
                              nama: 'Opname Pertama Kali',
                            ),
                          );
                          listKeteranganOpname.add(
                            KeteranganOpname(
                              value: 'temuan',
                              nama: 'Barang Temuan',
                            ),
                          );

                          selectedKeteranganOpname = KeteranganOpname(
                            value: 'hilang',
                            nama: 'Barang Hilang',
                          );

                          setState(() {
                            listProdukDiTambahkan[i].listKeteranganOpname =
                                listKeteranganOpname;
                            listProdukDiTambahkan[i].selectedKeteranganOpname =
                                selectedKeteranganOpname;
                          });
                        } else {
                          listKeteranganOpname.add(
                            KeteranganOpname(
                              value: 'sama',
                              nama: 'Tidak ada Kekuarangan',
                            ),
                          );
                          selectedKeteranganOpname = KeteranganOpname(
                            value: 'sama',
                            nama: 'Tidak ada Kekuarangan',
                          );

                          setState(() {
                            listProdukDiTambahkan[i].listKeteranganOpname =
                                listKeteranganOpname;
                            listProdukDiTambahkan[i].selectedKeteranganOpname =
                                selectedKeteranganOpname;
                          });
                        }
                      },
                      onDelete: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Apa anda yakin?'),
                              content: Text('Produk akan dihapus dari daftar'),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text(
                                    'Tidak',
                                    style: TextStyle(
                                      color: Colors.black54,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                FlatButton(
                                  child: Text('Ya'),
                                  onPressed: () {
                                    setState(() {
                                      listProdukDiTambahkan.removeWhere(
                                          (test) =>
                                              test.kodeProduk ==
                                              listProdukDiTambahkan[i]
                                                  .kodeProduk);
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      onDecrease: () {
                        int decreaseStokGudang = int.parse(
                                listProdukDiTambahkan[i].stokGudang.text) -
                            1;
                        int stokAdjustmentI = decreaseStokGudang -
                            listProdukDiTambahkan[i].stokSistem;

                        setState(() {
                          listProdukDiTambahkan[i].stokAdjustment =
                              stokAdjustmentI;
                        });

                        listProdukDiTambahkan[i].stokGudang.value =
                            TextEditingValue(
                                selection: listProdukDiTambahkan[i]
                                    .stokGudang
                                    .selection,
                                text: decreaseStokGudang.toString());

                        List<KeteranganOpname> listKeteranganOpname =
                            List<KeteranganOpname>();
                        KeteranganOpname selectedKeteranganOpname;
                        if (listProdukDiTambahkan[i].stokSistem !=
                            int.parse(
                                listProdukDiTambahkan[i].stokGudang.text)) {
                          listKeteranganOpname.add(
                            KeteranganOpname(
                              value: 'hilang',
                              nama: 'Barang Hilang',
                            ),
                          );
                          listKeteranganOpname.add(
                            KeteranganOpname(
                              value: 'rusak',
                              nama: 'Barang Rusak',
                            ),
                          );
                          listKeteranganOpname.add(
                            KeteranganOpname(
                              value: 'new',
                              nama: 'Opname Pertama Kali',
                            ),
                          );
                          listKeteranganOpname.add(
                            KeteranganOpname(
                              value: 'temuan',
                              nama: 'Barang Temuan',
                            ),
                          );

                          selectedKeteranganOpname = KeteranganOpname(
                            value: 'hilang',
                            nama: 'Barang Hilang',
                          );

                          setState(() {
                            listProdukDiTambahkan[i].listKeteranganOpname =
                                listKeteranganOpname;
                            listProdukDiTambahkan[i].selectedKeteranganOpname =
                                selectedKeteranganOpname;
                          });
                        } else {
                          listKeteranganOpname.add(
                            KeteranganOpname(
                              value: 'sama',
                              nama: 'Tidak ada Kekuarangan',
                            ),
                          );
                          selectedKeteranganOpname = KeteranganOpname(
                            value: 'sama',
                            nama: 'Tidak ada Kekuarangan',
                          );

                          setState(() {
                            listProdukDiTambahkan[i].listKeteranganOpname =
                                listKeteranganOpname;
                            listProdukDiTambahkan[i].selectedKeteranganOpname =
                                selectedKeteranganOpname;
                          });
                        }
                      },
                      onIncrease: () {
                        int increaseStokGudang = int.parse(
                                listProdukDiTambahkan[i].stokGudang.text) +
                            1;
                        int stokAdjustmentI = increaseStokGudang -
                            listProdukDiTambahkan[i].stokSistem;

                        setState(() {
                          listProdukDiTambahkan[i].stokAdjustment =
                              stokAdjustmentI;
                        });

                        listProdukDiTambahkan[i].stokGudang.value =
                            TextEditingValue(
                                selection: listProdukDiTambahkan[i]
                                    .stokGudang
                                    .selection,
                                text: increaseStokGudang.toString());

                        List<KeteranganOpname> listKeteranganOpname =
                            List<KeteranganOpname>();
                        KeteranganOpname selectedKeteranganOpname;
                        if (listProdukDiTambahkan[i].stokSistem !=
                            int.parse(
                                listProdukDiTambahkan[i].stokGudang.text)) {
                          listKeteranganOpname.add(
                            KeteranganOpname(
                              value: 'hilang',
                              nama: 'Barang Hilang',
                            ),
                          );
                          listKeteranganOpname.add(
                            KeteranganOpname(
                              value: 'rusak',
                              nama: 'Barang Rusak',
                            ),
                          );
                          listKeteranganOpname.add(
                            KeteranganOpname(
                              value: 'new',
                              nama: 'Opname Pertama Kali',
                            ),
                          );
                          listKeteranganOpname.add(
                            KeteranganOpname(
                              value: 'temuan',
                              nama: 'Barang Temuan',
                            ),
                          );

                          selectedKeteranganOpname = KeteranganOpname(
                            value: 'hilang',
                            nama: 'Barang Hilang',
                          );

                          setState(() {
                            listProdukDiTambahkan[i].listKeteranganOpname =
                                listKeteranganOpname;
                            listProdukDiTambahkan[i].selectedKeteranganOpname =
                                selectedKeteranganOpname;
                          });
                        } else {
                          listKeteranganOpname.add(
                            KeteranganOpname(
                              value: 'sama',
                              nama: 'Tidak ada Kekuarangan',
                            ),
                          );
                          selectedKeteranganOpname = KeteranganOpname(
                            value: 'sama',
                            nama: 'Tidak ada Kekuarangan',
                          );

                          setState(() {
                            listProdukDiTambahkan[i].listKeteranganOpname =
                                listKeteranganOpname;
                            listProdukDiTambahkan[i].selectedKeteranganOpname =
                                selectedKeteranganOpname;
                          });
                        }
                      },
                      dropdownButton: DropdownButton(
                        isExpanded: true,
                        value:
                            listProdukDiTambahkan[i].selectedKeteranganOpname,
                        items: listProdukDiTambahkan[i]
                            .listKeteranganOpname
                            .map(
                              (KeteranganOpname f) => DropdownMenuItem(
                                child: Text(f.nama),
                                value: f,
                              ),
                            )
                            .toList(),
                        onChanged: (ini) {
                          setState(() {
                            listProdukDiTambahkan[i].selectedKeteranganOpname =
                                ini;
                          });
                        },
                      ),
                    );
                  },
                ),
              )
            : Card(
                child: ListTile(
                  title: Text('Daftar Produk Kosong'),
                  subtitle: Text('Tambah produk di form tambah'),
                ),
              ),
      ),
    );
  }
}

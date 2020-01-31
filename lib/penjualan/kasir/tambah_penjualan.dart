import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:invee2/error/error.dart';
import 'package:invee2/localStorage/localStorage.dart';
import 'package:invee2/penjualan/kasir/customTileKasir.dart';
import 'package:invee2/penjualan/kasir/customer_mini/tambahCustomerMini.dart';
import 'package:invee2/penjualan/kasir/environment/cari_bundle.dart';
import 'package:invee2/penjualan/kasir/environment/cari_customer.dart';
import 'package:invee2/penjualan/kasir/environment/cari_produk.dart';
import 'package:invee2/penjualan/kasir/environment/kabupatenKota.dart';
import 'package:invee2/penjualan/kasir/environment/kecamatan.dart';
import 'package:invee2/penjualan/kasir/environment/model.dart';
import 'package:invee2/penjualan/kasir/environment/provinsi.dart';
import 'package:invee2/penjualan/kasir/tab_cariPrint.dart';
// import 'dart:async';
import 'dart:convert';
// import 'dart:io';
import 'package:invee2/routes/env.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

DateTime datepickerValue;
FocusNode datepickerFocus, produkFocus, qtyFocus, durasiFocus;

Provinsi selectedProvinsi;
KabupatenKota selectedKabupatenKota;
Kecamatan selectedKecamatan;

Produk selectedProduk;
Produk selectedProdukBundle;
Satuan selectedSatuan;
Satuan selectedSatuanBundle;
GolonganHarga selectedGolonganHarga;
GolonganHarga selectedGolonganHargaBundle;

bool isLoading,
    isError,
    isLoadingPrice,
    isCustomerKosong,
    isProvinsiKosong,
    isKabupatenKotaKosong,
    isKecamatanKosong,
    isJenisBayarKosong,
    isSimpan;
String tokenType, accessToken, selectedJenisPembayaran;
Map<String, String> requestHeaders = Map();

GlobalKey<ScaffoldState> _scaffoldKeyK;
List<Customer> listCustomer;
List<Produk> listProduk;

TextEditingController alamatController,
    qtyController,
    stokController,
    stokControllerBundle,
    customerController,
    kodePosController,
    durasiController,
    produkController;
AutoCompleteTextField customerAutoComplete, produkAutoComplete;
GlobalKey<AutoCompleteTextFieldState<Customer>> customerAutoCompleteKey;

GlobalKey<AutoCompleteTextFieldState<Produk>> produkAutoCompleteKey;
List<Satuan> listSatuan = List<Satuan>();
List<Satuan> listSatuanBundle = List<Satuan>();
List<GolonganHarga> listGolonganHarga = List<GolonganHarga>();
List<GolonganHarga> listGolonganHargaBundle = List<GolonganHarga>();

List<String> listJenisPembayaran = ['Tunai', 'Tempo', 'Cek Giro'];
NumberFormat numberFormat =
    NumberFormat.simpleCurrency(decimalDigits: 2, name: 'Rp. ');
List<Produk> listProdukDitambahkan = List<Produk>();

Map<String, dynamic> formSerialize;
double totalBelanja,
    totalDiskonPersen,
    totalDiskonNilai,
    totalPPN,
    totalSeluruhDiskon, // Cuman view
    totalBelanjaSetelahDiskon;

Customer selectedCustomer;
GlobalKey<FormState> formKey;
bool isMinimalPembelian;

GlobalKey<FormState> _form2;
MoneyMaskedTextController jumlahDiBayarController;
double kembalian;

showInSnackBarK(String content) {
  _scaffoldKeyK.currentState.showSnackBar(
    SnackBar(
      content: Text(content),
    ),
  );
}

class TambahPenjualan extends StatefulWidget {
  TambahPenjualan({Key key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _TambahPenjualanState();
  }
}

class _TambahPenjualanState extends State<TambahPenjualan> {
  _print() async {
  }

  // ========================= function get data ketika trigger change produk / satuan / golongan harga =========================
  getData(String selector, String produkAtauBundle) async {
    Map<String, String> parameter;
    parameter = Map<String, String>();
    if (selector == 'produk' && produkAtauBundle == 'produk') {
      setState(() {
        isLoadingPrice = true;
      });
      parameter = {
        'searchproduk': selectedProduk.kodeProduk,
      };
    } else if (selector == 'satuan' && produkAtauBundle == 'produk') {
      setState(() {
        isLoadingPrice = true;
      });
      parameter = {
        'searchproduk': selectedProduk.kodeProduk,
        'satuan': selectedSatuan.kodeSatuan,
        'group_harga': selectedGolonganHarga == null
            ? ''
            : selectedGolonganHarga.kodeGolongan,
      };
    } else if (selector == 'golonganHarga' && produkAtauBundle == 'produk') {
      setState(() {
        isLoadingPrice = true;
      });
      parameter = {
        'searchproduk': selectedProduk.kodeProduk,
        'satuan': selectedSatuan.kodeSatuan,
        'group_harga': selectedGolonganHarga.kodeGolongan,
      };
    } else if (selector == 'produk' && produkAtauBundle == 'bundle') {
      setState(() {
        isLoadingPrice = true;
      });
      parameter = {
        'searchproduk': selectedProdukBundle.kodeProduk,
      };
    } else if (selector == 'satuan' && produkAtauBundle == 'bundle') {
      setState(() {
        isLoadingPrice = true;
      });
      parameter = {
        'searchproduk': selectedProdukBundle.kodeProduk,
        'satuan': selectedSatuanBundle.kodeSatuan,
        'group_harga': selectedGolonganHargaBundle == null
            ? ''
            : selectedGolonganHargaBundle.kodeGolongan,
      };
    } else if (selector == 'golonganHarga' && produkAtauBundle == 'bundle') {
      setState(() {
        isLoadingPrice = true;
      });
      parameter = {
        'searchproduk': selectedProdukBundle.kodeProduk,
        'satuan': selectedSatuanBundle.kodeSatuan,
        'group_harga': selectedGolonganHargaBundle.kodeGolongan,
      };
    }

    try {
      final response = await http.post(
        url('api/getData'),
        headers: requestHeaders,
        body: parameter,
      );

      if (response.statusCode == 200) {
        dynamic responseJson = jsonDecode(response.body);
        // print(responseJson);
        if (selector == 'produk' && produkAtauBundle == 'produk') {
          // ======================================= Selector Produk =======================================
          // print('produj');

          selectedGolonganHarga = null;
          selectedSatuan = null;

          // print('add satuan');
          listSatuan = List<Satuan>();
          for (var i in responseJson['satuan']) {
            listSatuan.add(
              Satuan(
                idSatuan: i[0]['iu_id'].toString(),
                kodeSatuan: i[0]['iu_code'],
                namaSatuan: i[0]['iu_name'],
              ),
            );
          }
          setState(() {
            selectedSatuan = listSatuan[0];
          });
          selectedProduk.selectedKodeSatuan = selectedSatuan.kodeSatuan;
          selectedProduk.selectedNamaSatuan = selectedSatuan.namaSatuan;

          setState(() {
            listSatuan = listSatuan;
          });
          getData('satuan', 'produk');
        } else if (selector == 'satuan' && produkAtauBundle == 'produk') {
          // ======================================= Selector satuan =======================================
          selectedGolonganHarga = null;

          listGolonganHarga = List<GolonganHarga>();
          for (var j in responseJson['group']) {
            listGolonganHarga.add(
              GolonganHarga(
                kodeGolongan: j['gpp_id'] == '' ? '' : j['gpp_id'].toString(),
                namaGolongan: j['gp_name'],
              ),
            );
          }
          setState(() {
            stokController.text = responseJson['stock'].toString();
            selectedProduk.hargaProduk = responseJson['harga'].toString();
            isLoadingPrice = false;
          });
          FocusScope.of(context).requestFocus(qtyFocus);
        } else if (selector == 'golonganHarga' &&
            produkAtauBundle == 'produk') {
          // ===================================== Selector golonganHarga =====================================
          setState(() {
            selectedProduk.hargaProduk = responseJson['harga'].toString();
            isLoadingPrice = false;
          });
        } else if (selector == 'produk' && produkAtauBundle == 'bundle') {
          // ======================================= Selector Produk =======================================
          // print('produj');

          selectedGolonganHargaBundle = null;
          selectedSatuanBundle = null;

          // print('add satuan');
          listSatuanBundle = List<Satuan>();
          for (var i in responseJson['satuan']) {
            listSatuanBundle.add(
              Satuan(
                idSatuan: i[0]['iu_id'].toString(),
                kodeSatuan: i[0]['iu_code'],
                namaSatuan: i[0]['iu_name'],
              ),
            );
          }
          setState(() {
            selectedSatuanBundle = listSatuanBundle[0];
          });
          selectedProdukBundle.selectedKodeSatuan =
              selectedSatuanBundle.kodeSatuan;
          selectedProdukBundle.selectedNamaSatuan =
              selectedSatuanBundle.namaSatuan;

          setState(() {
            listSatuan = listSatuan;
          });
          getData('satuan', 'bundle');
        } else if (selector == 'satuan' && produkAtauBundle == 'bundle') {
          // ======================================= Selector satuan =======================================
          selectedGolonganHargaBundle = null;

          listGolonganHargaBundle = List<GolonganHarga>();
          for (var j in responseJson['group']) {
            listGolonganHargaBundle.add(
              GolonganHarga(
                kodeGolongan: j['gpp_id'] == '' ? '' : j['gpp_id'].toString(),
                namaGolongan: j['gp_name'],
              ),
            );
          }
          setState(() {
            stokControllerBundle.text = responseJson['stock'].toString();
            selectedProdukBundle.hargaProduk = responseJson['harga'].toString();
            isLoadingPrice = false;
          });
          FocusScope.of(context).requestFocus(qtyFocus);
        } else if (selector == 'golonganHarga' &&
            produkAtauBundle == 'bundle') {
          // ===================================== Selector golonganHarga =====================================
          setState(() {
            selectedProdukBundle.hargaProduk = responseJson['harga'].toString();
            isLoadingPrice = false;
          });
        }
      } else if (response.statusCode == 401) {
        showInSnackBarK('Token kedaluwarsa, silahkan logout dan login kembali');
        setState(() {
          isLoadingPrice = false;
        });
      } else {
        showInSnackBarK('Error code = ${response.statusCode}');
        Map responseJson = jsonDecode(response.body);

        if (responseJson.containsKey('message')) {
          showInSnackBarK(responseJson['message']);
        }
        print(jsonDecode(response.body));
        setState(() {
          isLoadingPrice = false;
        });
      }
    } catch (e, stacktrace) {
      print('Error = $e || Stacktrace = $stacktrace');
      showInSnackBarK('Error ${e.toString()}');
      setState(() {
        isLoadingPrice = false;
      });
    }
  }

// ==================================== function get list customer dan produk ====================================
  getTambahKasir() async {
    DataStore dataStore = DataStore();

    var tokenTypeStorage = await dataStore.getDataString('token_type');
    var accessTokenStorage = await dataStore.getDataString('access_token');

    tokenType = tokenTypeStorage;
    accessToken = accessTokenStorage;

    requestHeaders['Accept'] = 'application/json';
    requestHeaders['Authorization'] = '$tokenType $accessToken';

    setState(() {
      isLoading = true;
      isError = false;
    });

    try {
      final response = await http.get(
        url('api/tambahKasir'),
        headers: requestHeaders,
      );
      if (response.statusCode == 200) {
        dynamic responseJson = jsonDecode(response.body);

        print(responseJson);

        listCustomer = List<Customer>();

        for (var i in responseJson['member']) {
          listCustomer.add(
            Customer(
              idCustomer: i['cm_id'].toString(),
              kodeCustomer: i['cm_code'],
              namaCustomer: i['cm_name'],
              alamat: i['cm_address'],
              idKabupatenKota:
                  i['cm_city'] == 'null' ? null : i['cm_city'].toString(),
              idKecamatan: i['cm_district'] == 'null'
                  ? null
                  : i['cm_district'].toString(),
              idProvinsi: i['cm_province'] == 'null'
                  ? null
                  : i['cm_province'].toString(),
              namaProvinsi: i['p_nama'] == 'null' ? null : i['p_nama'],
              namaKecamatan: i['d_nama'] == 'null' ? null : i['d_nama'],
              namaKabupatenKota: i['c_nama'] == 'null' ? null : i['c_nama'],
              kodePos: i['cm_postalcode'] == 'null' ? null : i['cm_postalcode'],
            ),
          );
        }

        listProduk = List<Produk>();

        for (var j in responseJson['produk']) {
          listProduk.add(
            Produk(
              idProduk: j['i_id'].toString(),
              namaProduk: j['i_name'],
              kodeProduk: j['i_code'],
              kodeSatuan1: j['itp_ciunit'],
              kodeSatuan2: j['itp_ciunit2'],
              kodeSatuan3: j['itp_ciunit3'],
            ),
          );
        }

        setState(() {
          isLoading = false;
          isError = false;
        });
      } else if (response.statusCode == 401) {
        showInSnackBarK('Token kedaluwarsa, silahkan logout dan login kembali');
        setState(() {
          isLoading = false;
          isError = true;
        });
      } else {
        showInSnackBarK('Error Code ${response.statusCode}');
        Map responseJson = jsonDecode(response.body);

        if (responseJson.containsKey('message')) {
          showInSnackBarK(responseJson['message']);
        }
        print(jsonDecode(response.body));
        setState(() {
          isLoading = false;
          isError = true;
        });
      }
    } catch (e, stacktrace) {
      print('Error = $e || Stacktrace = $stacktrace');
      showInSnackBarK('Error ${e.toString()}');
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

// ========================== function dialog pilih pengiriman ==========================
  dialogPilihPengiriman() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: Text('Apakah Pembelian Sudah Benar?'),
        title: Text('Data Akan Disimpan!'),
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
          // FlatButton(
          //   child: Text(
          //     'Via Ekspedisi',
          //     style: TextStyle(
          //       color: Colors.cyan,
          //     ),
          //   ),
          //   onPressed: () {
          //     Navigator.pop(context);
          //     simpan('N');
          //   },
          // ),
          FlatButton(
            child: Text(
              'Order',
              style: TextStyle(
                color: Colors.cyan,
              ),
            ),
            onPressed: isSimpan
                ? null
                : () {
                    Navigator.pop(context);
                    simpan('Y');
                  },
          ),
        ],
      ),
    );
  }

// =================================== function simpan ===================================

  simpan(String metodePengiriman) async {
    setState(() {
      isSimpan = true;
    });
    formSerialize = Map<String, dynamic>();

    formSerialize['alamat'] = null;
    formSerialize['ambil'] = null;
    formSerialize['cbarang'] = List<String>();

    formSerialize['customer'] = null;
    formSerialize['disc'] = List<String>();
    formSerialize['discv'] = List<String>();

    formSerialize['harga'] = List<String>();
    formSerialize['kecamatan'] = null;
    formSerialize['kode_pos'] = null;

    formSerialize['kota'] = null;
    formSerialize['metode'] = null;
    formSerialize['provinsi'] = null;

    formSerialize['qtyproduk'] = List<String>();
    formSerialize['satuan'] = List<String>();
    formSerialize['tanggal_penjualan'] = null;

    formSerialize['total'] = List<String>();
    formSerialize['type_platform'] = null;
    formSerialize['durasi'] = null;
    formSerialize['tharga'] = null;
    formSerialize['tdisc'] = null;
    formSerialize['tppn'] = null;

    formSerialize['tharga'] = totalBelanja;
    formSerialize['tdisc'] = totalSeluruhDiskon;
    formSerialize['tppn'] = totalPPN;

    Map<String, String> requestHeadersX = Map<String, String>();
    requestHeadersX = requestHeaders;

    formSerialize['ambil'] = metodePengiriman;
    if (alamatController.text.isNotEmpty) {
      formSerialize['alamat'] = alamatController.text;
    }
    formSerialize['customer'] = selectedCustomer.idCustomer;

    if (selectedProvinsi != null) {
      formSerialize['provinsi'] = selectedProvinsi.idProvinsi;
    }
    if (selectedKabupatenKota != null) {
      formSerialize['kota'] = selectedKabupatenKota.idKabupatenKota;
    }
    if (selectedKecamatan != null) {
      formSerialize['kecamatan'] = selectedKecamatan.idKecamatan;
    }
    if (kodePosController.text.isNotEmpty) {
      formSerialize['kode_pos'] = kodePosController.text;
    }

    formSerialize['metode'] = selectedJenisPembayaran;
    formSerialize['tanggal_penjualan'] = datepickerValue.toString();
    formSerialize['type_platform'] = 'android';
    // formSerialize['durasi'] = durasiController.text;

    for (int i = 0; i < listProdukDitambahkan.length; i++) {
      formSerialize['cbarang'].add(listProdukDitambahkan[i].kodeProduk);
      formSerialize['disc'].add(
          listProdukDitambahkan[i].diskonPersenController.text == ''
              ? 0.toString()
              : listProdukDitambahkan[i].diskonPersenController.text);
      formSerialize['discv'].add(
          listProdukDitambahkan[i].diskonNilaiController.text == ''
              ? 0.toString()
              : listProdukDitambahkan[i].diskonNilaiController.text);
      formSerialize['harga'].add(listProdukDitambahkan[i].hargaProduk);

      formSerialize['qtyproduk']
          .add(listProdukDitambahkan[i].qtyController.text);
      formSerialize['satuan'].add(listProdukDitambahkan[i].selectedKodeSatuan);
      formSerialize['total'].add(listProdukDitambahkan[i].totalHarga);
    }

    requestHeadersX['Content-Type'] = "application/x-www-form-urlencoded";

    try {
      final response = await http.post(
        url('api/simpanKasir'),
        body: {
          'type_platform': 'android',
          'data': jsonEncode(formSerialize),
        },
        headers: requestHeadersX,
      );

      if (response.statusCode == 200) {
        dynamic responseJson = jsonDecode(response.body);

        if (responseJson['status'] == 'sukses') {

          Navigator.popUntil(
            context,
            ModalRoute.withName('/kasir'),
          );
        } else if (responseJson['status'] == 'gagal') {
          showInSnackBarK('Error, hubungi pengembang aplikasi');
        }

        print(responseJson);
      } else if (response.statusCode == 401) {
        showInSnackBarK('Token kedaluwarsa, silahkan logout dan login kembali');
      } else {
        showInSnackBarK('Error Code = ${response.statusCode}');
        print(jsonDecode(response.body));
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) => Container(
            child: Text(
              jsonDecode(response.body).toString(),
            ),
          ),
        );
      }
    } catch (e, stacktrace) {
      print('Error = $e || Stacktrace = $stacktrace');
      showInSnackBarK('Error = ${e.toString()}');
    }
    setState(() {
      isSimpan = false;
    });
  }

  void pindahKeCariBundle() async {
    Produk produkY = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => CariBundle(
          bundle: selectedProdukBundle,
          selectedProduk: selectedProduk,
        ),
      ),
    );

    if (produkY != null) {
      setState(() {
        selectedProdukBundle = produkY;
      });
      selectedProdukBundle.qtyController = TextEditingController();
      selectedProdukBundle.diskonNilaiController = TextEditingController();
      selectedProdukBundle.diskonPersenController = TextEditingController();
      getData('produk', 'bundle');
    }
  }

  void pindahKeCariProduk() async {
    Produk produkX = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => CariProduk(
          produk: selectedProduk,
        ),
      ),
    );

    if (produkX != null) {
      setState(() {
        selectedProduk = produkX;
      });
      selectedProduk.qtyController = TextEditingController();
      selectedProduk.diskonNilaiController = TextEditingController();
      selectedProduk.diskonPersenController = TextEditingController();
      getData('produk', 'produk');
    }
  }

  Future<bool> alertBackButton() {
    return showDialog(
      context: context,
      builder: (BuildContext context) =>
          AlertDialog(
            title: Text('Peringatan!'),
            content:
                Text('Data yang anda masukkan akan hilang, apa anda yakin?'),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text(
                  'Tidak',
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Text('Ya'),
              ),
            ],
          ) ??
          false,
    );
  }

  // ======================================= initState =======================================
  @override
  void initState() {
    formKey = GlobalKey<FormState>();
    isLoadingPrice = false;
    isLoading = false;
    isError = false;
    isSimpan = false;
    isMinimalPembelian = true;

    _form2 = GlobalKey<FormState>();
    jumlahDiBayarController = MoneyMaskedTextController(
      decimalSeparator: '.',
      thousandSeparator: ',',
      precision: 2,
    );
    kembalian = 0.0;

    getTambahKasir();
    datepickerFocus = FocusNode();
    datepickerValue = DateTime.now();

    selectedProvinsi = null;
    selectedKabupatenKota = null;
    selectedKecamatan = null;
    selectedCustomer = null;

    _scaffoldKeyK = GlobalKey<ScaffoldState>();
    customerAutoCompleteKey = GlobalKey();
    produkAutoCompleteKey = GlobalKey();

    alamatController = TextEditingController();
    qtyController = TextEditingController();
    stokController = TextEditingController();
    stokControllerBundle = TextEditingController();

    customerController = TextEditingController();
    produkController = TextEditingController();
    kodePosController = TextEditingController();

    durasiFocus = FocusNode();
    durasiController = TextEditingController();

    listSatuan = List<Satuan>();
    listSatuanBundle = List<Satuan>();
    listGolonganHarga = List<GolonganHarga>();
    listGolonganHargaBundle = List<GolonganHarga>();
    selectedJenisPembayaran = 'Tunai';
    selectedProduk = null;
    selectedProdukBundle = null;

    selectedGolonganHarga = null;
    selectedGolonganHargaBundle = null;
    selectedSatuan = null;
    selectedSatuanBundle = null;
    listProdukDitambahkan = List<Produk>();

    totalBelanja = 0.0;
    totalBelanjaSetelahDiskon = 0.0;
    totalDiskonNilai = 0.0;
    totalDiskonPersen = 0.0;
    totalPPN = 0.0;
    totalSeluruhDiskon = 0.0;

    isCustomerKosong = false;
    isKabupatenKotaKosong = false;
    isKecamatanKosong = false;
    isProvinsiKosong = false;
    isJenisBayarKosong = false;

    qtyFocus = FocusNode();
    produkFocus = FocusNode();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    super.dispose();
  }

// =============================== statefull build ===============================

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: alertBackButton,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            key: _scaffoldKeyK,
            appBar: AppBar(
              title: Text('Tambah Penjualan Offline'),
              bottom: TabBar(
                isScrollable: true,
                tabs: <Widget>[
                  Tab(
                    icon: Icon(Icons.add),
                    text: 'Form',
                  ),
                  Tab(
                    icon: Icon(Icons.list),
                    text: 'Daftar Produk',
                  ),
                ],
              ),
              actions: <Widget>[
                IconButton(
                  icon: Icon(
                    FontAwesomeIcons.userPlus,
                    size: 20.0,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        settings: RouteSettings(
                          name: '/tambah_customer_minimal',
                        ),
                        builder: (BuildContext context) =>
                            TambahCustomerMinimal(),
                      ),
                    );
                  },
                ),
                // IconButton(
                //   onPressed: () {
                //     if (listProdukDitambahkan.length != 0 &&
                //         selectedCustomer != null) {
                //       _print('NOTA/Tes');
                //     } else {
                //       if (selectedCustomer == null) {
                //         showInSnackBarK('Pilih Customer');
                //       }
                //       if (listProdukDitambahkan.length == 0) {
                //         showInSnackBarK('Daftar produk kosong');
                //       }
                //     }
                //   },
                //   icon: Icon(Icons.print),
                // )
              ],
            ),
            backgroundColor: Colors.grey[300],
            bottomNavigationBar: Container(
              padding: EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    width: 1.0,
                    color: Colors.black26,
                  ),
                ),
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 15.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 4,
                            child: Text(
                              'Total Penjualan',
                              style: TextStyle(
                                fontSize: 20.0,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Container(
                              // margin: EdgeInsets.only(
                              //   right: 80.0,
                              // ),
                              child: Text(
                                numberFormat.format(totalBelanjaSetelahDiskon),
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 20.0,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.endDocked,
            body: Form(
              key: formKey,
              child: TabBarView(
                children: <Widget>[
                  // ============================ Tab Index 0 ============================
                  isLoading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : isError
                          ? ErrorCobalLagi(
                              onPress: () => getTambahKasir(),
                            )
                          : SingleChildScrollView(
                              child: Container(
                                child: Column(
                                  children: <Widget>[
                                    // =========================== Data Customer ===========================
                                    Card(
                                      margin: EdgeInsets.only(
                                        bottom: 5.0,
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(5.0),
                                        child: Column(
                                          children: <Widget>[
                                            Container(
                                              margin: EdgeInsets.only(
                                                bottom: 10.0,
                                              ),
                                              child: Text(
                                                'Data Customer',
                                                style: TextStyle(
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            ListTile(
                                              leading: Icon(Icons.person),
                                              title: Container(
                                                padding: EdgeInsets.all(10.0),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  border: Border.all(
                                                    width: 0.5,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                                child: selectedCustomer == null
                                                    ? Text(
                                                        'Nama Customer/Member',
                                                        style: TextStyle(
                                                          color: Colors.black54,
                                                        ),
                                                      )
                                                    : Text(selectedCustomer
                                                        .namaCustomer),
                                              ),
                                              subtitle: isCustomerKosong
                                                  ? Text(
                                                      'Customer tidak boleh kosong',
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                      ),
                                                    )
                                                  : null,
                                              onTap: () async {
                                                Customer cariCustomer =
                                                    await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (BuildContext
                                                            context) =>
                                                        CariCustomer(
                                                      customer:
                                                          selectedCustomer,
                                                    ),
                                                  ),
                                                );

                                                if (cariCustomer != null) {
                                                  if (cariCustomer.alamat !=
                                                      'null') {
                                                    setState(() {
                                                      alamatController.text =
                                                          cariCustomer.alamat;
                                                    });
                                                  }
                                                  if (cariCustomer.kodePos !=
                                                      'null') {
                                                    setState(() {
                                                      kodePosController.text =
                                                          cariCustomer.kodePos;
                                                    });
                                                  }
                                                  if (cariCustomer.idProvinsi !=
                                                      'null') {
                                                    setState(() {
                                                      selectedProvinsi =
                                                          Provinsi(
                                                        idProvinsi: cariCustomer
                                                            .idProvinsi,
                                                        namaProvinsi:
                                                            cariCustomer
                                                                .namaProvinsi,
                                                      );
                                                    });
                                                  }
                                                  if (cariCustomer
                                                          .idKabupatenKota !=
                                                      'null') {
                                                    setState(() {
                                                      selectedKabupatenKota =
                                                          KabupatenKota(
                                                        idKabupatenKota:
                                                            cariCustomer
                                                                .idKabupatenKota,
                                                        namaKabupatenKota:
                                                            cariCustomer
                                                                .namaKabupatenKota,
                                                      );
                                                    });
                                                  }
                                                  if (cariCustomer
                                                          .idKecamatan !=
                                                      'null') {
                                                    setState(() {
                                                      selectedKecamatan =
                                                          Kecamatan(
                                                        idKecamatan:
                                                            cariCustomer
                                                                .idKecamatan,
                                                        namaKecamatan:
                                                            cariCustomer
                                                                .namaKecamatan,
                                                      );
                                                    });
                                                  }
                                                  setState(() {
                                                    selectedCustomer =
                                                        cariCustomer;
                                                  });
                                                }
                                              },
                                            ),
                                            ListTile(
                                              leading: Icon(
                                                  FontAwesomeIcons.addressBook),
                                              title: TextFormField(
                                                controller: alamatController,
                                                maxLines: 3,
                                                decoration: InputDecoration(
                                                  hintText: 'Alamat',
                                                ),
                                                // validator: (ini) {
                                                //   if (ini.isEmpty) {
                                                //     return 'Alamat tidak boleh kosong';
                                                //   }
                                                //   return null;
                                                // },
                                                onChanged: (ini) {
                                                  alamatController.value =
                                                      TextEditingValue(
                                                    selection: alamatController
                                                        .selection,
                                                    text: ini,
                                                  );
                                                },
                                              ),
                                            ),
                                            ListTile(
                                              leading:
                                                  Icon(FontAwesomeIcons.globe),
                                              title: selectedProvinsi == null
                                                  ? Text(
                                                      'Provinsi',
                                                      style: TextStyle(
                                                        color: Colors.black54,
                                                      ),
                                                    )
                                                  : Text(selectedProvinsi
                                                      .namaProvinsi),
                                              // subtitle:
                                              //     isProvinsiKosong == false
                                              //         ? null
                                              //         : Text(
                                              //             'Provinsi tidak boleh kosong',
                                              //             style: TextStyle(
                                              //               color: Colors.red,
                                              //             ),
                                              //           ),
                                              onTap: () async {
                                                final Provinsi provinsi =
                                                    await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (BuildContext
                                                            context) =>
                                                        CariProvinsi(
                                                      provinsi:
                                                          selectedProvinsi,
                                                    ),
                                                  ),
                                                );
                                                if (provinsi != null) {
                                                  setState(() {
                                                    selectedProvinsi = provinsi;
                                                    selectedKabupatenKota =
                                                        null;
                                                    selectedKecamatan = null;
                                                  });
                                                }
                                              },
                                            ),
                                            ListTile(
                                              leading:
                                                  Icon(FontAwesomeIcons.city),
                                              title: selectedKabupatenKota ==
                                                      null
                                                  ? Text(
                                                      'Kabupaten/Kota',
                                                      style: TextStyle(
                                                        color: Colors.black54,
                                                      ),
                                                    )
                                                  : Text(selectedKabupatenKota
                                                      .namaKabupatenKota),
                                              // subtitle:
                                              //     isKabupatenKotaKosong == false
                                              //         ? null
                                              //         : Text(
                                              //             'Kabupaten/Kota tidak boleh kosong',
                                              //             style: TextStyle(
                                              //               color: Colors.red,
                                              //             ),
                                              //           ),
                                              onTap: () async {
                                                final KabupatenKota
                                                    kabupatenKota =
                                                    await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (BuildContext
                                                            context) =>
                                                        CariKabupatenKota(
                                                      provinsi:
                                                          selectedProvinsi,
                                                      kabupatenKota:
                                                          selectedKabupatenKota,
                                                    ),
                                                  ),
                                                );
                                                if (kabupatenKota != null) {
                                                  setState(() {
                                                    selectedKabupatenKota =
                                                        kabupatenKota;
                                                    selectedKecamatan = null;
                                                  });
                                                }
                                              },
                                            ),
                                            ListTile(
                                              leading:
                                                  Icon(FontAwesomeIcons.home),
                                              title: selectedKecamatan == null
                                                  ? Text(
                                                      'Kecamatan',
                                                      style: TextStyle(
                                                        color: Colors.black54,
                                                      ),
                                                    )
                                                  : Text(selectedKecamatan
                                                      .namaKecamatan),
                                              // subtitle:
                                              //     isKecamatanKosong == false
                                              //         ? null
                                              //         : Text(
                                              //             'Kecamatan tidak boleh kosong',
                                              //             style: TextStyle(
                                              //               color: Colors.red,
                                              //             ),
                                              //           ),
                                              onTap: () async {
                                                final Kecamatan kecamatan =
                                                    await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (BuildContext
                                                            context) =>
                                                        CariKecamatan(
                                                      kecamatan:
                                                          selectedKecamatan,
                                                      kabupatenKota:
                                                          selectedKabupatenKota,
                                                    ),
                                                  ),
                                                );
                                                if (kecamatan != null) {
                                                  setState(() {
                                                    selectedKecamatan =
                                                        kecamatan;
                                                  });
                                                }
                                              },
                                            ),
                                            ListTile(
                                              leading: Icon(
                                                  FontAwesomeIcons.envelope),
                                              title: TextFormField(
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: InputDecoration(
                                                  hintText: 'Kode Pos',
                                                ),
                                                // validator: (ini) {
                                                //   if (ini.isEmpty) {
                                                //     return 'Kode Pos tidak boleh kosong';
                                                //   }
                                                //   return null;
                                                // },
                                                inputFormatters: <
                                                    TextInputFormatter>[
                                                  WhitelistingTextInputFormatter
                                                      .digitsOnly,
                                                ],
                                                controller: kodePosController,
                                                onChanged: (ini) {
                                                  kodePosController.value =
                                                      TextEditingValue(
                                                          selection:
                                                              kodePosController
                                                                  .selection,
                                                          text: ini);
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // =========================== Form Penjualan ===========================
                                    Card(
                                      margin: EdgeInsets.only(
                                        bottom: 5.0,
                                      ),
                                      child: Container(
                                        padding: EdgeInsets.all(5.0),
                                        child: Column(
                                          children: <Widget>[
                                            Container(
                                              margin: EdgeInsets.only(
                                                bottom: 10.0,
                                                top: 5.0,
                                              ),
                                              child: Text(
                                                'Form Penjualan',
                                                style: TextStyle(
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            ListTile(
                                              leading: Icon(
                                                  FontAwesomeIcons.calendar),
                                              title: Text(
                                                DateFormat('dd MMMM y')
                                                    .format(datepickerValue),
                                              ),
                                              // DateTimePickerFormField(
                                              //   initialDate: DateTime.now(),
                                              //   inputType: InputType.date,
                                              //   initialValue: datepickerValue,
                                              //   focusNode: datepickerFocus,
                                              //   lastDate: DateTime.now(),
                                              //   editable: false,
                                              //   validator: (ini) {
                                              //     if (ini == null) {
                                              //       return 'Tanggal Penjualan tidak boleh kosong';
                                              //     }
                                              //     return null;
                                              //   },
                                              //   format: DateFormat('dd-MM-y'),
                                              //   decoration: InputDecoration(
                                              //     hintText: 'Tanggal Penjualan',
                                              //   ),
                                              //   resetIcon:
                                              //       FontAwesomeIcons.times,
                                              //   onChanged: (ini) {
                                              //     setState(() {
                                              //       datepickerValue = ini;
                                              //     });
                                              //   },
                                              //   autofocus: false,
                                              // ),
                                            ),
                                            ListTile(
                                              leading: Icon(
                                                  FontAwesomeIcons.moneyBill),
                                              title:
                                                  Text(selectedJenisPembayaran),
                                              // DropdownButton(
                                              //   isExpanded: true,
                                              //   hint: Text('Pilih Jenis Bayar'),
                                              //   value: selectedJenisPembayaran,
                                              //   onChanged: (ini) {
                                              //     setState(() {
                                              //       selectedJenisPembayaran =
                                              //           ini;
                                              //     });
                                              //   },
                                              //   items: listJenisPembayaran
                                              //       .map(
                                              //         (f) => DropdownMenuItem(
                                              //           child: Text(f),
                                              //           value: f,
                                              //         ),
                                              //       )
                                              //       .toList(),
                                              // ),
                                              subtitle:
                                                  isJenisBayarKosong == false
                                                      ? null
                                                      : Text(
                                                          'Jenis Bayar tidak boleh kosong',
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // ============================ Data Barang ============================
                                    Card(
                                      margin: EdgeInsets.only(bottom: 5.0),
                                      child: Container(
                                        padding: EdgeInsets.all(5.0),
                                        child: Column(
                                          children: <Widget>[
                                            Padding(
                                              padding: EdgeInsets.all(5.0),
                                              child: Text(
                                                'Pilih Barang',
                                                style: TextStyle(
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            ListTile(
                                              leading:
                                                  Icon(FontAwesomeIcons.cubes),
                                              title: Container(
                                                padding: EdgeInsets.all(10.0),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  border: Border.all(
                                                    width: 0.5,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                                child: selectedProduk == null
                                                    ? Text(
                                                        'Pilih Produk',
                                                        style: TextStyle(
                                                          color: Colors.black54,
                                                        ),
                                                      )
                                                    : Text(selectedProduk
                                                        .namaProduk),
                                              ),
                                              onTap: () {
                                                pindahKeCariProduk();
                                              },
                                            ),
                                            ListTile(
                                              leading: Icon(FontAwesomeIcons
                                                  .balanceScale),
                                              title: DropdownButton(
                                                isExpanded: true,
                                                hint: Text('Pilih Satuan'),
                                                value: selectedSatuan,
                                                onChanged: (Satuan ini) {
                                                  setState(() {
                                                    selectedSatuan = ini;
                                                  });
                                                  selectedProduk
                                                          .selectedKodeSatuan =
                                                      ini.kodeSatuan;
                                                  getData('satuan', 'produk');
                                                },
                                                items: listSatuan
                                                    .map(
                                                      (Satuan f) =>
                                                          DropdownMenuItem(
                                                        child:
                                                            Text(f.namaSatuan),
                                                        value: f,
                                                      ),
                                                    )
                                                    .toList(),
                                              ),
                                            ),
                                            ListTile(
                                              onTap: () {},
                                              leading:
                                                  Icon(FontAwesomeIcons.tag),
                                              title: DropdownButton(
                                                isExpanded: true,
                                                hint: Text(
                                                    'Pilih Golongan Harga'),
                                                value: selectedGolonganHarga,
                                                onChanged: (GolonganHarga ini) {
                                                  setState(() {
                                                    selectedGolonganHarga = ini;
                                                  });
                                                  getData('golonganHarga',
                                                      'produk');
                                                },
                                                items: listGolonganHarga
                                                    .map(
                                                      (GolonganHarga f) =>
                                                          DropdownMenuItem(
                                                        child: Text(
                                                            f.namaGolongan),
                                                        value: f,
                                                      ),
                                                    )
                                                    .toList(),
                                              ),
                                            ),
                                            ListTile(
                                              leading: Icon(
                                                  FontAwesomeIcons.warehouse),
                                              title: TextField(
                                                controller: stokController,
                                                decoration: InputDecoration(
                                                  hintText: 'Stok gudang',
                                                ),
                                                readOnly: true,
                                                enabled: false,
                                              ),
                                            ),
                                            ListTile(
                                              leading: Icon(FontAwesomeIcons
                                                  .moneyBillAlt),
                                              title: selectedProduk == null
                                                  ? Text(
                                                      'Harga Produk',
                                                      style: TextStyle(
                                                        color: Colors.black54,
                                                      ),
                                                      textAlign:
                                                          TextAlign.right,
                                                    )
                                                  : isLoadingPrice == true
                                                      ? Center(
                                                          child:
                                                              CircularProgressIndicator(),
                                                        )
                                                      : Text(
                                                          numberFormat.format(
                                                            double.parse(
                                                              selectedProduk
                                                                  .hargaProduk,
                                                            ),
                                                          ),
                                                          textAlign:
                                                              TextAlign.right,
                                                        ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(5.0),
                                              child: Text(
                                                'Pilih Tutup',
                                                style: TextStyle(
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            ListTile(
                                              leading:
                                                  Icon(FontAwesomeIcons.cubes),
                                              title: Container(
                                                padding: EdgeInsets.all(10.0),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  border: Border.all(
                                                    width: 0.5,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                                child: selectedProdukBundle ==
                                                        null
                                                    ? Text(
                                                        'Pilih Tutup',
                                                        style: TextStyle(
                                                          color: Colors.black54,
                                                        ),
                                                      )
                                                    : Text(selectedProdukBundle
                                                        .namaProduk),
                                              ),
                                              onTap: () {
                                                if (selectedProduk != null) {
                                                  pindahKeCariBundle();
                                                } else {
                                                  showInSnackBarK(
                                                      'Pilih produk terlebih dahulu');
                                                }
                                              },
                                            ),
                                            ListTile(
                                              leading: Icon(FontAwesomeIcons
                                                  .balanceScale),
                                              title: DropdownButton(
                                                isExpanded: true,
                                                hint: Text('Pilih Satuan'),
                                                value: selectedSatuanBundle,
                                                onChanged: (Satuan ini) {
                                                  setState(() {
                                                    selectedSatuanBundle = ini;
                                                  });
                                                  selectedProdukBundle
                                                          .selectedKodeSatuan =
                                                      ini.kodeSatuan;
                                                  getData('satuan', 'produk');
                                                },
                                                items: listSatuanBundle
                                                    .map(
                                                      (Satuan f) =>
                                                          DropdownMenuItem(
                                                        child:
                                                            Text(f.namaSatuan),
                                                        value: f,
                                                      ),
                                                    )
                                                    .toList(),
                                              ),
                                            ),
                                            ListTile(
                                              onTap: () {},
                                              leading:
                                                  Icon(FontAwesomeIcons.tag),
                                              title: DropdownButton(
                                                isExpanded: true,
                                                hint: Text(
                                                    'Pilih Golongan Harga'),
                                                value:
                                                    selectedGolonganHargaBundle,
                                                onChanged: (GolonganHarga ini) {
                                                  setState(() {
                                                    selectedGolonganHargaBundle =
                                                        ini;
                                                  });
                                                  getData('golonganHarga',
                                                      'produk');
                                                },
                                                items: listGolonganHargaBundle
                                                    .map(
                                                      (GolonganHarga f) =>
                                                          DropdownMenuItem(
                                                        child: Text(
                                                            f.namaGolongan),
                                                        value: f,
                                                      ),
                                                    )
                                                    .toList(),
                                              ),
                                            ),
                                            ListTile(
                                              leading: Icon(
                                                  FontAwesomeIcons.warehouse),
                                              title: TextField(
                                                controller:
                                                    stokControllerBundle,
                                                decoration: InputDecoration(
                                                  hintText: 'Stok gudang',
                                                ),
                                                readOnly: true,
                                                enabled: false,
                                              ),
                                            ),
                                            ListTile(
                                              leading: Icon(FontAwesomeIcons
                                                  .moneyBillAlt),
                                              title: selectedProdukBundle ==
                                                      null
                                                  ? Text(
                                                      'Harga Produk',
                                                      style: TextStyle(
                                                        color: Colors.black54,
                                                      ),
                                                      textAlign:
                                                          TextAlign.right,
                                                    )
                                                  : isLoadingPrice == true
                                                      ? Center(
                                                          child:
                                                              CircularProgressIndicator(),
                                                        )
                                                      : Text(
                                                          numberFormat.format(
                                                            double.parse(
                                                              selectedProdukBundle
                                                                  .hargaProduk,
                                                            ),
                                                          ),
                                                          textAlign:
                                                              TextAlign.right,
                                                        ),
                                            ),
                                            ListTile(
                                              leading: Icon(
                                                  FontAwesomeIcons.warehouse),
                                              title: TextField(
                                                focusNode: qtyFocus,
                                                decoration: InputDecoration(
                                                  hintText: 'Qty',
                                                ),
                                                inputFormatters: <
                                                    TextInputFormatter>[
                                                  WhitelistingTextInputFormatter
                                                      .digitsOnly,
                                                ],
                                                keyboardType:
                                                    TextInputType.number,
                                                controller: qtyController,
                                                onChanged: (ini) {
                                                  // setState(() {
                                                  qtyController.value =
                                                      TextEditingValue(
                                                    selection:
                                                        qtyController.selection,
                                                    text: ini,
                                                  );
                                                  // });
                                                },
                                                onEditingComplete: () {
                                                  if (qtyController
                                                      .text.isEmpty) {
                                                    showInSnackBarK(
                                                        'Input Qty Kosong');
                                                  } else {
                                                    appendKeDaftar();
                                                  }
                                                },
                                              ),
                                            ),
                                            Center(
                                              child: RaisedButton(
                                                child: Text('Tambah ke Daftar'),
                                                color: Colors.cyan,
                                                textColor: Colors.white,
                                                onPressed: () {
                                                  if (qtyController
                                                      .text.isEmpty) {
                                                    showInSnackBarK(
                                                        'Input Qty Kosong');
                                                  } else {
                                                    appendKeDaftar();
                                                  }
                                                },
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    Card(
                                      margin: EdgeInsets.only(
                                        bottom: 100.0,
                                      ),
                                      child: Container(
                                        padding: EdgeInsets.all(5.0),
                                        child: Column(
                                          children: <Widget>[
                                            Container(
                                              padding: EdgeInsets.all(5.0),
                                              child: Text(
                                                'Total',
                                                style: TextStyle(
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.all(5.0),
                                              child: Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    flex: 4,
                                                    child: Text(
                                                      'Total Belanja',
                                                      textAlign:
                                                          TextAlign.right,
                                                      style: TextStyle(
                                                        fontSize: 17.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 5,
                                                    child: Text(
                                                      numberFormat
                                                          .format(totalBelanja),
                                                      textAlign:
                                                          TextAlign.right,
                                                      style: TextStyle(
                                                        fontSize: 16.0,
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.all(5.0),
                                              child: Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    flex: 4,
                                                    child: Text(
                                                      'Total PPN',
                                                      textAlign:
                                                          TextAlign.right,
                                                      style: TextStyle(
                                                        fontSize: 17.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 5,
                                                    child: Text(
                                                      numberFormat
                                                          .format(totalPPN),
                                                      textAlign:
                                                          TextAlign.right,
                                                      style: TextStyle(
                                                        fontSize: 16.0,
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.all(5.0),
                                              child: Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    flex: 4,
                                                    child: Text(
                                                      'Total Diskon',
                                                      textAlign:
                                                          TextAlign.right,
                                                      style: TextStyle(
                                                        fontSize: 17.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 5,
                                                    child: Text(
                                                      numberFormat.format(
                                                          totalSeluruhDiskon),
                                                      textAlign:
                                                          TextAlign.right,
                                                      style: TextStyle(
                                                        fontSize: 16.0,
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                  // =========================== End Tab Index 0 ===========================

                  // ============================ Tab Index 1 ============================
                  Scrollbar(
                    child: listProdukDitambahkan.length == 0
                        ? ListView(
                            children: <Widget>[
                              Card(
                                child: ListTile(
                                  title: Text(
                                    'Daftar produk kosong',
                                    textAlign: TextAlign.center,
                                  ),
                                  subtitle: Text(
                                    'Silahkan tambah barang di tab "Form"',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: EdgeInsets.only(
                              bottom: 50.0,
                            ),
                            itemCount: listProdukDitambahkan.length,
                            itemBuilder: (BuildContext context, int i) {
                              // print(listProdukDitambahkan[i].qtyController.text);
                              return TileTambahProdukKasir(
                                kodeProduk: listProdukDitambahkan[i].kodeProduk,
                                isDiskonFilled:
                                    listProdukDitambahkan[i].isDiskonFilled,
                                isDiskonPersen:
                                    listProdukDitambahkan[i].isDiskonPersen,
                                namaProduk: listProdukDitambahkan[i].namaProduk,
                                namaSatuan:
                                    listProdukDitambahkan[i].selectedNamaSatuan,
                                hargaProduk:
                                    listProdukDitambahkan[i].hargaProduk,
                                totalHargaProduk: double.parse(
                                    listProdukDitambahkan[i]
                                        .totalHargaSetelahDiskon),
                                diskonNilaiController: listProdukDitambahkan[i]
                                    .diskonNilaiController,
                                diskonPersenController: listProdukDitambahkan[i]
                                    .diskonPersenController,
                                qtyController:
                                    listProdukDitambahkan[i].qtyController,
                                onDelete: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                      title: Text('Peringatan!'),
                                      content: Text(
                                          'Apa anda yakin menghapus produk dari daftar?'),
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
                                            // hapus List<Produk> listprodukditambahkan index ke [i]
                                            setState(() {
                                              listProdukDitambahkan.removeAt(i);
                                            });
                                            sumTotalPenjualan();
                                            // end hapus
                                            Navigator.pop(context);
                                          },
                                        )
                                      ],
                                    ),
                                  );
                                },
                                onDiskonNilaiChange: (ini) {
                                  listProdukDitambahkan[i].diskonNilai = ini;

                                  listProdukDitambahkan[i]
                                      .diskonNilaiController
                                      .value = TextEditingValue(
                                    selection: listProdukDitambahkan[i]
                                        .diskonNilaiController
                                        .selection,
                                    text: ini,
                                  );

                                  sumTotalPenjualan();

                                  if (listProdukDitambahkan[i]
                                              .diskonNilaiController
                                              .text !=
                                          '' ||
                                      ini == '0') {
                                    setState(() {
                                      listProdukDitambahkan[i].isDiskonFilled =
                                          true;
                                      listProdukDitambahkan[i].isDiskonPersen =
                                          false;
                                    });
                                  } else {
                                    setState(() {
                                      listProdukDitambahkan[i].isDiskonFilled =
                                          false;
                                      listProdukDitambahkan[i].isDiskonPersen =
                                          false;
                                    });
                                  }
                                },
                                onDiskonPersenChange: (ini) {
                                  if (ini != '' || ini == '0') {
                                    setState(() {
                                      listProdukDitambahkan[i].isDiskonFilled =
                                          true;
                                      listProdukDitambahkan[i].isDiskonPersen =
                                          true;
                                    });
                                  } else {
                                    setState(() {
                                      listProdukDitambahkan[i].isDiskonFilled =
                                          false;
                                      listProdukDitambahkan[i].isDiskonPersen =
                                          false;
                                    });
                                  }

                                  sumTotalPenjualan();

                                  if (int.parse(ini) > 100) {
                                    ini = 100.toString();
                                    listProdukDitambahkan[i]
                                            .diskonPersenController
                                            .selection =
                                        TextSelection.collapsed(offset: 3);
                                  }

                                  listProdukDitambahkan[i].diskonPersen = ini;

                                  listProdukDitambahkan[i]
                                      .diskonPersenController
                                      .value = TextEditingValue(
                                    selection: listProdukDitambahkan[i]
                                        .diskonPersenController
                                        .selection,
                                    text: ini,
                                  );
                                },
                                onQtyChange: (ini) {
                                  if (int.parse(listProdukDitambahkan[i]
                                          .minimalBeliOffline) >
                                      int.parse(ini)) {
                                    listProdukDitambahkan[i]
                                        .qtyController
                                        .value = TextEditingValue(
                                      selection: listProdukDitambahkan[i]
                                          .qtyController
                                          .selection,
                                      text: ini,
                                    );
                                    showInSnackBarK(
                                        'Minimal Pembelian Offline ${listProdukDitambahkan[i].namaProduk} adalah ${listProdukDitambahkan[i].minimalBeliOffline}');
                                  } else {
                                    listProdukDitambahkan[i]
                                        .qtyController
                                        .value = TextEditingValue(
                                      selection: listProdukDitambahkan[i]
                                          .qtyController
                                          .selection,
                                      text: ini,
                                    );
                                  }
                                  // setState(() {
                                  //   listProdukDitambahkan[i].qtyController =
                                  //       listProdukDitambahkan[i].qtyController;
                                  // });

                                  sumTotalPenjualan();
                                },
                                errorText: int.parse(listProdukDitambahkan[i]
                                            .qtyController
                                            .text) <
                                        int.parse(listProdukDitambahkan[i]
                                            .minimalBeliOffline)
                                    ? 'Minimal Pembelian : ${listProdukDitambahkan[i].minimalBeliOffline}'
                                    : null,
                              );
                            },
                          ),
                  ),
                  // =========================== End Tab Index 1 ===========================
                ],
              ),
            ),
            // ============================ Button Simpan ============================
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                for (var data in listProdukDitambahkan) {
                  if (int.parse(data.qtyController.text) <
                      int.parse(data.minimalBeliOffline)) {
                    // print('false');
                    isMinimalPembelian = false;
                    break;
                  } else {
                    // print('true');
                    isMinimalPembelian = true;
                  }
                }
                if (formKey.currentState.validate() &&
                    selectedCustomer != null &&
                    // selectedKabupatenKota != null &&
                    // selectedProvinsi != null &&
                    // selectedKecamatan != null &&
                    // selectedJenisPembayaran != null &&
                    listProdukDitambahkan.length != 0 &&
                    isMinimalPembelian) {
                  setState(() {
                    isCustomerKosong = false;
                    isMinimalPembelian = true;
                    // isKabupatenKotaKosong = false;
                    // isProvinsiKosong = false;
                    // isKecamatanKosong = false;
                    // isJenisBayarKosong = false;
                  });
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return StatefulBuilder(
                          builder: (BuildContext context, setState) {
                        return AlertDialog(
                          title: Text('Pembayaran'),
                          content: Scrollbar(
                            child: SingleChildScrollView(
                              child: Form(
                                key: _form2,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    ListTile(
                                      title: Text('Total'),
                                      subtitle: Text(
                                        numberFormat
                                            .format(totalBelanjaSetelahDiskon),
                                      ),
                                    ),
                                    TextFormField(
                                      controller: jumlahDiBayarController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                          hintText: 'Jumlah dibayar'),
                                      inputFormatters: [
                                        WhitelistingTextInputFormatter
                                            .digitsOnly,
                                      ],
                                      onFieldSubmitted: (ini) {
                                        jumlahDiBayarController.value =
                                            TextEditingValue(
                                          selection:
                                              jumlahDiBayarController.selection,
                                          text: ini,
                                        );

                                        kembalian = jumlahDiBayarController
                                                .numberValue -
                                            totalBelanjaSetelahDiskon;
                                        setState(() {
                                          kembalian = kembalian;
                                        });
                                      },
                                      onChanged: (ini) {
                                        print(ini);
                                        jumlahDiBayarController.value =
                                            TextEditingValue(
                                          selection:
                                              jumlahDiBayarController.selection,
                                          text: ini,
                                        );
                                        print(jumlahDiBayarController
                                            .numberValue);

                                        kembalian = jumlahDiBayarController
                                                .numberValue -
                                            totalBelanjaSetelahDiskon;
                                        setState(() {
                                          kembalian = kembalian;
                                        });
                                      },
                                      validator: (ini) {
                                        if (ini.isEmpty) {
                                          return 'Input tidak boleh kosong';
                                        }
                                        if (totalBelanjaSetelahDiskon >
                                            jumlahDiBayarController
                                                .numberValue) {
                                          return 'Jumlah yang dibayar kurang';
                                        }
                                        return null;
                                      },
                                    ),
                                    ListTile(
                                      title: Text('Kembalian'),
                                      subtitle:
                                          Text(numberFormat.format(kembalian)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          actions: <Widget>[
                            FlatButton(
                              child: Text('Kembali'),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            FlatButton(
                              textColor: Colors.green,
                              child: Text('Lanjut'),
                              onPressed: () {
                                if (_form2.currentState.validate()) {
                                  Navigator.pop(context);
                                  dialogPilihPengiriman();
                                }
                              },
                            )
                          ],
                        );
                      });
                    },
                  );
                } else {
                  if (selectedCustomer == null) {
                    setState(() {
                      isCustomerKosong = true;
                    });
                  }
                  if (isMinimalPembelian == false) {
                    showInSnackBarK(
                        'Qty Pembelian ada yang kurang dari minimal pembelian');
                  }
                  // if (selectedKabupatenKota == null) {
                  //   setState(() {
                  //     isKabupatenKotaKosong = true;
                  //   });
                  // }
                  // if (selectedProvinsi == null) {
                  //   setState(() {
                  //     isProvinsiKosong = true;
                  //   });
                  // }
                  // if (selectedKecamatan == null) {
                  //   setState(() {
                  //     isKecamatanKosong = true;
                  //   });
                  // }
                  // if (selectedJenisPembayaran == null) {
                  //   setState(() {
                  //     isJenisBayarKosong = true;
                  //   });
                  // }
                  if (listProdukDitambahkan.length == 0) {
                    showInSnackBarK('Daftar Produk tidak boleh kosong');
                  }
                }
              },
              child: Icon(Icons.check),
            ),
            // End Button Simpan
          ),
        ),
      ),
    );
  }

  void sumTotalPenjualan() {
    totalBelanja = 0.0;
    totalDiskonPersen = 0.0;
    totalDiskonNilai = 0.0;
    totalPPN = 0.0;
    totalSeluruhDiskon = 0.0;

    // loop
    for (int i = 0; i < listProdukDitambahkan.length; i++) {
      // sum total semua belanja semua produk
      totalBelanja += double.parse(listProdukDitambahkan[i].hargaProduk) *
          int.parse(listProdukDitambahkan[i].qtyController.text);
      // sum total diskon persen semua produk
      totalDiskonPersen += double.parse(listProdukDitambahkan[i].hargaProduk) *
          int.parse(listProdukDitambahkan[i].qtyController.text) *
          (listProdukDitambahkan[i].diskonPersenController.text == ''
              ? 0
              : int.parse(
                      listProdukDitambahkan[i].diskonPersenController.text) /
                  100);
      // sum total diskon nilai semua produk
      totalDiskonNilai += double.parse(
          listProdukDitambahkan[i].diskonNilaiController.text == ''
              ? '0'
              : listProdukDitambahkan[i].diskonNilaiController.text);

      // variable harga, diskon nilai, diskon persen per produk, diskon per produk
      double totalHargaPerProduk,
          totalHargaSetelahDiskonPerProduk,
          totalDiskonPersenPerProduk,
          totalDiskonNilaiPerProduk,
          totalDiskonPerProduk;

      totalDiskonPersenPerProduk = double.parse(
              listProdukDitambahkan[i].hargaProduk) *
          int.parse(listProdukDitambahkan[i].qtyController.text) *
          (listProdukDitambahkan[i].diskonPersenController.text == ''
              ? 0
              : int.parse(
                      listProdukDitambahkan[i].diskonPersenController.text) /
                  100);

      totalDiskonNilaiPerProduk = (listProdukDitambahkan[i]
                  .diskonNilaiController
                  .text ==
              ''
          ? 0
          : double.parse(listProdukDitambahkan[i].diskonNilaiController.text));

      totalDiskonPerProduk =
          totalDiskonPersenPerProduk + totalDiskonNilaiPerProduk;

      totalHargaSetelahDiskonPerProduk =
          double.parse(listProdukDitambahkan[i].hargaProduk) *
                  int.parse(listProdukDitambahkan[i].qtyController.text) -
              totalDiskonPerProduk;

      totalHargaPerProduk = double.parse(listProdukDitambahkan[i].hargaProduk) *
          int.parse(listProdukDitambahkan[i].qtyController.text);

      // total harga per produk setelah di diskon
      listProdukDitambahkan[i].totalHargaSetelahDiskon =
          totalHargaSetelahDiskonPerProduk.toString();

      // total harga per produk belum di diskon
      listProdukDitambahkan[i].totalHarga = totalHargaPerProduk.toString();
    }
    // end loop
    totalBelanjaSetelahDiskon = totalBelanja;

    // pengurangan total seluruh belanja dengan total diskon nilai dan persen
    setState(() {
      totalSeluruhDiskon = totalDiskonNilai + totalDiskonPersen;
      totalBelanjaSetelahDiskon -= totalDiskonNilai + totalDiskonPersen;
      totalPPN = totalBelanjaSetelahDiskon * (10 / 110);
    });
  }

  void appendKeDaftar() {
    print('pressed');
    if (selectedProduk == null && isLoadingPrice == true ||
        selectedProduk == null) {
      showInSnackBarK('Pilih produk terlebih dahulu');
      // FocusScope.of(context).requestFocus();
      // pindahKeCariProduk();
    } else if (int.parse(stokController.text) < int.parse(qtyController.text)) {
      showInSnackBarK('Stok Kurang');
      FocusScope.of(context).requestFocus(qtyFocus);
    } else {
      print('statement false');
      if (listProdukDitambahkan
              .where(
                  (test) => test.kodeProduk.contains(selectedProduk.kodeProduk))
              .length >
          0) {
        showInSnackBarK('Produk sudah ada');
      } else if (int.parse(selectedProduk.minimalBeliOffline) >
          int.parse(qtyController.text)) {
        showInSnackBarK(
            'Minimal Pembelian Offline ${selectedProduk.namaProduk} adalah ${selectedProduk.minimalBeliOffline}');
        FocusScope.of(context).requestFocus(qtyFocus);
      } else if (listProdukDitambahkan
              .where((test) =>
                  test.kodeProduk.contains(selectedProdukBundle.kodeProduk))
              .length >
          0) {
        showInSnackBarK('Produk sudah ada');
      } else if (int.parse(selectedProdukBundle.minimalBeliOffline) >
          int.parse(qtyController.text)) {
        showInSnackBarK(
            'Minimal Pembelian Offline ${selectedProdukBundle.namaProduk} adalah ${selectedProdukBundle.minimalBeliOffline}');
        FocusScope.of(context).requestFocus(qtyFocus);
      } else {
        selectedProduk.qtyController =
            TextEditingController(text: qtyController.text);

        print(selectedProduk.qtyController.text);

        selectedProduk.diskonNilaiController = TextEditingController(text: '');

        selectedProduk.diskonPersenController = TextEditingController(text: '');

        double totalHarga = double.parse(selectedProduk.hargaProduk) *
            int.parse(qtyController.text);
        selectedProduk.totalHarga = totalHarga.toString();

        selectedProduk.isDiskonFilled = false;
        selectedProduk.isDiskonPersen = false;

        listProdukDitambahkan.add(selectedProduk);
        if (selectedProdukBundle != null) {
          selectedProdukBundle.qtyController =
              TextEditingController(text: qtyController.text);

          print(selectedProdukBundle.qtyController.text);

          selectedProdukBundle.diskonNilaiController =
              TextEditingController(text: '');

          selectedProdukBundle.diskonPersenController =
              TextEditingController(text: '');

          double totalHarga = double.parse(selectedProdukBundle.hargaProduk) *
              int.parse(qtyController.text);
          selectedProdukBundle.totalHarga = totalHarga.toString();

          selectedProdukBundle.isDiskonFilled = false;
          selectedProdukBundle.isDiskonPersen = false;

          listProdukDitambahkan.add(selectedProdukBundle);
        }

        // if (listProdukDitambahkan.length == 1) {
        //   totalBelanja = double.parse(selectedProduk.hargaProduk) *
        //       int.parse(qtyController.text);

        //   totalDiskonNilai = 0.0;
        //   totalDiskonPersen = 0.0;
        //   setState(() {
        //     totalBelanjaSetelahDiskon =
        //         double.parse(selectedProduk.hargaProduk) *
        //             int.parse(qtyController.text);
        //   });
        // } else {
        sumTotalPenjualan();
        // }
        selectedProduk = null;
        selectedSatuan = null;
        selectedGolonganHarga = null;
        selectedProdukBundle = null;
        selectedSatuanBundle = null;
        selectedGolonganHargaBundle = null;
        // produkController.clear();
        // produkAutoComplete.clear();
        qtyController.clear();
        stokController.clear();
        stokControllerBundle.clear();
        setState(() {
          listSatuan.clear();
          listGolonganHarga.clear();
        });
        pindahKeCariProduk();
      }
      // FocusScope.of(context).requestFocus(produkFocus);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_image/network.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:invee2/error/error.dart';
import 'dart:async';
import 'dart:convert';

import 'package:invee2/localStorage/localStorage.dart';
import 'package:invee2/master/customer/customerListTile.dart';
import 'package:invee2/master/customer/customerModel.dart';
import 'package:invee2/routes/env.dart';

GlobalKey<ScaffoldState> _scaffoldKeyDetailCustomer;

String tokenType, accessToken;
Map<String, String> requestHeaders = Map();
bool isLoading, isError;

Customer customer;

void showInSnackBarDetailCustomer(String value) {
  _scaffoldKeyDetailCustomer.currentState
      .showSnackBar(new SnackBar(content: new Text(value)));
}

class DetailCustomer extends StatefulWidget {
  final String id;

  DetailCustomer({this.id});

  @override
  _DetailCustomerState createState() => _DetailCustomerState();
}

class _DetailCustomerState extends State<DetailCustomer> {
  Future<Null> getDetailCustomer() async {
    DataStore storage = new DataStore();

    String tokenTypeStorage = await storage.getDataString('token_type');
    String accessTokenStorage = await storage.getDataString('access_token');

    tokenType = tokenTypeStorage;
    accessToken = accessTokenStorage;

    requestHeaders['Accept'] = 'application/json';
    requestHeaders['Authorization'] = '$tokenType $accessToken';

    setState(() {
      isLoading = true;
      isError = false;
    });

    try {
      final response = await http.post(
        url('api/detailAtauEditCustomerAndroid'),
        headers: requestHeaders,
        body: {
          'id': widget.id,
        },
      );

      if (response.statusCode == 200) {
        // return response;
        dynamic responseJson = json.decode(response.body);
        // print(responseJson);

        dynamic data = responseJson[0];

        customer = Customer(
          alamat: data['cm_address'],
          idCustomer: data['cm_id'].toString(),
          namaCustomer: data['cm_name'],
          kodeCustomer: data['cm_code'],
          email: data['cm_email'],
          telpon: data['cm_nphone'],
          idKabupatenKota: data['cm_city'],
          idProvinsi: data['cm_province'],
          idKecamatan: data['cm_district'],
          kodePos: data['cm_postalcode'],
          username: data['cm_username'],
          gambar: data['cm_path'],
          gender: data['cm_gender'],
          tanggalLahir: data['cm_born'],
          tempatLahir: data['cm_cityborn'],
          noRekening: data['cm_nbank'],
          namaBank: data['cm_bank'],
          namaKabupatenKota: data['c_nama'],
          namaKecamatan: data['d_nama'],
          namaProvinsi: data['p_nama'],
        );

        setState(() {
          isLoading = false;
          isError = false;
        });
      } else {
        showInSnackBarDetailCustomer(
            'Request failed with status: ${response.statusCode}');
            
        Map responseJson = jsonDecode(response.body);

        if (responseJson.containsKey('message')) {
          showInSnackBarDetailCustomer(responseJson['message']);
        }
        print(jsonDecode(response.body));
        setState(() {
          isLoading = false;
          isError = true;
        });
      }
    } on TimeoutException catch (_) {
      showInSnackBarDetailCustomer('Timed out, Try again');
      setState(() {
        isLoading = false;
        isError = true;
      });
    } catch (e) {
      showInSnackBarDetailCustomer('Error : ${e.toString()}');
      print('Error : $e');
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  @override
  void initState() {
    _scaffoldKeyDetailCustomer = GlobalKey<ScaffoldState>();
    isLoading = true;
    isError = false;

    getDetailCustomer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKeyDetailCustomer,
      appBar: AppBar(
        title: Text('Detail Customer'),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : isError
              ? ErrorCobalLagi(
                  onPress: getDetailCustomer,
                )
              : Scrollbar(
                  child: RefreshIndicator(
                    onRefresh: getDetailCustomer,
                    child: ListView(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5.0),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.5),
                              width: 0.5,
                            ),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: Colors.grey[300].withOpacity(0.5),
                                offset: Offset(0.1, 0.1),
                                blurRadius: 2.0,
                                spreadRadius: 1.0,
                              ),
                            ],
                          ),
                          child: Column(
                            children: <Widget>[
                              Container(
                                margin:
                                    EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 10.0),
                                child: Text(
                                  'Info Customer',
                                  style: TextStyle(
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                child: Column(
                                  children: <Widget>[
                                    customer.gambar == null
                                        ? Image(
                                            image: NetworkImageWithRetry(
                                              urlShop('assets/img/noimage.jpg'),
                                            ),
                                            // width: 300.0,
                                            // height: 300.0,
                                          )
                                        : Image(
                                            image: NetworkImageWithRetry(
                                              urlShop(
                                                  'storage/image/member/profile/${customer.gambar}'),
                                            ),
                                            width: 300.0,
                                            height: 300.0,
                                          ),
                                  ],
                                ),
                              ),
                              Divider(),
                              ListTileCustomer(
                                leading: Icon(
                                  FontAwesomeIcons.user,
                                  size: 15.0,
                                ),
                                title: Text(
                                  customer.namaCustomer != null
                                      ? customer.namaCustomer
                                      : 'Data belum diubah',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                                subtitle: Text(
                                  'Nama Customer',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 13.0,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Divider(),
                              ListTileCustomer(
                                leading: Icon(
                                  FontAwesomeIcons.barcode,
                                  size: 15.0,
                                ),
                                title: Text(
                                  customer.kodeCustomer != null
                                      ? customer.kodeCustomer
                                      : 'Data belum diubah',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                                subtitle: Text(
                                  'Kode Customer',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 13.0,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Divider(),
                              ListTileCustomer(
                                leading: Icon(
                                  FontAwesomeIcons.userCog,
                                  size: 15.0,
                                ),
                                title: Text(
                                  customer.username != null
                                      ? customer.username
                                      : 'Data belum diubah',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                                subtitle: Text(
                                  'Usernmae Customer',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 13.0,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Divider(),
                              ListTileCustomer(
                                leading: Icon(
                                  FontAwesomeIcons.envelope,
                                  size: 15.0,
                                ),
                                title: Text(
                                  customer.email != null
                                      ? customer.email
                                      : 'Data belum diubah',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                                subtitle: Text(
                                  'Email Customer',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 13.0,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Divider(),
                              ListTileCustomer(
                                leading: Icon(
                                  FontAwesomeIcons.phone,
                                  size: 15.0,
                                ),
                                title: Text(
                                  customer.telpon != null
                                      ? customer.telpon
                                      : 'Data belum diubah',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                                subtitle: Text(
                                  'No. HP',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 13.0,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Divider(),
                              ListTileCustomer(
                                leading: Icon(
                                  FontAwesomeIcons.venusMars,
                                  size: 15.0,
                                ),
                                title: Text(
                                  customer.gender != null
                                      ? customer.gender == 'L'
                                          ? 'Laki-laki'
                                          : 'Perempuan'
                                      : 'Data belum diubah',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                                subtitle: Text(
                                  'Jenis Kelamin',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 13.0,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Divider(),
                              ListTileCustomer(
                                leading: Icon(
                                  FontAwesomeIcons.building,
                                  size: 15.0,
                                ),
                                title: Text(
                                  customer.namaBank != null
                                      ? customer.namaBank
                                      : 'Data belum diubah',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                                subtitle: Text(
                                  'Nama Bank',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 13.0,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Divider(),
                              ListTileCustomer(
                                leading: Icon(
                                  FontAwesomeIcons.fileInvoiceDollar,
                                  size: 15.0,
                                ),
                                title: Text(
                                  customer.noRekening != null
                                      ? customer.noRekening
                                      : 'Data belum diubah',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                                subtitle: Text(
                                  'No. Rekening',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 13.0,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Divider(),
                              ListTileCustomer(
                                leading: Icon(
                                  FontAwesomeIcons.calendarAlt,
                                  size: 15.0,
                                ),
                                title: Text(
                                  customer.tanggalLahir != null
                                      ? customer.tanggalLahir
                                      : 'Data belum diubah',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                                subtitle: Text(
                                  'Tanggal Lahir',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 13.0,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Divider(),
                              ListTileCustomer(
                                leading: Icon(
                                  FontAwesomeIcons.hospitalAlt,
                                  size: 15.0,
                                ),
                                title: Text(
                                  customer.tempatLahir != null
                                      ? customer.tempatLahir
                                      : 'Data belum diubah',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                                subtitle: Text(
                                  'Tempat Lahir',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 13.0,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5.0),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.5),
                              width: 0.5,
                            ),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: Colors.grey[300].withOpacity(0.5),
                                offset: Offset(0.1, 0.1),
                                blurRadius: 2.0,
                                spreadRadius: 1.0,
                              ),
                            ],
                          ),
                          child: Column(
                            children: <Widget>[
                              Container(
                                margin:
                                    EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 10.0),
                                child: Text(
                                  'Alamat Customer',
                                  style: TextStyle(
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Divider(),
                              ListTileCustomer(
                                leading: Icon(
                                  FontAwesomeIcons.home,
                                  size: 15.0,
                                ),
                                title: Text(
                                  customer.alamat != null
                                      ? customer.alamat
                                      : 'Data belum diubah',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                                subtitle: Text(
                                  'Alamat Customer',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 13.0,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Divider(),
                              ListTileCustomer(
                                leading: Icon(
                                  FontAwesomeIcons.portrait,
                                  size: 15.0,
                                ),
                                title: Text(
                                  customer.namaProvinsi != null
                                      ? customer.namaProvinsi
                                      : 'Data belum diubah',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                                subtitle: Text(
                                  'Provinsi',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 13.0,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Divider(),
                              ListTileCustomer(
                                leading: Icon(
                                  FontAwesomeIcons.city,
                                  size: 15.0,
                                ),
                                title: Text(
                                  customer.namaKabupatenKota != null
                                      ? customer.namaKabupatenKota
                                      : 'Data belum diubah',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                                subtitle: Text(
                                  'Kabupaten/Kota',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 13.0,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Divider(),
                              ListTileCustomer(
                                leading: Icon(
                                  FontAwesomeIcons.placeOfWorship,
                                  size: 15.0,
                                ),
                                title: Text(
                                  customer.namaKecamatan != null
                                      ? customer.namaKecamatan
                                      : 'Data belum diubah',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                                subtitle: Text(
                                  'Kecamatan',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 13.0,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Divider(),
                              ListTileCustomer(
                                leading: Icon(
                                  FontAwesomeIcons.mailBulk,
                                  size: 15.0,
                                ),
                                title: Text(
                                  customer.kodePos != null
                                      ? customer.kodePos
                                      : 'Data belum diubah',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                                subtitle: Text(
                                  'Kode Pos',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 13.0,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
    );
  }
}

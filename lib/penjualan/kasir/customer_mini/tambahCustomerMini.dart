// import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image/network.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:invee2/environment/imagePicker.dart';
// import 'package:invee2/error/error.dart';
import 'dart:async';
import 'dart:convert';
// import 'package:intl/intl.dart';
import 'package:invee2/localStorage/localStorage.dart';
import 'package:invee2/master/customer/customerListTile.dart';
import 'package:invee2/master/customer/customerModel.dart';
import 'package:invee2/penjualan/kasir/environment/kabupatenKota.dart';
import 'package:invee2/penjualan/kasir/environment/kecamatan.dart';
import 'package:invee2/penjualan/kasir/environment/model.dart'
    as kasir;
import 'package:invee2/penjualan/kasir/environment/provinsi.dart';
import 'package:invee2/routes/env.dart';

GlobalKey<ScaffoldState> _scaffoldKeyTambahCustomerMinimal;

String tokenType, accessToken;
Map<String, String> requestHeaders = Map();
bool isLoading, isError;

Customer customer;
TextEditingController namaCustomerController,
    usernameController,
    emailController,
    telponController,
    // bankController,
    // rekeningController,
    // tempatLahirController,
    alamatController,
    passwordController,
    // tanggalLahirController,
    kodePosController;

FocusNode namaCustomerFocus,
    usernameFocus,
    emailFocus,
    telponFocus,
    // bankFocus,
    // rekeningFocus,
    // tempatLahirFocus,
    alamatFocus,
    // tanggalLahirFocus,
    passwordFocus,
    kodePosFocus;

DateTime tanggalLahir;
File image;

GlobalKey<FormState> _formKey;
List<JenisKelamin> listGender;
JenisKelamin selectedGender;

void showInSnackBarTambahCustomerMinimal(String value) {
  _scaffoldKeyTambahCustomerMinimal.currentState
      .showSnackBar(new SnackBar(content: new Text(value)));
}

class TambahCustomerMinimal extends StatefulWidget {
  @override
  _DetailCustomerState createState() => _DetailCustomerState();
}

class _DetailCustomerState extends State<TambahCustomerMinimal> {
  Widget floatingActionButton() {
    if (!isLoading) {
      return FloatingActionButton(
        onPressed: () {
          if (_formKey.currentState.validate() && selectedGender != null) {
            showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: Text('Peringatan!'),
                content: Text('Data akan disimpan, apa anda yakin?'),
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
                      Navigator.pop(context);

                      simpan();
                    },
                  )
                ],
              ),
            );
          } else {
            if (selectedGender == null) {
              showInSnackBarTambahCustomerMinimal(
                  'Jenis Kelamin tidak boleh kosong');
            }
          }
        },
        child: Icon(Icons.done),
      );
    } else {
      return FloatingActionButton(
        backgroundColor: Colors.grey,
        child: Icon(
          Icons.check,
          color: Colors.black,
        ),
        onPressed: null,
      );
    }
  }

  simpan() async {
    DataStore storage = new DataStore();

    String tokenTypeStorage = await storage.getDataString('token_type');
    String accessTokenStorage = await storage.getDataString('access_token');

    tokenType = tokenTypeStorage;
    accessToken = accessTokenStorage;

    requestHeaders['Accept'] = 'application/json';
    requestHeaders['Authorization'] = '$tokenType $accessToken';

    Map<String, dynamic> formSerialize = Map<String, dynamic>();

    Map<String, String> requestHeadersX = Map();

    requestHeadersX = requestHeaders;

    // requestHeadersX['content-type'] = 'application/x-www-form-urlencoded';

    formSerialize['nama_customer'] = namaCustomerController.text;
    formSerialize['email'] = emailController.text;
    formSerialize['gender'] = selectedGender.isi;
    if (passwordController.text.isNotEmpty) {
      formSerialize['password'] = passwordController.text;
    }
    if (telponController.text.isNotEmpty) {
      formSerialize['nomor_hp'] = telponController.text;
    }
    if (alamatController.text.isNotEmpty) {
      formSerialize['alamat'] = alamatController.text;
    }
    if (usernameController.text.isNotEmpty) {
      formSerialize['username'] = usernameController.text;
    }
    // formSerialize['nomor_rekening'] = rekeningController.text;
    // formSerialize['tempat_lahir'] = tempatLahirController.text;
    // formSerialize['tanggal_lahir'] = tanggalLahirController.text;
    // formSerialize['bank'] = bankController.text;
    if (customer.idProvinsi != null) {
      formSerialize['provinsi_customer'] = customer.idProvinsi;
    }
    if (customer.idKabupatenKota != null) {
      formSerialize['kota_customer'] = customer.idKabupatenKota;
    }
    if (customer.idKecamatan != null) {
      formSerialize['kecamatan_customer'] = customer.idKecamatan;
    }
    if (kodePosController.text.isNotEmpty) {
      formSerialize['kode_pos'] = kodePosController.text;
    }

    if (image != null) {
      formSerialize['gambar'] = base64Encode(image.readAsBytesSync());
    }

    print(formSerialize);

    try {
      final response = await http.post(
        url('api/simpan_customer_minimal'),
        headers: requestHeadersX,
        body: formSerialize,
      );
      if (response.statusCode == 200) {
        dynamic responseJson = jsonDecode(response.body);

        if (responseJson['status'] == 'sukses') {
          Navigator.popUntil(
            context,
            ModalRoute.withName('/kasir/create_penjualan'),
          );
        } else if (responseJson['error'] == 'Username Sudah Terpakai') {
          showInSnackBarTambahCustomerMinimal('Username Sudah Terpakai');
        } else if (responseJson['error'] == 'Email Sudah Terpakai') {
          showInSnackBarTambahCustomerMinimal('Email Sudah Terpakai');
        } else {
          print(responseJson);
          showInSnackBarTambahCustomerMinimal(responseJson.toString());
        }
      } else if (response.statusCode == 401) {
        showInSnackBarTambahCustomerMinimal(
            'Token kedaluwarsa, silahkan login kembali');
      } else {
        showInSnackBarTambahCustomerMinimal(
            'Error Code : ${response.statusCode}');
        print(jsonDecode(response.body));
        Map responseJson = jsonDecode(response.body);

        if (responseJson.containsKey('message')) {
          showInSnackBarTambahCustomerMinimal(responseJson['message']);
        }
      }
    } catch (e) {
      showInSnackBarTambahCustomerMinimal('Error : ${e.toString()}');
      print('Error : $e');
    }
  }

  Future<bool> peringatanPindahHalaman() {
    return showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text('Peringatan!'),
            content:
                Text('Data yang anda isi akan menghilang, apa anda yakin?'),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text('Tidak'),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Text(
                  'Ya',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              )
            ],
          ),
        ) ??
        false;
  }

  @override
  void initState() {
    _scaffoldKeyTambahCustomerMinimal = GlobalKey<ScaffoldState>();
    isLoading = false;
    isError = false;
    selectedGender = null;
    image = null;

    namaCustomerFocus = FocusNode();
    emailFocus = FocusNode();
    usernameFocus = FocusNode();
    alamatFocus = FocusNode();
    kodePosFocus = FocusNode();
    // bankFocus = FocusNode();
    // tempatLahirFocus = FocusNode();
    // rekeningFocus = FocusNode();
    // tanggalLahirFocus = FocusNode();
    passwordFocus = FocusNode();
    telponFocus = FocusNode();

    namaCustomerController = TextEditingController();
    usernameController = TextEditingController();
    emailController = TextEditingController();
    telponController = TextEditingController();
    // bankController = TextEditingController();
    // rekeningController = TextEditingController();
    // tempatLahirController = TextEditingController();
    alamatController = TextEditingController();
    passwordController = TextEditingController();
    // tanggalLahirController = TextEditingController();
    kodePosController = TextEditingController();

    customer = Customer();

    tanggalLahir = DateTime.now();

    _formKey = GlobalKey<FormState>();

    listGender = [
      JenisKelamin(
        isi: 'L',
        nama: 'Laki-laki',
      ),
      JenisKelamin(
        isi: 'P',
        nama: 'Perempuan',
      ),
    ];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: peringatanPindahHalaman,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          key: _scaffoldKeyTambahCustomerMinimal,
          appBar: AppBar(
            title: Text('Tambah Customer'),
          ),
          floatingActionButton: floatingActionButton(),
          body: Form(
            key: _formKey,
            child: Scrollbar(
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
                          margin: EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 10.0),
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
                              image == null
                                  ? InkWell(
                                      onTap: () async {
                                        File imageX = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            settings: RouteSettings(
                                                name: '/ambil_gambar'),
                                            builder: (BuildContext context) =>
                                                AmbilGambar(
                                              title: 'Ambil Gambar',
                                            ),
                                          ),
                                        );

                                        if (imageX != null) {
                                          setState(() {
                                            image = imageX;
                                          });
                                        }
                                      },
                                      child: Image(
                                        image: NetworkImageWithRetry(
                                          url('assets/img/add-image-icon-sm.png'),
                                        ),
                                        // width: 300.0,
                                        // height: 300.0,
                                      ),
                                    )
                                  : Image.file(
                                      image,
                                      width: 300.0,
                                      height: 300.0,
                                    ),
                              Container(
                                padding: EdgeInsets.all(5.0),
                                child: RaisedButton(
                                  textColor: Colors.white,
                                  onPressed: () async {
                                    File imageX = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        settings: RouteSettings(
                                            name: '/ambil_gambar'),
                                        builder: (BuildContext context) =>
                                            AmbilGambar(
                                          title: 'Ambil Gambar',
                                        ),
                                      ),
                                    );

                                    if (imageX != null) {
                                      setState(() {
                                        image = imageX;
                                      });
                                    }
                                  },
                                  child: Text('Pilih Gambar'),
                                ),
                              ),
                              image != null
                                  ? Container(
                                      child: RaisedButton(
                                        textColor: Colors.white,
                                        color: Colors.red,
                                        child: Text('Hapus Gambar'),
                                        onPressed: () {
                                          setState(() {
                                            image = null;
                                          });
                                        },
                                      ),
                                    )
                                  : Container(),
                            ],
                          ),
                        ),
                        Divider(),
                        Divider(),
                        ListTileCustomer(
                          leading: Icon(
                            FontAwesomeIcons.user,
                            size: 15.0,
                          ),
                          title: TextFormField(
                            autofocus: true,
                            controller: namaCustomerController,
                            focusNode: namaCustomerFocus,
                            decoration: InputDecoration(
                              labelText: 'Nama Customer',
                              labelStyle: TextStyle(
                                fontSize: 18.0,
                              ),
                              helperText: 'Nama wajib di isi',
                            ),
                            validator: (ini) {
                              if (ini.isEmpty) {
                                return 'Nama tidak boleh kosong';
                              }
                              return null;
                            },
                            onEditingComplete: () {
                              FocusScope.of(context).requestFocus(telponFocus);
                            },
                          ),
                        ),
                        Divider(),
                        ListTileCustomer(
                          leading: Icon(
                            FontAwesomeIcons.phone,
                            size: 15.0,
                          ),
                          title: TextFormField(
                            controller: telponController,
                            focusNode: telponFocus,
                            decoration: InputDecoration(
                              labelText: 'Telpon Customer',
                              labelStyle: TextStyle(
                                fontSize: 18.0,
                              ),
                              helperText: 'Telpon wajib di isi',
                            ),
                            inputFormatters: <TextInputFormatter>[
                              WhitelistingTextInputFormatter.digitsOnly,
                            ],
                            keyboardType: TextInputType.number,
                            validator: (ini) {
                              if (ini.isEmpty) {
                                return 'Telpon tidak boleh kosong';
                              }
                              return null;
                            },
                            // onEditingComplete: (){
                            //   FocusScope.of(context).requestFocus(usernameFocus);
                            // },
                          ),
                        ),
                        Divider(),
                        ListTileCustomer(
                          leading: Icon(
                            FontAwesomeIcons.venusMars,
                            size: 15.0,
                          ),
                          title: DropdownButton(
                            isExpanded: true,
                            hint: Text('Pilih jenis kelamin'),
                            value: selectedGender,
                            items: listGender
                                .map(
                                  (f) => DropdownMenuItem(
                                    child: Text(f.nama),
                                    value: f,
                                  ),
                                )
                                .toList(),
                            onChanged: (ini) {
                              setState(() {
                                selectedGender = ini;
                              });
                              FocusScope.of(context)
                                  .requestFocus(usernameFocus);
                            },
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
                            FontAwesomeIcons.userCog,
                            size: 15.0,
                          ),
                          title: TextFormField(
                            controller: usernameController,
                            focusNode: usernameFocus,
                            decoration: InputDecoration(
                              labelText: 'Username Customer',
                              labelStyle: TextStyle(
                                fontSize: 18.0,
                              ),
                            ),
                            // validator: (ini) {
                            //   if (ini.isEmpty) {
                            //     return 'Username tidak boleh kosong';
                            //   }
                            //   return null;
                            // },
                            onEditingComplete: () {
                              FocusScope.of(context)
                                  .requestFocus(passwordFocus);
                            },
                          ),
                        ),
                        Divider(),
                        ListTileCustomer(
                          leading: Icon(
                            FontAwesomeIcons.userSecret,
                            size: 15.0,
                          ),
                          title: TextFormField(
                            obscureText: true,
                            controller: passwordController,
                            focusNode: passwordFocus,
                            decoration: InputDecoration(
                              labelText: 'Password Customer',
                              helperStyle: TextStyle(
                                fontSize: 14.0,
                                color: Colors.green,
                              ),
                              labelStyle: TextStyle(
                                fontSize: 18.0,
                              ),
                            ),
                            validator: (ini) {
                              if (ini.length < 3 && ini.isNotEmpty) {
                                return 'Minimal panjang password 3 kata';
                              }
                              return null;
                            },
                            onEditingComplete: () {
                              FocusScope.of(context).requestFocus(emailFocus);
                            },
                          ),
                        ),
                        Divider(),
                        ListTileCustomer(
                          leading: Icon(
                            FontAwesomeIcons.envelope,
                            size: 15.0,
                          ),
                          title: TextFormField(
                            validator: (ini) {
                              Pattern pattern =
                                  r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                              RegExp regex = new RegExp(pattern);
                              if (!regex.hasMatch(ini) && ini.isNotEmpty)
                                return 'Format email tidak sesuai';
                              else
                                return null;
                            },
                            focusNode: emailFocus,
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email Customer',
                              labelStyle: TextStyle(
                                fontSize: 18.0,
                              ),
                            ),
                          ),
                        ),

                        // Divider(),
                        // ListTileCustomer(
                        //   leading: Icon(
                        //     FontAwesomeIcons.building,
                        //     size: 15.0,
                        //   ),
                        //   title: TextFormField(
                        //     focusNode: bankFocus,
                        //     controller: bankController,
                        //     decoration: InputDecoration(
                        //       labelText: 'Nama Bank',
                        //       labelStyle: TextStyle(
                        //         fontSize: 18.0,
                        //       ),
                        //     ),
                        //     onEditingComplete: () {
                        //       FocusScope.of(context)
                        //           .requestFocus(rekeningFocus);
                        //     },
                        //   ),
                        // ),
                        // Divider(),
                        // ListTileCustomer(
                        //   leading: Icon(
                        //     FontAwesomeIcons.fileInvoiceDollar,
                        //     size: 15.0,
                        //   ),
                        //   title: TextFormField(
                        //     focusNode: rekeningFocus,
                        //     controller: rekeningController,
                        //     decoration: InputDecoration(
                        //       labelText: 'No. Rekening',
                        //       labelStyle: TextStyle(
                        //         fontSize: 18.0,
                        //       ),
                        //     ),
                        //     keyboardType: TextInputType.number,
                        //     inputFormatters: <TextInputFormatter>[
                        //       WhitelistingTextInputFormatter.digitsOnly,
                        //     ],
                        //     // onEditingComplete: () {
                        //     //   FocusScope.of(context)
                        //     //       .requestFocus(tanggalLahirFocus);
                        //     // },
                        //   ),
                        // ),
                        // Divider(),
                        // ListTileCustomer(
                        //   leading: Icon(
                        //     FontAwesomeIcons.calendarAlt,
                        //     size: 15.0,
                        //   ),
                        //   title: DateTimePickerFormField(
                        //     inputType: InputType.date,
                        //     editable: false,
                        //     lastDate: DateTime.now(),
                        //     // controller: tanggalLahirController,
                        //     initialValue: tanggalLahir,
                        //     onChanged: (ini) {
                        //       tanggalLahir = ini;
                        //     },
                        //     initialDate: DateTime.now(),
                        //     decoration: InputDecoration(
                        //       labelText: 'Tanggal Lahir',
                        //       labelStyle: TextStyle(
                        //         fontSize: 18.0,
                        //       ),
                        //     ),
                        //     focusNode: tanggalLahirFocus,
                        //     format: DateFormat('yyyy-MM-dd'),
                        //   ),
                        // ),
                        // Divider(),
                        // ListTileCustomer(
                        //   leading: Icon(
                        //     FontAwesomeIcons.hospitalAlt,
                        //     size: 15.0,
                        //   ),
                        //   title: TextFormField(
                        //     controller: tempatLahirController,
                        //     focusNode: tempatLahirFocus,
                        //     decoration: InputDecoration(
                        //       labelText: 'Tempat Lahir',
                        //       labelStyle: TextStyle(
                        //         fontSize: 18.0,
                        //       ),
                        //     ),
                        //     onEditingComplete: () {
                        //       FocusScope.of(context).requestFocus(alamatFocus);
                        //     },
                        //   ),
                        // ),
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
                          margin: EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 10.0),
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
                          title: TextFormField(
                            focusNode: alamatFocus,
                            controller: alamatController,
                            decoration: InputDecoration(
                              labelText: 'Alamat Customer',
                              labelStyle: TextStyle(
                                fontSize: 18.0,
                              ),
                            ),
                            // validator: (ini) {
                            //   if (ini.isEmpty) {
                            //     return 'Alamat tidak boleh kosong';
                            //   }
                            //   return null;
                            // },
                          ),
                        ),
                        Divider(),
                        InkWell(
                          onTap: () async {
                            kasir.Provinsi selectedProvinsi;
                            if (customer.idProvinsi != null) {
                              selectedProvinsi = kasir.Provinsi(
                                idProvinsi: customer.idProvinsi,
                                namaProvinsi: customer.namaProvinsi,
                              );
                            } else {
                              selectedProvinsi = null;
                            }

                            kasir.Provinsi pilihProvinsi = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) => CariProvinsi(
                                  provinsi: selectedProvinsi,
                                ),
                              ),
                            );

                            if (pilihProvinsi != null) {
                              setState(() {
                                customer.idProvinsi = pilihProvinsi.idProvinsi;
                                customer.namaProvinsi =
                                    pilihProvinsi.namaProvinsi;

                                customer.idKabupatenKota = null;
                                customer.namaKabupatenKota = null;
                                customer.idKecamatan = null;
                                customer.namaKecamatan = null;
                              });
                            }
                          },
                          child: ListTileCustomer(
                            leading: Icon(
                              FontAwesomeIcons.portrait,
                              size: 15.0,
                            ),
                            title: Text(
                              customer.namaProvinsi != null
                                  ? customer.namaProvinsi
                                  : 'Pilih Provinsi',
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
                        ),
                        Divider(),
                        InkWell(
                          onTap: () async {
                            kasir.Provinsi selectedProvinsi;
                            kasir.KabupatenKota selectedKabupatenKota;

                            if (customer.idProvinsi != null) {
                              selectedProvinsi = kasir.Provinsi(
                                idProvinsi: customer.idProvinsi,
                                namaProvinsi: customer.namaProvinsi,
                              );
                            } else {
                              selectedProvinsi = null;
                            }

                            if (customer.idKabupatenKota != null) {
                              selectedKabupatenKota = kasir.KabupatenKota(
                                idKabupatenKota: customer.idKabupatenKota,
                                namaKabupatenKota: customer.namaKabupatenKota,
                              );
                            } else {
                              selectedKabupatenKota = null;
                            }

                            if (customer.idProvinsi != null) {
                              kasir.KabupatenKota pilihKabupatenKota =
                                  await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      CariKabupatenKota(
                                    provinsi: selectedProvinsi,
                                    kabupatenKota: selectedKabupatenKota,
                                  ),
                                ),
                              );

                              if (pilihKabupatenKota != null) {
                                setState(() {
                                  customer.idKabupatenKota =
                                      pilihKabupatenKota.idKabupatenKota;
                                  customer.namaKabupatenKota =
                                      pilihKabupatenKota.namaKabupatenKota;

                                  customer.idKecamatan = null;
                                  customer.namaKecamatan = null;
                                });
                              }
                            } else {
                              showInSnackBarTambahCustomerMinimal(
                                  'Provinsi tidak boleh kosong');
                            }
                          },
                          child: ListTileCustomer(
                            leading: Icon(
                              FontAwesomeIcons.city,
                              size: 15.0,
                            ),
                            title: Text(
                              customer.namaKabupatenKota != null
                                  ? customer.namaKabupatenKota
                                  : 'Pilih Kabupaten/Kota',
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
                        ),
                        Divider(),
                        InkWell(
                          onTap: () async {
                            kasir.Kecamatan selectedKecamatan;
                            kasir.KabupatenKota selectedKabupatenKota;

                            if (customer.idKecamatan != null) {
                              selectedKecamatan = kasir.Kecamatan(
                                idKecamatan: customer.idKecamatan,
                                namaKecamatan: customer.namaKecamatan,
                              );
                            } else {
                              selectedKecamatan = null;
                            }

                            if (customer.idKabupatenKota != null) {
                              selectedKabupatenKota = kasir.KabupatenKota(
                                idKabupatenKota: customer.idKabupatenKota,
                                namaKabupatenKota: customer.namaKabupatenKota,
                              );
                            } else {
                              selectedKabupatenKota = null;
                            }

                            if (customer.idProvinsi != null) {
                              kasir.Kecamatan pilihKecamatan =
                                  await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      CariKecamatan(
                                    kecamatan: selectedKecamatan,
                                    kabupatenKota: selectedKabupatenKota,
                                  ),
                                ),
                              );

                              if (pilihKecamatan != null) {
                                setState(() {
                                  customer.idKecamatan =
                                      pilihKecamatan.idKecamatan;
                                  customer.namaKecamatan =
                                      pilihKecamatan.namaKecamatan;
                                });
                              }
                            } else {
                              showInSnackBarTambahCustomerMinimal(
                                  'Kabupaten/Kota tidak boleh kosong');
                            }
                          },
                          child: ListTileCustomer(
                            leading: Icon(
                              FontAwesomeIcons.placeOfWorship,
                              size: 15.0,
                            ),
                            title: Text(
                              customer.namaKecamatan != null
                                  ? customer.namaKecamatan
                                  : 'Pilih Kecamatan',
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
                        ),
                        Divider(),
                        ListTileCustomer(
                          leading: Icon(
                            FontAwesomeIcons.mailBulk,
                            size: 15.0,
                          ),
                          title: TextFormField(
                            controller: kodePosController,
                            focusNode: kodePosFocus,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              WhitelistingTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              labelText: 'Kode Pos',
                              labelStyle: TextStyle(
                                fontSize: 18.0,
                              ),
                            ),
                            // validator: (ini) {
                            //   if (ini.isEmpty) {
                            //     return 'Kode Pos tidak boleh kosong';
                            //   } else if (ini.length < 2) {
                            //     return 'Panjang kata Kode pos kurang 4';
                            //   } else if (ini.length < 3) {
                            //     return 'Panjang kata Kode pos kurang 3';
                            //   } else if (ini.length < 4) {
                            //     return 'Panjang kata Kode pos kurang 2';
                            //   } else if (ini.length < 5) {
                            //     return 'Panjang kata Kode pos kurang 1';
                            //   }
                            //   return null;
                            // },
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

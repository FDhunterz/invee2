import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

GlobalKey<ScaffoldState> _scaffoldKeyPenerimaanBarangFilter;
DateTime tanggal1, tanggal2;
FocusNode tanggal1Focus, tanggal2Focus;
GlobalKey<FormState> _formFilter;
TextEditingController tanggal1Controller, tanggal2Controller;

void showInSnackBarPenerimaanBarangFilter(String value,
    {SnackBarAction action}) {
  _scaffoldKeyPenerimaanBarangFilter.currentState.showSnackBar(new SnackBar(
    content: new Text(value),
    action: action,
  ));
}

class FilterPenerimaanBarang extends StatefulWidget {
  final DateTime tanggalX, tanggal2X;

  FilterPenerimaanBarang({
    this.tanggalX,
    this.tanggal2X,
  });

  @override
  _FilterPenerimaanBarangState createState() => _FilterPenerimaanBarangState();
}

class _FilterPenerimaanBarangState extends State<FilterPenerimaanBarang> {
  @override
  void initState() {
    tanggal1 = widget.tanggalX;
    tanggal2 = widget.tanggal2X;

    tanggal1Focus = FocusNode();
    tanggal2Focus = FocusNode();

    _formFilter = GlobalKey<FormState>();
    tanggal1Controller = TextEditingController(
        text: widget.tanggalX != null
            ? DateFormat('dd-MM-yyyy').format(widget.tanggalX)
            : '');
    tanggal2Controller = TextEditingController(
        text: widget.tanggal2X != null
            ? DateFormat('dd-MM-yyyy').format(widget.tanggal2X)
            : '');

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
      appBar: AppBar(
        title: Text('Filter Tanggal'),
        actions: <Widget>[
          FlatButton(
            child: Text(
              'Hapus Filter',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () {
              setState(() {
                tanggal1 = null;
                tanggal2 = null;
                tanggal1Controller.clear();
                tanggal2Controller.clear();
              });
            },
          )
        ],
      ),
      floatingActionButton: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
        onPressed: () {
          if (_formFilter.currentState.validate()) {
            Navigator.pop(
              context,
              {
                'tanggal1': tanggal1,
                'tanggal2': tanggal2,
              },
            );
          } else {
            showInSnackBarPenerimaanBarangFilter(
              'Tanggal Awal & Tanggal akhir tidak boleh kosong atau tekan hapus filter untuk membersihkan filter',
            );
          }
        },
        child: Text(
          'Simpan',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Scrollbar(
        child: Form(
          key: _formFilter,
          child: ListView(
            children: <Widget>[
              ListTile(
                title: DateTimeField(
                  focusNode: tanggal1Focus,
                  format: DateFormat('dd-MM-yyyy'),
                  initialValue: tanggal1,
                  controller: tanggal1Controller,
                  readOnly: true,
                  onShowPicker: (context, currentValue) {
                    return showDatePicker(
                      firstDate: DateTime(
                        DateTime.now().year,
                      ),
                      initialDate: currentValue ?? DateTime.now(),
                      context: context,
                      lastDate: DateTime.now(),
                    );
                  },
                  decoration: InputDecoration(
                    hintText: 'Tanggal Awal',
                  ),
                  validator: (ini) {
                    print(ini.toString());
                    if (ini == null && tanggal2 != null) {
                      return 'Tanggal Awal tidak boleh kosong';
                    }
                    return null;
                  },
                  onChanged: (ini) {
                    setState(() {
                      tanggal1 = ini;
                    });
                  },
                ),
              ),
              ListTile(
                title: DateTimeField(
                  focusNode: tanggal2Focus,
                  format: DateFormat('dd-MM-yyyy'),
                  initialValue: tanggal2,
                  controller: tanggal2Controller,
                  readOnly: true,
                  onShowPicker: (context, currentValue) {
                    return showDatePicker(
                      firstDate: DateTime(
                        DateTime.now().year,
                      ),
                      initialDate: currentValue ?? DateTime.now(),
                      context: context,
                      lastDate: DateTime.now(),
                    );
                  },
                  decoration: InputDecoration(
                    hintText: 'Tanggal Akhir',
                  ),
                  validator: (ini) {
                    print(ini.toString());
                    if (ini == null && tanggal1 != null) {
                      return 'Tanggal Akhir tidak boleh kosong';
                    }
                    return null;
                  },
                  onChanged: (ini) {
                    setState(() {
                      tanggal2 = ini;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

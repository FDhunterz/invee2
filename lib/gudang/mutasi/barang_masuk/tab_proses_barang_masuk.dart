import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TabProsesBarangMasuk extends StatefulWidget {
  final String reffBarangKeluar,
      reffBarangMasuk,
      noResi,
      gudangPengirim,
      tanggalPengiriman,
      catatan;

  final DateTime initialValue;
  final FocusNode datepickerFocus;
  final Function(DateTime) onChanged;
  final TextEditingController datePickerController;

  TabProsesBarangMasuk({
    @required this.datePickerController,
    @required this.datepickerFocus,
    @required this.reffBarangKeluar,
    @required this.reffBarangMasuk,
    @required this.noResi,
    @required this.catatan,
    @required this.gudangPengirim,
    @required this.tanggalPengiriman,
    @required this.onChanged,
    @required this.initialValue,
  });

  @override
  _TabProsesBarangMasukState createState() => _TabProsesBarangMasukState();
}

class _TabProsesBarangMasukState extends State<TabProsesBarangMasuk> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        child: Card(
          child: Container(
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: Text('No. Referensi Barang Keluar'),
                    ),
                    Expanded(
                      flex: 5,
                      child: widget.reffBarangKeluar == null
                          ? Text('Belum ada')
                          : Text(widget.reffBarangKeluar),
                    ),
                  ],
                ),
                Divider(),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: Text('No. Referensi Barang Masuk'),
                    ),
                    Expanded(
                      flex: 5,
                      child: widget.reffBarangMasuk == null
                          ? Text('Belum ada')
                          : Text(widget.reffBarangMasuk),
                    ),
                  ],
                ),
                Divider(),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: Text('No. Resi Pengiriman'),
                    ),
                    Expanded(
                      flex: 5,
                      child: Text(widget.noResi),
                    ),
                  ],
                ),
                Divider(),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: Text('Gudang Pengirim'),
                    ),
                    Expanded(
                      flex: 5,
                      child: Text(widget.gudangPengirim),
                    ),
                  ],
                ),
                Divider(),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: Text('Tanggal Pengiriman'),
                    ),
                    Expanded(
                      flex: 5,
                      child: Text(
                        DateFormat('dd MMMM yyyy').format(
                          DateTime.parse(widget.tanggalPengiriman),
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: Text('Catatan Pengiriman'),
                    ),
                    Expanded(
                      flex: 5,
                      child: Text(widget.catatan),
                    ),
                  ],
                ),
                Divider(),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: Text('Tanggal Barang Masuk'),
                    ),
                    Expanded(
                      flex: 5,
                      child: DateTimeField(
                        validator: (thisValue) {
                          if (thisValue == null) {
                            return 'Input tidak boleh kosong!';
                          }
                          return null;
                        },
                        readOnly: true,
                        focusNode: widget.datepickerFocus,
                        format: DateFormat('dd-MM-yyyy'),
                        initialValue: widget.initialValue,
                        decoration: InputDecoration(
                          hintText: 'Tanggal Barang Masuk',
                          contentPadding: EdgeInsets.all(5.0),
                        ),
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
                        controller: widget.datePickerController,
                        onChanged: (ini) {
                          widget.onChanged(ini);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

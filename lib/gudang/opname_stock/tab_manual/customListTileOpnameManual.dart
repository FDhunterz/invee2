import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomListTileOpnameManual extends StatefulWidget {
  final String kodeProduk, namaProduk, namaSatuan;
  final int stokAdjustment, stokSistem;
  final Function onDelete, onDecrease, onIncrease;
  final TextEditingController stokGudang;
  final DropdownButton dropdownButton;
  final Function(String) stokGudangOnChange;
  CustomListTileOpnameManual({
    @required this.stokGudangOnChange,
    @required this.dropdownButton,
    @required this.kodeProduk,
    @required this.namaProduk,
    @required this.stokAdjustment,
    @required this.stokGudang,
    @required this.stokSistem,
    @required this.onDelete,
    @required this.onDecrease,
    @required this.onIncrease,
    @required this.namaSatuan,
  });
  @override
  _CustomListTileOpnameManualState createState() =>
      _CustomListTileOpnameManualState();
}

class _CustomListTileOpnameManualState
    extends State<CustomListTileOpnameManual> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 15.0),
        child: Column(
          children: <Widget>[
            Row(
              textDirection: TextDirection.rtl,
              children: <Widget>[
                Container(
                  width: 50.0,
                  child: RaisedButton(
                    padding: EdgeInsets.all(5.0),
                    child: Icon(Icons.delete),
                    textColor: Colors.white,
                    color: Colors.red,
                    onPressed: widget.onDelete,
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: Text(
                    'Nama Produk',
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Text(
                    widget.namaProduk,
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
                  flex: 3,
                  child: Text(
                    'Kode Produk',
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Text(
                    widget.kodeProduk,
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
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Text(
                          'Stok Sistem',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                      Container(
                        child: Text(
                          "${widget.stokSistem}",
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Text(
                          'Stok Adjustment',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                      Container(
                        child: Text(
                          "${widget.stokAdjustment}",
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Text(
                          'Satuan',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                      Container(
                        child: Text(
                          widget.namaSatuan,
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            Divider(),
            Row(
              children: <Widget>[
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Stok Gudang',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: FlatButton(
                                  padding: EdgeInsets.all(5.0),
                                  child: Icon(Icons.remove),
                                  onPressed: widget.onDecrease),
                            ),
                            Expanded(
                              flex: 5,
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Stok Gudang',
                                ),
                                textAlign: TextAlign.center,
                                textAlignVertical: TextAlignVertical.center,
                                keyboardType: TextInputType.number,
                                controller: widget.stokGudang,
                                inputFormatters: <TextInputFormatter>[
                                  WhitelistingTextInputFormatter.digitsOnly
                                ],
                                onChanged: (ini){
                                  widget.stokGudangOnChange(ini);
                                },
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: FlatButton(
                                padding: EdgeInsets.all(5.0),
                                child: Icon(Icons.add),
                                onPressed: widget.onIncrease,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
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
                    'Keterangan',
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: widget.dropdownButton,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TileDetailBarangMasuk extends StatelessWidget {
  final String namaProduk,
      namaSatuan,
      gudangPeminta,
      stokGudang,
      jumlahDisetujui,
      jumlahDiterima,
      kurang,
      jumlahDiminta,
      informasiKekurangan;

  TileDetailBarangMasuk({
    this.jumlahDiminta,
    this.gudangPeminta,
    this.informasiKekurangan,
    this.jumlahDisetujui,
    this.jumlahDiterima,
    this.kurang,
    this.namaProduk,
    this.namaSatuan,
    this.stokGudang,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        child: Container(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: Text('Nama Produk'),
                  ),
                  Expanded(
                    flex: 5,
                    child: Text(namaProduk),
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
                    child: Text(gudangPeminta),
                  ),
                ],
              ),
              Divider(),
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: Text('Informasi Kekurangan'),
                  ),
                  Expanded(
                    flex: 5,
                    child: Text(informasiKekurangan),
                  ),
                ],
              ),
              Divider(),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Text('Satuan'),
                        Text(namaSatuan),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Text('Stok Gudang'),
                        Text(stokGudang),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Text('Jumlah Diminta'),
                        Text(jumlahDiminta),
                      ],
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
                        Text('Jumlah Disetujui'),
                        Text(jumlahDisetujui),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Text('Jumlah Diterima'),
                        Text(jumlahDiterima),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Text('Kurang'),
                        Text(kurang),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TileProsesBarangMasuk extends StatefulWidget {
  final String namaProduk,
      namaSatuan,
      gudangPeminta,
      stokGudang,
      jumlahDisetujui,
      // jumlahDiterima,
      kurang,
      informasiKekurangan,
      jumlahDiminta;

  final Function onDecrease, onIncrease, onEditingComplete;

  final Function(String) inputOnChanged, onChangedDropDown;

  final TextEditingController controllerJumlahDiterima;

  final FocusNode focusJumlahDiterima;

  final TextInputAction textInputAction;

  final DropdownButton dropDownButton;

  TileProsesBarangMasuk({
    this.dropDownButton,
    this.onChangedDropDown,
    this.inputOnChanged,
    this.onDecrease,
    this.onIncrease,
    this.onEditingComplete,
    this.focusJumlahDiterima,
    this.controllerJumlahDiterima,
    this.textInputAction,
    this.informasiKekurangan,
    this.jumlahDiminta,
    this.gudangPeminta,
    this.jumlahDisetujui,
    // this.jumlahDiterima,
    this.kurang,
    this.namaProduk,
    this.namaSatuan,
    this.stokGudang,
  });

  @override
  _TileProsesBarangMasukState createState() => _TileProsesBarangMasukState();
}

class _TileProsesBarangMasukState extends State<TileProsesBarangMasuk> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        child: Container(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: Text('Nama Produk'),
                  ),
                  Expanded(
                    flex: 5,
                    child: Text(widget.namaProduk),
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
                    child: Text(widget.gudangPeminta),
                  ),
                ],
              ),
              Divider(),
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: Text('Informasi Kekurangan'),
                  ),
                  Expanded(
                    flex: 5,
                    child: Text(widget.informasiKekurangan),
                  ),
                ],
              ),
              Divider(),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Text('Satuan'),
                        Text(widget.namaSatuan),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Text('Stok Gudang'),
                        Text(widget.stokGudang),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Text('Jumlah Diminta'),
                        Text(widget.jumlahDiminta),
                      ],
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
                        Text('Jumlah Disetujui'),
                        Text(widget.jumlahDisetujui),
                      ],
                    ),
                  ),
                  // Expanded(
                  //   child: Column(
                  //     children: <Widget>[
                  //       Text('Jumlah Diterima'),
                  //       Text(widget.jumlahDiterima),
                  //     ],
                  //   ),
                  // ),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Text('Kurang'),
                        Text(widget.kurang),
                      ],
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
                            'Jumlah Diterima',
                            style: TextStyle(
                                // fontSize: 16.0,
                                ),
                          ),
                        ),
                        Container(
                          child: Center(
                            child: IntrinsicWidth(
                              child: Container(
                                // color: Colors.red,
                                width: 200.0,
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 2,
                                      child: FlatButton(
                                        padding: EdgeInsets.all(5.0),
                                        child: Icon(Icons.remove),
                                        onPressed: widget.onDecrease,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: TextFormField(
                                        controller:
                                            widget.controllerJumlahDiterima,
                                        focusNode: widget.focusJumlahDiterima,
                                        textInputAction: widget.textInputAction,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: <TextInputFormatter>[
                                          WhitelistingTextInputFormatter
                                              .digitsOnly
                                        ],
                                        onChanged: (thisValue) {
                                          widget.inputOnChanged(thisValue);
                                        },
                                        validator: (thisValue) {
                                          if (thisValue.isEmpty) {
                                            return 'Input tidak boleh kosong';
                                          }
                                          return null;
                                        },
                                        onEditingComplete: () {
                                          widget.onEditingComplete();
                                        },
                                        textAlign: TextAlign.center,
                                        decoration: InputDecoration(
                                          hintText: 'Qty',
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: FlatButton(
                                        padding: EdgeInsets.all(5.0),
                                        child: Icon(Icons.add),
                                        onPressed: widget.onIncrease,
                                      ),
                                      flex: 2,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: widget.dropDownButton,
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

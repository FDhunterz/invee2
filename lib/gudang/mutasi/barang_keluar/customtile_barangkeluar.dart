import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TileDetailBarangKeluar extends StatelessWidget {
  final String namaProduk, satuan, stokDiminta, stokGudangPengirim;

  TileDetailBarangKeluar(
      {this.namaProduk,
      this.satuan,
      this.stokDiminta,
      this.stokGudangPengirim});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: Text(
                    'Nama Barang',
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Text('$namaProduk'),
                ),
              ],
            ),
            Divider(),
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Satuan',
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                      Text('$satuan'),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Stok diminta',
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                      Text('$stokDiminta'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TileProsesBarangKeluar extends StatefulWidget {
  final String namaProduk,
      gudangPeminta,
      gudangDiminta,
      satuan,
      stokGudangDiminta,
      jumlahDiminta;

  final Function(String) onChanged;
  final Function onDecrease, onIncrease, onEditingComplete;

  final TextEditingController controllerJumlahDiminta;
  final FocusNode focusJumlahDiminta;

  final TextInputAction textInputAction;

  TileProsesBarangKeluar({
    this.onEditingComplete,
    this.textInputAction,
    this.focusJumlahDiminta,
    this.controllerJumlahDiminta,
    this.onDecrease,
    this.onIncrease,
    this.onChanged,
    this.namaProduk,
    this.gudangDiminta,
    this.gudangPeminta,
    this.satuan,
    this.stokGudangDiminta,
    this.jumlahDiminta,
  });

  @override
  _TileProsesBarangKeluarState createState() => _TileProsesBarangKeluarState();
}

class _TileProsesBarangKeluarState extends State<TileProsesBarangKeluar> {
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
                    child: Text('Nama Produk'),
                  ),
                  Expanded(
                    child: Text('${widget.namaProduk}'),
                  ),
                ],
              ),
              Divider(),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text('Gudang Peminta'),
                  ),
                  Expanded(
                    child: Text('${widget.gudangPeminta}'),
                  ),
                ],
              ),
              Divider(),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text('Gudang Pengirim'),
                  ),
                  Expanded(
                    child: Text('${widget.gudangDiminta}'),
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
                        Text('${widget.satuan}'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Text('Stok Gud.Pengirim'),
                        if (widget.stokGudangDiminta == 'null' ||
                            widget.stokGudangDiminta.isEmpty)
                          Text(
                            'Barang belum diopname',
                            style: TextStyle(color: Colors.red),
                          )
                        else
                          Text(widget.stokGudangDiminta),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Text('Jumlah diminta'),
                        Text(widget.jumlahDiminta),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(),
              Column(
                children: <Widget>[
                  Container(
                    child: Text(
                      'Jumlah disetujui',
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                  Container(
                    child: Center(
                      child: IntrinsicWidth(
                        child: Container(
                          // color: Colors.red,
                          width: 150.0,
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
                                  controller: widget.controllerJumlahDiminta,
                                  focusNode: widget.focusJumlahDiminta,
                                  textInputAction: widget.textInputAction,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    WhitelistingTextInputFormatter.digitsOnly
                                  ],
                                  onChanged: (thisValue) {
                                    widget.onChanged(thisValue);
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
            ],
          ),
        ),
      ),
    );
  }
}

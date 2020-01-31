import 'package:flutter/material.dart';

class CustomTilePenerimaan extends StatefulWidget {
  CustomTilePenerimaan({
    this.title,
    this.subtitle,
    this.subtitle2,
    this.leading,
    this.trailing,
    this.onTab,
    this.status,
  });
  final String title, subtitle, subtitle2, trailing, status;
  final Widget leading;
  final Function onTab;
  @override
  _CustomTilePenerimaanState createState() => _CustomTilePenerimaanState();
}

class _CustomTilePenerimaanState extends State<CustomTilePenerimaan> {
  Widget _tglPenerimaanDanStatus({tanggalTerima, status}) {
    if (tanggalTerima == null && status == 'process') {
      return Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
              bottom: 5.0,
            ),
            child: Text(
              'Belum diterima',
              style: TextStyle(
                color: Colors.white,
                backgroundColor: Colors.orange,
                fontSize: 14.0,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(
              bottom: 5.0,
            ),
            child: Text(
              'Proses Pengiriman',
              style: TextStyle(
                color: Colors.white,
                backgroundColor: Colors.cyan,
              ),
            ),
          )
        ],
      );
    } else if (tanggalTerima != null && status == 'process') {
      return Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
              bottom: 5.0,
            ),
            child: Text(
              tanggalTerima,
              style: TextStyle(
                color: Colors.blue[800],
                fontSize: 14.0,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(
              bottom: 5.0,
            ),
            child: Text(
              'Proses Pengiriman',
              style: TextStyle(
                color: Colors.white,
                backgroundColor: Colors.cyan,
              ),
            ),
          )
        ],
      );
    } else if (tanggalTerima != null && status == 'success') {
      return Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
              bottom: 5.0,
            ),
            child: Text(
              tanggalTerima,
              style: TextStyle(
                color: Colors.blue[800],
                fontSize: 14.0,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(
              bottom: 5.0,
            ),
            child: Text(
              'Sudah Diterima',
              style: TextStyle(
                color: Colors.white,
                backgroundColor: Colors.green,
              ),
            ),
          )
        ],
      );
    } else {
      return Text('Ada yang salah, hubungi pengembang aplikasi!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTab,
      child: Container(
        margin: EdgeInsets.only(
          top: 5.0,
          bottom: 5.0,
        ),
        child: Row(
          children: <Widget>[
             widget.leading != null ? Expanded(
              flex: 1,
              child: Container(
                width: 20.0,
                padding: EdgeInsets.all(5.0),
                child: Center(
                  child: widget.leading,
                ),
              ),
            ) : Container(),
            Expanded(
              flex: 10,
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 4,
                        child: Container(
                          width: double.infinity,
                          child: Text(
                            widget.title,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        flex: 4,
                        child: Column(
                          children: <Widget>[
                            Container(
                              width: double.infinity,
                              child: Text(
                                'Tanggal Order : ${widget.subtitle}',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              child: Text(
                                'Staff : ${widget.subtitle2}',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.black54,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          width: double.infinity,
                          child: Center(
                            child: _tglPenerimaanDanStatus(
                                tanggalTerima: widget.trailing,
                                status: widget.status),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ListTileCustomer extends StatelessWidget {
  final Widget title, subtitle, trailing;
  final Icon leading;
  ListTileCustomer({
    this.title,
    this.leading,
    this.subtitle,
    this.trailing,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      margin: EdgeInsets.only(
        // top: 5.0,
        left: 5.0,
        right: 5.0,
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 50,
            child: leading != null ? leading : Container(),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  subtitle != null ? subtitle : Container(),
                  title != null ? title : Container(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

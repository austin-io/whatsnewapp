import 'package:flutter/material.dart';

class SortButton extends StatelessWidget {

  final String _text;

  final VoidCallback _query;

  SortButton(this._text, this._query);

  @override
  Widget build(BuildContext context) {
    return new Container(
      padding: EdgeInsets.only(right: 5),
      child: RaisedButton(
        child: Text(_text, style: TextStyle(color: Colors.white)),
        color: Colors.green[300],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
        onPressed: _query,
      ),
    );
  }
}
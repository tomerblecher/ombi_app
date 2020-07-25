import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ombiapp/services/login_service.dart';
import 'package:ombiapp/services/router.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(child:
    ListView(
      children: <Widget>[
        UserAccountsDrawerHeader(otherAccountsPictures: <Widget>[IconButton(icon:Icon(Icons.exit_to_app), onPressed: () async{
          print('pressed');
          await loginManager.disconnect();
          Navigator.of(context).pop(); // Pop the Drawer itself before passing the page context to navigator.
          RouterService.navigate(context, Routes.ROOT);
        },)],
          accountName: Text("Test"),
          accountEmail: Text("tomer.blecher.brolix@gmail.com"),
        )
      ],
    ));
  }
}

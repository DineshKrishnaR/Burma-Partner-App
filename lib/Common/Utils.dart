
import 'package:burmapartner/Login/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:localstorage/localstorage.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences pref;

class Helper {
  
  isvalidElement(data) {
    return data != null;
  }
  
  clearAllData() async {
    pref = await SharedPreferences.getInstance();
    await pref.clear();
  }

  sessionExpired(context) {
    Helper().clearAllData();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Loginscreen()),
    );
    // Apptoast().showErrorToast('Session Expired!');
    Fluttertoast.showToast(msg: 'Session Expired!');
  }

  logout(BuildContext context) async {
  Helper().clearAllData();

  // final pref = await SharedPreferences.getInstance();
  // await pref.clear();
  // await Hive.deleteFromDisk();
   final pref = await SharedPreferences.getInstance();
  await pref.clear();
  
  final storage = LocalStorage('app_store');
  await storage.ready;
  await storage.clear();
  
  await Hive.deleteFromDisk();
  // 🔥 remove all previous pages (Dashboard, Profile etc)
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const Loginscreen()),
    (route) => false,   // removes all old routes
  );

  Fluttertoast.showToast(msg: 'Logout successfully!');
}

}
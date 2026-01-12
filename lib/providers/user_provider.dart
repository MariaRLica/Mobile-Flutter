import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  String uid = '';
  String name = '';
  String email = '';
  String photoUrl = ''; // aqui guardamos o path/local url da imagem

  bool get isLogged => uid.isNotEmpty;

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    uid = prefs.getString('user.uid') ?? '';
    name = prefs.getString('user.name') ?? '';
    email = prefs.getString('user.email') ?? '';
    photoUrl = prefs.getString('user.photoUrl') ?? '';
    notifyListeners();
  }

  Future<void> saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user.uid', uid);
    await prefs.setString('user.name', name);
    await prefs.setString('user.email', email);
    await prefs.setString('user.photoUrl', photoUrl);
  }

  Future<void> signInLocal(
      {required String uid, String name = '', String email = ''}) async {
    this.uid = uid;
    this.name = name;
    this.email = email;
    await saveToPrefs();
    notifyListeners();
  }

  Future<void> signOut() async {
    uid = '';
    name = '';
    email = '';
    photoUrl = '';
    await saveToPrefs();
    notifyListeners();
  }

  // -------------------------
  // Novos helpers úteis para ProfileScreen
  // -------------------------
  Future<void> setName(String newName) async {
    name = newName;
    await saveToPrefs();
    notifyListeners();
  }

  /// photoPath é o path retornado por image_picker (ex: '/data/user/0/.../cache/...')
  Future<void> setPhotoUrl(String photoPath) async {
    photoUrl = photoPath;
    await saveToPrefs();
    notifyListeners();
  }

  Future<void> clearPhoto() async {
    photoUrl = '';
    await saveToPrefs();
    notifyListeners();
  }
}

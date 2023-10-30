import 'package:daftar_belanja/class/daftar.dart';
import 'package:string_validator/string_validator.dart' as validator;
import 'package:mysql1/mysql1.dart';
import 'package:daftar_belanja/database_settings.dart';

abstract class User {
  int? _userId;
  String? _nama;
  String? _nomorTelepon;
  String? _alamat;
  String? _email;

  String get nama => _nama!;
  int get id => _userId!;

  Future<bool> createAccount(String nama, String password, String nomorTelepon, String alamat, String email);
  Future<bool> login(String email, String password);
  Future<bool> deleteAccount();
  bool logOut();

  Map<String, dynamic> getAllAttributes() {
    return {
      "User ID": _userId,
      "Nama": _nama,
      "Nomor Telepon": _nomorTelepon,
      "Alamat": _alamat,
      "Email": _email
    };
  }
}

class CommonUser extends User {

  /// Create Account
  @override
  Future<bool> createAccount(String nama, String password, String nomorTelepon, String alamat, String email) async {
    if (validator.isLength(password, 8)) {
      throw(ArgumentError("Password Minimal 8 Karakter"));
    }

    MySqlConnection koneksi = await MySqlConnection.connect(settingsDB);

    Results hasil = await koneksi.query(
      "INSERT INTO users (name, nomor_telepon, alamat, email, password) VALUE (?, ?, ?, ?, ?)",
      [nama, nomorTelepon, alamat, email, password]
    );

    await koneksi.close();

    _userId = hasil.insertId;
    _nama = nama;
    _nomorTelepon = nomorTelepon;
    _alamat = alamat;
    _email = email;

    return true;
  }

  @override
  Future<bool> login(String email, String password) async {
    if (!validator.isEmail(email)) {
      throw(ArgumentError("Email tidak valid"));
    }

    if (validator.isLength(password, 8)) {
      throw(ArgumentError("Password Minimal 8 Karakter"));
    }

    MySqlConnection koneksi = await MySqlConnection.connect(settingsDB);

    Results hasil = await koneksi.query(
      "SELECT * FROM users WHERE email = ? AND password = ?",
      [email, password]
    );

    await koneksi.close();

    if (hasil.length == 1) {
      Map<String, dynamic> user = hasil.first.fields;
      _userId = user['user_id'];
      _nama = user['name'];
      _nomorTelepon = user['nomor_telepon'];
      _alamat = user['alamat'].toString();
      _email = user['email'];

      return true;
    } else if (hasil.isEmpty) {
      throw(Exception("Gagal Login!"));
    } else {
      throw(Exception("Ada Kesalahan!"));
    }
  }

  @override
  bool logOut() {
    if (_userId == null && _nama == null && _nomorTelepon == null && _alamat == null && _email == null) {
      throw(Exception("Status Sudah Tidak Login !"));
    } else {
      _userId = _nama = _nomorTelepon = _alamat = _email = null;
      return true;
    }
  }

  @override
  Future<bool> deleteAccount() async {
    if (_userId == null && _nama == null && _nomorTelepon == null && _alamat == null && _email == null) {
      throw(Exception("Status Sudah Tidak Login !"));
    } else {
      MySqlConnection koneksi = await MySqlConnection.connect(settingsDB);

      Results hasil = await koneksi.query("DELETE FROM users WHERE user_id = ?", [_userId]);

      await koneksi.close();

      if (hasil.affectedRows! == 1) {
        _userId = _nama = _nomorTelepon = _alamat = _email = null;
        return true;
      } else if (hasil.affectedRows == 0) {
        throw(Exception("Tidak Menemukan Akun yang Ingin Dihapus !"));
      } else {
        throw(Exception("Ada Kesalahan !"));
      }
    }
  }

  Future<List<DaftarBelanja>> getAllDaftarBelanja() async {
    MySqlConnection koneksi = await MySqlConnection.connect(settingsDB);

    Results hasil = await koneksi.query("SELECT * FROM daftar_barang WHERE user_id = ?", [_userId]);

    await koneksi.close();

    List<DaftarBelanja> daftarBelanja = [];

    for (var data in hasil) {
      DaftarBelanja daftar = DaftarBelanja.init(data[0], data[1], data[2].toString(), data[3].toString());

      daftarBelanja.add(daftar);
    }

    return daftarBelanja;
  }

  Future<DaftarBelanja> buatDaftar(String namaDaftar) async {
    MySqlConnection koneksi = await MySqlConnection.connect(settingsDB);

    Results hasil = await koneksi.query("INSERT INTO daftar_barang (nama_daftar, user_id) VALUES (?, ?)", [namaDaftar, _userId]);

    Results date = await koneksi.query("SELECT date_created, date_updated FROM daftar_barang WHERE id = ?", [hasil.insertId]);

    await koneksi.close();

    DaftarBelanja daftar = DaftarBelanja.init(hasil.insertId, namaDaftar, date.first[0].toString(), date.first[1].toString());

    return daftar;
  }
}

class Seller extends User {
  String? _namaToko;

  @override
  Map<String, dynamic> getAllAttributes() {
    return {
      "User ID": _userId,
      "Nama": _nama,
      "Nama Toko": _namaToko,
      "Nomor Telepon": _nomorTelepon,
      "Alamat": _alamat,
      "Email": _email
    };
  }

  @override
  Future<bool> createAccount(String nama, String password, String nomorTelepon, String alamat, String email, [String? namaToko]) async {
    if (validator.isLength(password, 8)) {
      throw(ArgumentError("Password Minimal 8 Karakter"));
    }

    MySqlConnection koneksi = await MySqlConnection.connect(settingsDB);

    Results hasil = await koneksi.query("INSERT INTO sellers (name, nama_toko, nomor_telepon, alamat, email, password) VALUES (?, ?, ?, ?, ?, ?)",
      [nama, namaToko, nomorTelepon, alamat, email, password]
    );

    await koneksi.close();

    _userId = hasil.insertId;
    _nama = nama;
    _namaToko = namaToko;
    _nomorTelepon = nomorTelepon;
    _alamat = alamat;
    _email = email;

    return true;
  }

  @override
  Future<bool> login(String email, String password) async {
    if (!validator.isEmail(email)) {
      throw(ArgumentError("Email tidak valid"));
    }

    if (validator.isLength(password, 8)) {
      throw(ArgumentError("Password Minimal 8 Karakter"));
    }

    MySqlConnection koneksi = await MySqlConnection.connect(settingsDB);

    Results hasil = await koneksi.query(
      "SELECT * FROM sellers WHERE email = ? AND password = ?",
      [email, password]
    );

    await koneksi.close();

    if (hasil.length == 1) {
      Map<String, dynamic> user = hasil.first.fields;
      _userId = user['user_id'];
      _nama = user['name'];
      _namaToko = user['nama_toko'];
      _nomorTelepon = user['nomor_telepon'];
      _alamat = user['alamat'].toString();
      _email = user['email'];

      return true;
    } else if (hasil.isEmpty) {
      throw(Exception("Gagal Login!"));
    } else {
      throw(Exception("Ada Kesalahan!"));
    }
  }

  @override
  bool logOut() {
    if (_userId == null && _nama == null && _namaToko == null && _nomorTelepon == null && _alamat == null && _email == null) {
      throw(Exception("Status Sudah Tidak Login !"));
    } else {
      _userId = _nama = _namaToko = _nomorTelepon = _alamat = _email = null;
      return true;
    }
  }

  @override
  Future<bool> deleteAccount() async {
    if (_userId == null && _nama == null && _namaToko == null && _nomorTelepon == null && _alamat == null && _email == null) {
      throw(Exception("Status Sudah Tidak Login !"));
    } else {
      MySqlConnection koneksi = await MySqlConnection.connect(settingsDB);

      Results hasil = await koneksi.query("DELETE FROM sellers WHERE user_id = ?", [_userId]);

      await koneksi.close();

      if (hasil.affectedRows! == 1) {
        _userId = _nama = _namaToko = _nomorTelepon = _alamat = _email = null;
        return true;
      } else if (hasil.affectedRows == 0) {
        throw(Exception("Tidak Menemukan Akun yang Ingin Dihapus !"));
      } else {
        throw(Exception("Ada Kesalahan !"));
      }
    }
  }

}
// keyword import digunakan untuk mengimport file dart lain ke dalam file dart utama guna memungkinkan mengakses
// class, function ataupun variable pada file yang berbeda

/*
  Proses kueri ke database bersifat Asynchronous (Asinkron). Operasi Asynchronous memungkinkan program Anda menyelesaikan
  pekerjaannya sambil menunggu operasi lainnya selesai.

  Kita dapat mengetahui apakah suatu function dalam program dart adalah proses asynchronous atau tidak dengan melihat
  nilai kembaliannya (return value). Proses Asynchronous selalu mengembalikan objek Future atau objek Stream.

  Proses Asynchronous ini membuat program tetap berjalan tanpa harus menunggu proses kueri ke database selesai.

  Jika bukan itu yang kita harapkan, misal kita sebenarnya ingin membuat program menunggu proses kueri ke database selesai
  baru lanjut mengeksekusi proses selanjutnya. Hal tersebut dapat dipenuhi dengan menggunakan function "async & await".

  Kata kunci async dan await mendukung pemrograman asynchronous, memungkinkan Anda menulis kode asynchronous yang terlihat
  mirip dengan kode synchronous (sinkron). Keyword "async" ditaruh setelah parameter dan sebelum pembuka blok kode function.
  Lalu, keyword "await" digunakan untuk memberitahu program untuk menunggu proses Asynchronous selesai sebelum melanjutkan ke
  proses selanjutnya.

  Contoh:
  Future<int> contohAsyncAwait() async {
    int hasil = await prosesAsynchronous(); // Program berhenti, menunggu proses asinkron selesai

    return hasil;
  }
*/

// import file daftar.dart
import 'package:daftar_belanja/class/daftar.dart';

// import package string_validator, agar dapat memvalidasi nilai string
import 'package:string_validator/string_validator.dart' as validator;

// import package mysql1, agar program dart dapat berinteraksi dengan database MySQL
import 'package:mysql1/mysql1.dart';

// import file database_settings.dart, berisi konfigurasi untuk terhubung ke database MySQL
import 'package:daftar_belanja/database_settings.dart';

// import package crypt, untuk fitur hash password (Membuat passsword tidak dapat dibaca)
import 'package:crypt/crypt.dart';

/// Class abstract [User] berisi struktur abstrak untuk objek User yang akan menggunakan aplikasi ini
abstract class User {
  /// User ID
  int? _userId;
  /// Nama User
  String? _nama;
  /// Nomor Telepon
  String? _nomorTelepon;
  /// Alamat
  String? _alamat;
  /// Email
  String? _email;

  /// Fungsi Getter untuk mendapatkan nama user
  String get nama => _nama!;

  /// Fungsi Getter untuk mendapatkan User ID
  int get id => _userId!;

  Future<dynamic> createAccount(String nama, String password, String nomorTelepon, String alamat, String email);
  Future<dynamic> login(String email, String password);
  Future<bool> update(String nama, String oldPassword, String nomorTelepon, String alamat, String email, [String? newPassword]);
  Future<bool> deleteAccount();
  bool logOut();

  /// Dapatkan semua isi properti dari objek User
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

/// Objek dari Class [CommonUser] digunakan untuk merepresentasikan User biasa yang menggunakan aplikasi daftar belanja.
/// Class [CommonUser] diturunkan dari abstract class [User]
class CommonUser extends User {
  /// Registrasi akun user baru
  @override
  Future<bool> createAccount(String nama, String password, String nomorTelepon, String alamat, String email) async {
    if (!validator.isLength(password, 8)) {
      throw (ArgumentError("Password Minimal 8 Karakter"));
    }

    MySqlConnection koneksi = await MySqlConnection.connect(settingsDB);

    Results hasil = await koneksi.query(
        "INSERT INTO users (name, nomor_telepon, alamat, email, password) VALUE (?, ?, ?, ?, ?)",
        [nama, nomorTelepon, alamat, email, Crypt.sha256(password).toString()]
    );

    await koneksi.close();

    _userId = hasil.insertId;
    _nama = nama;
    _nomorTelepon = nomorTelepon;
    _alamat = alamat;
    _email = email;

    return true;
  }

  /// Login ke akun user yang sudah terdaftar
  @override
  Future<bool> login(String email, String password) async {
    if (!validator.isLength(password, 8)) {
      throw (ArgumentError("Password Minimal 8 Karakter"));
    }

    MySqlConnection koneksi = await MySqlConnection.connect(settingsDB);

    Results hasil = await koneksi.query("SELECT * FROM users WHERE email = ? AND nama_toko IS NULL", [email]);

    await koneksi.close();

    if (hasil.length == 1) {
      Map<String, dynamic> user = hasil.first.fields;

      if (!Crypt(user['password']).match(password)) {
        throw (Exception("Gagal Login!"));
      }

      _userId = user['user_id'];
      _nama = user['name'];
      _nomorTelepon = user['nomor_telepon'];
      _alamat = user['alamat'].toString();
      _email = user['email'];

      return true;
    } else if (hasil.isEmpty) {
      throw (Exception("Gagal Login!"));
    } else {
      throw (Exception("Ada Kesalahan!"));
    }
  }

  /// Update data profil user
  @override
  Future<bool> update(String nama, String oldPassword, String nomorTelepon, String alamat, String email, [String? newPassword]) async {
    if (_userId == null && _nama == null && _nomorTelepon == null && _alamat == null && _email == null) {
      throw (Exception("Status Sudah Tidak Login !"));
    } else {
      MySqlConnection koneksi = await MySqlConnection.connect(settingsDB);

      Results passwordFromDB = await koneksi.query("SELECT password FROM users WHERE user_id = ?", [_userId]);

      late Results hasil;

      if (passwordFromDB.length == 1) {
        if (!Crypt(passwordFromDB.first.first).match(oldPassword)) {
          throw ("Gagal Update Profil Akun");
        }
      } else {
        throw (Exception("Ada Kesalahan!"));
      }

      if (newPassword != null) {
        if (!validator.isLength(newPassword, 8)) {
          throw (ArgumentError("Password Minimal 8 Karakter"));
        }

        hasil = await koneksi.query(
            "UPDATE users SET name = ?, nomor_telepon = ?, alamat = ?, email = ?, password = ? WHERE user_id = ?",
            [nama, nomorTelepon, alamat, email, Crypt.sha256(newPassword).toString(), _userId]
        );
      } else {
        hasil = await koneksi.query(
            "UPDATE users SET name = ?, nomor_telepon = ?, alamat = ?, email = ? WHERE user_id = ?",
            [nama, nomorTelepon, alamat, email, _userId]
        );
      }

      await koneksi.close();

      if (hasil.affectedRows == 1) {
        _nama = nama;
        _nomorTelepon = nomorTelepon;
        _alamat = alamat;
        _email = email;

        return true;
      } else if (hasil.affectedRows == 0) {
        throw (Exception("Tidak Menemukan User yang Ingin Di Update !"));
      } else {
        throw (Exception("Ada Kesalahan!"));
      }
    }
  }

  /// Log out dari akun user yang digunakan
  @override
  bool logOut() {
    if (_userId == null && _nama == null && _nomorTelepon == null && _alamat == null &&_email == null) {
      throw (Exception("Status Sudah Tidak Login !"));
    } else {
      _userId = _nama = _nomorTelepon = _alamat = _email = null;
      return true;
    }
  }

  /// Hapus akun user
  @override
  Future<bool> deleteAccount() async {
    if (_userId == null && _nama == null && _nomorTelepon == null && _alamat == null && _email == null) {
      throw (Exception("Status Sudah Tidak Login !"));
    } else {
      List<DaftarBelanja> daftarBelanja = await getAllDaftarBelanja();

      for (DaftarBelanja daftar in daftarBelanja) {
        await daftar.delete();
      }

      MySqlConnection koneksi = await MySqlConnection.connect(settingsDB);

      Results hasil = await koneksi.query("DELETE FROM users WHERE user_id = ?", [_userId]);

      await koneksi.close();

      if (hasil.affectedRows! == 1) {
        _userId = _nama = _nomorTelepon = _alamat = _email = null;
        return true;
      } else if (hasil.affectedRows == 0) {
        throw (Exception("Tidak Menemukan Akun yang Ingin Dihapus !"));
      } else {
        throw (Exception("Ada Kesalahan !"));
      }
    }
  }

  /// Dapatkan semua daftar belanja yang dimiliki oleh user
  Future<List<DaftarBelanja>> getAllDaftarBelanja() async {
    MySqlConnection koneksi = await MySqlConnection.connect(settingsDB);

    Results hasil = await koneksi.query("SELECT * FROM daftar_barang WHERE user_id = ?", [_userId]);

    await koneksi.close();

    List<DaftarBelanja> daftarBelanja = [];

    for (var data in hasil) {
      DaftarBelanja daftar = DaftarBelanja(data[0], data[1], data[2].toString(), data[3].toString());

      daftarBelanja.add(daftar);
    }

    return daftarBelanja;
  }

  /// Buat daftar belanja baru milik user
  Future<DaftarBelanja> buatDaftar(String namaDaftar) async {
    MySqlConnection koneksi = await MySqlConnection.connect(settingsDB);

    Results hasil = await koneksi.query(
        "INSERT INTO daftar_barang (nama_daftar, user_id) VALUES (?, ?)",
        [namaDaftar, _userId]
    );

    Results date = await koneksi.query(
        "SELECT date_created, date_updated FROM daftar_barang WHERE id = ?",
        [hasil.insertId]
    );

    await koneksi.close();

    DaftarBelanja daftar = DaftarBelanja(hasil.insertId!, namaDaftar, date.first[0].toString(), date.first[1].toString());

    return daftar;
  }
}

/// Objek dari Class [Seller] digunakan untuk merepresentasikan penjual (seller) yang menggunakan aplikasi daftar belanja.
/// Class [Seller] diturunkan dari abstract class [User]
class Seller extends User {
  /// Nama Toko Penjual
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

  /// Registrasi akun seller baru
  @override
  Future<DaftarProduk> createAccount(String nama, String password, String nomorTelepon, String alamat, String email, [String? namaToko]) async {
    if (!validator.isLength(password, 8)) {
      throw (ArgumentError("Password Minimal 8 Karakter"));
    }

    MySqlConnection koneksi = await MySqlConnection.connect(settingsDB);

    Results hasil = await koneksi.query(
        "INSERT INTO users (name, nama_toko, nomor_telepon, alamat, email, password) VALUES (?, ?, ?, ?, ?, ?)",
        [nama, namaToko, nomorTelepon, alamat, email, Crypt.sha256(password).toString()]
    );

    await koneksi.close();

    _userId = hasil.insertId;
    _nama = nama;
    _namaToko = namaToko;
    _nomorTelepon = nomorTelepon;
    _alamat = alamat;
    _email = email;

    DaftarProduk daftarProduk = await _buatDaftar("seller_$_namaToko");

    return daftarProduk;
  }

  /// Otomatis membuat daftar produk untuk setiap akun seller yang dibuat
  Future<DaftarProduk> _buatDaftar(String namaDaftar) async {
    MySqlConnection koneksi = await MySqlConnection.connect(settingsDB);

    Results hasil = await koneksi.query(
        "INSERT INTO daftar_barang (nama_daftar, user_id) VALUES (?, ?)",
        [namaDaftar, _userId]
    );

    Results date = await koneksi.query(
        "SELECT date_created, date_updated FROM daftar_barang WHERE id = ?",
        [hasil.insertId]
    );

    await koneksi.close();

    DaftarProduk daftar = DaftarProduk(hasil.insertId!, namaDaftar, date.first[0].toString(), date.first[1].toString());

    return daftar;
  }

  /// Login ke akun seller yang sudah terdaftar
  @override
  Future<DaftarProduk> login(String email, String password) async {
    if (!validator.isLength(password, 8)) {
      throw(ArgumentError("Password Minimal 8 Karakter"));
    }

    MySqlConnection koneksi = await MySqlConnection.connect(settingsDB);

    Results hasil = await koneksi.query("SELECT * FROM users WHERE email = ? AND nama_toko IS NOT NULL", [email]);

    await koneksi.close();

    if (hasil.length == 1) {
      Map<String, dynamic> user = hasil.first.fields;

      if ((!Crypt(user['password']).match(password)) && user['password'] != password) {
        throw (Exception("Gagal Login!"));
      }

      _userId = user['user_id'];
      _nama = user['name'];
      _namaToko = user['nama_toko'];
      _nomorTelepon = user['nomor_telepon'];
      _alamat = user['alamat'].toString();
      _email = user['email'];

      DaftarProduk daftarProduk = await _getSpesificDaftarProduk();

      return daftarProduk;
    } else if (hasil.isEmpty) {
      throw (Exception("Gagal Login!"));
    } else {
      throw (Exception("Ada Kesalahan!"));
    }
  }

  /// Update data profil seller
  @override
  Future<bool> update(String nama, String oldPassword, String nomorTelepon, String alamat, String email, [String? newPassword, String? namaToko]) async {
    if (_userId == null && _nama == null && _namaToko == null && _nomorTelepon == null && _alamat == null && _email == null) {
      throw (Exception("Status Sudah Tidak Login !"));
    } else {
      MySqlConnection koneksi = await MySqlConnection.connect(settingsDB);

      Results passwordFromDB = await koneksi.query("SELECT password FROM users WHERE user_id = ?", [_userId]);

      late Results hasil;

      if (passwordFromDB.length == 1) {
        if (!Crypt(passwordFromDB.first.first).match(oldPassword)) {
          throw ("Gagal Update Profil Akun");
        }
      } else {
        throw (Exception("Ada Kesalahan!"));
      }

      if (newPassword != null) {
        if (!validator.isLength(newPassword, 8)) {
          throw (ArgumentError("Password Minimal 8 Karakter"));
        }

        hasil = await koneksi.query(
            "UPDATE users SET name = ?, nama_toko = ?, nomor_telepon = ?, alamat = ?, email = ?, password = ? WHERE user_id = ?",
            [nama, namaToko, nomorTelepon, alamat, email, Crypt.sha256(newPassword).toString(), _userId]
        );
      } else {
        hasil = await koneksi.query(
            "UPDATE users SET name = ?, nama_toko = ?, nomor_telepon = ?, alamat = ?, email = ? WHERE user_id = ?",
            [nama, namaToko, nomorTelepon, alamat, email, _userId]
        );
      }

      await koneksi.close();

      if (hasil.affectedRows == 1) {

        if (_namaToko != namaToko) {
          DaftarProduk daftarProduk = await _getSpesificDaftarProduk();

          await daftarProduk.update("seller_$namaToko");
        }

        _nama = nama;
        _namaToko = namaToko;
        _nomorTelepon = nomorTelepon;
        _alamat = alamat;
        _email = email;

        return true;
      } else if (hasil.affectedRows == 0) {
        throw (Exception("Tidak Menemukan User yang Ingin Di Update !"));
      } else {
        throw (Exception("Ada Kesalahan!"));
      }
    }
  }

  /// Otomatis dijalankan setiap kali login. mengambil Daftar Produk milik seller yang bersangkutan
  Future<DaftarProduk> _getSpesificDaftarProduk() async {
    MySqlConnection koneksi = await MySqlConnection.connect(settingsDB);

    Results hasil = await koneksi.query("SELECT * FROM daftar_barang WHERE user_id = ?", [_userId]);

    await koneksi.close();

    if (hasil.length == 1) {
      Map<String, dynamic> data = hasil.first.fields;

      DaftarProduk daftarProduk = DaftarProduk(data['id'], data['nama_daftar'], data['date_created'].toString(), data['date_updated'].toString());

      return daftarProduk;
    } else if (hasil.isEmpty) {
      throw (Exception("Gagal Mendapatkan Daftar Produk!"));
    } else {
      throw (Exception("Ada Kesalahan!"));
    }
  }

  /// Log out dari akun seller yang digunakan
  @override
  bool logOut() {
    if (_userId == null && _nama == null && _namaToko == null && _nomorTelepon == null && _alamat == null && _email == null) {
      throw (Exception("Status Sudah Tidak Login !"));
    } else {
      _userId = _nama = _namaToko = _nomorTelepon = _alamat = _email = null;
      return true;
    }
  }

  /// Hapus akun seller
  @override
  Future<bool> deleteAccount() async {
    if (_userId == null && _nama == null && _namaToko == null && _nomorTelepon == null && _alamat == null && _email == null) {
      throw (Exception("Status Sudah Tidak Login !"));
    } else {
      DaftarProduk daftarProduk = await _getSpesificDaftarProduk();

      await daftarProduk.delete();

      MySqlConnection koneksi = await MySqlConnection.connect(settingsDB);

      Results hasil = await koneksi.query("DELETE FROM users WHERE user_id = ?", [_userId]);

      await koneksi.close();

      if (hasil.affectedRows! == 1) {
        _userId = _nama = _namaToko = _nomorTelepon = _alamat = _email = null;
        return true;
      } else if (hasil.affectedRows == 0) {
        throw (Exception("Tidak Menemukan Akun yang Ingin Dihapus !"));
      } else {
        throw (Exception("Ada Kesalahan !"));
      }
    }
  }

  /// Method static milik class Seller untuk mendapatkan semua seller yang terdaftar di aplikasi.
  /// Digunakan agar CommonUser bisa memilih produk dari seller yang terdaftar di aplikasi
  static Future<List<Map<String, dynamic>>> getAllSeller() async {
    List<Map<String, dynamic>> daftarSeller = [];
    MySqlConnection koneksi = await MySqlConnection.connect(settingsDB);

    Results hasil = await koneksi.query("SELECT * FROM users WHERE nama_toko IS NOT NULL");

    await koneksi.close();

    for (ResultRow seller in hasil) {
      Map<String, dynamic> dataSeller = seller.fields;

      daftarSeller.add(dataSeller);
    }

    return daftarSeller;
  }
}

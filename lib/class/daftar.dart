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

// import file barang.dart
import 'package:daftar_belanja/class/barang.dart';

// import file database_settings.dart, berisi konfigurasi untuk terhubung ke database MySQL
import 'package:daftar_belanja/database_settings.dart';

// import package mysql1, agar program dart dapat berinteraksi dengan database MySQL
import 'package:mysql1/mysql1.dart';

/// Class abstract [Daftar] berisi struktur abstrak yang akan digunakan untuk menyimpan daftar barang
abstract class Daftar {
  /// ID Daftar
  int? _idDaftar;
  /// Nama Daftar
  String? _namaDaftar;
  /// Waktu Dibuat
  String? _dateCreated;
  /// Waktu Di-update
  String? _dateUpdated;

  /// Fungsi Getter untuk mendapatkan nama daftar
  String get namaDaftar => _namaDaftar!;

  /// Constructor Class [Daftar], untuk menginisialisasi nilai properti
  Daftar(int idDaftar, String namaDaftar, String dateCreated, String dateUpdated) {
    _idDaftar = idDaftar;
    _namaDaftar = namaDaftar;
    _dateCreated = _dateParse(DateTime.parse(dateCreated));
    _dateUpdated = _dateParse(DateTime.parse(dateUpdated));
  }

  Future<List<Barang>> getAllBarang();
  Future<bool> tambahBarang(String nama, int harga, String deskripsi, String kategori, int kuantitas, [String? url]);
  Future<bool> update(String nama);
  Future<bool> delete();

  /// Dapatkan semua isi properti dari objek daftar
  List getAttributes() {
    return [_namaDaftar, _dateCreated, _dateUpdated];
  }

  /// Mengubah format waktu bawaan dart ke format waktu yang mudah dibaca manusia
  String _dateParse(DateTime time) {
    List<String> bulan = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];

    return "${time.day} ${bulan[time.month - 1]} ${time.year} ${time.hour}:${time.minute}:${time.second}";
  }
}

/// Objek dari class [DaftarBelanja] digunakan untuk merepresentasikan Daftar Belanja milik user biasa
/// Class [DaftarBelanja] diturunkan dari abstract class [Daftar]
class DaftarBelanja extends Daftar {
  /// Constructor Class [DaftarBelanja], untuk menginisialisasi nilai properti
  DaftarBelanja(int idDaftar, String namaDaftar, String dateCreated, String dateUpdated) : super(idDaftar, namaDaftar, dateCreated, dateUpdated);

  /// Mendapatkan semua barang dari sebuah daftar belanja
  @override
  Future<List<Barang>> getAllBarang() async {
    MySqlConnection koneksi = await MySqlConnection.connect(settingsDB);

    Results hasil = await koneksi.query("SELECT * FROM barang WHERE daftar_id = ?", [_idDaftar]);

    await koneksi.close();

    List<Barang> listBarang = [];

    for (var data in hasil) {
      Barang barang = Barang(data[0], data[1], data[2], data[3].toString(), data[4], data[5], data[6].toString());

      listBarang.add(barang);
    }

    return listBarang;
  }

  /// Tambah barang ke dalam daftar belanja
  @override
  Future<bool> tambahBarang(String nama, int harga, String? deskripsi, String kategori, int kuantitas, [String? url]) async {
    MySqlConnection koneksi = await MySqlConnection.connect(settingsDB);

    Results hasil = await koneksi.query(
        "INSERT INTO barang (nama, harga, deskripsi, kategori, kuantitas, url, daftar_id) VALUES (?, ?, ?, ?, ?, ?, ?)",
        [nama, harga, deskripsi, kategori, kuantitas, url, _idDaftar]
    );

    DateTime update = DateTime.now();

    Results hasil2 = await koneksi.query(
        "UPDATE daftar_barang SET date_updated = ? WHERE id = ?",
        [update.toIso8601String(), _idDaftar]
    );

    await koneksi.close();

    if (hasil.insertId != null && hasil2.affectedRows == 1) {
      _dateUpdated = _dateParse(update);
      return true;
    } else {
      return false;
    }
  }

  /// Hitung total harga semua barang di dalam daftar belanja
  Future<int> hitungTotalHarga() async {
    List<Barang> listBarang = await getAllBarang();

    int total = 0;

    for (Barang barang in listBarang) {
      total += barang.kuantitas * barang.harga;
    }

    return total;
  }

  /// Update nama Daftar Belanja
  @override
  Future<bool> update(String nama) async {
    if (_idDaftar == null && _namaDaftar == null && _dateCreated == null && _dateUpdated == null) {
      throw (Exception("Tidak Ada Daftar Barang !"));
    } else {
      MySqlConnection koneksi = await MySqlConnection.connect(settingsDB);

      Results hasil = await koneksi.query(
          "UPDATE daftar_barang SET nama_daftar = ? WHERE id = ?",
          [nama, _idDaftar]
      );

      Results date = await koneksi.query("SELECT date_updated FROM daftar_barang WHERE id = ?", [_idDaftar]);

      await koneksi.close();

      if (hasil.affectedRows == 1) {
        _namaDaftar = nama;
        _dateUpdated = _dateParse(DateTime.parse(date.fields[0].toString()));

        return true;
      } else if (hasil.affectedRows == 0) {
        throw (Exception("Tidak Menemukan Daftar Belanja yang Ingin Di-update !"));
      } else {
        throw (Exception("Ada Kesalahan!"));
      }
    }
  }

  /// Hapus daftar belanja
  @override
  Future<bool> delete() async {
    if (_idDaftar == null && _namaDaftar == null && _dateCreated == null && _dateUpdated == null) {
      throw (Exception("Tidak Ada Daftar Belanja !"));
    } else {
      MySqlConnection koneksi = await MySqlConnection.connect(settingsDB);

      Results hasil = await koneksi.query("DELETE FROM daftar_barang WHERE id = ?", [_idDaftar]);

      await koneksi.query("DELETE FROM barang WHERE daftar_id = ?", [_idDaftar]);

      await koneksi.close();

      if (hasil.affectedRows == 1) {
        _idDaftar = _namaDaftar = _dateCreated = _dateUpdated = null;

        return true;
      } else if (hasil.affectedRows == 0) {
        throw (Exception("Tidak Menemukan Daftar Belanja yang Ingin Dihapus !"));
      } else {
        throw (Exception("Ada Kesalahan!"));
      }
    }
  }
}

/// Objek dari class [DaftarProduk] digunakan untuk merepresentasikan Daftar Produk milik seller
/// Class [DaftarProduk] diturunkan dari abstract class [Daftar]
class DaftarProduk extends Daftar {
  /// Constructor Class [DaftarProduk], untuk menginisialisasi nilai properti
  DaftarProduk(int idDaftar, String namaDaftar, String dateCreated, String dateUpdated) : super(idDaftar, namaDaftar, dateCreated, dateUpdated);

  /// Mendapatkan semua barang di dalam daftar produk
  @override
  Future<List<Barang>> getAllBarang() async {
    MySqlConnection koneksi = await MySqlConnection.connect(settingsDB);

    Results hasil = await koneksi.query("SELECT * FROM barang WHERE daftar_id = ?", [_idDaftar]);

    await koneksi.close();

    List<Barang> listBarang = [];

    for (var data in hasil) {
      Barang barang = Barang(data[0], data[1], data[2], data[3].toString(), data[4], data[5], data[6].toString());

      listBarang.add(barang);
    }

    return listBarang;
  }

  /// Tambah barang ke dalam daftar produk
  @override
  Future<bool> tambahBarang(String nama, int harga, String? deskripsi, String kategori, int kuantitas, [String? url]) async {
    MySqlConnection koneksi = await MySqlConnection.connect(settingsDB);

    Results hasil = await koneksi.query(
        "INSERT INTO barang (nama, harga, deskripsi, kategori, kuantitas, url, daftar_id) VALUES (?, ?, ?, ?, ?, ?, ?)",
        [nama, harga, deskripsi, kategori, kuantitas, url, _idDaftar]
    );

    DateTime update = DateTime.now();

    Results hasil2 = await koneksi.query(
        "UPDATE daftar_barang SET date_updated = ? WHERE id = ?",
        [update.toIso8601String(), _idDaftar]
    );

    await koneksi.close();

    if (hasil.insertId != null && hasil2.affectedRows == 0) {
      _dateUpdated = _dateParse(update);
      return true;
    } else {
      return false;
    }
  }

  /// Update nama Daftar Produk
  @override
  Future<bool> update(String nama) async {
    if (_idDaftar == null && _namaDaftar == null && _dateCreated == null && _dateUpdated == null) {
      throw (Exception("Tidak Ada Daftar Barang !"));
    } else {
      MySqlConnection koneksi = await MySqlConnection.connect(settingsDB);

      Results hasil = await koneksi.query(
          "UPDATE daftar_barang SET nama_daftar = ? WHERE id = ?",
          [nama, _idDaftar]
      );

      Results date = await koneksi.query("SELECT date_updated FROM daftar_barang WHERE id = ?", [_idDaftar]);

      await koneksi.close();

      if (hasil.affectedRows == 1) {
        _namaDaftar = nama;
        _dateUpdated = _dateParse(DateTime.parse(date.fields[0].toString()));

        return true;
      } else if (hasil.affectedRows == 0) {
        throw (Exception("Tidak Menemukan Daftar Belanja yang Ingin Di-update !"));
      } else {
        throw (Exception("Ada Kesalahan!"));
      }
    }
  }

  // Hapus Daftar Produk
  @override
  Future<bool> delete() async {
    if (_idDaftar == null && _namaDaftar == null && _dateCreated == null && _dateUpdated == null) {
      throw (Exception("Tidak Ada Daftar Belanja !"));
    } else {
      MySqlConnection koneksi = await MySqlConnection.connect(settingsDB);

      Results hasil = await koneksi.query("DELETE FROM daftar_barang WHERE id = ?", [_idDaftar]);

      await koneksi.query("DELETE FROM barang WHERE daftar_id = ?", [_idDaftar]);

      await koneksi.close();

      if (hasil.affectedRows == 1) {
        _idDaftar = _namaDaftar = _dateCreated = _dateUpdated = null;

        return true;
      } else if (hasil.affectedRows == 0) {
        throw (Exception("Tidak Menemukan Daftar Belanja yang Ingin Dihapus !"));
      } else {
        throw (Exception("Ada Kesalahan!"));
      }
    }
  }
}

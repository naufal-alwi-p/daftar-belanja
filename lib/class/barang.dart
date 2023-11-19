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

// import file database_settings.dart, berisi konfigurasi untuk terhubung ke database MySQL
import 'package:daftar_belanja/database_settings.dart';

// import package mysql1, agar program dart dapat berinteraksi dengan database MySQL
import 'package:mysql1/mysql1.dart';

/// Class [Barang] digunakan untuk merepresentasikan Barang yang disimpan dalam Daftar Belanja atau Daftar Produk
class Barang {
  /// ID Barang
  int? _idBarang;
  /// Nama Barang
  String? _nama;
  /// Harga Barang
  int? _harga;
  /// Deskripsi Barang
  String? _deskripsi;
  /// Kategori Barang
  String? _kategori;
  /// Kuantitas Barang
  int? _kuantitas;
  /// URL Barang
  String? _url;

  /// Fungsi Getter untuk mendapatkan harga barang
  int get harga => _harga!;

  /// Fungsi Getter untuk mendapatkan kuantitas barang
  int get kuantitas => _kuantitas!;

  /// Constructor Class [Barang], fungsinya untuk menginisialisasi nilai dari properti di dalam objek [Barang]
  Barang(this._idBarang, this._nama, this._harga, this._deskripsi, this._kategori, this._kuantitas, [this._url]);

  /// Update data barang
  Future<bool> update(String nama, int harga, String? deskripsi, String kategori, int kuantitas, [String? url]) async {
    if (_idBarang == null && _nama == null && _harga == null && _deskripsi == null && _kategori == null && _kuantitas == null && _url == null) {
      throw (Exception("Tidak Ada Data Barang !"));
    } else {
      MySqlConnection koneksi = await MySqlConnection.connect(settingsDB);

      Results hasil = await koneksi.query(
          "UPDATE barang SET nama = ?, harga = ?, deskripsi = ?, kategori = ?, kuantitas = ?, url = ? WHERE id = ?",
          [nama, harga, deskripsi, kategori, kuantitas, url, _idBarang]
      );

      DateTime update = DateTime.now();

      Results hasil2 = await koneksi.query(
          "UPDATE daftar_barang SET daftar_barang.date_updated = ? WHERE daftar_barang.id = (SELECT barang.daftar_id FROM barang WHERE barang.id = ?)",
          [update.toIso8601String(), _idBarang]
      );

      await koneksi.close();

      if (hasil.affectedRows == 1 && hasil2.affectedRows == 1) {
        _nama = nama;
        _harga = harga;
        _deskripsi = deskripsi;
        _kategori = kategori;
        _kuantitas = kuantitas;
        _url = url;

        return true;
      } else if (hasil.affectedRows == 0) {
        throw (Exception("Tidak Menemukan Barang yang Ingin Di-update !"));
      } else {
        throw (Exception("Ada Kesalahan!"));
      }
    }
  }

  /// Hapus barang
  Future<bool> delete() async {
    if (_idBarang == null && _nama == null && _harga == null && _deskripsi == null && _kategori == null && _kuantitas == null && _url == null) {
      throw (Exception("Tidak Ada Data Barang !"));
    } else {
      MySqlConnection koneksi = await MySqlConnection.connect(settingsDB);

      Results hasil = await koneksi.query("DELETE FROM barang WHERE id = ?", [_idBarang]);

      DateTime update = DateTime.now();

      Results hasil2 = await koneksi.query(
          "UPDATE daftar_barang SET daftar_barang.date_updated = ? WHERE daftar_barang.id = (SELECT barang.daftar_id FROM barang WHERE barang.id = ?)",
          [update.toIso8601String(), _idBarang]
      );

      await koneksi.close();

      if (hasil.affectedRows == 1 && hasil2.affectedRows == 1) {
        _idBarang = _nama = _harga = _deskripsi = _kategori = _kuantitas = _url = null;

        return true;
      } else if (hasil.affectedRows == 0) {
        throw (Exception("Tidak Menemukan Barang yang Ingin Dihapus !"));
      } else {
        throw (Exception("Ada Kesalahan!"));
      }
    }
  }

  /// Dapatkan semua isi properti dari objek barang
  Map<String, dynamic> showDetail() {
    Map<String, dynamic> detail = {
      "ID": _idBarang,
      "Nama": _nama,
      "Harga": _harga,
      "Deskripsi": (_deskripsi == 'null') ? '-' : _deskripsi,
      "Kategori": _kategori,
      "Kuantitas": _kuantitas,
      "URL": (_url == 'null') ? '-' : _url
    };

    return detail;
  }
}

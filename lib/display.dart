import 'package:daftar_belanja/class/barang.dart';
import 'package:daftar_belanja/class/daftar.dart';
import 'package:daftar_belanja/class/user.dart';
import 'package:dart_console/dart_console.dart';
import 'package:interact/interact.dart';
import 'package:string_validator/string_validator.dart' as validator;

Console console = Console();

void header(String pageName, {String? error, String? loggedUser}) {
  console.setForegroundColor(ConsoleColor.brightGreen);
  console.setTextStyle(bold: true);

  console.writeLine("APLIKASI DAFTAR BELANJA", TextAlignment.center);

  console.resetColorAttributes();
  console.setTextStyle(bold: false);

  console.writeLine(pageName, TextAlignment.center);

  if (loggedUser != null) {
    console.writeLine("Login as $loggedUser", TextAlignment.right);
  }

  if (error != null) {
    console.setForegroundColor(ConsoleColor.yellow);
    console.writeLine(error);
    console.writeLine("");
    console.resetColorAttributes();
  }
}

int home() {
  header("Main Menu");

  List<String> opsi = ["User", "Seller", "Exit"];

  int hasil = Select(prompt: "Ingin Login Sebagai ?", options: opsi).interact();

  return hasil;
}

int menuLogin({String? error}) {
  header("Login Menu", error: error);

  List<String> opsi = ["Login", "Buat Akun", "Kembali"];

  int hasil = Select(prompt: "Pilih Opsi", options: opsi).interact();

  console.clearScreen();

  return hasil;
}

List loginPage() {
  header("Login Form");

  late String email, password;
  bool? confirmation;

  while (confirmation != true) {
    email = Input(
      prompt: "Email:",
      validator: (email) {
          if (validator.isEmail(email)) {
            return true;
          } else {
            throw (ValidationError("Isi email dengan benar !"));
          }
        }
    ).interact();
    password = Password(prompt: "Password:").interact();

    confirmation = Confirm(prompt: "Submit?", waitForNewLine: true).interact();
  }

  console.clearScreen();

  return [email, password];
}

List createAccountPage(User user) {
  header("Create Account Form");

  console.setTextStyle(bold: true);
  console.writeLine("Masukkan Data Berikut");
  console.setTextStyle(bold: false);

  late String nama, nomorTelepon, alamat, email, password;
  String? namaToko;
  bool? confirmation;

  while (confirmation != true) {
    nama = Input(
        prompt: "Nama:",
        validator: (nama) {
          if (validator.isAlpha(validator.blacklist(nama, ' '))) {
            return true;
          } else {
            throw (ValidationError("Nama Harus Terdiri dari huruf saja"));
          }
        }).interact();

    if (user.runtimeType == Seller) {
      namaToko = Input(prompt: "Nama Toko:").interact();
    }

    nomorTelepon = Input(
        prompt: "Nomor Telepon:",
        validator: (nomorTelepon) {
          if (validator.isNumeric(nomorTelepon)) {
            return true;
          } else {
            throw (ValidationError("Isikan Nomor Telepon"));
          }
        }).interact();

    alamat = Input(
        prompt: "Alamat:",
        validator: (alamat) {
          if (validator.isAscii(alamat)) {
            return true;
          } else {
            throw (ValidationError("Isi Alamat Dengan Benar !"));
          }
        }).interact();

    email = Input(
        prompt: "Email:",
        validator: (email) {
          if (validator.isEmail(email)) {
            return true;
          } else {
            throw (ValidationError("Isi email dengan benar !"));
          }
        }).interact();

    password = Password(
      prompt: "Password:",
      confirmation: true,
      confirmPrompt: "Konfirmasi Password:",
    ).interact();

    confirmation = Confirm(prompt: "Submit?", waitForNewLine: true).interact();
  }

  console.clearScreen();

  return (namaToko == null)
      ? [nama, password, nomorTelepon, alamat, email]
      : [nama, password, nomorTelepon, alamat, email, namaToko];
}

Future<int> homepage({CommonUser? user, Seller? seller, String? error}) async {
  late String pageName, userName;
  late List<String> opsi;

  Table tabel = Table()
    ..borderStyle = BorderStyle.square
    ..borderType = BorderType.grid
    ..headerStyle = FontStyle.bold
    ..insertColumn(header: 'No.')
    ..insertColumn(header: 'Nama Daftar', alignment: TextAlignment.center)
    ..insertColumn(header: 'Date Created', alignment: TextAlignment.center)
    ..insertColumn(header: 'Date Update', alignment: TextAlignment.center);

  if (user != null) {
    pageName = "User Homepage";
    opsi = ["Pilih Daftar Belanja", "Buat Daftar Belanja", "Show My Profile"];
    userName = user.nama;
    tabel.title = "List Daftar Belanja";
  } else if (seller != null) {
    pageName = "Seller Homepage";
    opsi = [
      "Tambah Produk",
      "Edit Produk",
      "Hapus Produk",
      "Detail Produk",
      "Show My Profile"
    ];
    userName = seller.nama;
    tabel.title = "List Produk";
  }

  header(pageName, error: error, loggedUser: userName);

  if (user != null) {
    List<DaftarBelanja> daftarBelanja = await user.getAllDaftarBelanja();
    int index = 1;

    for (DaftarBelanja daftar in daftarBelanja) {
      List row = daftar.getAttributes();

      tabel.insertRow([index++,row[0], row[1], row[2]]);
    }
  }

  print(tabel);

  int hasil = Select(prompt: "Opsi", options: opsi).interact();

  console.clearScreen();

  return hasil;
}

int showProfile(User user, {String? error}) {
  late String pageName;
  late int opsi;
  bool? confirmation;

  Table tabel = Table()
    ..borderStyle = BorderStyle.square
    ..borderType = BorderType.grid
    ..showHeader = false
    ..insertColumn()
    ..insertColumn();

  if (user.runtimeType == CommonUser) {
    pageName = tabel.title = "User Profile";
  } else {
    pageName = tabel.title = "Seller Profile";
  }

  while (confirmation != true) {
    header(pageName, error: error);

    user.getAllAttributes().forEach((key, value) {
      tabel.insertRow([key, value]);
    });

    print(tabel);

    opsi = Select(prompt: 'Opsi', options: ["Kembali", "Logout", "Hapus Akun"])
        .interact();

    if (opsi == 1 || opsi == 2) {
      confirmation = Confirm(prompt: "Apakah Kamu Yakin?", waitForNewLine: true)
          .interact();
    } else {
      confirmation = true;
    }

    console.clearScreen();
  }

  return opsi;
}

String buatDaftarBelanjaForm() {
  header("Form Daftar Belanja");

  late String namaDaftar;
  bool? confirmation;

  while (confirmation != true) {
    namaDaftar = Input(prompt: "Nama Daftar:").interact();

    confirmation = Confirm(prompt: "Submit?", waitForNewLine: true).interact();
  }

  console.clearScreen();

  return namaDaftar;
}

Future<DaftarBelanja?> selectList(CommonUser user) async {
  Table tabel = Table()
    ..borderStyle = BorderStyle.square
    ..borderType = BorderType.grid
    ..headerStyle = FontStyle.bold
    ..title = "List Daftar Belanja"
    ..insertColumn(header: "No.")
    ..insertColumn(header: 'Nama Daftar', alignment: TextAlignment.center)
    ..insertColumn(header: 'Date Created', alignment: TextAlignment.center)
    ..insertColumn(header: 'Date Update', alignment: TextAlignment.center);

  List<DaftarBelanja> daftarBelanja = await user.getAllDaftarBelanja();
  List<String> opsi = [];
  int index = 1;

  for (var daftar in daftarBelanja) {
    List row = daftar.getAttributes();

    tabel.insertRow([index, row[0], row[1], row[2]]);

    opsi.add("${index++}. ${row[0]}");
  }

  opsi.add("Kembali");

  header("Pilih Daftar", loggedUser: user.nama);

  print(tabel);

  int hasil = Select(prompt: "Pilih Daftar Belanja", options: opsi).interact();

  console.clearScreen();

  return (hasil == (opsi.length - 1)) ? null : daftarBelanja[hasil];
}

Future<int> spesificList(
    {CommonUser? user, Seller? seller, DaftarBelanja? daftarBelanja}) async {
  Table tabel = Table()
    ..borderStyle = BorderStyle.square
    ..borderType = BorderType.grid
    ..headerStyle = FontStyle.bold;

  if (user != null && daftarBelanja != null) {
    tabel
      ..title = daftarBelanja.namaDaftarBelanja
      ..insertColumn(header: "No.")
      ..insertColumn(header: "Nama", alignment: TextAlignment.center)
      ..insertColumn(header: "Harga", alignment: TextAlignment.center)
      ..insertColumn(header: "Kategori", alignment: TextAlignment.center)
      ..insertColumn(header: "Kuantitas", alignment: TextAlignment.center)
      ..insertColumn(header: "URL", alignment: TextAlignment.center);

    List<Barang> listBarang = await daftarBelanja.getAllBarang();
    int index = 1;

    for (Barang barang in listBarang) {
      Map data = barang.showDetail();

      List<Object> row = [
        index++,
        data['Nama'],
        data['Harga'],
        data['Kategori'],
        data['Kuantitas'],
        data['URL'].toString()
      ];

      tabel.insertRow(row);
    }

    header("Daftar Belanja", loggedUser: user.nama);

    print(tabel);

    int totalHarga = await daftarBelanja.hitungTotalHarga();

    console.setTextStyle(bold: true);
    console.write("Total Harga: ");
    console.setTextStyle(bold: false);
    console.writeLine(totalHarga);

    List<String> opsi = ["Tambah Barang", "Lihat Detail Barang", "Kembali"];

    int hasil = Select(prompt: "Opsi", options: opsi).interact();

    console.clearScreen();

    return hasil;
  }

  return -1;
}

List tambahBarangForm({CommonUser? user, Seller? seller}) {
  if (user != null) {
    header("Tambah Barang Form", loggedUser: user.nama);

    String nama = Input(prompt: "Nama Barang:").interact();

    String harga = Input(
        prompt: "Harga Barang:",
        validator: (harga) {
          if (validator.isNumeric(harga)) {
            return true;
          } else {
            throw (ValidationError("Isikan Nomor Telepon"));
          }
        }).interact();

    int angkaHarga = int.parse(harga);

    String? deskripsi = Input(prompt: "Deskripsi Barang").interact();
    if (deskripsi == "") {
      deskripsi = null;
    }

    String kategori = Input(prompt: "Kategori Barang").interact();

    String kuantitas = Input(
        prompt: "Kuantitas Barang",
        validator: (kuantitas) {
          if (validator.isNumeric(kuantitas)) {
            return true;
          } else {
            throw (ValidationError("Isikan Nomor Telepon"));
          }
        }).interact();

    int angkaKuantitas = int.parse(kuantitas);

    String? url;
    bool confirmation =
        Confirm(prompt: "Apakah ini barang online?", waitForNewLine: true)
            .interact();

    if (confirmation) {
      url = Input(prompt: "URL Barang").interact();
    }

    console.clearScreen();

    return [nama, angkaHarga, deskripsi, kategori, angkaKuantitas, url];
  }

  return [];
}

Future<Barang?> selectDetailBarang({CommonUser? user, Select? seller, DaftarBelanja? daftarBelanja}) async {
  Table tabel = Table()
    ..borderStyle = BorderStyle.square
    ..borderType = BorderType.grid
    ..headerStyle = FontStyle.bold;

  if (user != null && daftarBelanja != null) {
    tabel
      ..title = daftarBelanja.namaDaftarBelanja
      ..insertColumn(header: "No.")
      ..insertColumn(header: "Nama", alignment: TextAlignment.center)
      ..insertColumn(header: "Harga", alignment: TextAlignment.center)
      ..insertColumn(header: "Kategori", alignment: TextAlignment.center)
      ..insertColumn(header: "Kuantitas", alignment: TextAlignment.center)
      ..insertColumn(header: "URL", alignment: TextAlignment.center);

    List<Barang> listBarang = await daftarBelanja.getAllBarang();
    List<String> opsi = [];
    int index = 1;

    for (Barang barang in listBarang) {
      Map data = barang.showDetail();

      opsi.add("$index. ${data['Nama']}");

      List<Object> row = [
        index++,
        data['Nama'],
        data['Harga'],
        data['Kategori'],
        data['Kuantitas'],
        data['URL'].toString()
      ];

      tabel.insertRow(row);
    }

    opsi.add("Kembali");

    header("Detail Barang", loggedUser: user.nama);

    print(tabel);

    int hasil = Select(prompt: "Pilih Barang", options: opsi).interact();

    console.clearScreen();

    return (hasil == (opsi.length - 1)) ? null : listBarang[hasil];
  }

  return null;
}

int spesificBarang({CommonUser? user, Seller? seller, required Barang barang}) {
  Table tabel = Table()
    ..borderStyle = BorderStyle.square
    ..borderType = BorderType.grid
    ..showHeader = false
    ..insertColumn()
    ..insertColumn();

  if (user != null) {
    tabel.title = "Detail Barang";
    late int hasil;
    bool? confirmation;

    Map<String, dynamic> data = barang.showDetail();

    data.forEach((key, value) {
      tabel.insertRow([key, value.toString()]);
    });


    while (confirmation != true) {
      header("Detail Barang", loggedUser: user.nama);

      print(tabel);

      hasil = Select(prompt: "Opsi", options: ["Edit Barang", "Hapus Barang", "Kembali"]).interact();

      if (hasil == 1) {
        confirmation = Confirm(prompt: "Apakah Kamu Yakin?", waitForNewLine: true).interact();
      } else {
        confirmation = false;
      }
      
    }

    console.clearScreen();

    return hasil;
  }

  return -1;
}

import 'package:daftar_belanja/class/barang.dart';
import 'package:daftar_belanja/class/daftar.dart';
import 'package:daftar_belanja/class/user.dart';
import 'package:daftar_belanja/display.dart';

Future<void> start() async {
  console.clearScreen();
  int? opsi;

  while (opsi != 2) {
    opsi = home();

    if (opsi != 2) {
      console.clearScreen();
    } else {
      console.writeLine("Good Bye");
      return;
    }

    switch (opsi) {
      case 0:
        await commonUserRoutine();
        break;
      case 1:
        await sellerRoutine();
        break;
    }
  }
}

Future<void> commonUserRoutine() async {
  String? err;
  CommonUser user = CommonUser();

  while (true) {
    int opsi = menuLogin(error: err);

    if (opsi == 0) {
      late bool hasil;
      List data = loginPage();

      try {
        hasil = await user.login(data[0], data[1]);
      } catch (e) {
        err = e.toString();
        continue;
      }

      if (hasil) {
        break;
      }
    } else if (opsi == 1) {
      late bool hasil;
      List data = createAccountPage(user);

      try {
        hasil = await user.createAccount(
            data[0], data[1], data[2], data[3], data[4]);
      } catch (e) {
        err = e.toString();
        continue;
      }

      if (hasil) {
        break;
      }
    } else if (opsi == 2) {
      return;
    }
  }

  await homepageRoutine(user: user);
}

Future<void> sellerRoutine() async {
  String? err;
  Seller user = Seller();

  while (true) {
    int opsi = menuLogin(error: err);

    if (opsi == 0) {
      late bool hasil;
      List data = loginPage();

      try {
        hasil = await user.login(data[0], data[1]);
      } catch (e) {
        err = e.toString();
        continue;
      }

      if (hasil) {
        break;
      }
    } else if (opsi == 1) {
      late bool hasil;
      List data = createAccountPage(user);

      try {
        hasil = await user.createAccount(
            data[0], data[1], data[2], data[3], data[4], data[5]);
      } catch (e) {
        err = e.toString();
        continue;
      }

      if (hasil) {
        break;
      }
    } else if (opsi == 2) {
      return;
    }
  }

  await homepageRoutine(seller: user);
}

Future<void> homepageRoutine({CommonUser? user, Seller? seller}) async {
  while (true) {
    String? err;
    int opsi = await homepage(user: user, seller: seller, error: err);

    if (user != null) {
      if (opsi == 0) {
        await selectListRoutine(user);
      } else if (opsi == 1) {
        String namaDaftar = buatDaftarBelanjaForm();

        await user.buatDaftar(namaDaftar);

        // showSpesificList(user: user, daftarBelanja: daftarBelanja);
      } else if (opsi == 2) {
        if (await showMyProfileRoutine(user)) {
          return;
        }
      }
    }
  }
}

Future<bool> showMyProfileRoutine(User user) async {
  while (true) {
    String? err;
    int opsi = showProfile(user, error: err);

    if (opsi == 0) {
      return false;
    } else if (opsi == 1) {
      try {
        if (user.logOut()) {
          return true;
        }
      } catch (e) {
        err = e.toString();
        continue;
      }
    } else if (opsi == 2) {
      try {
        if (await user.deleteAccount()) {
          return true;
        }
      } catch (e) {
        err = e.toString();
        continue;
      }
    }
  }
}

Future<void> selectListRoutine(CommonUser user) async {
  while (true) {
    DaftarBelanja? daftarBelanja = await selectList(user);

    if (daftarBelanja == null) {
      return;
    } else {
      await showSpesificList(user: user, daftarBelanja: daftarBelanja);
    }

  }
}

Future<void> showSpesificList({CommonUser? user, Seller? seller, DaftarBelanja? daftarBelanja}) async {
  while (true) {
    if (daftarBelanja != null && user != null) {
      int opsi = await spesificList(user: user, daftarBelanja: daftarBelanja);

      if (opsi == 0) {
        List data = tambahBarangForm(user: user);

        if (await daftarBelanja.tambahBarang(data[0], data[1], data[2], data[3], data[4], data[5])) {
          continue;
        }
      } else if (opsi == 1) {
        Barang? barang = await selectDetailBarang(user: user, daftarBelanja: daftarBelanja);

        if (barang != null) {
            await showSpesificBarangRoutine(user: user, barang: barang);
        }
      } else if (opsi == 2) {
        return;
      }
    }
    
  }
}

Future<void> showSpesificBarangRoutine({CommonUser? user, Seller? seller, Barang? barang}) async {
    while (true) {
        if (barang != null && user != null) {
            int opsi = spesificBarang(barang: barang, user: user);

            if (opsi == 1) {
                if (await barang.delete()) {
                    return;
                }
            }else if (opsi == 2) {
                return;
            }
        }
    }
}

# Guild Petualang (aplikasi Flutter)

Irisan pertama dari prototipe `../prototype/index.html`: pintu guild, Terra (dialog bertahap, wujud perempuan/laki-laki), papan quest, detail quest, daftar petualang, konfirmasi, dan layar "Quest diterima". Data masih contoh di memori; belum ada server.

## Menjalankan
Flutter dan Android SDK memakai jalur **tanpa spasi** lewat pintasan (junction):
- `C:\flutter` menunjuk ke folder Flutter
- `C:\AndroidSdk` menunjuk ke Android SDK

```
cd app
flutter pub get
flutter test
flutter run -d chrome        # atau emulator Android
flutter build apk --debug
```

## Belum ada
Editor avatar, Kartu Petualang, profil lengkap, memasang permintaan, chat dengan Terra, pembayaran, dan verifikasi identitas.

## Aset
`assets/terra/*.svg` dan `assets/scene/*.svg` diekstrak dari prototipe. Ganti dengan ilustrasi final bila sudah ada.

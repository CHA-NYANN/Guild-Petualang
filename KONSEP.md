# Guild Petualang — Dokumen Konsep

> **Mulai dari misi kecil. Bangun kemampuan. Buka kesempatan yang lebih besar.**

Status: konsep utama sudah disepakati, tetapi detail operasionalnya belum final.
Angka yang ditandai *(ilustrasi)* masih bisa berubah setelah pengujian.

---

## 1. Ringkasan

Guild Petualang adalah aplikasi mobile (Android & iOS) yang menggabungkan **platform kerja nyata berbasis misi (quest)** dengan **sistem progres bergaya RPG**.

Pengguna masuk ke "guild", sebuah organisasi independen yang punya cabang di kota-kota di seluruh Indonesia. Di sana pengguna bisa memasang permintaan pekerjaan atau mendaftar menjadi petualang, mengambil quest, menerima bayaran, dan naik rank.

**Arah produk: Hybrid.** Aplikasi ini game sekaligus platform kerja. Identitas RPG-nya kuat, tetapi urusan pekerjaan, pembayaran, dan perlindungan pengguna dirancang sebagai layanan nyata yang bisa dipercaya.

### Prinsip desain utama
- **Game melayani kesempatan kerja.** Kesempatan kerja tidak boleh dikorbankan demi permainan.
- **Satu aktivitas nyata menghasilkan satu catatan transaksi tepercaya.** Catatan itu yang kemudian diterjemahkan menjadi progres game (EXP, achievement).
- **Poin bukan pengganti bayaran.** Achievement juga bukan pengganti bukti kompetensi.
- **AI membantu, manusia memutuskan.** Keputusan penting (sengketa, sanksi, verifikasi, quest rank atas) dibuat oleh staff guild manusia.

---

## 2. Latar Masalah

- Angka pengangguran di Indonesia tinggi, dan ada ketimpangan antara pencari kerja dan pekerjaan yang tersedia.
- Syarat lowongan sering tidak sebanding dengan pekerjaannya, sehingga orang yang mau bekerja pun kesulitan masuk.
- Ada stigma atau gengsi terhadap jenis pekerjaan tertentu.
- Banyak kebutuhan kerja kecil dan lokal yang tidak terorganisasi.
- Orang yang punya kemampuan tetapi tidak punya pengalaman formal kesulitan membuktikan dirinya.

**Visi perubahan:** menggabungkan **akses kerja**, **pasar misi**, **penghargaan atas kemampuan nyata**, dan **gamifikasi** dalam satu ekosistem.

---

## 3. Peran Pengguna

| Peran | Keterangan |
|---|---|
| **Warga Biasa** | Peran default semua pengguna baru. Bisa melihat papan quest dan memasang permintaan. |
| **Petualang** | Warga yang mendaftar untuk mengambil quest. Dimulai dari rank F. |
| **Firma Dagang** | Pemberi quest dengan kepentingan komersial. Tidak boleh memakai skema harga "warga". |
| **Pemerintah** | Pemberi quest dari instansi pemerintahan. Tidak boleh memakai skema harga "warga". |
| **Staff Guild** | Manusia yang bekerja remote: memeriksa quest, menengahi sengketa, memverifikasi, dan memberi dukungan. |

### Identitas & verifikasi
- **Rank F boleh anonim** agar hambatan masuk rendah.
- **Rank E ke atas wajib mendaftarkan identitas beserta bukti identitas**, supaya ada akuntabilitas jika terjadi tindak kriminal.
- Identitas publik boleh berupa nama samaran. Data identitas asli dilindungi dan tidak ditampilkan ke pengguna lain.

---

## 4. Sistem Quest

### 4.1 Jenis quest (berdasarkan pemberi atau bidang)
Semua jenis quest dibuka sejak awal.
- **Misi warga:** bantuan sehari-hari, mencari barang hilang, membantu pindahan, menemani jalan-jalan.
- **Misi firma dagang / UMKM:** desain, administrasi, data, pemasaran, operasional.
- **Misi pemerintah:** diajukan lewat mekanisme dan kewenangan resmi.
- **Misi spesialis:** IT lanjut, farmasi, akuntansi, dan bidang lain yang butuh kompetensi atau izin tertentu.

### 4.2 Lokasi pengerjaan
- **Lokal:** terikat lokasi dan muncul di Papan Permintaan kota tersebut.
- **Jarak jauh (remote):** bisa dikerjakan dari mana saja dan tidak terikat kota.

> Remote adalah *cara pengerjaan*, bukan kategori bidang. Sebuah quest bisa remote sekaligus spesialis.

### 4.3 Aturan dasar
- Tidak ada nilai imbalan minimum. Siapa pun boleh memasang quest.
- Petualang boleh mengambil quest kapan saja selama memenuhi syarat **rank** dan **stat khusus**.
- Setiap quest punya **batas waktu pemasangan** (jika lewat, quest terhapus otomatis dan harus dipasang ulang) dan **batas waktu penyelesaian**.
- Sebelum mengambil quest, petualang harus bisa melihat lingkup kerja, persyaratan, imbalan, tenggat, tahapan, aturan pembatalan, dan konsekuensi kegagalan.
- Pemberi quest tidak boleh mengubah syarat secara sepihak setelah quest diterima. Perubahan besar butuh persetujuan petualang atau ditinjau guild.

### 4.4 Pemeriksaan & persyaratan quest
Persyaratan quest **dikendalikan standar guild**, bukan ditentukan bebas oleh pemberi quest.

1. Pemberi quest menjelaskan pekerjaan, hasil yang diharapkan, imbalan, dan tenggat.
2. **AI menyarankan** tingkat kesulitan, rank minimum, stat khusus, dan menilai kewajaran syaratnya.
3. Jalur pemeriksaan ditentukan menurut jenis quest:

| Jenis quest | Pemeriksaan |
|---|---|
| Rutin & berisiko rendah | Lolos cek otomatis AI, lalu langsung dipublikasikan |
| Mencurigakan / berisiko | Ditahan untuk diperiksa staff guild (walaupun rank-nya rendah) |
| Rank atas | AI memberi rekomendasi, lalu **penilai manusia** menyetujui sebelum publikasi |

Pemberi quest boleh meminta syarat lebih tinggi asalkan alasannya jelas.

---

## 5. Pembayaran

### 5.1 Alur dana
1. Pemberi quest **membayar di muka** sebelum quest terbit.
2. Guild **menahan dana** (mekanisme escrow lewat penyedia pembayaran yang sah).
3. Setelah quest selesai, guild mengambil **komisi (%)** dan sisanya diserahkan ke petualang.

### 5.2 Skenario
| Kondisi | Hasil |
|---|---|
| Quest selesai | Petualang dibayar sesuai kesepakatan setelah dipotong komisi |
| Tidak ada petualang yang mengambil | Dana kembali **100%** ke pemberi quest |
| Gagal karena kesalahan petualang | Dana kembali **100%** ke pemberi quest, petualang dikenai sanksi/denda |
| Tenggat habis, tetapi ada progres | Dibayar sesuai tahapan yang terbukti selesai, sisanya dikembalikan |
| Pemberi quest terbukti melanggar | Dana tidak dikembalikan (sebagian atau penuh) sesuai aturan, dan petualang tetap dibayar atas pekerjaan yang terbukti |

### 5.3 Pembayaran progres (milestone), opsi C
- **Tahapan dan nilai tiap tahap disepakati di awal**, misalnya konsep 30%, draf 40%, final 30% *(ilustrasi)*.
- Jika progres disengketakan, **staff guild menilai bukti** dari kedua pihak.
- Pembayaran atas kerja yang sah tidak ditentukan oleh siapa yang paling keras komplain.

---

## 6. Tenggat, Kegagalan & Sengketa

- **Tenggat habis:** hasil menyesuaikan progres. Jika sebagian besar pekerjaan sudah dikerjakan, quest **dianggap selesai** dengan potongan bayaran dan EXP kecil. Jika terlalu sering tidak selesai, petualang bisa kena **ban sementara** dari mengambil quest.
- **Hasil ditolak:** penolakan wajib disertai keterangan. Jika guild menilai alasannya masuk akal, quest dinyatakan gagal. Guild bertindak sebagai **pihak ketiga netral**.
- **Petualang membatalkan tanpa alasan valid:** dikenai sanksi.
- **Kedua pihak berselisih:** ditangani **staff guild manusia**.
- Kegagalan harus dibedakan penyebabnya: kelalaian petualang, pemberi quest menghambat atau mengubah kesepakatan, atau keadaan di luar kendali kedua pihak.
- Progres harus bisa dibuktikan, misalnya dengan draf, file, atau bukti serah terima.

---

## 7. Sanksi

Sanksi bersifat **proporsional sesuai tingkat keparahan**. Setiap sanksi wajib didasari bukti dan punya **jalur banding**.

| Tingkat | Contoh | Kemungkinan sanksi |
|---|---|---|
| Ringan | Kelalaian kecil, terlambat tetapi masih bisa diperbaiki | Peringatan, pengurangan EXP terbatas |
| Sedang | Batal tanpa alasan valid, berulang kali mengabaikan kewajiban | Pengurangan EXP, pembatasan mengambil quest |
| Berat | Penipuan, pemalsuan bukti, sengaja merugikan | Pembekuan akun, cabut akses, turun EXP/rank, ban permanen |

**Sanksi untuk pemberi quest:** dana tidak dikembalikan (sebagian atau penuh), **ban sementara** dari membuat permintaan, dan Anti-Achievement.

---

## 8. Progres Petualang

Ada tiga sistem progres yang saling terkait, tetapi tidak saling menggantikan.

### 8.1 Rank & EXP
- Rank naik berdasarkan **total EXP**, bukan jumlah quest.
- Quest yang lebih sulit memberi EXP lebih besar. Standar EXP ditetapkan guild, bukan oleh pemberi quest.
- **Ambang EXP tetap dan sama untuk semua petualang.**

| Rank | Sebutan | Total EXP *(ilustrasi)* |
|---|---|---|
| F | Petualang baru | 0 – 999 |
| E | Petualang junior | 1.000 – 2.999 |
| D | Petualang senior | 3.000 – 6.999 |
| C | Petualang tingkat atas | 7.000 – 14.999 |
| B | Petualang berpengalaman | 15.000 – 29.999 |
| A | Petualang tingkat expert | 30.000 – 59.999 |
| S | Petualang tingkat tertinggi | 60.000+ |

Rank **A dan S** khusus untuk petualang dengan keahlian khusus yang benar-benar terbukti (bukan sekadar gelar).

### 8.2 Jalur masuk orang berpengalaman
Semua petualang mulai dari rank F. Orang yang sudah ahli **boleh langsung membuktikan kemampuannya**, tetapi ditempatkan **1–2 rank di bawah** level yang terbukti karena masih baru di guild.

### 8.3 Stat
Stat ditampilkan di profil dan bisa dilihat oleh petualang maupun pemberi quest.

- **Stat umum:** kemampuan dasar, misalnya ketelitian, komunikasi, pemecahan masalah, kedisiplinan.
- **Stat khusus:** keahlian bidang, misalnya pemrograman, desain grafis, pertukangan, penerjemahan.

**Aturan gerbang quest:** quest yang mensyaratkan stat khusus **hanya bisa diambil petualang yang punya stat itu**, walaupun rank-nya sudah cukup.

| Petualang | Rank | Pemrograman | Quest "Website UMKM" (Rank C, Pemrograman ≥ 60) |
|---|---|---|---|
| A | C | 75 | Memenuhi syarat |
| B | B | 40 | Tidak (stat kurang) |
| C | D | 90 | Tidak (rank kurang) |

*(ilustrasi)*

**Cara mendapat stat khusus:** gabungan portofolio/sertifikat dan ujian guild.
**Cara stat berkembang:** pengalaman dari quest yang relevan, ditambah evaluasi atau bukti tambahan untuk mencapai level tinggi.
**Status stat:** belum terverifikasi, terverifikasi, berpengalaman.

> Stat tinggi bukan pengganti lisensi profesi. Pekerjaan yang secara hukum wajib berizin tetap mensyaratkan izin tersebut.

---

## 9. Achievement & Anti-Achievement

**Tidak ada sistem reputasi berupa angka atau rating bintang.** Sebagai gantinya ada label perilaku untuk **kedua pihak** (petualang dan pemberi quest), dan label ini **bisa dilihat semua pengguna**.

- **Achievement:** misalnya *Reliable Adventurer*, *Master Crafter*, *Community Helper* *(contoh nama)*.
- **Anti-Achievement:** misalnya *Deadline Breaker*, *Moving Goalpost*, *False Complainer* *(contoh nama)*.

**Masa berlaku Anti-Achievement:**
- Label aktif selama periode tertentu (misalnya 30 hari, *ilustrasi*).
- Jika perilaku yang sama terulang, masa aktifnya diperpanjang atau dimulai ulang.
- Jika tidak terulang, label hilang dengan sendirinya.
- Pelanggaran kelas berat: label bertahan lebih lama atau permanen.

**Aturan:**
- Label hanya diberikan setelah pelanggaran **terbukti**, bukan saat laporan masih diperiksa.
- Ada mekanisme banding dan koreksi.
- Profil publik hanya menampilkan jenis label dan statusnya, bukan percakapan, identitas, atau bukti sengketa.
- Catatan internal guild boleh tetap disimpan secara terbatas untuk mendeteksi pengulangan.

---

## 9a. Avatar, Profil & Kartu Petualang

### Avatar
Setiap petualang bisa **mengubah tampilan avatarnya**: gaya rambut, warna rambut, warna kulit, warna mata, pakaian, dan aksesori. Avatar tampil besar di profil dan menjadi wajah petualang di mata pengguna lain.

### Kartu Petualang
Di bawah avatar ada **Kartu Petualang** yang berisi:
- foto profil,
- nama petualang dan nomor kartu,
- rank,
- **identitas asli** (nama lengkap, nomor identitas yang disamarkan, kota domisili),
- status verifikasi (belum dilengkapi, menunggu verifikasi, terverifikasi).

### Siapa melihat apa
| Pihak yang melihat | Avatar, rank, EXP | Stat & Achievement | Kartu Petualang (foto & identitas asli) |
|---|---|---|---|
| Pemilik profil | Ya | Ya | **Ya** |
| Pemberi quest yang pekerjaannya diambil petualang tersebut | Ya | Ya | **Ya** |
| Pengguna lain | Ya | Ya | **Tidak**, data pribadi disembunyikan |

- Nomor identitas selalu ditampilkan sebagian saja (hanya 4 digit terakhir).
- Pengguna lain tidak hanya melihat kartu yang kosong, tetapi datanya memang tidak dikirim ke tampilan mereka.
- Rank F boleh anonim, jadi kartu bisa belum dilengkapi. Mulai Rank E identitas wajib.

---

## 10. Terra — Resepsionis AI

- **Nama:** Terra (satu nama saja).
- **Wujud:** satu karakter yang sama, dengan **gender yang bisa dipilih pengguna** (seperti Rover di Wuthering Waves atau Trailblazer di Honkai: Star Rail). Nama, kepribadian, seragam, dan fungsinya sama.
- **Kepribadian:** ramah, profesional, tenang, terasa seperti resepsionis guild di anime RPG.
- **Lore:** tidak ada. Terra adalah maskot sekaligus asisten AI resmi guild.
- **Cakupan:** **satu Terra untuk seluruh guild**. Setiap cabang kota punya **staff manusia** sendiri.
- **Teknologi:** terhubung ke API LLM (Gemini / GPT / Claude).

**Yang boleh dilakukan Terra:** menyapa, menjelaskan aturan guild, membantu menyusun deskripsi quest, menyarankan persyaratan quest, dan menjawab pertanyaan.

**Yang tidak boleh dilakukan Terra:** memutuskan sengketa, menetapkan sanksi, mengesahkan kompetensi, atau mengubah status transaksi. Data imbalan, status quest, pembayaran, dan sanksi selalu diambil dari sistem resmi. Terra tidak boleh mengklaim sesuatu sudah disetujui sebelum sistem benar-benar mencatatnya.

---

## 11. Pengalaman Pengguna

### 11.1 Animasi pembuka (±3–5 detik)
1. Pintu guild terbuka perlahan, memperlihatkan cahaya hangat dari dalam.
2. Kamera bergerak masuk dan Terra tersenyum di meja resepsionis:
   **"Selamat datang di Guild Petualang."**
3. Tampilan berpindah ke beranda.

Untuk pengguna lama, animasi ini bisa di-skip atau dinonaktifkan.

### 11.2 Beranda
- Beranda adalah **Terra** dengan avatar berekspresi dan kotak dialog di bawahnya (gaya Katheryne di Genshin Impact).
- **Akun baru:** Terra menjelaskan apa itu guild dan fungsinya, lalu bertanya, "Apakah kamu ingin menjadi petualang?"
- **Akun lama:** sapaan pembuka singkat dan bervariasi sesuai konteks, dan **bisa di-skip**.
- Papan quest, profil, dan notifikasi tetap mudah dijangkau. Terra adalah pemandu, bukan gerbang yang menghalangi.

### 11.3 Onboarding
- **Tidak ada tutorial wajib.** Petualang rank F langsung boleh mengambil quest.
- Tersedia **video tutorial opsional**.

### 11.4 Layar inti
- **Papan Quest:** kartu modern berisi imbalan, rank minimum, stat yang dibutuhkan, tenggat, dan lokasi atau label remote. Harus mudah dipindai.
- **Profil:** rank, EXP, stat umum dan khusus, Achievement, dan Anti-Achievement, ditampilkan seperti profil karakter RPG.

### 11.5 Gaya visual
**Fantasi Modern:** UI aplikasi kontemporer dengan avatar anime dan istilah RPG (quest, rank, EXP, guild), tanpa nuansa perkamen atau kayu yang berlebihan.

---

## 12. Staff Guild

Guild bukan sistem yang berjalan sendiri tanpa manusia. Di tahap awal, peran staff dijalankan sendiri oleh pendiri. Seiring guild berkembang, peran-peran ini dibuka menjadi lapangan kerja baru:

- **Quest Evaluator:** menilai tingkat kesulitan dan kewajaran quest.
- **Quest Mediator:** menangani penolakan hasil, sengketa, dan banding.
- **Guild Support:** membantu pengguna.
- **Identity & Safety Officer:** verifikasi identitas dan laporan penyalahgunaan.
- **Guild Operations:** mengawasi kualitas quest dan aktivitas cabang.

Kasus rutin dibantu otomatisasi, sementara kasus sengketa ditangani manusia.

---

## 13. Belum Diputuskan

- Nilai EXP final per tingkat kesulitan dan ambang rank final.
- Persentase komisi guild (sama untuk semua kategori atau berbeda).
- Skema harga khusus untuk Firma Dagang dan Pemerintah.
- Mekanisme verifikasi identitas dan kompetensi secara detail.
- Rumus dan skala stat (umum dan khusus), serta daftar stat awal.
- Ambang "progres cukup" saat tenggat habis.
- Durasi ban sementara dan durasi label Anti-Achievement.
- Daftar nama Achievement dan Anti-Achievement.
- Penyedia pembayaran (escrow, refund, pencairan) beserta kepatuhan hukumnya (perlindungan data pribadi, transaksi elektronik, ketenagakerjaan).
- Alur detail untuk tiap peran, keamanan, dan detail UI.
- Stack teknologi aplikasi mobile.
- Berapa lama pemberi quest boleh melihat Kartu Petualang (selama quest berjalan, atau seterusnya)?
- Daftar pilihan avatar (rambut, pakaian, aksesori), dan apakah ada yang dibuka lewat achievement atau rank.
- Aturan foto profil (wajib foto wajah, verifikasi foto, moderasi) dan penyimpanan data identitas yang aman.
- Bolehkah pemberi quest membatalkan quest yang belum diambil siapa pun, dan apakah dananya kembali penuh? (Aplikasi saat ini belum menyediakan tombol batal.)
- Bagaimana nasib dana dan quest ketika petualang membatalkan setelah mengambil, dan apakah quest kembali terbit di papan?
- Bagaimana pemberi quest dari Pemerintah dan Firma Dagang diverifikasi sebelum boleh memasang atas nama instansi atau usaha? (Aplikasi saat ini mengunci pilihan Pemerintah.)
- Apakah pemberi quest harus mendaftar identitas, atau cukup nama samaran seperti Rank F? Berapa batas nilai imbalan untuk akun yang belum terverifikasi?

### Asumsi sementara di aplikasi Flutter (alur "Pasang quest")

Hanya untuk prototipe, bukan keputusan:
- Warga Biasa boleh memasang tanpa mendaftar sebagai petualang. Nama tampilan wajib diisi (boleh nama samaran).
- Empat langkah: pekerjaan (termasuk "dianggap selesai jika…"), imbalan & waktu, tahapan (1, 2, atau 3 tahap dengan pembagian tetap 100 / 50-50 / 30-40-30), lalu tinjau & bayar.
- Saran rank, stat, dan jalur pemeriksaan memakai aturan kata kunci sederhana (bukan AI sungguhan). Pemberi quest boleh menaikkan rank dari saran dengan menulis alasan.
- Jalur pemeriksaan: rutin langsung terbit; rank C ke atas menunggu penilai guild; isi yang mencurigakan ditahan staff guild. Quest yang ditahan belum tampil di papan, dan belum ada layar staff untuk menyetujuinya.
- EXP ditetapkan guild menurut rank dan jumlah tahap, bukan oleh pemberi quest.
- Pembayaran masih simulasi dan memakai biaya guild 10% yang sama untuk semua jenis pemberi quest.

### Suara di aplikasi Flutter

- Musik latar aula (loop 32 detik) dan tiga efek (pintu terbuka, ketukan, lonceng quest) dibuat sendiri dengan skrip `app/tool/make_audio.js`, tanpa sampel orang lain, jadi tidak ada kewajiban lisensi. Jalankan ulang skrip untuk mengubah nada atau suasananya.
- Musik mulai setelah pintu guild terbuka, berhenti saat aplikasi masuk latar belakang, dan bisa dimatikan lewat tombol di beranda atau di Profil. Pilihan bisu tersimpan.
- Belum diputuskan: apakah nanti memakai musik gubahan atau berlisensi sungguhan, dan apakah Terra perlu suara.

## 14. Rencana Nanti (bukan prioritas awal)

- **Perpustakaan Guild:** materi belajar untuk mengembangkan skill khusus. Mengikuti materi tidak otomatis menjadi bukti kompetensi.

---

## 15. Risiko yang Perlu Diantisipasi

- **Pasar kosong:** pencari kerja datang, tetapi quest tidak ada, atau sebaliknya.
- **Keselamatan & penipuan:** quest dunia nyata melibatkan pertemuan, barang, uang, dan akses.
- **Eksploitasi:** imbalan tidak layak bisa membuat guild menjadi pasar tenaga murah. Imbalan, lingkup, dan beban kerja perlu transparan.
- **Ketergantungan pada AI:** Terra bisa salah, sehingga tindakannya dibatasi oleh aturan sistem.
- **Gamifikasi salah arah:** pengguna mengejar poin lebih dari kualitas, atau mengambil terlalu banyak quest.
- **Biaya operasional staff** yang naik seiring pertumbuhan, sehingga dibutuhkan standar, formulir bukti, dan prosedur yang konsisten.

---

## Lampiran: Konteks Tugas Design Thinking

Konsep ini juga menjadi bahan **Tugas Individu Design Thinking Brief** (mata kuliah Kewirausahaan Teknologi, Magister Teknik Informatika).

Tahapan tugas: Empathize (≥3 narasumber berbeda peran), Define (POV + How Might We), Ideate (≥10 ide, ≥2 di antaranya non-teknologi, lalu dipilih dengan kriteria desirability/feasibility/viability), Prototype (low/mid-fidelity untuk satu core flow), Test (think-aloud ≥3 pengguna, SUS opsional, ≥2 perbaikan), dan Refleksi.
Luaran: PDF maksimal 5 halaman beserta lampiran bukti proses.

Catatan:
- Semua wawancara dan pengujian harus **benar-benar dilakukan** atas persetujuan narasumber. Data tidak boleh dikarang.
- Keputusan dalam dokumen ini adalah **hipotesis desain** yang akan diuji, bukan kesimpulan riset.
- Kandidat calon narasumber: pencari kerja, pemberi kerja/UMKM, dan pekerja lepas atau orang berketerampilan.

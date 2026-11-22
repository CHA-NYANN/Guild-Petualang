/**
 * Google Form kuesioner SUS (System Usability Scale) untuk peserta uji think-aloud,
 * plus penghitung skor otomatis.
 *
 * Cara pakai:
 * 1. Buka https://script.google.com, buat proyek baru, tempel isi file ini.
 * 2. Isi PENELITI di bawah.
 * 3. Jalankan buatFormSUS sekali. Link isian muncul di log eksekusi.
 * 4. Setelah sesi think-aloud, minta peserta mengisi form dengan kode P1, P2, P3.
 * 5. Jalankan hitungSkorSUS. Skor tiap peserta dan rata-ratanya ditulis ke sheet "Skor SUS".
 */

// ===== ISI DULU =====
var PENELITI = '[Isi namamu]';
// ====================

var PERNYATAAN_SUS = [
  'Saya pikir saya akan sering menggunakan sistem ini.',
  'Saya merasa sistem ini terlalu rumit padahal bisa dibuat lebih sederhana.',
  'Saya pikir sistem ini mudah digunakan.',
  'Saya pikir saya membutuhkan bantuan orang teknis untuk dapat menggunakan sistem ini.',
  'Saya merasa fungsi-fungsi dalam sistem ini terintegrasi dengan baik.',
  'Saya pikir terlalu banyak ketidakkonsistenan dalam sistem ini.',
  'Saya membayangkan kebanyakan orang akan belajar menggunakan sistem ini dengan sangat cepat.',
  'Saya merasa sistem ini sangat merepotkan untuk digunakan.',
  'Saya merasa sangat percaya diri menggunakan sistem ini.',
  'Saya perlu belajar banyak hal sebelum bisa menggunakan sistem ini.'
];

function buatFormSUS() {
  if (PENELITI.indexOf('[') > -1) throw new Error('Isi dulu PENELITI di bagian atas skrip.');

  var form = FormApp.create('Kuesioner Kemudahan Penggunaan Prototipe Guild Petualang');
  form.setDescription(
    'Diisi setelah mencoba prototipe Guild Petualang. Tidak ada jawaban benar atau salah; yang dinilai prototipenya, bukan kamu.\n\n' +
    'Jawaban hanya dipakai untuk tugas kuliah ' + PENELITI + ' dan dilaporkan tanpa nama.');
  form.setCollectEmail(false);
  form.setLimitOneResponsePerUser(false);
  form.setAllowResponseEdits(false);
  form.setConfirmationMessage('Terima kasih sudah mencoba prototipenya!');

  form.addCheckboxItem()
    .setTitle('Persetujuan')
    .setChoiceValues(['Saya bersedia jawaban ini dipakai untuk tugas kuliah tanpa menyebut nama saya.'])
    .setRequired(true);
  form.addTextItem()
    .setTitle('Kode peserta')
    .setHelpText('Isi dengan kode dari peneliti, misalnya P1. Jangan tulis nama.')
    .setRequired(true);

  PERNYATAAN_SUS.forEach(function (s, i) {
    form.addScaleItem()
      .setTitle((i + 1) + '. ' + s)
      .setBounds(1, 5)
      .setLabels('Sangat tidak setuju', 'Sangat setuju')
      .setRequired(true);
  });

  var ss = SpreadsheetApp.create('Jawaban SUS Guild Petualang');
  form.setDestination(FormApp.DestinationType.SPREADSHEET, ss.getId());

  var props = PropertiesService.getScriptProperties();
  props.setProperty('FORM_SUS_ID', form.getId());
  props.setProperty('SHEET_SUS_ID', ss.getId());

  Logger.log('LINK ISIAN (bagikan ke peserta): ' + form.getPublishedUrl());
  Logger.log('LINK EDIT: ' + form.getEditUrl());
  Logger.log('SPREADSHEET JAWABAN: ' + ss.getUrl());
}

function hitungSkorSUS() {
  var props = PropertiesService.getScriptProperties();
  var formId = props.getProperty('FORM_SUS_ID');
  var sheetId = props.getProperty('SHEET_SUS_ID');
  if (!formId || !sheetId) throw new Error('Jalankan buatFormSUS dulu dari proyek yang sama.');

  var form = FormApp.openById(formId);
  var ss = SpreadsheetApp.openById(sheetId);
  var sh = ss.getSheetByName('Skor SUS') || ss.insertSheet('Skor SUS');
  sh.clear();

  var baris = [['Kode peserta', 'Skor SUS (0–100)']];
  var total = 0, n = 0;

  form.getResponses().forEach(function (r) {
    var kode = '', nilai = [];
    r.getItemResponses().forEach(function (ir) {
      var tipe = ir.getItem().getType();
      if (tipe === FormApp.ItemType.TEXT) kode = ir.getResponse();
      else if (tipe === FormApp.ItemType.SCALE) nilai.push(Number(ir.getResponse()));
    });
    if (nilai.length !== 10) return;
    // Nomor ganjil: nilai − 1. Nomor genap: 5 − nilai. Jumlahnya × 2,5.
    var jumlah = 0;
    nilai.forEach(function (v, i) { jumlah += (i % 2 === 0) ? (v - 1) : (5 - v); });
    var skor = jumlah * 2.5;
    baris.push([kode, skor]);
    total += skor;
    n++;
  });

  baris.push(['Rata-rata', n ? total / n : '']);
  sh.getRange(1, 1, baris.length, 2).setValues(baris);
  Logger.log('Skor dihitung untuk ' + n + ' peserta. Lihat sheet "Skor SUS": ' + ss.getUrl());
}

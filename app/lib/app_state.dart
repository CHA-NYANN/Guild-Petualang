import 'package:flutter/foundation.dart';

import 'data/quests.dart';

/// Keadaan aplikasi untuk prototipe: belum ada server, semua di memori.
class AppState extends ChangeNotifier {
  int navIndex = 0; // 0 beranda, 1 papan, 2 profil
  bool registered = false;
  String name = '';
  String gender = 'f'; // wujud Terra: f atau m
  final List<String> taken = [];

  /// Quest yang dipasang pengguna, yang terbaru di depan.
  final List<Quest> posted = [];

  bool remoteTab = false;
  String category = 'Semua';
  bool onlyEligible = false;

  void goTo(int i) {
    navIndex = i;
    notifyListeners();
  }

  void setGender(String g) {
    gender = g;
    notifyListeners();
  }

  void register(String n) {
    registered = true;
    name = n.trim();
    notifyListeners();
  }

  void take(String id) {
    if (!taken.contains(id)) taken.add(id);
    notifyListeners();
  }

  void post(Quest q) {
    posted.insert(0, q);
    notifyListeners();
  }

  String nextPostedId() => 'u${posted.length + 1}';

  /// Dana yang sedang ditahan guild untuk permintaan pengguna.
  int get escrowTotal => posted.fold(0, (sum, q) => sum + q.reward);

  void setTab(bool remote) {
    remoteTab = remote;
    notifyListeners();
  }

  void setCategory(String c) {
    category = c;
    notifyListeners();
  }

  void toggleOnlyEligible() {
    onlyEligible = !onlyEligible;
    notifyListeners();
  }

  List<Quest> get allQuests => [...posted, ...quests];

  /// Quest yang sudah terbit di papan.
  List<Quest> get openQuests => allQuests.where((q) => !q.inReview).toList();

  Quest questById(String id) => allQuests.firstWhere((q) => q.id == id);

  List<Quest> visibleQuests() {
    return openQuests.where((q) {
      if (q.remote != remoteTab) return false;
      if (const {'Warga', 'UMKM', 'Pemerintah'}.contains(category) && q.giver != category) return false;
      if (category == 'Spesialis' && q.stat == null) return false;
      if (onlyEligible && !_canTake(q)) return false;
      return true;
    }).toList();
  }

  bool _canTake(Quest q) => !q.mine && checkQuest(q).ok;

  /// Quest di papan yang bisa diambil orang lain (tidak termasuk milikmu).
  int get takeableTotal => openQuests.where((q) => !q.mine).length;

  int get eligibleCount => openQuests.where(_canTake).length;
}

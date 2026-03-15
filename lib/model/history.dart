// ─── History Model ────────────────────────────────────────────
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QRHistoryItem {
  final String label;   // display title
  final String type;    // 'URL' | 'Text' | 'Contact'
  final String data;    // raw QR data
  final String createdAt;

  QRHistoryItem({
    required this.label,
    required this.type,
    required this.data,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() =>
      {'label': label, 'type': type, 'data': data, 'createdAt': createdAt};

  factory QRHistoryItem.fromJson(Map<String, dynamic> j) => QRHistoryItem(
        label: j['label'], type: j['type'],
        data: j['data'], createdAt: j['createdAt']);
}

// ─── History Store (singleton) ───────────────────────────────
class HistoryStore extends ChangeNotifier {
  static final HistoryStore _i = HistoryStore._();
  factory HistoryStore() => _i;
  HistoryStore._();

  List<QRHistoryItem> _items = [];
  List<QRHistoryItem> get items => List.unmodifiable(_items);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('qr_history') ?? [];
    _items = raw.map((s) => QRHistoryItem.fromJson(jsonDecode(s))).toList();
    notifyListeners();
  }

  Future<void> add(QRHistoryItem item) async {
    _items.insert(0, item);
    await _save();
    notifyListeners();
  }

  Future<void> remove(int index) async {
    _items.removeAt(index);
    await _save();
    notifyListeners();
  }

  Future<void> clear() async {
    _items.clear();
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'qr_history', _items.map((e) => jsonEncode(e.toJson())).toList());
  }
}
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'database_repository.dart';
import 'package:uuid/uuid.dart';
import 'package:simple_beautiful_checklist_exercise/src/features/task_list/models/checklist_item.dart';

// Repository-Implementierung mit SharedPreferences als Speicher.
// Idee: Daten dauerhaft sichern, ohne Datenbank, nur als JSON-String.
// Implementiert DatabaseRepository, also bleibt austauschbar (z. B. gegen SQLite).

class SharedPreferencesRepository implements DatabaseRepository {
  static const String _prefsKey = 'checklist_items_v1';
  // Schlüssel für gespeicherte Liste. "v1" für spätere Migration praktisch.

  static const String _createdCountKey = 'checklist_items_created_count'; // NEU
  // neu ggü. Grund Code: extra Key, um alle jemals erstellten Aufgaben mitzuzählen.

  static const _uuid = Uuid();
  // Hilfstool um eindeutige IDs zu generieren.
  // Änderung zum Grund Code: vorher gabs evtl. nur Text als Identifikation.

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();
  // Getter für die Instanz. Spart Schreibarbeit in allen Methoden.

  // ---------- intern: komplette Liste als Modelle laden/speichern ----------

  Future<List<ChecklistItem>> _loadAll() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return <ChecklistItem>[];
    final decoded = jsonDecode(raw);
    if (decoded is List) {
      return decoded
          .cast<Map>()
          .map((m) => ChecklistItem.fromJson(Map<String, dynamic>.from(m)))
          .toList();
    }
    return <ChecklistItem>[];
  }
  // Holt die komplette Liste raus, die als JSON gespeichert wurde.
  // Unterschied zum Grund Code: hier werden echte ChecklistItem-Objekte zurückgegeben,
  // nicht nur Strings. Damit haben wir IDs + Text verfügbar.

  Future<void> _saveAll(List<ChecklistItem> items) async {
    final prefs = await _prefs;
    final jsonStr = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_prefsKey, jsonStr);
  }
  // Speichert die Liste wieder ab – diesmal als JSON-Array von Maps.

  // ---------- Bonus: Gesamtzahl aller jemals erstellten Aufgaben -----------

  Future<int> getCreatedCount() async {
    final prefs = await _prefs;
    return prefs.getInt(_createdCountKey) ?? 0;
  }
  // NEU: liest die Gesamtanzahl aus, standardmäßig 0 wenn nix drin.

  Future<void> _incrementCreatedCount() async {
    final prefs = await _prefs;
    final current = prefs.getInt(_createdCountKey) ?? 0;
    await prefs.setInt(_createdCountKey, current + 1);
  }
  // NEU: interner Zähler hochschrauben, jedes Mal wenn was Neues erstellt wird.
  // Gab es im Grund Code noch nicht.

  // ---------- Zusatz-API: Arbeiten per ID ---------------------------------

  Future<List<ChecklistItem>> getItemsWithIds() => _loadAll();
  // Gibt alle Items inkl. ID zurück. Nicht nur Text.

  Future<String> addItemWithId(String text) async {
    final items = await _loadAll();
    final id = _uuid.v4();
    // neue eindeutige ID für jedes Item
    items.add(ChecklistItem(id: id, text: text));
    await _saveAll(items);

    // Bonus: Zähler hochzählen
    await _incrementCreatedCount();

    return id;
  }
  // NEU im Vergleich zum Grund Code: Items haben IDs und erhöhen den CreatedCounter.

  Future<void> editItemById(String id, String newText) async {
    final items = await _loadAll();
    final idx = items.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    items[idx] = items[idx].copyWith(text: newText);
    await _saveAll(items);
  }
  // Statt Index (wie im Grund Code) jetzt Bearbeitung gezielt über ID.
  // Stabiler, weil Reihenfolge egal ist.

  Future<void> deleteItemById(String id) async {
    final items = await _loadAll();
    items.removeWhere((e) => e.id == id);
    await _saveAll(items);
  }
  // Löschen über ID, gleiches Prinzip wie Bearbeiten.

  // ---------- Interface-API: kompatibel (Index-basiert) -------------------

  @override
  Future<int> getItemCount() async => (await _loadAll()).length;
  // Pflicht-Methode aus DatabaseRepository. Zählt einfach Liste.

  @override
  Future<List<String>> getItems() async =>
      (await _loadAll()).map((e) => e.text).toList();
  // liefert nur Texte zurück (für alte APIs, die noch ohne ID arbeiten).

  @override
  Future<void> addItem(String item) async {
    await addItemWithId(item); // delegiert an ID-Variante -> zählt mit
  }
  // NEU: statt Items direkt speichern -> leitet an die neue ID-Methode weiter,
  // so wird der Counter immer hochgezählt.

  @override
  Future<void> editItem(int index, String newItem) async {
    final items = await _loadAll();
    if (index < 0 || index >= items.length) return;
    final id = items[index].id;
    await editItemById(id, newItem);
  }
  // Index wird auf ID gemappt -> damit bleibt die alte API lauffähig.
  // Änderung zum Grund Code: intern wird trotzdem ID-basiert gearbeitet.

  @override
  Future<void> deleteItem(int index) async {
    final items = await _loadAll();
    if (index < 0 || index >= items.length) return;
    final id = items[index].id;
    await deleteItemById(id);
  }

  // Gleiches Prinzip wie beim Edit: alte Index-Methode bleibt, ruft ID-Methode auf.
}

// Kurzfazit zu den Änderungen ggü. simplen Grund Code (nur String-Liste):
// - Items haben IDs (Uuid) -> Bearbeitung und Löschen stabiler.
// - copyWith + fromJson/toJson für Models -> moderner Umgang mit Daten.
// - Extra Counter für "alle jemals erstellten Items" -> Statistik-Feature möglich.
// - API jetzt zweigleisig: moderne ID-basierte Methoden + alte Index-basiert für Kompatibilität.
// - SharedPreferences als JSON-String gespeichert -> flexibler als StringList.

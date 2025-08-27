class ChecklistItem {
  final String id;
  final String text;

  // Datenmodell für ein einzelnes Item.
  // id = eindeutige Kennung, text = Inhalt des Tasks.

  const ChecklistItem({required this.id, required this.text});
  // Konstruktor mit required Feldern – heißt: ohne id oder text gibt’s kein Objekt.
  // Gegenüber ganz einfachem "POJO"-Style jetzt immutable (final Felder + const Konstruktor).

  ChecklistItem copyWith({String? id, String? text}) =>
      ChecklistItem(id: id ?? this.id, text: text ?? this.text);
  // NEU ggü. absolutem Grund Code: copyWith.
  // Vorteil: ich kann einzelne Felder ändern, ohne das komplette Objekt neu aufzubauen.
  // Beispiel: nur den Text updaten, aber id behalten.

  factory ChecklistItem.fromJson(Map<String, dynamic> json) =>
      ChecklistItem(id: json['id'] as String, text: json['text'] as String);
  // NEU: Factory-Konstruktor für JSON.
  // Praktisch, wenn die Items von ner API oder aus lokalem Speicher kommen.
  // Konvertiert Map -> Objekt. as String sorgt dafür, dass die Typen stimmen.

  Map<String, dynamic> toJson() => {'id': id, 'text': text};
  // Rückweg von Objekt -> JSON.
  // Damit krieg ich die Daten z. B. in SharedPrefs, Files oder ne Datenbank rein.
}

// Fazit zu Änderungen ggü. wirklich nacktem Grund Code (nur Felder + Konstruktor):
// - copyWith: elegantes Update von immutable Objekten.
// - fromJson + toJson: macht das Model speicher- und netzwerktauglich.
// - final Felder + const Konstruktor: sorgt für sauberes, unveränderbares Datenmodell.

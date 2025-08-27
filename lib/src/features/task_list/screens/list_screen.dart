import 'package:flutter/material.dart';
import 'package:simple_beautiful_checklist_exercise/data/database_repository.dart';
import 'package:simple_beautiful_checklist_exercise/src/features/task_list/widgets/empty_content.dart';
import 'package:simple_beautiful_checklist_exercise/src/features/task_list/widgets/item_list.dart';

// Ziel von dem Screen: simple Checkliste anzeigen, Items aus Repository laden, neue Items anlegen.
// Wichtig: Nichts am Code ändern – nur Gedankenstützen als Kommentare.

class ListScreen extends StatefulWidget {
  const ListScreen({
    super.key,
    required this.repository,
  });

  final DatabaseRepository repository;
  // kommt von außen rein – so bleibt der Screen schön testbar.
  // Im "Grund Code" war das genauso (Dependency-Injection über den Konstruktor).

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final List<String> _items = [];
  // lokale Kopie der Items, die wir vom Repository holen.

  bool isLoading = true;
  // NEU ggü. ganz einfachem Grundgerüst: eigener Loading-State.
  // Idee: Erst Spinner zeigen, dann Liste. Verhindert flackerndes UI.

  final TextEditingController _controller = TextEditingController();
  // Controller fürs Textfeld unten. So komme ich an den Inhalt ran und kann ihn danach leeren.

  @override
  void initState() {
    super.initState();
    _updateList();
    // direkt beim Start Daten reinziehen. Klassisch.
  }

  @override
  void dispose() {
    _controller.dispose();
    // wichtig: Controller wegräumen, sonst meckert Flutter (Memory-Leak).
    super.dispose();
  }

  Future<void> _updateList() async {
    // während des Ladens optional Spinner zeigen
    if (mounted) {
      setState(() => isLoading = true);
      // NEU: vor dem Fetch auf "busy" gehen. Sieht einfach sauberer aus.
    }
    final loaded = await widget.repository.getItems();
    // Daten aus der Quelle holen. Wenn das async ist, bitte immer auf mounted achten.

    if (!mounted) return;
    // falls der Screen inzwischen weg ist: hier hart raus, kein setState mehr.

    setState(() {
      _items
        ..clear()
        ..addAll(loaded);
      // lokale Liste aktuell halten. Clear + AddAll statt neue Referenz,
      // damit Widgets, die _items referenzieren, nicht kaputt gehen.

      isLoading = false;
      // fertig mit Laden -> UI darf rendern.
    });
  }

  Future<void> _handleAdd(String value) async {
    final title = value.trim();
    if (title.isEmpty) return;
    // kein Quatsch abspeichern

    // WICHTIG: warten bis persistiert, sonst lesen wir direkt wieder die alte Liste
    await widget.repository.addItem(title);
    // NEU im Vergleich zur ganz simplen Variante: wirklich auf den Persist-Call warten.

    _controller.clear();
    // UI zurücksetzen, damit der User direkt weiter tippen kann.

    await _updateList();
    // danach neu ziehen, damit wir auf dem Stand sind, den das Repo zurückgibt.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meine Checkliste'),
        centerTitle: true,
        // Standard-AppBar, nichts Wildes. Title fest verdrahtet – reicht hier.
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          // NEU: Loading-UI. Vorher hätte man evtl. direkt die Liste gezeigt und sie war kurz leer.
          : Column(
              children: [
                Expanded(
                  child: _items.isEmpty
                      ? const EmptyContent()
                      // Wenn nix da ist: eigenes leeres Widget.
                      // "EmptyContent" ist ein ausgelagertes UI-Teil – nice für Konsistenz.
                      : ItemList(
                          repository: widget.repository,
                          items: _items,
                          updateOnChange: _updateList, // bleibt wie gehabt
                          // Merke: ItemList kümmert sich intern um Änderungen (z. B. Löschen/Toggle)
                          // und ruft danach _updateList() auf, damit der Screen frisch bleibt.
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(40.0),

                  // relativ viel Padding -> Eingabefeld bekommt Luft, wirkt ruhiger.
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Task Hinzufügen',

                      // Klarer Call-to-Action als Label.
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () async {
                          await _handleAdd(_controller.text);
                          // Shortcut: Klick aufs Plus fügt das ein, was gerade im Feld steht.
                          // NEU ggü. ultraminimal: expliziter async-Flow, damit nix ruckelt.
                        },
                      ),
                    ),
                    onSubmitted: (value) async {
                      await _handleAdd(value);
                      // Enter-Taste triggert denselben Flow wie das Plus. Einheitlich.
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

// Kurzfazit zu den Änderungen ggü. Grund Code (nur als Erinnerung):
// - isLoading-State eingeführt + CircularProgressIndicator: sauberes Ladeverhalten.
// - mounted-Checks vor setState nach await: verhindert Crashes, wenn Screen unmounted ist.
// - _handleAdd wartet auf repository.addItem und ruft danach _updateList: keine Race Conditions.
// - _controller.dispose im dispose(): Hygienefaktor.
// - ItemList bekommt updateOnChange: zentraler Refresh-Mechanismus bleibt stabil.
// - EmptyContent für leeres State-Design: keine nackte "leere Liste", wirkt gepflegter.

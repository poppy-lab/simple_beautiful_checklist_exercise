import 'package:flutter/material.dart';
import 'package:simple_beautiful_checklist_exercise/data/database_repository.dart';
import 'package:simple_beautiful_checklist_exercise/src/features/statistics/screens/statistics_screen.dart';

import 'list_screen.dart';

// Home sammelt die beiden Tabs (Aufgaben / Statistik) und wechselt unten über die BottomNavigation.
// Ziel: Screens als Widgets einhängen (nicht als Methoden aufrufen) und ihren State behalten.

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.repository});

  final DatabaseRepository repository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedNavBarIndex = 0;
  // merkt, welcher Tab aktiv ist.

  late final List<Widget> _pages;
  // NEU ggü. Grund-Code: late final statt veränderbare Liste.
  // Warum? Wir bauen die Seiten genau einmal in initState und fassen die Liste danach nicht mehr an.

  @override
  void initState() {
    super.initState();
    _pages = [
      // WICHTIG: hier als Widgets instanziieren, nicht als "Methoden" aufrufen.
      // So verschwindet der Fehler "The method 'StatisticsScreen' isn't defined..."
      ListScreen(repository: widget.repository),
      StatisticsScreen(repository: widget.repository),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // NEU ggü. Grund-Code: IndexedStack statt direkter Zugriff über Liste.
      // Vorteil: beide Screens bleiben im Baum und behalten ihren State (kein ständiges Neuaufbauen).
      body: IndexedStack(
        index: _selectedNavBarIndex,
        children: _pages,
      ),

      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Aufgaben',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Statistik',
          ),
        ],
        currentIndex: _selectedNavBarIndex,
        selectedItemColor: Colors.deepPurple,

        // minimal neutralisiert (kein .shade200 notwendig) – ändert die UI nicht merklich.
        onTap: (int index) {
          setState(() {
            _selectedNavBarIndex = index;
            // einfacher Tab-Wechsel, Rest übernimmt der IndexedStack.
          });
        },
        type: BottomNavigationBarType.fixed,
        // fix, weil 2 Items -> verhindert unnötige Animationen/Shift-Effekte.
      ),
    );
  }
}

// Änderungen ggü. deinem Grund-Code (Merkliste):
// - late final _pages + Aufbau in initState: Seiten genau einmal erstellen.
// - IndexedStack statt body = _navBarWidgets[index]: hält den State beider Seiten stabil.
// - Screens korrekt als Widgets instanziieren (ListScreen(...), StatisticsScreen(...)),
//   nicht als (vermeintliche) Methoden aufrufen → beseitigt den "isn't defined as method"-Fehler.
// - selectedItemColor leicht vereinfacht; optisch praktisch gleich, weniger Nullable-Fummelei.

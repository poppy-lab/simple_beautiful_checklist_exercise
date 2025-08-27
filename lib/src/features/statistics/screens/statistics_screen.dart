import 'package:flutter/material.dart';
import 'package:simple_beautiful_checklist_exercise/data/database_repository.dart';
import 'package:simple_beautiful_checklist_exercise/data/shared_preferences_repository.dart';
import 'package:simple_beautiful_checklist_exercise/src/features/statistics/widgets/task_counter_card.dart';

// Dit hier is der Statistik-Screen.
// Zeigt mir zwei Sachen: wie viele offen sind und wie viele jemals erstellt wurden,
// och wenn se schon wieda wech sind. So hab ick beides uffm Schirm.

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key, required this.repository});

  final DatabaseRepository repository;
  // kricht das Repo reingereicht. Kann man also auch mal’n anderes Repo ranschrauben.

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int currentTaskCount = 0;
  // aktuell offene Aufgaben – also dit was noch ansteht
  int totalCreatedCount = 0;
  // alles was jemals angelegt wurde, och wenn später gelöscht

  void loadCounts() async {
    final taskCount = await widget.repository.getItemCount();
    // holt Anzahl der offenen Aufgaben über Repo
    // (Änderung zum Grund Code: statt komplette Liste zu laden, reicht jetzt ne Zahl)

    int createdCount = 0;
    if (widget.repository is SharedPreferencesRepository) {
      // extra Feature nur im SharedPrefsRepo:
      // kann mir auch sagen, wie viele jemals erstellt wurden
      createdCount = await (widget.repository as SharedPreferencesRepository)
          .getCreatedCount();
    }

    if (taskCount != currentTaskCount || createdCount != totalCreatedCount) {
      // nur wenn sich wat ändert, dann setState -> vermeidet nerviges Geflacker
      setState(() {
        currentTaskCount = taskCount;
        totalCreatedCount = createdCount;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    loadCounts();
    // Ja, ick weiß, im build normalerweise nicht so’n Ding.
    // Hier aber okay, weil wir oben prüfen, ob sich was verändert hat. Sonst jibt keene neue Rebuilds.

    final textStyle = Theme.of(context).textTheme.titleMedium;
    // Style aus Theme holen, sieht dann nich aus wie’n Fremdkörper.

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task-Statistik'),
        centerTitle: true,
      ),

      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 60),

            // bissel Luft nach oben, sonst klebt dit alles am AppBar
            Text('Aktuelle Aufgaben', style: textStyle),
            const SizedBox(height: 12),
            TaskCounterCard(taskCount: currentTaskCount),

            // erste Card: zeigt mir wat grad offen is
            const SizedBox(height: 28),

            Text('Erstellte Aufgaben insgesamt', style: textStyle),
            const SizedBox(height: 12),
            TaskCounterCard(
              taskCount: totalCreatedCount,
              label: 'Anzahl aller Tasks (auch bereits gelöschte)',
              // NEU ggü. Grund Code: label is frei gesetzt.
              // Damit is klar, dat hier nich nur offene gezählt werden.
            ),
          ],
        ),
      ),
    );
  }
}

// Änderungen zum Grund Code (nur als Merker):
// - loadCounts() holt Zahlen direkt statt komplette Listen.
// - totalCreatedCount is extra Feld, kommt aus SharedPreferencesRepo mit getCreatedCount().
// - TaskCounterCard hat jetzt label, kann man für zweite Anzeige frei beschriften.
// - kleine UI-Politur (Abstände, Styles aus Theme), sonst alles schlicht.
// Fazit: Screen bleibt easy, zeigt aber zwei verschiedene Kennzahlen – und wirkt stimmiger.

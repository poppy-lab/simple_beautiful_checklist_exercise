import 'dart:ui' as ui;
import 'package:flutter/material.dart';

// Card zeigt Zahl + Label. Optik etwas getuned damit’s ruhiger wirkt.
// Wichtig: keine Logik, nur Darstellung.

class TaskCounterCard extends StatelessWidget {
  final int taskCount;
  // Zahl kommt von außen -> flexibel einsetzbar

  final String label;
  // NEU ggü. Grund Code: Label ist nicht mehr fest verdrahtet,
  // sondern frei von außen übergebbar. Default bleibt: "Anzahl der offenen Tasks".

  const TaskCounterCard({
    super.key,
    required this.taskCount,
    this.label = 'Anzahl der offenen Tasks',
  });

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).textTheme;
    // Basistypo vom Theme holen – sorgt für konsistenten Look zur restlichen App.

    final labelStyle = base.titleMedium?.copyWith(
      fontSize: 18,
      height: 1.15,
      letterSpacing: 0.1,
    );
    // Label minimal feingetuned: etwas dichtere Zeilenhöhe und leichtes LetterSpacing.
    // Ändert die UI kaum, macht aber den Text „ruhiger“.

    final numberStyle = const TextStyle(
      fontSize: 30,
      // kleiner als früher (vorher 36), passt besser in den Kreis
      fontWeight: FontWeight.w700,
      // kräftig aber nicht übertrieben bold
      color: Colors.white,
      height: 1.0,
      // sorgt dafür, dass die Zahl optisch mittig steht
      fontFeatures: [ui.FontFeature.tabularFigures()],
      // NEU: tabularFigures -> alle Ziffern gleich breit
      // Vorteil: wenn die Zahl springt (9 -> 10 -> 11), bleibt sie stabil, nix wackelt.
      shadows: [
        Shadow(blurRadius: 3, color: Colors.black26, offset: Offset(1, 1)),
      ],
      // NEU: dezenter Shadow -> Zahl hebt sich besser vom lila Kreis ab.
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      // außenrum Luft, damit die Card nicht am Rand klebt.
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),

        // abgerundete Ecken -> moderner Look
        color: const Color.fromARGB(26, 222, 103, 255),

        // halbtransparentes Lila als Hintergrund – gleiche Farbe wie vorher
        elevation: 5,

        // Schatten, damit die Card ein bisschen schwebt
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          // innen Luft, damit Inhalt nicht gequetscht ist
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _NumberBadge(
                value: taskCount,
                textStyle: numberStyle,
                diameter: 48,
                // NEU: Badge hat jetzt feste Größe statt Padding
                // -> Zahl wirkt immer gleichmäßig zentriert, egal ob 1 oder 10.
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: labelStyle,
                  softWrap: true,
                  maxLines: 2,
                  // max. 2 Zeilen -> wenn Label mal länger ist, bricht es sauber um
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumberBadge extends StatelessWidget {
  final int value;
  final TextStyle textStyle;
  final double diameter;

  const _NumberBadge({
    required this.value,
    required this.textStyle,
    this.diameter = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Colors.purple,
        shape: BoxShape.circle,
      ),
      // fester Kreis in Lila, immer gleich groß
      child: Text(
        '$value',
        style: textStyle,
        textAlign: TextAlign.center,
      ),
      // Zahl mittig im Kreis, Stil kommt von oben
    );
  }
}

// Änderungen ggü. altem Grund Code (nur Zahl + Text in Card):
// - Label jetzt Parameter (nicht mehr fest im Widget).
// - numberStyle: mit tabularFigures + Shadow + kleinere Schriftgröße.
// - _NumberBadge mit fixer Größe statt Padding -> Kreise wirken immer gleichmäßig.
// - labelStyle mit minimalem Feintuning (Zeilenhöhe, Spacing).
// Ergebnis: gleiche UI wie vorher, aber viel gleichmäßiger und lesbarer.

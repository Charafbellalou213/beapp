import 'package:flutter/material.dart';

class SdgImpactScreen extends StatelessWidget {
  const SdgImpactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('SDG 8.9')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.public, color: colorScheme.onPrimaryContainer),
                    const SizedBox(width: 8),
                    Text(
                      'SDG 8 — Decent Work and Economic Growth',
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Target 8.9: "By 2030, devise and implement policies to promote '
                  'sustainable tourism that creates jobs and promotes local culture '
                  'and products."',
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'sdgs.un.org/goals/goal8',
                  style: TextStyle(color: colorScheme.onPrimaryContainer, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const _ImpactSection(
            icon: Icons.directions_walk,
            title: 'Perché camminare è più sostenibile',
            body:
                'Ogni percorso in Beapp si fa a piedi: niente bus turistici, niente '
                'emissioni per spostarsi tra le tappe. Camminare rallenta il turismo, '
                'lo rende più consapevole e riduce l\'impatto ambientale della visita.',
          ),
          _ImpactSection(
            icon: Icons.museum_outlined,
            title: 'Come Beapp valorizza cultura e prodotti locali',
            body:
                'Ogni luogo racconta la sua storia (categoria Storia, Cultura, Arte, '
                'Prodotti locali...) invece di essere solo un punto su una mappa. I '
                'punti assegnati premiano chi si ferma davvero a scoprire un posto, '
                'non solo chi lo attraversa.',
            iconColor: colorScheme.tertiary,
          ),
          _ImpactSection(
            icon: Icons.storefront_outlined,
            title: 'Come Beapp supporta ristoranti, chioschi e botteghe',
            body:
                'La schermata Ristoranti collega ogni percorso a locali tipici reali '
                'di Padova — non catene. Segnare "Ho mangiato qui" e vedere il legame '
                'tra piatto e cultura locale trasforma una passeggiata in un piccolo '
                'sostegno concreto all\'economia del territorio.',
            iconColor: colorScheme.secondary,
          ),
          const _ImpactSection(
            icon: Icons.emoji_events_outlined,
            title: 'Perché la gamification',
            body:
                'Punti, badge e percorsi brevi/medi/lunghi non sono solo un gioco: '
                'motivano a visitare più luoghi tipici e più locali, aumentando in '
                'modo naturale l\'impatto positivo di ogni visita a Padova.',
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _ImpactSection extends StatelessWidget {
  const _ImpactSection({
    required this.icon,
    required this.title,
    required this.body,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String body;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor ?? Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(body, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

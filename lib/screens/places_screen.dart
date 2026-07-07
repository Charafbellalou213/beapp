import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/place.dart';
import '../providers/app_state.dart';
import '../widgets/place_card.dart';
import 'place_detail_screen.dart';

class PlacesScreen extends StatefulWidget {
  const PlacesScreen({super.key});

  @override
  State<PlacesScreen> createState() => _PlacesScreenState();
}

class _PlacesScreenState extends State<PlacesScreen> {
  PlaceCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final places = _selectedCategory == null
        ? appState.places
        : appState.places.where((place) => place.category == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Luoghi')),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: const Text('Tutti'),
                    selected: _selectedCategory == null,
                    onSelected: (_) => setState(() => _selectedCategory = null),
                  ),
                ),
                ...PlaceCategory.values.map(
                  (category) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(placeCategoryLabel(category)),
                      selected: _selectedCategory == category,
                      onSelected: (_) => setState(() => _selectedCategory = category),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: appState.isLoadingData
                ? const Center(child: CircularProgressIndicator())
                : places.isEmpty
                    ? const Center(child: Text('Nessun luogo in questa categoria'))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        itemCount: places.length,
                        itemBuilder: (context, index) {
                          final place = places[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: PlaceCard(
                              place: place,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => PlaceDetailScreen(place: place),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

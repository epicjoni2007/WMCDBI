import 'package:flutter/material.dart';
import 'pets_page.dart';
import 'visits_page.dart';

class PetsVisitsPage extends StatelessWidget {
  const PetsVisitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(tabs: [Tab(text: 'Pets'), Tab(text: 'Termine')]),
          Expanded(
            child: TabBarView(children: [PetsPage(), VisitsPage()]),
          ),
        ],
      ),
    );
  }
}

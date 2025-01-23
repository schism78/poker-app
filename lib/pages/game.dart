import 'package:flutter/material.dart';

class Game extends StatefulWidget {
  const Game({super.key});

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.index = 0;
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final int numberOfPlayers = args['numberOfPlayers'];
    final List<String> playerNames = args['playerNames'];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: SafeArea(
          child: AppBar(
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: 'Ставки'),
                Tab(text: 'Таблица'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Center(child: Text('Количество игроков: $numberOfPlayers')),
          Center(child: Text('Имена игроков: ${playerNames}')),
        ],
      ),
    );
  }
}

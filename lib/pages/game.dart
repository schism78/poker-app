import 'package:flutter/material.dart';
import 'package:app/services/database_helper.dart'; // Убедитесь, что правильно импортируете файл с базой данных

class Game extends StatefulWidget {
  const Game({super.key});

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late int numberOfPlayers;
  late int maxCards;
  late List<String> playerNames;
  late List<String> roundList;

  // Метод для создания списка раундов
  List<String> createRoundList(int numberOfPlayers, int maxCards) {
    List<String> roundList = [];

    // Добавляем карты по возрастанию
    for (int i = 0; i < maxCards - 1; i++) {
      roundList.add((i + 1).toString());
    }

    // Добавляем максимальную карту для каждого игрока
    for (int i = 0; i < numberOfPlayers; i++) {
      roundList.add(maxCards.toString());
    }

    // Добавляем карты по убыванию
    for (int i = maxCards - 1; i > 0; i--) {
      roundList.add(i.toString());
    }

    for (int i = 0; i < numberOfPlayers; i++) {
      roundList.add("Б");
    }

    for (int i = 0; i < numberOfPlayers; i++) {
      roundList.add("З");
    }

    for (int i = 0; i < numberOfPlayers; i++) {
      roundList.add("Т");
    }

    return roundList;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.index = 0;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Получаем данные из аргументов маршрута
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      numberOfPlayers = args['numberOfPlayers'] ??
          0; // Устанавливаем значение по умолчанию на 0
      playerNames = List<String>.from(args['playerNames'] ??
          []); // Устанавливаем пустой список, если playerNames не переданы

      // Рассчитываем максимальное количество карт
      maxCards = 36 ~/
          numberOfPlayers; // Используем целочисленное деление (например, 36 / 3 = 12)

      // Создаем список раундов
      roundList = createRoundList(numberOfPlayers, maxCards);

      // Создаем игру в базе данных после получения данных
      _createGame();
    } else {
      // Если аргументы не переданы, можно обработать эту ошибку или использовать значения по умолчанию
      numberOfPlayers = 0;
      playerNames = [];
      maxCards = 0;
      roundList = [];
    }
  }

  // Метод для вставки новой игры в базу данных
  Future<void> _createGame() async {
    final dbHelper = DatabaseHelper();
    await dbHelper.insertGame(numberOfPlayers);
  }

  @override
  Widget build(BuildContext context) {
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
          Center(child: Text('Имена игроков: ${roundList.join(", ")}')),
        ],
      ),
    );
  }
}

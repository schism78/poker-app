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

  // Переменная для хранения текущего раунда
  int currentRound = 0;

  // Список для хранения выбранных заказанных взяток для каждого игрока
  late List<int> orderedTakes;

  // Список для хранения типа ставки (Темная или Обычная)
  late List<String> orderedTakesType;

  // Список для хранения реальных взяток, которые игроки действительно взяли
  late List<int> actualTakes;

  // Флаг для первого запуска
  bool isFirstRun = true;

  // Флаг для принятия ставок
  bool betsAccepted = false;

  // Сообщение об ошибке
  String errorMessage = '';

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

    if (isFirstRun) {
      // Получаем данные из аргументов маршрута
      final Map<String, dynamic>? args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (args != null) {
        numberOfPlayers = args['numberOfPlayers'] ?? 0;
        playerNames = List<String>.from(args['playerNames'] ?? []);
        maxCards = 36 ~/ numberOfPlayers; // Используем целочисленное деление
        roundList = createRoundList(numberOfPlayers, maxCards);

        // Инициализируем список взяток для каждого игрока (по умолчанию 0)
        orderedTakes = List<int>.filled(numberOfPlayers, 0);

        // Инициализируем список типов ставок (по умолчанию "Обычная")
        orderedTakesType = List<String>.filled(numberOfPlayers, "Обычная");

        // Инициализируем список реальных взяток (по умолчанию 0)
        actualTakes = List<int>.filled(numberOfPlayers, 0);

        // Создаем игру в базе данных после получения данных
        _createGame();
      } else {
        numberOfPlayers = 0;
        playerNames = [];
        maxCards = 0;
        roundList = [];
        orderedTakes = [];
        orderedTakesType = [];
        actualTakes = [];
      }

      isFirstRun = false;
    }
  }

  // Метод для вставки новой игры в базу данных
  Future<void> _createGame() async {
    final dbHelper = DatabaseHelper();
    await dbHelper.insertGame(numberOfPlayers);
  }

  // Метод для увеличения текущего раунда и сброса ставок
  void _nextRound() {
    if (currentRound < roundList.length - 1) {
      setState(() {
        currentRound++;
        // После перехода к следующему раунду сбрасываем ставки на 0
        orderedTakes = List<int>.filled(numberOfPlayers, 0);
        // Сброс типа ставки на "Обычная"
        orderedTakesType = List<String>.filled(numberOfPlayers, "Обычная");
        actualTakes =
            List<int>.filled(numberOfPlayers, 0); // Сбрасываем реальные взятки
        betsAccepted =
            false; // После раунда нужно снова сбросить флаг принятия ставок
        errorMessage = ''; // Очищаем сообщение об ошибке
      });
    }
  }

  // Метод для создания списка значений для Dropdown в зависимости от типа раунда
  List<int> _generateDropdownItems(String roundValue) {
    if (roundValue == "Т" || roundValue == "З" || roundValue == "Б") {
      return List.generate(maxCards + 1, (index) => index); // От 0 до maxCards
    } else {
      int roundInt = int.tryParse(roundValue) ?? 0;
      return List.generate(
          roundInt + 1, (index) => index); // От 0 до roundValue
    }
  }

  // Метод для создания списка типов ставок
  List<String> _generateTakeTypeOptions() {
    return ["Обычная", "Темная"];
  }

  // Метод для принятия ставок с валидацией
  void _acceptBets() {
    // Получаем тип раунда
    String roundValue = roundList[currentRound];

    int totalOrderedTakes = orderedTakes.fold(0, (sum, take) => sum + take);
    int compareValue = 0;

    // Если тип раунда - это число
    if (int.tryParse(roundValue) != null) {
      compareValue = int.tryParse(roundValue) ?? 0;
    } else if (roundValue == "Т" || roundValue == "З" || roundValue == "Б") {
      compareValue = maxCards;
    }

    // Сравниваем сумму заказанных взяток с соответствующим значением
    if (totalOrderedTakes == compareValue) {
      setState(() {
        errorMessage =
            'Сумма заказанных взяток не может быть равной $compareValue!';
      });
    } else {
      setState(() {
        betsAccepted = true;
        errorMessage = ''; // Сброс ошибки при успешной валидации
      });
    }
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
          // Вкладка "Ставки"
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Вывод типа текущего раунда
                Text(
                  'Тип раунда: ${roundList[currentRound]}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                // Список ставок
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: numberOfPlayers,
                  itemBuilder: (context, index) {
                    String roundValue = roundList[currentRound];
                    List<int> availableChoices =
                        _generateDropdownItems(roundValue);

                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Имя игрока
                          Text(playerNames[index]),
                          // Дропдаун для выбора количества взяток
                          DropdownButton<int>(
                            value: orderedTakes[
                                index], // отображение выбранного значения
                            items: availableChoices
                                .map((value) => DropdownMenuItem<int>(
                                      value: value,
                                      child: Text(value.toString()),
                                    ))
                                .toList(),
                            onChanged: betsAccepted
                                ? null // Если ставки приняты, не меняем
                                : (newValue) {
                                    setState(() {
                                      orderedTakes[index] = newValue!;
                                    });
                                  },
                          ),
                          // Дропдаун для выбора типа ставки
                          DropdownButton<String>(
                            value: orderedTakesType[
                                index], // отображение выбранного типа ставки
                            items: _generateTakeTypeOptions()
                                .map((type) => DropdownMenuItem<String>(
                                      value: type,
                                      child: Text(type),
                                    ))
                                .toList(),
                            onChanged: betsAccepted
                                ? null // Если ставки приняты, не меняем
                                : (newValue) {
                                    setState(() {
                                      orderedTakesType[index] = newValue!;
                                    });
                                  },
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(height: 16),
                // Вывод сообщения об ошибке
                if (errorMessage.isNotEmpty)
                  Text(
                    errorMessage,
                    style: TextStyle(color: Colors.red),
                  ),
                SizedBox(height: 16),
                // Кнопка "Принять ставки"
                ElevatedButton(
                  onPressed: _acceptBets,
                  child: Text('Принять ставки'),
                ),
                SizedBox(height: 16),

                // Если ставки приняты, показываем новый список для выбора реальных взяток
                if (betsAccepted) ...[
                  // Список для выбора реальных взяток
                  Text("Реальные взятки игроков:"),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: numberOfPlayers,
                    itemBuilder: (context, index) {
                      String roundValue = roundList[currentRound];
                      List<int> availableChoices =
                          _generateDropdownItems(roundValue);

                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Имя игрока
                            Text(playerNames[index]),
                            // Дропдаун для выбора реального количества взяток
                            DropdownButton<int>(
                              value: actualTakes[
                                  index], // отображение выбранного значения
                              items: availableChoices
                                  .map((value) => DropdownMenuItem<int>(
                                        value: value,
                                        child: Text(value.toString()),
                                      ))
                                  .toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  actualTakes[index] = newValue!;
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  // Кнопка "Перейти к следующему раунду"
                  ElevatedButton(
                    onPressed: _nextRound,
                    child: Text('Перейти к следующему раунду'),
                  ),
                ],
              ],
            ),
          ),
          // Вкладка "Таблица"
          Center(child: Text('Имена игроков: ${playerNames.join(", ")}')),
        ],
      ),
    );
  }
}

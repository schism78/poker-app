import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _numberOfPlayers = 3;
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.index = 0;
    _controllers =
        List.generate(_numberOfPlayers, (index) => TextEditingController());
  }

  bool _checkIfAllFieldsAreFilled() {
    for (TextEditingController controller in _controllers) {
      if (controller.text.isEmpty) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('Покер'),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'История'),
            Tab(text: 'Создать'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Center(
            child: Text('Содержимое для Истории'),
          ),
          ListView(
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Количество игроков (3-8):'),
                    DropdownButton<int>(
                      value: _numberOfPlayers,
                      items: List.generate(8 - 3 + 1, (index) => index + 3)
                          .map((value) => DropdownMenuItem<int>(
                                value: value,
                                child: Text(value.toString()),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _numberOfPlayers = value!;
                          _controllers = List.generate(_numberOfPlayers,
                              (index) => TextEditingController());
                        });
                      },
                    ),
                    SizedBox(height: 16.0),
                    Text('Имена игроков:'),
                    Column(
                      children: List.generate(_numberOfPlayers, (index) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: TextField(
                            controller: _controllers[index],
                            decoration: InputDecoration(
                              labelText: 'Игрок ${index + 1}',
                            ),
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 16.0),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_checkIfAllFieldsAreFilled()) {
                            // Обработка, если все поля заполнены
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Заполните все поля!'),
                              ),
                            );
                          }
                        },
                        child: Text('Начать'),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

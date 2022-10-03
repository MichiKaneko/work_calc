import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:work_calc/user.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: '稼働時間計測ツール'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<User> users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future _loadUsers() async {
    final pref = await SharedPreferences.getInstance();
    List<String> userNameList = pref.getStringList('users') ?? [];
    List<String> workingDaysList = pref.getStringList('workingDays') ?? [];
    List<String> workingHoursList = pref.getStringList('workingHours') ?? [];

    setState(() {
      users = [];
      for (int i = 0; i < userNameList.length; i++) {
        users.add(User(
          name: userNameList[i],
          workingDays: double.parse(workingDaysList[i]),
          workingHours: double.parse(workingHoursList[i]),
        ));
      }
    });
  }

  Future _saveUsers() async {
    final pref = await SharedPreferences.getInstance();
    List<String> userNameList = [];
    List<String> workingDaysList = [];
    List<String> workingHoursList = [];
    for (var element in users) {
      userNameList.add(element.name);
      workingDaysList.add(element.workingDays.toString());
      workingHoursList.add(element.workingHours.toString());
    }
    pref.setStringList('users', userNameList);
    pref.setStringList('workingDays', workingDaysList);
    pref.setStringList('workingHours', workingHoursList);
  }

  String userName = '';
  TextEditingController userNameController = TextEditingController();

  void _addUser() {
    userName = userNameController.text;
    setState(() {
      User user = User(name: userName, workingDays: 5, workingHours: 5.5);
      users.add(user);
      userName = '';
      userNameController.clear();
    });
    _saveUsers();
  }

  void _setWorkingDays(int index, double value) {
    setState(() {
      users[index].workingDays = value;
    });
    _saveUsers();
  }

  void _setWorkingHours(int index, double value) {
    setState(() {
      users[index].workingHours = value;
    });
    _saveUsers();
  }

  void _removeUser(int index) {
    setState(() {
      users.removeAt(index);
    });
    _saveUsers();
  }

  bool isEmpty() {
    return userName.isEmpty;
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
  }

  String _calcWorkingHours() {
    double totalWorkingHours = 0;
    for (User user in users) {
      totalWorkingHours += user.workingDays * user.workingHours;
    }
    return totalWorkingHours.toString();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SelectableText(
                      _calcWorkingHours(),
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Text('時間'),
                    IconButton(
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: _calcWorkingHours()));
                      },
                      icon: const Icon(
                        Icons.copy,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                '今週の稼働メンバー・稼働日数・稼働時間を入力してください',
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      SizedBox(
                        width: size.width * 0.15,
                        height: 30,
                        child: const Text(
                          'メンバー名',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                        width: size.width * 0.25,
                        height: 30,
                        child: const Text(
                          '稼働日数',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                        width: size.width * 0.25,
                        height: 30,
                        child: const Text(
                          '稼働時間',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(
                        width: 50,
                        height: 30,
                        child: Text(
                          '削除',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ]),
                    for (int i = 0; i < users.length; i++)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: size.width * 0.15,
                            height: 50,
                            child: Text(
                              users[i].name,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(
                            width: size.width * 0.25,
                            height: 70,
                            child: Column(
                              children: [
                                Text(
                                  users[i].workingDays.toString(),
                                  textAlign: TextAlign.center,
                                ),
                                Slider(
                                  value: users[i].workingDays,
                                  min: 0,
                                  max: 7,
                                  divisions: 14,
                                  label: users[i].workingDays.toString(),
                                  onChanged: (double value) {
                                    _setWorkingDays(i, value);
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: size.width * 0.25,
                            height: 70,
                            child: Column(
                              children: [
                                Text(
                                  users[i].workingHours.toString(),
                                  textAlign: TextAlign.center,
                                ),
                                Slider(
                                  value: users[i].workingHours,
                                  min: 0,
                                  max: 8,
                                  divisions: 16,
                                  label: users[i].workingHours.toString(),
                                  onChanged: (double value) {
                                    _setWorkingHours(i, value);
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 50,
                            height: 70,
                            child: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                _removeUser(i);
                              },
                            ),
                          ),
                        ],
                      )
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    child: TextFormField(
                      decoration: const InputDecoration(
                        hintText: 'メンバー名を入力',
                      ),
                      controller: userNameController,
                      maxLength: 20,
                      onEditingComplete: () => _addUser(),
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  ElevatedButton(
                    onPressed: userNameController.text.isEmpty
                        ? null
                        : () => _addUser(),
                    child: const Text('追加'),
                  ),
                ],
              )
            ],
          ),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo/memo/memo.dart';
import 'package:memo/notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const ProviderScope(
    child: MyApp()),
  );
}

final StateNotifierProvider<MemoNotifier, List<Memo>> memoNotifier =
  StateNotifierProvider<MemoNotifier, List<Memo>>((ref) {
    return MemoNotifier(List.empty(growable: true));
  });
final TextEditingController _controller = TextEditingController();


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meemo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Meemo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }



  Future<void> initData() async {
    final prefs = await SharedPreferences.getInstance();
    _controller.text = prefs.getString('stored') ?? '';
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    log(state.name);
    switch (state) {
      case AppLifecycleState.inactive:
        final prefs = await SharedPreferences.getInstance();
        if (_controller.value.text.isNotEmpty) {
          await prefs.setString('stored', _controller.value.text);
        }
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: const AppPage()
      )
    );
  }
}

class AppPage extends ConsumerWidget {
  const AppPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Meemo'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.textsms)),
              Tab(icon: Icon(Icons.list)),
            ],
          ),
        ),
        body: const TabBarView(
            children: [WriterPage(), ListUpPage()],
        )
    );
  }

}

class WriterPage extends ConsumerWidget {
  final _pd = 10.0;

  const WriterPage({super.key});

  Memo _makeMemo(String text) {
    Memo memo = Memo(id: UniqueKey().toString(), text: text, date: DateTime.timestamp().toString());
    return memo;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Builder(builder: (context) =>
       Stack(
          children: [
            SizedBox(
                height: (MediaQuery.of(context).size.height - (Scaffold.of(context).appBarMaxHeight ?? 0)
                    .floor()),
                width: MediaQuery.of(context).size.width - _pd,
                child: Padding(
                  padding: EdgeInsets.only(left: _pd, bottom: _pd * 2.0),
                  child: TextField(
                    controller: _controller,
                    expands: true,
                    maxLines: null,
                    decoration: const InputDecoration(
                      border: InputBorder.none
                    ),
                  ),
                )
            ),
            Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: EdgeInsets.all((MediaQuery.of(context).size.width / _pd)),
                  child: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      String text = _controller.value.text.trim();
                      text = text.replaceAll(RegExp(r'\n(\n)+'), '\n\n');
                      log(text);
                      if (text.isNotEmpty) {
                        ref.watch(memoNotifier.notifier)
                            .addMemo(memo: _makeMemo(text));
                        _controller.clear();
                      }
                    },
                    color: Colors.blue,
                    iconSize: 32,
                  ),
                )
            )
          ],
        )
    );
  }
}

class ListUpPage extends ConsumerWidget {
  const ListUpPage({super.key});

  Future<void> _wait() async {
    Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reversedList = ref.watch(memoNotifier).reversed;
    return FutureBuilder(
        future: _wait(),
        builder: (context, snapshot) {
      return ListView.builder(
          itemCount: reversedList.length,
          itemBuilder: (context, index) {
            return GestureDetector(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 50.0),
                      child: Text(reversedList.elementAt(index).text),
                    ),
                    const Divider(),
                  ]
                ),
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context)
                        => DetailPage(memo: reversedList.elementAt(index))
                  ));
                },
            );
          },
          
      );
    });
  }
}

class DetailPage extends ConsumerWidget {
  final Memo memo;
  const DetailPage({super.key, required this.memo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
      ),
      body: ListView(
        children: memo.toMap().entries.map((e) =>
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
                child: Text('${e.key}: ${e.value}'),
              )
            ).toList(),
        ),
    );
  }
}
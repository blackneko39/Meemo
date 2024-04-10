import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memo/memo/memo.dart';

import 'memo/db.dart';

class MemoNotifier extends StateNotifier<List<Memo>> {
  final DB db = DB();
  MemoNotifier(super.state) {
    initData();
  }

  void initData() async {
    await db.initDatabase();
    state = await db.getMemos();
  }

  void addMemo({required Memo memo}) {
    state = [...state, memo];
    db.insertMemo(memo: memo);
  }
}
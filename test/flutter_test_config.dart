import 'dart:async';

import 'package:drift/drift.dart';

/// Widget tests each open their own in-memory database and can't close it
/// inside the fake-async zone, so drift's "created AppDatabase multiple times"
/// warning is a false positive here: no two instances share an executor.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  await testMain();
}

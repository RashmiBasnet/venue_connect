import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:venue_connect/app/app.dart';
import 'package:venue_connect/core/services/hive/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveService().init();

  runApp(ProviderScope(child: App()));
}

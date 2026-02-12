import 'package:flutter/material.dart';
import 'package:rapid_crak/src/rust/frb_generated.dart';
import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RustLib.init();
  runApp(const MyApp());
}

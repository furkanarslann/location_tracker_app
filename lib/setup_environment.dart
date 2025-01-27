// ignore_for_file: non_constant_identifier_names
import 'package:flutter_dotenv/flutter_dotenv.dart';

final class Environment {
  const Environment._();

  static Future<void> setup() async {
    await dotenv.load(fileName: '.env');
  }

  static final String googleMapsApiKey = dotenv.get('googleMapsApiKey');
}

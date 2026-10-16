import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

/// Адрес твоей Realtime Database.
/// Где взять: Firebase Console → Realtime Database → вкладка Data →
/// ссылка вверху над данными (с иконкой 🔗). Скопируй её целиком сюда.
const String databaseUrl = 'https://lab7-7666b-default-rtdb.firebaseio.com';

/// Подключение к базе по явному адресу
FirebaseDatabase get db => FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: databaseUrl,
    );
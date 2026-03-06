import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import '../services/firestore_service.dart';
import '../services/quote_api_service.dart';

const String ravynDropTaskName = 'ravynDropTask';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _notifications.initialize(
      settings: initSettings,
    );

    // Create notification channel
    const channel = AndroidNotificationChannel(
      'ravyn_drop_channel',
      'Ravyn Drop',
      description: 'Daily wisdom from Ravyn',
      importance: Importance.high,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future<void> showRavynDropNotification(String quote, String author) async {
    const androidDetails = AndroidNotificationDetails(
      'ravyn_drop_channel',
      'Ravyn Drop',
      channelDescription: 'Daily wisdom from Ravyn',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(''),
      icon: '@mipmap/ic_launcher',
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.show(
      id: 0,
      title: '🪶 Ravyn dropped a thought for you.',
      body: '"$quote" — $author',
      notificationDetails: notificationDetails,
    );
  }

  static Future<void> scheduleDaily() async {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
    await Workmanager().registerPeriodicTask(
      'ravyn-drop-daily',
      ravynDropTaskName,
      frequency: const Duration(hours: 24),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == ravynDropTaskName) {
      try {
        final firestoreService = FirestoreService();
        final apiService = QuoteApiService();

        // Check if we already have a drop for today
        final existingDrop = await firestoreService.getTodaysRavynDrop();
        if (existingDrop != null) return true;

        // Fetch a fresh quote
        final quotes = await apiService.fetchQuotes();
        if (quotes.isNotEmpty) {
          final drop = quotes.first;
          await firestoreService.saveRavynDrop(drop);
          await NotificationService.showRavynDropNotification(
            drop.text,
            drop.author,
          );

          // Save to prefs for display
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('ravyn_drop_text', drop.text);
          await prefs.setString('ravyn_drop_author', drop.author);
        }
      } catch (e) {
        return false;
      }
    }
    return true;
  });
}

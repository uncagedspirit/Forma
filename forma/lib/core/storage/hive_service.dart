import 'package:forma/core/storage/user_preferences_model.dart';
import 'package:forma/features/goals/data/models/goal_model.dart';
import 'package:forma/features/habits/data/models/habit_log_model.dart';
import 'package:forma/features/habits/data/models/habit_model.dart';
import 'package:forma/features/mood/data/models/mood_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logging/logging.dart';

/// Initializes and manages Hive storage for Forma.
///
/// Responsible for:
/// - Initializing Hive
/// - Opening all required boxes
/// - Registering all TypeAdapters
/// - Providing access to boxes
///
/// Call [init()] before runApp() in all entry points.
class HiveService {
  HiveService._();

  static final _logger = Logger('HiveService');

  // Box names
  static const String habitsBoxName = 'habitsBox';
  static const String goalsBoxName = 'goalsBox';
  static const String logsBoxName = 'logsBox';
  static const String moodBoxName = 'moodBox';
  static const String prefsBoxName = 'prefsBox';

  // Box instances (initialized after init())
  static late final Box<HabitModel> habitsBox;
  static late final Box<GoalModel> goalsBox;
  static late final Box<HabitLogModel> logsBox;
  static late final Box<MoodModel> moodBox;
  static late final Box<UserPreferencesModel> prefsBox;

  /// Initializes Hive and opens all required boxes.
  ///
  /// Must be called before runApp() and before any repository access.
  static Future<void> init() async {
    _logger.info('Initializing Hive...');

    // Initialize Hive
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(HabitModelAdapter());
    Hive.registerAdapter(HabitLogModelAdapter());
    Hive.registerAdapter(GoalModelAdapter());
    Hive.registerAdapter(MoodModelAdapter());
    Hive.registerAdapter(UserPreferencesModelAdapter());

    // Open all boxes
    habitsBox = await Hive.openBox<HabitModel>(habitsBoxName);
    goalsBox = await Hive.openBox<GoalModel>(goalsBoxName);
    logsBox = await Hive.openBox<HabitLogModel>(logsBoxName);
    moodBox = await Hive.openBox<MoodModel>(moodBoxName);
    prefsBox = await Hive.openBox<UserPreferencesModel>(prefsBoxName);

    _logger.info('Hive initialized successfully');
  }

  /// Closes all boxes and Hive.
  ///
  /// Call this when the app is terminating (optional, as Hive auto-saves).
  static Future<void> dispose() async {
    _logger.info('Closing Hive...');
    await habitsBox.close();
    await goalsBox.close();
    await logsBox.close();
    await moodBox.close();
    await prefsBox.close();
    _logger.info('Hive closed');
  }
}
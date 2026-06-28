import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/firebase_service.dart';
import '../data/squad_goals_service.dart';

final squadGoalsServiceProvider = Provider<SquadGoalsService>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return SquadGoalsService(firestore);
});

final activeSquadGoalsBySportProvider = StreamProvider.family.autoDispose<List<SquadGoal>, String>(
  (ref, sport) {
    final service = ref.watch(squadGoalsServiceProvider);
    return service.getActiveGoalsBySport(sport);
  },
);

final playerSquadGoalsProvider = StreamProvider.family.autoDispose<List<SquadGoal>, String>(
  (ref, playerId) {
    final service = ref.watch(squadGoalsServiceProvider);
    return service.getPlayerGoals(playerId);
  },
);

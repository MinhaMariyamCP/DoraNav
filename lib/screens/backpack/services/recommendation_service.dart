import '../models/backpack_context.dart';
import '../models/suggestion_item.dart';

/// Contract for recommendation provider.
/// The UI only consumes this interface, allowing real routing engine to drive it later.
abstract class RecommendationService {
  Future<BackpackResponse> getRecommendations(BackpackContext context);
  Future<BackpackResponse> searchItems(String query, BackpackContext context);
}

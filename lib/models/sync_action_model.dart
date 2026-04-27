import 'package:isar/isar.dart';

part 'sync_action_model.g.dart';

@collection
class SyncAction {
  Id id = Isar.autoIncrement;

  String method = 'POST'; // 'POST', 'PUT', 'DELETE'
  String endpoint = '';   // e.g., '/tournaments/create'
  
  // We will store the entire API request body as a JSON string
  String payload = '';    

  DateTime createdAt = DateTime.now();
  
  // To handle retry logic if the server happens to be down
  int retryCount = 0;     
}
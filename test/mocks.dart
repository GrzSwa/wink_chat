// Mocks for testing
import 'package:mockito/annotations.dart';
import 'package:wink_chat/src/common/domain/repositories/auth_repository.dart';
import 'package:wink_chat/src/features/account/data/locations_repository.dart';
import 'package:wink_chat/src/features/account/data/user_repository.dart';
import 'package:wink_chat/src/features/auth/data/repositories/firebase_user_repository.dart';
import 'package:wink_chat/src/features/explore/data/repositories/chat_repository.dart';
import 'package:wink_chat/src/features/explore/data/repositories/explore_repository.dart';

@GenerateMocks([
  AuthRepository,
  FirebaseUserRepository,
  LocationsRepository,
  UserRepository,
  ChatRepository,
  ExploreRepository,
])
void main() {}

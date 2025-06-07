// Mocks for testing
import 'package:mockito/annotations.dart';
import 'package:wink_chat/src/common/domain/repositories/auth_repository.dart';
import 'package:wink_chat/src/features/auth/data/repositories/firebase_user_repository.dart';

@GenerateMocks([AuthRepository, FirebaseUserRepository])
void main() {}

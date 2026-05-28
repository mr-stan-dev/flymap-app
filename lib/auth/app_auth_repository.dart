import 'package:firebase_auth/firebase_auth.dart';
import 'package:flymap/logger.dart';

abstract class AppAuthRepository {
  String? get currentUserId;

  Future<String?> initialize();

  Future<String> ensureSignedIn();
}

class FirebaseAppAuthRepository implements AppAuthRepository {
  FirebaseAppAuthRepository({FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;
  final _logger = const Logger('AppAuthRepository');

  @override
  String? get currentUserId => _auth.currentUser?.uid;

  @override
  Future<String?> initialize() async {
    try {
      return await ensureSignedIn();
    } catch (error) {
      _logger.error('Anonymous auth bootstrap skipped: $error');
      return _auth.currentUser?.uid;
    }
  }

  @override
  Future<String> ensureSignedIn() async {
    final current = _auth.currentUser;
    if (current != null) {
      return current.uid;
    }
    final credential = await _auth.signInAnonymously();
    final user = credential.user;
    if (user == null) {
      throw StateError('Firebase anonymous auth returned no user.');
    }
    return user.uid;
  }
}

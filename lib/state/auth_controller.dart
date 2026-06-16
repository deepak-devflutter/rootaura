import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../core/constants/shop_config.dart';
import '../data/auth_service.dart';
import '../data/models/user_profile.dart';
import '../data/user_repository.dart';

/// App-wide authentication + profile state. A single [ChangeNotifier] keeps
/// things simple — no external state-management package. Also used as
/// go_router's `refreshListenable` so route guards re-run on sign-in/out.
class AuthController extends ChangeNotifier {
  AuthController._();
  static final AuthController instance = AuthController._();

  User? _user;
  UserProfile? _profile;
  bool _ready = false;

  User? get user => _user;
  UserProfile? get profile => _profile;
  bool get isSignedIn => _user != null;

  /// Admin if the profile role is 'admin' OR the email is allow-listed in
  /// [ShopConfig]. The database enforces the same rule in firestore.rules.
  bool get isAdmin {
    if (_profile?.isAdmin ?? false) return true;
    final email = _user?.email?.toLowerCase();
    return email != null && ShopConfig.adminEmails.contains(email);
  }

  /// True once the first auth state has been resolved (avoids redirect flicker).
  bool get ready => _ready;

  void start() {
    AuthService.instance.authState().listen(_onAuthChanged);
  }

  Future<void> _onAuthChanged(User? user) async {
    _user = user;
    if (user != null) {
      _profile = await UserRepository.instance.ensureProfile(user);
    } else {
      _profile = null;
    }
    _ready = true;
    notifyListeners();
  }

  /// Reloads the profile after edits (address book, name, etc.).
  Future<void> refreshProfile() async {
    if (_user == null) return;
    _profile = await UserRepository.instance.fetch(_user!.uid);
    notifyListeners();
  }

  void setProfile(UserProfile profile) {
    _profile = profile;
    notifyListeners();
  }

  Future<void> signOut() => AuthService.instance.signOut();
}

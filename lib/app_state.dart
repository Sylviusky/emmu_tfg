import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Shared application state that keeps track of email verification for the
/// profile screen and registration flow.
class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    _userSubscription =
        FirebaseAuth.instance.userChanges().listen(_handleUserChange);
  }

  late final StreamSubscription<User?> _userSubscription;

  bool _emailVerified = false;
  bool get emailVerified => _emailVerified;

  void _handleUserChange(User? user) {
    final verified = user?.emailVerified ?? false;
    if (verified == _emailVerified) return;
    _emailVerified = verified;
    notifyListeners();
  }

  Future<void> refreshLoggedInUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
    await currentUser.reload();
    _handleUserChange(FirebaseAuth.instance.currentUser);
  }

  @override
  void dispose() {
    _userSubscription.cancel();
    super.dispose();
  }
}


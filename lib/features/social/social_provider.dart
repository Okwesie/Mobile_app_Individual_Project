import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:adventure_logger/core/models/public_log_entry.dart';
import 'package:adventure_logger/core/models/user_profile.dart';
import 'package:adventure_logger/core/services/user_service.dart';

class CommunityProvider extends ChangeNotifier {
  final UserService _svc = UserService.instance;

  UserProfile? _myProfile;
  List<PublicLogEntry> _feed = [];
  bool _feedLoading = false;
  final Map<String, bool> _myReactions = {};
  String? _uid;

  UserProfile? get myProfile => _myProfile;
  List<PublicLogEntry> get feed => List.unmodifiable(_feed);
  bool get feedLoading => _feedLoading;
  PublicLogEntry? feedEntry(String logDocId) {
    for (final entry in _feed) {
      if (entry.id == logDocId) return entry;
    }
    return null;
  }

  CommunityProvider() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _uid = user.uid;
        _init(user);
      } else {
        _uid = null;
        _myProfile = null;
        _feed = [];
        _myReactions.clear();
        notifyListeners();
      }
    });
  }

  Future<void> _init(User user) async {
    await _svc.createOrUpdateProfile(
      uid: user.uid,
      displayName: user.displayName ?? 'Explorer',
      photoURL: user.photoURL,
    );
    _myProfile = await _svc.getProfile(user.uid);
    notifyListeners();
    loadFeed();
  }

  Future<void> loadFeed() async {
    _feedLoading = true;
    notifyListeners();
    try {
      _feed = await _svc.getCommunityFeed();
      final uid = _uid;
      if (uid != null) {
        final reactions = await Future.wait(
          _feed.map((e) => _svc.getMyReaction(e.id, uid)),
        );
        for (var i = 0; i < _feed.length; i++) {
          _myReactions[_feed[i].id] = reactions[i];
        }
      }
    } catch (_) {
      _feed = [];
    } finally {
      _feedLoading = false;
      notifyListeners();
    }
  }

  bool hasReacted(String logDocId) => _myReactions[logDocId] ?? false;

  Future<void> toggleReaction(String logDocId) async {
    final uid = _uid;
    if (uid == null) return;
    final current = _myReactions[logDocId] ?? false;
    // Optimistic update
    _myReactions[logDocId] = !current;
    final idx = _feed.indexWhere((e) => e.id == logDocId);
    if (idx >= 0) {
      _feed[idx] = _feed[idx].copyWith(
        reactionCount: _feed[idx].reactionCount + (current ? -1 : 1),
      );
    }
    notifyListeners();
    try {
      await _svc.toggleReaction(
        logDocId: logDocId,
        uid: uid,
        currentlyReacted: current,
      );
    } catch (_) {
      // Revert on failure
      _myReactions[logDocId] = current;
      loadFeed();
    }
  }

  Future<void> updateBio(String bio) async {
    final uid = _uid;
    if (uid == null) return;
    await _svc.updateBio(uid, bio);
    _myProfile = _myProfile?.copyWith(bio: bio);
    notifyListeners();
  }

  Future<UserProfile?> getProfile(String uid) => _svc.getProfile(uid);

  Future<int> countPublicLogsForUser(String uid) =>
      _svc.countPublicLogsForUser(uid);
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/fasting_session.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection names
  static const String _fastingSessionsCollection = 'fasting_sessions';
  static const String _userStatsCollection = 'user_stats';

  // Get user's fasting sessions collection reference
  CollectionReference _getUserFastingSessionsRef(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection(_fastingSessionsCollection);
  }

  // Get user stats document reference
  DocumentReference _getUserStatsRef(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection(_userStatsCollection)
        .doc('stats');
  }

  // Save a fasting session
  Future<void> saveFastingSession(String userId, FastingSession session) async {
    try {
      await _getUserFastingSessionsRef(userId).add(session.toFirestore());
    } catch (e) {
      throw 'Failed to save fasting session: $e';
    }
  }

  // Update a fasting session
  Future<void> updateFastingSession(
      String userId, String sessionId, FastingSession session) async {
    try {
      await _getUserFastingSessionsRef(userId)
          .doc(sessionId)
          .update(session.toFirestore());
    } catch (e) {
      throw 'Failed to update fasting session: $e';
    }
  }

  // Delete a fasting session
  Future<void> deleteFastingSession(String userId, String sessionId) async {
    try {
      await _getUserFastingSessionsRef(userId).doc(sessionId).delete();
    } catch (e) {
      throw 'Failed to delete fasting session: $e';
    }
  }

  // Get all fasting sessions for a user
  Future<List<FastingSession>> getFastingSessions(String userId) async {
    try {
      QuerySnapshot snapshot = await _getUserFastingSessionsRef(userId)
          .orderBy('startTime', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return FastingSession.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      throw 'Failed to load fasting sessions: $e';
    }
  }

  // Get fasting sessions stream for real-time updates
  Stream<List<FastingSession>> getFastingSessionsStream(String userId) {
    return _getUserFastingSessionsRef(userId)
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return FastingSession.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Get fasting sessions for a specific date range
  Future<List<FastingSession>> getFastingSessionsInRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      QuerySnapshot snapshot = await _getUserFastingSessionsRef(userId)
          .where('startTime',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('startTime', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('startTime', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return FastingSession.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      throw 'Failed to load fasting sessions for date range: $e';
    }
  }

  // Save user statistics
  Future<void> saveUserStats(String userId, Map<String, dynamic> stats) async {
    try {
      await _getUserStatsRef(userId).set(stats, SetOptions(merge: true));
    } catch (e) {
      throw 'Failed to save user statistics: $e';
    }
  }

  // Get user statistics
  Future<Map<String, dynamic>?> getUserStats(String userId) async {
    try {
      DocumentSnapshot doc = await _getUserStatsRef(userId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      throw 'Failed to load user statistics: $e';
    }
  }

  // Get user statistics stream
  Stream<Map<String, dynamic>?> getUserStatsStream(String userId) {
    return _getUserStatsRef(userId).snapshots().map((doc) {
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    });
  }

  // Batch operations for better performance
  Future<void> batchSaveFastingSessions(
      String userId, List<FastingSession> sessions) async {
    try {
      WriteBatch batch = _firestore.batch();

      for (FastingSession session in sessions) {
        DocumentReference doc = _getUserFastingSessionsRef(userId).doc();
        batch.set(doc, session.toFirestore());
      }

      await batch.commit();
    } catch (e) {
      throw 'Failed to batch save fasting sessions: $e';
    }
  }

  // Initialize user document if it doesn't exist
  Future<void> initializeUserDocument(String userId) async {
    try {
      DocumentReference userDoc = _firestore.collection('users').doc(userId);

      DocumentSnapshot doc = await userDoc.get();
      if (!doc.exists) {
        await userDoc.set({
          'createdAt': FieldValue.serverTimestamp(),
          'lastSeen': FieldValue.serverTimestamp(),
        });
      } else {
        await userDoc.update({
          'lastSeen': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw 'Failed to initialize user document: $e';
    }
  }
}

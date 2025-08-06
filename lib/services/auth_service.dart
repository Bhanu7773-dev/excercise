import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Google Sign In
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        await _saveUserToFirestore(user);
      }

      return user;
    } catch (e, stack) {
      print('Google Sign-In error: $e\n$stack');
      return null;
    }
  }

  // Save user data to Firestore
  Future<void> _saveUserToFirestore(User user) async {
    try {
      await _db.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': user.displayName ?? 'Unknown User',
        'email': user.email ?? '',
        'photoUrl': user.photoURL ?? '',
        'lastLogin': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error saving user to Firestore: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print('Sign out error: $e');
    }
  }

  // Save exercise data
  Future<void> saveExercise({
    required String exerciseName,
    required DateTime date,
    required int duration,
    int? reps,
    Map<String, dynamic>? additionalData,
  }) async {
    final User? user = currentUser;
    if (user == null) throw Exception('No user logged in');

    try {
      final exerciseData = <String, dynamic>{
        'name': exerciseName,
        'date': date.toIso8601String(),
        'duration': duration,
        'timestamp': FieldValue.serverTimestamp(),
      };
      if (reps != null) exerciseData['reps'] = reps;
      if (additionalData != null) exerciseData.addAll(additionalData);

      await _db
          .collection('users')
          .doc(user.uid)
          .collection('exercises')
          .add(exerciseData);
    } catch (e) {
      print('Error saving exercise: $e');
      rethrow;
    }
  }

  // Get user exercises
  Future<List<Map<String, dynamic>>> getExercises({
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final User? user = currentUser;
    if (user == null) throw Exception('No user logged in');

    try {
      Query query = _db
          .collection('users')
          .doc(user.uid)
          .collection('exercises')
          .orderBy('date', descending: true);

      if (startDate != null) {
        query = query.where('date',
            isGreaterThanOrEqualTo: startDate.toIso8601String());
      }
      if (endDate != null) {
        query =
            query.where('date', isLessThanOrEqualTo: endDate.toIso8601String());
      }
      if (limit != null) {
        query = query.limit(limit);
      }

      final QuerySnapshot snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting exercises: $e');
      return [];
    }
  }

  // Get exercises for a specific date
  Future<List<Map<String, dynamic>>> getExercisesForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return await getExercises(
      startDate: startOfDay,
      endDate: endOfDay,
    );
  }

  // Delete an exercise
  Future<void> deleteExercise(String exerciseId) async {
    final User? user = currentUser;
    if (user == null) throw Exception('No user logged in');

    try {
      await _db
          .collection('users')
          .doc(user.uid)
          .collection('exercises')
          .doc(exerciseId)
          .delete();
    } catch (e) {
      print('Error deleting exercise: $e');
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    final User? user = currentUser;
    if (user == null) throw Exception('No user logged in');

    try {
      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }
      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }

      final updateData = <String, dynamic>{
        'lastUpdated': FieldValue.serverTimestamp(),
      };
      if (displayName != null) updateData['name'] = displayName;
      if (photoURL != null) updateData['photoUrl'] = photoURL;

      await _db.collection('users').doc(user.uid).update(updateData);
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  // Get user stats
  Future<Map<String, dynamic>> getUserStats() async {
    final User? user = currentUser;
    if (user == null) throw Exception('No user logged in');

    try {
      final exercises = await getExercises();
      final totalExercises = exercises.length;
      final totalDuration = exercises.fold<int>(
        0,
        (sum, exercise) => sum + (exercise['duration'] as int? ?? 0),
      );

      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      final recentExercises = await getExercises(startDate: weekAgo);

      return {
        'totalExercises': totalExercises,
        'totalDuration': totalDuration,
        'exercisesThisWeek': recentExercises.length,
        'averageDuration':
            totalExercises > 0 ? totalDuration / totalExercises : 0,
      };
    } catch (e) {
      print('Error getting user stats: $e');
      return <String, dynamic>{};
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class ExperienceRepository {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  final String _collection = 'experiences';

  // CREATE - Provider creates experience
  Future<String> createExperience({
    required String providerId,
    required String title,
    required String description,
    required double priceRWF,
    required GeoPoint location,
    required String category,
    required List<String> images,
  }) async {
    try {
      final docRef = await _firestore.collection(_collection).add({
        'providerId': providerId,
        'title': title,
        'description': description,
        'priceRWF': priceRWF,
        'location': location,
        'category': category,
        'images': images,
        'isAvailable': true,
        'verificationBadges': [],
        'createdAt': Timestamp.now(),
        'rating': 0.0,
        'reviewCount': 0,
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create experience: \${e.toString()}');
    }
  }

  // READ - Get all experiences with filters
  Stream<QuerySnapshot> getExperiences({
    String? category,
    double? maxPrice,
    bool? isAvailable,
  }) {
    Query query = _firestore.collection(_collection);

    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }
    if (maxPrice != null) {
      query = query.where('priceRWF', isLessThanOrEqualTo: maxPrice);
    }
    if (isAvailable != null) {
      query = query.where('isAvailable', isEqualTo: isAvailable);
    }

    return query.orderBy('createdAt', descending: true).snapshots();
  }

  // READ - Get provider's experiences
  Stream<QuerySnapshot> getProviderExperiences(String providerId) {
    return _firestore
        .collection(_collection)
        .where('providerId', isEqualTo: providerId)
        .snapshots();
  }

  // READ - Get single experience
  Future<DocumentSnapshot> getExperienceById(String experienceId) async {
    return await _firestore.collection(_collection).doc(experienceId).get();
  }

  // UPDATE - Update experience
  Future<void> updateExperience(String experienceId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = Timestamp.now();
      await _firestore.collection(_collection).doc(experienceId).update(data);
    } catch (e) {
      throw Exception('Failed to update experience: \${e.toString()}');
    }
  }

  // DELETE - Delete experience
  Future<void> deleteExperience(String experienceId) async {
    try {
      await _firestore.collection(_collection).doc(experienceId).delete();
    } catch (e) {
      throw Exception('Failed to delete experience: \${e.toString()}');
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseSeeder {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> seedAllData() async {
    await seedUsers();
    await seedExperiences();
    await seedBookings();
    await seedReviews();
    print('✅ Database seeded successfully!');
  }

  // Seed Tourist Users
  Future<void> seedUsers() async {
    final users = [
      {
        'uid': 'tourist_001',
        'email': 'emma.vogel@email.com',
        'displayName': 'Emma Vogel',
        'phone': '+250788111111',
        'role': 'tourist',
        'photoURL': 'https://i.pravatar.cc/150?img=1',
        'createdAt': Timestamp.now(),
      },
      {
        'uid': 'tourist_002',
        'email': 'john.doe@email.com',
        'displayName': 'John Doe',
        'phone': '+250788222222',
        'role': 'tourist',
        'photoURL': 'https://i.pravatar.cc/150?img=2',
        'createdAt': Timestamp.now(),
      },
      {
        'uid': 'provider_001',
        'email': 'grace.uwimana@email.com',
        'displayName': 'Grace Uwimana',
        'phone': '+250788333333',
        'role': 'provider',
        'photoURL': 'https://i.pravatar.cc/150?img=3',
        'providerProfile': {
          'bio': 'Certified gorilla guide with 10+ years experience',
          'location': 'Musanze, Rwanda',
          'badges': ['IGCP Certified', 'Community Verified'],
          'verificationStatus': 'verified',
          'earnings': 850000,
        },
        'createdAt': Timestamp.now(),
      },
      {
        'uid': 'provider_002',
        'email': 'marie.uwase@email.com',
        'displayName': 'Marie Uwase',
        'phone': '+250788444444',
        'role': 'provider',
        'photoURL': 'https://i.pravatar.cc/150?img=4',
        'providerProfile': {
          'bio': 'Traditional dance instructor and cultural ambassador',
          'location': 'Kigali, Rwanda',
          'badges': ['RCHA Verified', 'Community Verified'],
          'verificationStatus': 'verified',
          'earnings': 420000,
        },
        'createdAt': Timestamp.now(),
      },
    ];

    for (final user in users) {
      await _firestore.collection('users').doc(user['uid'] as String).set(user);
    }
    print('✅ Users seeded');
  }

  // Seed Experiences
  Future<void> seedExperiences() async {
    final experiences = [
      {
        'id': 'exp_001',
        'providerId': 'provider_001',
        'title': 'Gorilla Trekking Experience',
        'description':
            'Join me for an unforgettable mountain gorilla trekking adventure in Volcanoes National Park. I will share stories of conservation, coexistence, and post-genocide reconciliation.',
        'priceRWF': 85000,
        'priceUSD': 65,
        'duration': '4 hours',
        'location': {
          'name': 'Volcanoes National Park',
          'latitude': -1.4833,
          'longitude': 29.5167,
        },
        'category': 'nature',
        'images': [
          'https://images.unsplash.com/photo-1547471080-7cc2caa01a7e?w=800',
          'https://images.unsplash.com/photo-1551009175-8a68da93d5f9?w=800',
        ],
        'isAvailable': true,
        'verificationBadges': ['IGCP Certified', 'Community Verified'],
        'rating': 4.9,
        'reviewCount': 127,
        'maxGroupSize': 8,
        'includes': ['Park fees', 'Guide fee', 'Water', 'Snacks'],
        'createdAt': Timestamp.now(),
      },
      {
        'id': 'exp_002',
        'providerId': 'provider_002',
        'title': 'Traditional Intore Dance Workshop',
        'description':
            'Learn the ancient art of Intore dance from master performers. This immersive workshop includes traditional costumes, drumming lessons, and the history of Rwandan royal dance.',
        'priceRWF': 15000,
        'priceUSD': 12,
        'duration': '3 hours',
        'location': {
          'name': 'Kigali Cultural Village',
          'latitude': -1.9441,
          'longitude': 30.0619,
        },
        'category': 'culture',
        'images': [
          'https://images.unsplash.com/photo-1516026672322-bc52d61a55d5?w=800',
        ],
        'isAvailable': true,
        'verificationBadges': ['RCHA Verified', 'Community Verified'],
        'rating': 4.8,
        'reviewCount': 89,
        'maxGroupSize': 12,
        'includes': ['Costume rental', 'Drum lesson', 'Certificate'],
        'createdAt': Timestamp.now(),
      },
      {
        'id': 'exp_003',
        'providerId': 'provider_001',
        'title': 'Coffee Farm & Tasting Tour',
        'description':
            'Discover the journey from bean to cup at our family-owned coffee plantation. Pick coffee cherries, learn traditional processing methods, and enjoy a cupping session.',
        'priceRWF': 20000,
        'priceUSD': 15,
        'duration': '4 hours',
        'location': {
          'name': 'Huye District',
          'latitude': -2.5833,
          'longitude': 29.7500,
        },
        'category': 'food',
        'images': [
          'https://images.unsplash.com/photo-1447933601403-0c6688de566e?w=800',
        ],
        'isAvailable': true,
        'verificationBadges': ['Community Verified'],
        'rating': 4.7,
        'reviewCount': 56,
        'maxGroupSize': 6,
        'includes': ['Farm tour', 'Tasting session', 'Bag of coffee'],
        'createdAt': Timestamp.now(),
      },
      {
        'id': 'exp_004',
        'providerId': 'provider_002',
        'title': 'Basket Weaving with Imirasire Co-op',
        'description':
            'Create your own traditional Rwandan basket with guidance from women artisans. Learn the symbolic patterns and take home your handmade craft.',
        'priceRWF': 25000,
        'priceUSD': 19,
        'duration': '3 hours',
        'location': {
          'name': 'Huye Cooperative Center',
          'latitude': -2.6000,
          'longitude': 29.7333,
        },
        'category': 'culture',
        'images': [
          'https://images.unsplash.com/photo-1606293459339-a0c4de5d5c5e?w=800',
        ],
        'isAvailable': true,
        'verificationBadges': ['RCHA Verified', 'Women Owned'],
        'rating': 4.9,
        'reviewCount': 43,
        'maxGroupSize': 8,
        'includes': ['Materials', 'Tutorial', 'Your basket'],
        'createdAt': Timestamp.now(),
      },
      {
        'id': 'exp_005',
        'providerId': 'provider_001',
        'title': 'Sunset Canopy Walkway',
        'description':
            'Experience the rainforest from above on the famous Nyungwe canopy walkway. Spot monkeys, birds, and breathtaking views at golden hour.',
        'priceRWF': 35000,
        'priceUSD': 27,
        'duration': '2 hours',
        'location': {
          'name': 'Nyungwe Forest',
          'latitude': -2.4833,
          'longitude': 29.2500,
        },
        'category': 'nature',
        'images': [
          'https://images.unsplash.com/photo-1547471080-7cc2caa01a7e?w=800',
        ],
        'isAvailable': true,
        'verificationBadges': ['Community Verified'],
        'rating': 4.8,
        'reviewCount': 78,
        'maxGroupSize': 10,
        'includes': ['Park entry', 'Guide', 'Safety equipment'],
        'createdAt': Timestamp.now(),
      },
    ];

    for (final exp in experiences) {
      await _firestore
          .collection('experiences')
          .doc(exp['id'] as String)
          .set(exp);
    }
    print('✅ Experiences seeded');
  }

  // Seed Bookings
  Future<void> seedBookings() async {
    final bookings = [
      {
        'id': 'booking_001',
        'touristId': 'tourist_001',
        'experienceId': 'exp_001',
        'providerId': 'provider_001',
        'status': 'confirmed',
        'bookingDate': Timestamp.now(),
        'experienceDate': Timestamp.fromDate(DateTime(2026, 4, 5)),
        'groupSize': 2,
        'totalPrice': 170000,
        'paymentMethod': 'MTN Mobile Money',
        'paymentStatus': 'paid',
        'createdAt': Timestamp.now(),
      },
      {
        'id': 'booking_002',
        'touristId': 'tourist_001',
        'experienceId': 'exp_002',
        'providerId': 'provider_002',
        'status': 'completed',
        'bookingDate': Timestamp.fromDate(DateTime(2026, 3, 15)),
        'experienceDate': Timestamp.fromDate(DateTime(2026, 3, 20)),
        'groupSize': 1,
        'totalPrice': 15000,
        'paymentMethod': 'Airtel Money',
        'paymentStatus': 'paid',
        'createdAt': Timestamp.fromDate(DateTime(2026, 3, 15)),
      },
      {
        'id': 'booking_003',
        'touristId': 'tourist_002',
        'experienceId': 'exp_003',
        'providerId': 'provider_001',
        'status': 'pending',
        'bookingDate': Timestamp.now(),
        'experienceDate': Timestamp.fromDate(DateTime(2026, 4, 10)),
        'groupSize': 4,
        'totalPrice': 80000,
        'paymentMethod': 'MTN Mobile Money',
        'paymentStatus': 'pending',
        'createdAt': Timestamp.now(),
      },
    ];

    for (final booking in bookings) {
      await _firestore
          .collection('bookings')
          .doc(booking['id'] as String)
          .set(booking);
    }
    print('✅ Bookings seeded');
  }

  // Seed Reviews
  Future<void> seedReviews() async {
    final reviews = [
      {
        'id': 'review_001',
        'bookingId': 'booking_002',
        'touristId': 'tourist_001',
        'providerId': 'provider_002',
        'experienceId': 'exp_002',
        'rating': 5,
        'comment':
            'An absolutely magical experience! Grace was incredibly knowledgeable and passionate. The gorillas were breathtaking. Highly recommend!',
        'photos': [],
        'createdAt': Timestamp.fromDate(DateTime(2026, 3, 21)),
      },
      {
        'id': 'review_002',
        'bookingId': 'booking_002',
        'touristId': 'tourist_001',
        'providerId': 'provider_002',
        'experienceId': 'exp_002',
        'rating': 5,
        'comment':
            'The dance workshop was the highlight of my trip. Marie is a wonderful teacher and the history she shared was fascinating.',
        'photos': [],
        'createdAt': Timestamp.fromDate(DateTime(2026, 3, 21)),
      },
    ];

    for (final review in reviews) {
      await _firestore
          .collection('reviews')
          .doc(review['id'] as String)
          .set(review);
    }
    print('✅ Reviews seeded');
  }
}

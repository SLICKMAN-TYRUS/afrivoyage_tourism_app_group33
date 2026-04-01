import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedFirestore() async {
  final firestore = FirebaseFirestore.instance;

  // 1. users
  await firestore.collection('users').doc('user_001').set({
    "uid": "user_001",
    "fullName": "Uwimana Aline",
    "email": "aline.uwimana@gmail.com",
    "phoneNumber": "+250788123456",
    "nationality": "Rwandan",
    "profileImageUrl": "https://afrivoyage.com/profiles/uwimana.jpg",
    "createdAt": "2026-04-01T10:00:00Z",
    "isVerified": true,
    "favoriteExperiences": ["exp_001", "exp_002"],
    "dateOfBirth": "1998-07-15",
    "gender": "Female",
    "address": "Kacyiru, Kigali",
    "emergencyContact": {
      "name": "Mugisha Eric",
      "phone": "+250788654321"
    },
    "preferences": {
      "language": "English",
      "currency": "RWF",
      "receivePromotions": true
    },
    "lastLogin": "2026-04-01T15:30:00Z"
  });

  // 2. providers
  await firestore.collection('providers').doc('prov_001').set({
    "providerId": "prov_001",
    "companyName": "Rwanda Safaris Ltd",
    "contactPerson": "Niyonzima Jean",
    "email": "info@rwandasafaris.rw",
    "phoneNumber": "+250788654321",
    "address": "KN 5 Rd, Kigali, Rwanda",
    "licenseNumber": "RW-TR-2026-001",
    "profileImageUrl": "https://afrivoyage.com/providers/rwanda_safaris.jpg",
    "createdAt": "2026-04-01T09:00:00Z",
    "isApproved": true,
    "servicesOffered": ["Wildlife Tours", "Cultural Tours"],
    "languagesSpoken": ["Kinyarwanda", "English", "French"],
    "website": "https://rwandasafaris.rw",
    "ratings": 4.7,
    "reviewCount": 25,
    "about": "Leading tour operator in Rwanda specializing in wildlife and cultural experiences.",
    "socialLinks": {
      "facebook": "https://facebook.com/rwandasafaris",
      "instagram": "https://instagram.com/rwandasafaris"
    }
  });

  // 3. experiences
  await firestore.collection('experiences').doc('exp_001').set({
    "experienceId": "exp_001",
    "title": "Gorilla Trekking in Volcanoes National Park",
    "description": "Experience the thrill of trekking mountain gorillas in their natural habitat in Musanze.",
    "location": "Volcanoes National Park, Musanze",
    "price": 1500.0,
    "currency": "RWF",
    "images": [
      "https://afrivoyage.com/experiences/gorilla1.jpg",
      "https://afrivoyage.com/experiences/gorilla2.jpg"
    ],
    "providerId": "prov_001",
    "availableDates": [
      "2026-04-10T08:00:00Z",
      "2026-04-17T08:00:00Z"
    ],
    "durationHours": 6,
    "category": "Wildlife",
    "language": "Kinyarwanda, English",
    "rating": 4.8,
    "reviewCount": 12,
    "createdAt": "2026-03-30T12:00:00Z",
    "maxGroupSize": 8,
    "minAge": 15,
    "included": ["Guide", "Permits", "Lunch"],
    "notIncluded": ["Transport"],
    "highlights": [
      "See mountain gorillas up close",
      "Guided by experienced rangers"
    ],
    "tags": ["adventure", "nature", "wildlife"],
    "itinerary": [
      {
        "time": "08:00",
        "activity": "Briefing at park headquarters"
      },
      {
        "time": "09:00",
        "activity": "Start trekking"
      },
      {
        "time": "13:00",
        "activity": "Lunch and return"
      }
    ]
  });

  // 4. bookings
  await firestore.collection('bookings').doc('book_001').set({
    "bookingId": "book_001",
    "userId": "user_001",
    "experienceId": "exp_001",
    "providerId": "prov_001",
    "bookingDate": "2026-04-01T11:00:00Z",
    "scheduledDate": "2026-04-10T08:00:00Z",
    "numberOfPeople": 2,
    "totalPrice": 3000.0,
    "currency": "RWF",
    "status": "confirmed",
    "specialRequests": "Vegetarian meal",
    "createdAt": "2026-04-01T11:00:00Z",
    "paymentStatus": "paid",
    "paymentMethod": "Mobile Money",
    "transactionReference": "MTN123456",
    "cancellationReason": null,
    "lastUpdated": "2026-04-01T12:00:00Z",
    "participants": [
      {
        "name": "Uwimana Aline",
        "age": 27,
        "nationality": "Rwandan"
      },
      {
        "name": "Mugisha Eric",
        "age": 30,
        "nationality": "Rwandan"
      }
    ],
    "contactInfo": {
      "email": "aline.uwimana@gmail.com",
      "phone": "+250788123456"
    }
  });

  // 5. reviews
  await firestore.collection('reviews').doc('rev_001').set({
    "reviewId": "rev_001",
    "userId": "user_001",
    "experienceId": "exp_001",
    "providerId": "prov_001",
    "rating": 5,
    "comment": "Amazing experience! The gorillas were incredible and the guide was very knowledgeable.",
    "createdAt": "2026-04-11T15:00:00Z",
    "images": [
      "https://afrivoyage.com/reviews/gorilla_review.jpg"
    ],
    "response": {
      "providerId": "prov_001",
      "message": "Thank you for your feedback!",
      "respondedAt": "2026-04-12T09:00:00Z"
    },
    "title": "Unforgettable Gorilla Trekking",
    "visitDate": "2026-04-10"
  });

  // 6. payments
  await firestore.collection('payments').doc('pay_001').set({
    "paymentId": "pay_001",
    "bookingId": "book_001",
    "userId": "user_001",
    "providerId": "prov_001",
    "amount": 3000.0,
    "currency": "RWF",
    "paymentMethod": "Mobile Money",
    "status": "completed",
    "transactionReference": "MTN123456",
    "createdAt": "2026-04-01T12:00:00Z",
    "paymentGateway": "MTN Rwanda",
    "receiptUrl": "https://afrivoyage.com/receipts/pay_001.pdf"
  });

  print('Firestore seeding complete!');
}
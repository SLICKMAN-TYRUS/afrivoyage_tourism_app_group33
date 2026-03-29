class Experience {
  final String id;
  final String title;
  final String description;
  final String location;
  final int price; // in RWF
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final String? providerId; // who created this experience

  Experience({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    this.providerId,
  });

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      price: (json['price'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
      providerId: json['providerId'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'location': location,
    'price': price,
    'rating': rating,
    'reviewCount': reviewCount,
    'imageUrl': imageUrl,
    'providerId': providerId,
  };
}
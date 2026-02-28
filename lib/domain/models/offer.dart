class Offer {
  final String id;
  final String title;
  final List<String> sneakerIds;
  final int discountPercentage;
  final bool active;

  Offer({
    required this.id,
    required this.title,
    required this.sneakerIds,
    required this.discountPercentage,
    required this.active,
  });

  // Factory to convert JSON from your Node.js backend to a Dart object
  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['_id'],
      title: json['title'],
      sneakerIds: List<String>.from(json['sneakerIds']),
      discountPercentage: json['discountPercentage'],
      active: json['active'] ?? true,
    );
  }
}
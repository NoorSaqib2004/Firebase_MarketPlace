import 'package:cloud_firestore/cloud_firestore.dart';

class ListingModel {
  final String listingId;
  final String title;
  final String description;
  final double price;
  final List<String> images;
  final String category;
  final String ownerId;
  final String sellerName;
  final String sellerEmail;
  final Timestamp? createdAt;
  final String status;

  ListingModel({
    required this.listingId,
    required this.title,
    required this.description,
    required this.price,
    required this.images,
    required this.category,
    required this.ownerId,
    this.sellerName = 'Unknown',
    this.sellerEmail = '',
    this.createdAt,
    required this.status,
  });

  factory ListingModel.fromMap(Map<String, dynamic> map) {
    return ListingModel(
      listingId: map['listingId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] is num) ? (map['price'] as num).toDouble() : 0.0,
      images: List<String>.from(map['images'] ?? []),
      category: map['category'] ?? '',
      ownerId: map['ownerId'] ?? '',
      sellerName: map['sellerName'] ?? 'Unknown',
      sellerEmail: map['sellerEmail'] ?? '',
      createdAt: map['createdAt'] as Timestamp?,
      status: map['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'listingId': listingId,
      'title': title,
      'description': description,
      'price': price,
      'images': images,
      'category': category,
      'ownerId': ownerId,
      'sellerName': sellerName,
      'sellerEmail': sellerEmail,
      'createdAt': createdAt,
      'status': status,
    };
  }

  ListingModel copyWith({
    String? listingId,
    String? title,
    String? description,
    double? price,
    List<String>? images,
    String? category,
    String? ownerId,
    String? sellerName,
    String? sellerEmail,
    Timestamp? createdAt,
    String? status,
  }) {
    return ListingModel(
      listingId: listingId ?? this.listingId,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      images: images ?? this.images,
      category: category ?? this.category,
      ownerId: ownerId ?? this.ownerId,
      sellerName: sellerName ?? this.sellerName,
      sellerEmail: sellerEmail ?? this.sellerEmail,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'ListingModel(listingId: $listingId, title: $title, description: $description, price: $price, images: $images, category: $category, ownerId: $ownerId, sellerName: $sellerName, sellerEmail: $sellerEmail, createdAt: $createdAt, status: $status)';
  }
}

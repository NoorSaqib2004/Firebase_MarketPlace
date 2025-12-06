class FavoriteModel {
  final String listingId;

  FavoriteModel({required this.listingId});

  factory FavoriteModel.fromMap(Map<String, dynamic> map) {
    return FavoriteModel(listingId: map['listingId'] ?? '');
  }

  Map<String, dynamic> toMap() {
    return {'listingId': listingId};
  }

  FavoriteModel copyWith({String? listingId}) {
    return FavoriteModel(listingId: listingId ?? this.listingId);
  }

  @override
  String toString() => 'FavoriteModel(listingId: $listingId)';
}

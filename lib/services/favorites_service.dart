class FavoritesService {
  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() => _instance;
  FavoritesService._internal();

  final List<Map<String, dynamic>> _favorites = [];

  List<Map<String, dynamic>> get favorites => List.unmodifiable(_favorites);

  bool isFavorite(String serviceName) {
    return _favorites.any((service) => service['name'] == serviceName);
  }

  void toggleFavorite(Map<String, dynamic> service) {
    final index = _favorites.indexWhere((fav) => fav['name'] == service['name']);
    if (index >= 0) {
      _favorites.removeAt(index);
    } else {
      _favorites.add(Map<String, dynamic>.from(service));
    }
  }
}

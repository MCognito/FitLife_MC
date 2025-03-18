import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/library_item.dart';
import '../service/library_service.dart';

// Provider for the LibraryViewModel
final libraryViewModelProvider =
    ChangeNotifierProvider<LibraryViewModel>((ref) {
  return LibraryViewModel();
});

class LibraryViewModel extends ChangeNotifier {
  final LibraryService _libraryService = LibraryService();

  List<LibraryItem> _libraryItems = [];
  List<LibraryItem> get libraryItems => _libraryItems;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // Map to track expanded state of each item
  final Map<String, bool> _expandedItems = {};
  bool isExpanded(String itemId) => _expandedItems[itemId] ?? false;

  // Available categories
  List<String> _categories = [];
  List<String> get categories => _categories;

  // Currently selected category
  String? _selectedCategory;
  String? get selectedCategory => _selectedCategory;

  // Initialize the ViewModel
  LibraryViewModel() {
    fetchLibraryItems();
  }

  // Toggle the expanded state of an item
  void toggleExpanded(String itemId) {
    _expandedItems[itemId] = !(_expandedItems[itemId] ?? false);
    notifyListeners();
  }

  // Set the selected category
  void setSelectedCategory(String? category) {
    _selectedCategory = category;
    if (category != null) {
      fetchLibraryItemsByCategory(category);
    } else {
      fetchLibraryItems();
    }
  }

  // Fetch all library items
  Future<void> fetchLibraryItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _libraryItems = await _libraryService.getLibraryItems();
      _extractCategories();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Fetch library items by category
  Future<void> fetchLibraryItemsByCategory(String category) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _libraryItems = await _libraryService.getLibraryItemsByCategory(category);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Extract unique categories from library items
  void _extractCategories() {
    final Set<String> uniqueCategories = {};
    for (var item in _libraryItems) {
      if (item.category.isNotEmpty) {
        uniqueCategories.add(item.category);
      }
    }
    _categories = uniqueCategories.toList()..sort();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewModels/library_view_model.dart';
import '../custom_widgets/library_item_card.dart';
import '../custom_widgets/category_filter.dart';

class LibraryPage extends ConsumerWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(libraryViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitness Library'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => viewModel.fetchLibraryItems(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filter
          if (viewModel.categories.isNotEmpty)
            CategoryFilter(
              categories: viewModel.categories,
              selectedCategory: viewModel.selectedCategory,
              onCategorySelected: (category) =>
                  viewModel.setSelectedCategory(category),
            ),

          // Content area
          Expanded(
            child: _buildContent(viewModel),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(LibraryViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: ${viewModel.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.fetchLibraryItems(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (viewModel.libraryItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.library_books, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              viewModel.selectedCategory != null
                  ? 'No items found in ${viewModel.selectedCategory} category'
                  : 'No library items available',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.fetchLibraryItems(),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        itemCount: viewModel.libraryItems.length,
        itemBuilder: (context, index) {
          final item = viewModel.libraryItems[index];
          return LibraryItemCard(
            item: item,
            isExpanded: viewModel.isExpanded(item.id),
            onToggle: (id) => viewModel.toggleExpanded(id),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../models/library_item.dart';

class LibraryItemCard extends StatelessWidget {
  final LibraryItem item;
  final bool isExpanded;
  final Function(String) onToggle;

  const LibraryItemCard({
    Key? key,
    required this.item,
    required this.isExpanded,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and expand/collapse button
          InkWell(
            onTap: () => onToggle(item.id),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          ),

          // Expandable content
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(height: 16, thickness: 1),
                  Text(
                    item.content,
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.visible,
                    softWrap: true,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

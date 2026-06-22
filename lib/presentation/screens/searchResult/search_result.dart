import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sneaker_recognizer_plateform/presentation/screens/productDetails/details.dart';
import '../../../domain/models/sneaker.dart';

class SneakerResultPage extends StatefulWidget {
  final List<Map<String, dynamic>> result;

  const SneakerResultPage({super.key, required this.result});

  @override
  State<SneakerResultPage> createState() => _SneakerResultPageState();
}

class _SneakerResultPageState extends State<SneakerResultPage> {
  late final List<Sneaker> _sneakers;
  String _activeFilter = 'All';
  String _sortBy = 'Pertinence';
  final Set<String> _liked = {};

  static const List<String> _filters = [
    'All',
    'Taille',
    'Prix',
    'Marque',
    'État',
  ];

  static const List<String> _sortOptions = [
    'Pertinence',
    'Prix croissant',
    'Prix décroissant',
  ];

  @override
  void initState() {
    super.initState();
    _sneakers = widget.result.map((e) => Sneaker.fromJson(e)).toList();
  }

  List<Sneaker> get _sorted {
    final list = List<Sneaker>.from(_sneakers);
    switch (_sortBy) {
      case 'Prix croissant':
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Prix décroissant':
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      default:
        break;
    }
    return list;
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Trier par',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.black,
                letterSpacing: -.3,
              ),
            ),
            const SizedBox(height: 16),
            ..._sortOptions.map(
              (opt) => GestureDetector(
                onTap: () {
                  setState(() => _sortBy = opt);
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: _sortBy == opt ? Colors.black : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                  child: Text(
                    opt,
                    style: TextStyle(
                      fontSize: 15,
                      color: _sortBy == opt ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sorted = _sorted;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 1.5),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black, size: 18),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Résultats',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: Colors.black,
                letterSpacing: -.3,
              ),
            ),
            Text(
              '${_sneakers.length} articles',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black.withOpacity(.4),
              ),
            ),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.fromLTRB(0, 10, 16, 10),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              child: const Row(
                children: [
                  Icon(Icons.tune, size: 15, color: Colors.black),
                  SizedBox(width: 5),
                  Text(
                    'Filtres',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: _buildFiltersRow(),
        ),
      ),
      body: Column(
        children: [
          _buildResultsMeta(sorted.length),
          Expanded(
            child: sorted.isEmpty ? _buildEmptyState() : _buildGrid(sorted),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersRow() {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final isActive = _activeFilter == _filters[i];
          return GestureDetector(
            onTap: () => setState(() => _activeFilter = _filters[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isActive ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              child: Center(
                child: Text(
                  _filters[i],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                    color: isActive ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultsMeta(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$count articles',
            style: TextStyle(fontSize: 13, color: Colors.black.withOpacity(.4)),
          ),
          GestureDetector(
            onTap: _showSortSheet,
            child: Row(
              children: [
                const Icon(Icons.swap_vert, size: 16, color: Colors.black),
                const SizedBox(width: 4),
                Text(
                  _sortBy,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<Sneaker> items) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final sneaker = items[index];
        return _ResultCard(
          sneaker: sneaker,
          allSneakers: items,
          liked: _liked.contains(sneaker.id),
          onLike: () => setState(() {
            _liked.contains(sneaker.id)
                ? _liked.remove(sneaker.id)
                : _liked.add(sneaker.id);
          }),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 1.5),
            ),
            child: const Icon(Icons.search_off, size: 28, color: Colors.black),
          ),
          const SizedBox(height: 20),
          const Text(
            'Aucun article trouvé',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              letterSpacing: -.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Essayez d'autres filtres",
            style: TextStyle(fontSize: 14, color: Colors.black.withOpacity(.4)),
          ),
        ],
      ),
    );
  }
}

// ─── Result card ───────────────────────────────────────────────────────────────

class _ResultCard extends StatelessWidget {
  final Sneaker sneaker;
  final List<Sneaker> allSneakers;
  final bool liked;
  final VoidCallback onLike;

  const _ResultCard({
    required this.sneaker,
    required this.allSneakers,
    required this.liked,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ProductDetailsPage(sneaker: sneaker, allSneakers: allSneakers),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black, width: 1.5),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildImage()),
            _buildInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Stack(
      fit: StackFit.expand,
      children: [
        _resolveImage(),
        // Member badge top-left
        if (sneaker.isMember)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Partner',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        // Favourite top-right
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: onLike,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: Icon(
                liked ? Icons.favorite : Icons.favorite_border,
                size: 15,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _resolveImage() {
    final url = sneaker.imageUrl;
    if (url != null && url.isNotEmpty) {
      if (url.startsWith('data:image')) {
        return _imageFromDataUri(url) ?? _placeholder();
      }
      return Image.network(
        url,
        fit: BoxFit.cover,
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : Container(color: Colors.grey.shade100),
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    final b64 = sneaker.imageBase64;
    if (b64 != null && b64.isNotEmpty) {
      final raw = b64.contains(',') ? b64.split(',').last : b64;
      try {
        final bytes = base64Decode(raw);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(),
        );
      } catch (_) {}
    }
    return _placeholder();
  }

  Widget? _imageFromDataUri(String dataUri) {
    try {
      final bytes = base64Decode(dataUri.split(',').last);
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    } catch (_) {
      return null;
    }
  }

  Widget _placeholder() => Container(
    color: Colors.grey.shade100,
    child: const Center(
      child: Icon(Icons.image_not_supported, color: Colors.black26, size: 32),
    ),
  );

  Widget _buildInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sneaker.shopName,
            style: TextStyle(fontSize: 11, color: Colors.black.withOpacity(.4)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            sneaker.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            sneaker.priceEuro,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

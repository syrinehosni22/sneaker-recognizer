import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../domain/models/sneaker.dart';
import '../../../services/sneaker_api_service.dart';
import '../productDetails/details.dart';

// ─── Category models ───────────────────────────────────────────────────────────

class _CatSection {
  final String? group;
  final List<_CatItem> items;
  const _CatSection({this.group, required this.items});
}

class _CatItem {
  final String id;
  final String label;
  final String? count;
  final bool isLeaf;
  const _CatItem({
    required this.id,
    required this.label,
    this.count,
    this.isLeaf = false,
  });
}

// ─── Category tree data ────────────────────────────────────────────────────────

const Map<String, List<_CatSection>> _categoryTree = {
  'root': [
    _CatSection(
      items: [
        _CatItem(id: 'femmes', label: 'Femmes', count: '1.2M articles'),
        _CatItem(id: 'hommes', label: 'Hommes', count: '890K articles'),
        _CatItem(id: 'enfants', label: 'Enfants', count: '640K articles'),
      ],
    ),
  ],
  'femmes': [
    _CatSection(
      items: [
        _CatItem(id: 'f_vetements', label: 'Vêtements', count: '480K'),
        _CatItem(id: 'f_chaussures', label: 'Chaussures', count: '210K'),
        _CatItem(id: 'f_sacs', label: 'Sacs & bagages', count: '95K'),
        _CatItem(id: 'f_accessoires', label: 'Accessoires', count: '130K'),
      ],
    ),
  ],
  'hommes': [
    _CatSection(
      items: [
        _CatItem(id: 'h_vetements', label: 'Vêtements', count: '360K'),
        _CatItem(id: 'h_chaussures', label: 'Chaussures', count: '180K'),
        _CatItem(id: 'h_sacs', label: 'Sacs & bagages', count: '42K'),
        _CatItem(id: 'h_accessoires', label: 'Accessoires', count: '85K'),
      ],
    ),
  ],
  'enfants': [
    _CatSection(
      items: [
        _CatItem(id: 'e_bebe', label: 'Bébé (0-24 mois)', count: '140K'),
        _CatItem(id: 'e_fille', label: 'Fille (2-14 ans)', count: '180K'),
        _CatItem(id: 'e_garcon', label: 'Garçon (2-14 ans)', count: '170K'),
      ],
    ),
  ],

  'f_vetements': [
    _CatSection(
      items: [
        _CatItem(id: 'fv_robes', label: 'Robes', count: '82K', isLeaf: true),
        _CatItem(id: 'fv_jupes', label: 'Jupes', count: '34K', isLeaf: true),
        _CatItem(
          id: 'fv_hauts',
          label: 'Hauts & t-shirts',
          count: '96K',
          isLeaf: true,
        ),
        _CatItem(
          id: 'fv_pantalons',
          label: 'Pantalons & jeans',
          count: '74K',
          isLeaf: true,
        ),
        _CatItem(
          id: 'fv_manteaux',
          label: 'Manteaux & vestes',
          count: '61K',
          isLeaf: true,
        ),
        _CatItem(
          id: 'fv_lingerie',
          label: 'Lingerie & pyjamas',
          count: '29K',
          isLeaf: true,
        ),
        _CatItem(
          id: 'fv_maillots',
          label: 'Maillots de bain',
          count: '11K',
          isLeaf: true,
        ),
      ],
    ),
  ],
  'f_chaussures': [
    _CatSection(
      items: [
        _CatItem(
          id: 'fc_sneakers',
          label: 'Sneakers',
          count: '58K',
          isLeaf: true,
        ),
        _CatItem(
          id: 'fc_talons',
          label: 'Talons & escarpins',
          count: '31K',
          isLeaf: true,
        ),
        _CatItem(
          id: 'fc_bottes',
          label: 'Bottes & bottines',
          count: '44K',
          isLeaf: true,
        ),
        _CatItem(
          id: 'fc_ballerines',
          label: 'Ballerines',
          count: '19K',
          isLeaf: true,
        ),
        _CatItem(
          id: 'fc_sandales',
          label: 'Sandales & nu-pieds',
          count: '24K',
          isLeaf: true,
        ),
      ],
    ),
  ],
  'f_sacs': [
    _CatSection(
      items: [
        _CatItem(
          id: 'fs_main',
          label: 'Sacs à main',
          count: '28K',
          isLeaf: true,
        ),
        _CatItem(id: 'fs_dos', label: 'Sacs à dos', count: '22K', isLeaf: true),
        _CatItem(id: 'fs_tote', label: 'Tote bags', count: '15K', isLeaf: true),
        _CatItem(
          id: 'fs_pochettes',
          label: 'Pochettes',
          count: '12K',
          isLeaf: true,
        ),
        _CatItem(id: 'fs_valises', label: 'Valises', count: '8K', isLeaf: true),
      ],
    ),
  ],
  'f_accessoires': [
    _CatSection(
      items: [
        _CatItem(id: 'fa_bijoux', label: 'Bijoux', count: '55K', isLeaf: true),
        _CatItem(
          id: 'fa_ceintures',
          label: 'Ceintures',
          count: '14K',
          isLeaf: true,
        ),
        _CatItem(
          id: 'fa_echarpes',
          label: 'Écharpes & foulards',
          count: '18K',
          isLeaf: true,
        ),
        _CatItem(
          id: 'fa_chapeaux',
          label: 'Chapeaux & casquettes',
          count: '12K',
          isLeaf: true,
        ),
        _CatItem(
          id: 'fa_lunettes',
          label: 'Lunettes',
          count: '9K',
          isLeaf: true,
        ),
      ],
    ),
  ],
  'h_vetements': [
    _CatSection(
      items: [
        _CatItem(
          id: 'hv_tshirts',
          label: 'T-shirts & polos',
          count: '90K',
          isLeaf: true,
        ),
        _CatItem(
          id: 'hv_chemises',
          label: 'Chemises',
          count: '48K',
          isLeaf: true,
        ),
        _CatItem(
          id: 'hv_pulls',
          label: 'Pulls & sweats',
          count: '55K',
          isLeaf: true,
        ),
        _CatItem(
          id: 'hv_pantalons',
          label: 'Pantalons & jeans',
          count: '70K',
          isLeaf: true,
        ),
        _CatItem(
          id: 'hv_manteaux',
          label: 'Manteaux & vestes',
          count: '52K',
          isLeaf: true,
        ),
        _CatItem(
          id: 'hv_shorts',
          label: 'Shorts & bermudas',
          count: '22K',
          isLeaf: true,
        ),
        _CatItem(
          id: 'hv_costumes',
          label: 'Costumes & blazers',
          count: '16K',
          isLeaf: true,
        ),
      ],
    ),
  ],
  'h_chaussures': [
    _CatSection(
      items: [
        _CatItem(
          id: 'hc_sneakers',
          label: 'Sneakers',
          count: '72K',
          isLeaf: true,
        ),
        _CatItem(
          id: 'hc_boots',
          label: 'Boots & bottines',
          count: '38K',
          isLeaf: true,
        ),
        _CatItem(
          id: 'hc_mocassins',
          label: 'Mocassins & derbies',
          count: '21K',
          isLeaf: true,
        ),
        _CatItem(
          id: 'hc_sandales',
          label: 'Sandales & claquettes',
          count: '18K',
          isLeaf: true,
        ),
      ],
    ),
  ],
  'h_sacs': [
    _CatSection(
      items: [
        _CatItem(id: 'hs_dos', label: 'Sacs à dos', count: '18K', isLeaf: true),
        _CatItem(
          id: 'hs_sport',
          label: 'Sacs de sport',
          count: '12K',
          isLeaf: true,
        ),
        _CatItem(id: 'hs_valises', label: 'Valises', count: '7K', isLeaf: true),
      ],
    ),
  ],
  'h_accessoires': [
    _CatSection(
      items: [
        _CatItem(
          id: 'ha_montres',
          label: 'Montres',
          count: '32K',
          isLeaf: true,
        ),
        _CatItem(
          id: 'ha_ceintures',
          label: 'Ceintures',
          count: '14K',
          isLeaf: true,
        ),
        _CatItem(
          id: 'ha_casquettes',
          label: 'Casquettes & bonnets',
          count: '18K',
          isLeaf: true,
        ),
        _CatItem(
          id: 'ha_lunettes',
          label: 'Lunettes',
          count: '11K',
          isLeaf: true,
        ),
      ],
    ),
  ],
  'e_bebe': [
    _CatSection(
      items: [
        _CatItem(
          id: 'eb_vetements',
          label: 'Vêtements bébé',
          count: '62K',
          isLeaf: true,
        ),
        _CatItem(
          id: 'eb_chaussures',
          label: 'Chaussures bébé',
          count: '18K',
          isLeaf: true,
        ),
        _CatItem(
          id: 'eb_puericulture',
          label: 'Puériculture',
          count: '35K',
          isLeaf: true,
        ),
        _CatItem(
          id: 'eb_jouets',
          label: 'Jouets bébé',
          count: '25K',
          isLeaf: true,
        ),
      ],
    ),
  ],
  'e_fille': [
    _CatSection(
      items: [
        _CatItem(
          id: 'ef_vetements',
          label: 'Vêtements fille',
          count: '80K',
          isLeaf: true,
        ),
        _CatItem(
          id: 'ef_chaussures',
          label: 'Chaussures fille',
          count: '35K',
          isLeaf: true,
        ),
        _CatItem(
          id: 'ef_accessoires',
          label: 'Accessoires',
          count: '22K',
          isLeaf: true,
        ),
      ],
    ),
  ],
  'e_garcon': [
    _CatSection(
      items: [
        _CatItem(
          id: 'eg_vetements',
          label: 'Vêtements garçon',
          count: '75K',
          isLeaf: true,
        ),
        _CatItem(
          id: 'eg_chaussures',
          label: 'Chaussures garçon',
          count: '38K',
          isLeaf: true,
        ),
        _CatItem(
          id: 'eg_accessoires',
          label: 'Accessoires',
          count: '18K',
          isLeaf: true,
        ),
      ],
    ),
  ],
};

const Map<String, String> _categoryLabels = {
  'root': 'Parcourir',
  'femmes': 'Femmes',
  'hommes': 'Hommes',
  'enfants': 'Enfants',
  'f_vetements': 'Vêtements',
  'f_chaussures': 'Chaussures',
  'f_sacs': 'Sacs & bagages',
  'f_accessoires': 'Accessoires',
  'h_vetements': 'Vêtements',
  'h_chaussures': 'Chaussures',
  'h_sacs': 'Sacs & bagages',
  'h_accessoires': 'Accessoires',
  'h_sport': 'Sport & loisirs',
  'e_bebe': 'Bébé',
  'e_fille': 'Fille',
  'e_garcon': 'Garçon',
};

// ─── Screen ────────────────────────────────────────────────────────────────────

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;
  List<Sneaker> _results = [];
  final Set<String> _liked = {};
  int _searchToken = 0;

  // Category tree navigation
  List<String> _catPath = ['root'];

  // ── Getters ────────────────────────────────────────────────────────────────
  String get _currentCatId => _catPath.last;
  List<_CatSection> get _currentSections => _categoryTree[_currentCatId] ?? [];
  bool get _isRoot => _currentCatId == 'root';
  bool get _isSearching => _controller.text.trim().isNotEmpty;

  String get _searchQuery {
    final text = _controller.text.trim();
    // Build a meaningful query from path + text
    final pathLabels = _catPath
        .skip(1)
        .map((id) => _categoryLabels[id] ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
    return [...pathLabels, text].join(' ').trim();
  }

  // ── Search ─────────────────────────────────────────────────────────────────
  Future<void> _search(String value) async {
    final query = _searchQuery;
    if (query.isEmpty) {
      setState(() {
        _results = [];
        _loading = false;
      });
      return;
    }

    _searchToken++;
    final token = _searchToken;
    setState(() {
      _loading = true;
      _results = [];
    });

    try {
      final response = await SneakerApiService.searchSneakerByName(query);
      if (token != _searchToken) return;
      final List<dynamic> raw = response['results'] ?? [];
      setState(() {
        _results = raw.map((e) => Sneaker.fromJson(e)).toList();
        _loading = false;
      });
    } catch (_) {
      if (token != _searchToken) return;
      setState(() {
        _results = [];
        _loading = false;
      });
    }
  }

  // ── Category navigation ────────────────────────────────────────────────────
  void _navigateCat(_CatItem item) {
    if (item.isLeaf) {
      // Leaf → use label as search query
      _controller.text = item.label;
      setState(() {
        _results = [];
      });
      _search(item.label);
    } else if (_categoryTree.containsKey(item.id)) {
      setState(() {
        _catPath.add(item.id);
        _results = [];
      });
    }
  }

  void _catBack() {
    if (_catPath.length > 1) setState(() => _catPath.removeLast());
  }

  void _clearSearch() {
    _controller.clear();
    setState(() {
      _results = [];
      _catPath = ['root'];
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: _isSearching
                  ? _buildSearchResults()
                  : _buildCategoryTree(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Search bar ─────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(14),
        ),
        child: TextField(
          controller: _controller,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          onChanged: (v) {
            setState(() {});
            if (v.trim().length > 2) {
              _search(v);
            } else if (v.trim().isEmpty) {
              setState(() => _results = []);
            }
          },
          decoration: InputDecoration(
            hintText: 'Rechercher...',
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(.45),
              fontSize: 15,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.white.withOpacity(.6),
              size: 20,
            ),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Colors.white.withOpacity(.6),
                      size: 18,
                    ),
                    onPressed: _clearSearch,
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  // ── Category tree ──────────────────────────────────────────────────────────
  Widget _buildCategoryTree() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          if (_isRoot)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 20),
              child: Text(
                'Parcourir',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -.6,
                  color: Colors.black,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _catBack,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 1.5),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        size: 17,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _categoryLabels[_currentCatId] ?? '',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -.6,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

          // List items
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _currentSections
                  .expand((section) => section.items)
                  .map(
                    (item) =>
                        _CatRow(item: item, onTap: () => _navigateCat(item)),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Search results ─────────────────────────────────────────────────────────
  Widget _buildSearchResults() {
    if (_loading) return _buildSkeleton();
    if (_results.isEmpty) return _buildEmptyState();

    return Column(
      children: [
        // Meta bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_results.length} résultats',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black.withOpacity(.4),
                ),
              ),
              const Row(
                children: [
                  Icon(Icons.swap_vert, size: 16, color: Colors.black),
                  SizedBox(width: 4),
                  Text(
                    'Pertinence',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.68,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: _results.length,
            itemBuilder: (context, index) {
              final sneaker = _results[index];
              return _SneakerCard(
                sneaker: sneaker,
                liked: _liked.contains(sneaker.id),
                onLike: () => setState(() {
                  _liked.contains(sneaker.id)
                      ? _liked.remove(sneaker.id)
                      : _liked.add(sneaker.id);
                }),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailsPage(
                      sneaker: sneaker,
                      allSneakers: _results,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Skeleton ───────────────────────────────────────────────────────────────
  Widget _buildSkeleton() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => const _SkeletonCard(),
    );
  }

  // ── Empty state ────────────────────────────────────────────────────────────
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
            'Aucun résultat',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              letterSpacing: -.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Essayez un autre terme',
            style: TextStyle(fontSize: 14, color: Colors.black.withOpacity(.4)),
          ),
        ],
      ),
    );
  }
}

// ─── Category row ──────────────────────────────────────────────────────────────

class _CatRow extends StatefulWidget {
  final _CatItem item;
  final VoidCallback onTap;
  const _CatRow({required this.item, required this.onTap});

  @override
  State<_CatRow> createState() => _CatRowState();
}

class _CatRowState extends State<_CatRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: _pressed ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black, width: 1.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.item.label,
                style: TextStyle(
                  fontSize: 15,
                  color: _pressed ? Colors.white : Colors.black,
                ),
              ),
            ),
            if (widget.item.count != null)
              Text(
                widget.item.count!,
                style: TextStyle(
                  fontSize: 12,
                  color: _pressed
                      ? Colors.white.withOpacity(.5)
                      : Colors.black.withOpacity(.35),
                ),
              ),
            const SizedBox(width: 10),
            Icon(
              Icons.chevron_right,
              size: 16,
              color: _pressed ? Colors.white : Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sneaker card ──────────────────────────────────────────────────────────────

class _SneakerCard extends StatelessWidget {
  final Sneaker sneaker;
  final bool liked;
  final VoidCallback onLike;
  final VoidCallback onTap;

  const _SneakerCard({
    required this.sneaker,
    required this.liked,
    required this.onLike,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
                color: liked ? Colors.black : Colors.black,
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
      final raw = dataUri.split(',').last;
      final bytes = base64Decode(raw);
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    } catch (_) {
      return null;
    }
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey.shade100,
      child: const Center(
        child: Icon(Icons.image_not_supported, color: Colors.black26, size: 32),
      ),
    );
  }

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

// ─── Skeleton card ─────────────────────────────────────────────────────────────

class _SkeletonCard extends StatefulWidget {
  const _SkeletonCard();

  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
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
            Expanded(child: Container(color: Colors.grey.shade100)),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 4),
              child: Container(
                height: 10,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 4, 10, 12),
              child: Container(
                height: 10,
                width: 70,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

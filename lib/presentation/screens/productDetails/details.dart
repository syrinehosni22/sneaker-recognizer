import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../domain/models/sneaker.dart';
import '../../../services/cart_service.dart';

class ProductDetailsPage extends StatefulWidget {
  final Sneaker sneaker;
  final List<Sneaker> allSneakers;

  const ProductDetailsPage({
    super.key,
    required this.sneaker,
    required this.allSneakers,
  });

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  late Sneaker _current;
  bool _addedToCart = false;

  @override
  void initState() {
    super.initState();
    _current = widget.sneaker;
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  List<Sneaker> get _otherOffers =>
      widget.allSneakers.where((s) => s.id != _current.id).toList();

  Future<void> _openLink(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _addToCart() {
    context.read<CartService>().addSneaker(_current);
    setState(() => _addedToCart = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Added to cart',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
            GestureDetector(
              onTap: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
              child: const Icon(Icons.close, color: Colors.white54, size: 16),
            ),
          ],
        ),
      ),
    );
    // Reset button after 2s
    Future.delayed(
      const Duration(seconds: 2),
      () => mounted ? setState(() => _addedToCart = false) : null,
    );
  }

  void _buyNow() {
    context.read<CartService>().addSneaker(_current);
    Navigator.pushNamed(context, '/cart');
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildImage()),
          SliverToBoxAdapter(child: _buildInfo()),
          SliverToBoxAdapter(child: _buildShopRow()),
          if (_otherOffers.isNotEmpty) ...[
            SliverToBoxAdapter(child: _buildSectionTitle('Other offers')),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _OfferRow(
                    sneaker: _otherOffers[i],
                    onTap: () => setState(() {
                      _current = _otherOffers[i];
                      _addedToCart = false;
                    }),
                    onBuy: () => _openLink(_otherOffers[i].shopUrl),
                  ),
                  childCount: _otherOffers.length,
                ),
              ),
            ),
          ] else
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ── App bar ────────────────────────────────────────────────────────────────

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      pinned: true,
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
      title: Text(
        _current.shopName,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
      actions: [
        if (_current.isMember)
          Container(
            margin: const EdgeInsets.fromLTRB(0, 12, 8, 12),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text(
                'Partner',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        // Cart icon with count
        Consumer<CartService>(
          builder: (_, cart, __) => Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.black,
                ),
                onPressed: () => Navigator.pushNamed(context, '/cart'),
              ),
              if (cart.items.isNotEmpty)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${cart.items.length}',
                        style: const TextStyle(
                          fontSize: 9,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ── Hero image ─────────────────────────────────────────────────────────────

  Widget _buildImage() {
    return Container(
      height: 300,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      clipBehavior: Clip.hardEdge,
      child: _resolveImage(_current),
    );
  }

  // ── Product info ───────────────────────────────────────────────────────────

  Widget _buildInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            _current.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              letterSpacing: -.3,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 14),

          // Price row
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _current.priceEuro,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  letterSpacing: -.5,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'incl. taxes',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black.withOpacity(.35),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _divider(),
        ],
      ),
    );
  }

  // ── Shop row ───────────────────────────────────────────────────────────────

  Widget _buildShopRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shop info
          GestureDetector(
            onTap: () => _openLink(_current.shopUrl),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.storefront_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _current.shopName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            if (_current.isMember) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Partner',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tap to visit shop',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black.withOpacity(.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.open_in_new,
                    size: 16,
                    color: Colors.black.withOpacity(.4),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _divider(),
        ],
      ),
    );
  }

  // ── Section title ──────────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.black,
          letterSpacing: -.3,
        ),
      ),
    );
  }

  Widget _divider() =>
      Container(height: 1, color: Colors.black.withOpacity(.08));

  // ── Bottom action bar ──────────────────────────────────────────────────────

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black, width: 1.5)),
      ),
      child: Row(
        children: [
          // Add to cart
          Expanded(
            child: GestureDetector(
              onTap: _addToCart,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 52,
                decoration: BoxDecoration(
                  color: _addedToCart ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _addedToCart
                            ? Icons.check
                            : Icons.shopping_bag_outlined,
                        size: 18,
                        color: _addedToCart ? Colors.white : Colors.black,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _addedToCart ? 'Added!' : 'Add to cart',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _addedToCart ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Buy now
          Expanded(
            child: GestureDetector(
              onTap: _buyNow,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text(
                    'Buy now',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Image resolver ─────────────────────────────────────────────────────────

  Widget _resolveImage(Sneaker s) {
    final url = s.imageUrl ?? s.thumbnail;
    if (url != null && url.isNotEmpty) {
      if (url.startsWith('data:image')) {
        return _imageFromDataUri(url) ?? _placeholder();
      }
      return Image.network(
        url,
        fit: BoxFit.contain,
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : Container(color: Colors.grey.shade100),
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    final b64 = s.imageBase64;
    if (b64 != null && b64.isNotEmpty) {
      final raw = b64.contains(',') ? b64.split(',').last : b64;
      try {
        return Image.memory(
          base64Decode(raw),
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _placeholder(),
        );
      } catch (_) {}
    }
    return _placeholder();
  }

  Widget? _imageFromDataUri(String uri) {
    try {
      final bytes = base64Decode(uri.split(',').last);
      return Image.memory(
        bytes,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    } catch (_) {
      return null;
    }
  }

  Widget _placeholder() => const Center(
    child: Icon(Icons.image_not_supported, color: Colors.black26, size: 40),
  );
}

// ─── Other offer row ───────────────────────────────────────────────────────────

class _OfferRow extends StatefulWidget {
  final Sneaker sneaker;
  final VoidCallback onTap;
  final VoidCallback onBuy;

  const _OfferRow({
    required this.sneaker,
    required this.onTap,
    required this.onBuy,
  });

  @override
  State<_OfferRow> createState() => _OfferRowState();
}

class _OfferRowState extends State<_OfferRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.sneaker;
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _pressed ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black, width: 1.5),
        ),
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              clipBehavior: Clip.hardEdge,
              child: _thumb(s),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          s.shopName,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: _pressed ? Colors.white : Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (s.isMember)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _pressed ? Colors.white : Colors.black,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Partner',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              color: _pressed ? Colors.black : Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    s.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: _pressed
                          ? Colors.white.withOpacity(.6)
                          : Colors.black.withOpacity(.45),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Price + buy
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  s.priceEuro,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _pressed ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: widget.onBuy,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _pressed ? Colors.white : Colors.black,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Buy',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _pressed ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _thumb(Sneaker s) {
    final url = s.imageUrl ?? s.thumbnail;
    if (url != null && url.isNotEmpty && !url.startsWith('data:')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.image_not_supported,
          size: 20,
          color: Colors.black26,
        ),
      );
    }
    return const Icon(
      Icons.image_not_supported,
      size: 20,
      color: Colors.black26,
    );
  }
}

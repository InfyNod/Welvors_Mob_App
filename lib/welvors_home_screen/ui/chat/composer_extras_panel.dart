import 'package:flutter/material.dart';
import 'package:flutter_giphy_picker/giphy_ui.dart';

import 'package:velvors/onbording_allpage/theme/app_colors.dart';
import 'package:velvors/onbording_allpage/theme/app_text.dart';
import 'package:velvors/welvors_home_screen/services/gift_api_service.dart';

/// One item inside a gift grid.
class GiftItem {
  final int id;
  final String name;
  final String emoji;
  final int coins;
  final String image;
  final String triggerLine;
  final String receiverLine;
  final int categoryId;

  const GiftItem(
    this.name,
    this.emoji,
    this.coins, {
    this.id = 0,
    this.image = '',
    this.triggerLine = '',
    this.receiverLine = '',
    this.categoryId = 0,
  });

  factory GiftItem.fromApi(ApiGift gift) => GiftItem(
    gift.name,
    '',
    gift.coinCost,
    id: gift.id,
    image: gift.image,

    triggerLine: gift.triggerLine,
    receiverLine: gift.receiverLine,
    categoryId: gift.categoryId,
  );
}

/// One item inside a GIF grid.
class GifItem {
  final String label;

  const GifItem(this.label);
}

/// Composer extras:
/// Emoji / Stickers / Meme & Fun / Effects / GIF / Gifts
class ComposerExtrasPanel extends StatefulWidget {
  final int initialTab;
  final ValueChanged<String> onEmojiSelected;
  final ValueChanged<String> onStickerSelected;
  final void Function(String emoji, String label) onMemeSelected;
  final void Function(String emoji, String label) onEffectSelected;

  /// [url] = selected GIPHY GIF URL
  /// [category] = selected category
  final void Function(String url, String category) onGifSelected;

  final void Function(GiftItem gift) onGiftSelected;

  const ComposerExtrasPanel({
    super.key,
    this.initialTab = 0,
    required this.onEmojiSelected,
    required this.onStickerSelected,
    required this.onMemeSelected,
    required this.onEffectSelected,
    required this.onGifSelected,
    required this.onGiftSelected,
  });

  @override
  State<ComposerExtrasPanel> createState() => _ComposerExtrasPanelState();
}

class _ComposerExtrasPanelState extends State<ComposerExtrasPanel> {
  late int _mainTab = widget.initialTab;
  GiftItem? _selectedGift;
  List<GiftCategory> _apiGiftCategories = const [];
  List<ApiGift> _apiGifts = const [];
  bool _giftLoading = false;
  String? _giftError;

  @override
  void initState() {
    super.initState();
    if (_mainTab == 5) {
      _loadGifts();
    }
  }

  Future<void> _loadGifts() async {
    if (_giftLoading) return;
    setState(() {
      _giftLoading = true;
      _giftError = null;
    });
    try {
      final catalog = await GiftApiService.fetchCatalog();
      if (!mounted) return;
      setState(() {
        _apiGiftCategories = catalog.categories;
        _apiGifts = catalog.gifts;
        _giftCategory = _giftCategory.clamp(
          0,
          catalog.categories.isEmpty ? 0 : catalog.categories.length - 1,
        );
        _giftLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Gift catalog load failed: $e');
      if (!mounted) return;
      setState(() {
        _giftLoading = false;
        _giftError = e.toString();
      });
    }
  }

  @override
  void didUpdateWidget(covariant ComposerExtrasPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) {
      setState(() {
        _mainTab = widget.initialTab;
        _selectedGift = null;
      });
      if (_mainTab == 5 && _apiGifts.isEmpty) {
        _loadGifts();
      }
    }
  }

  int _stickerCategory = 0;
  int _gifCategory = 0;
  int _giftCategory = 0;

  // --------------------------------------------------------------
  // GIPHY API KEY
  // --------------------------------------------------------------

  /// Replace this with your GIPHY API key.
  static const String _giphyApiKey = 'YOUR_GIPHY_API_KEY';

  // --------------------------------------------------------------
  // MAIN TABS
  // --------------------------------------------------------------

  static const List<Map<String, dynamic>> _mainTabs = [
    {'label': 'Emoji', 'icon': '😀'},
    {'label': 'Stickers', 'icon': '😍'},
    {'label': 'Meme & Fun', 'icon': '😂'},
    {'label': 'Effects', 'icon': '🎉'},
    {'label': 'GIF', 'icon': '🎬'},
    {'label': 'Gifts', 'icon': '🎁'},
  ];

  // --------------------------------------------------------------
  // EMOJI
  // --------------------------------------------------------------

  static const List<String> _emojis = [
    '😀',
    '😁',
    '😂',
    '🤣',
    '😊',
    '😍',
    '🥰',
    '😘',
    '😉',
    '😎',
    '🤩',
    '🤔',
    '👍',
    '👎',
    '🙏',
    '👏',
    '🎉',
    '❤️',
    '💕',
    '💖',
    '💗',
    '💘',
    '💝',
    '🔥',
    '✨',
    '🌹',
    '🥂',
    '🍷',
    '🎂',
    '😴',
    '🥳',
    '😇',
  ];

  // --------------------------------------------------------------
  // STICKERS
  // --------------------------------------------------------------

  static const List<String> _stickerCategories = [
    'Love',
    'Cute',
    'Reactions',
    'Flirty',
    'Hearts',
    'Celebrations',
  ];

  static const Map<String, List<String>> _stickers = {
    'Love': ['😍', '🥰', '😘', '💖', '💓', '💞', '😻', '🫶', '👩‍❤️‍👨', '💍'],
    'Cute': ['🐻', '🐰', '🐶', '🐱', '🦄', '🐼', '🧸', '🌸'],
    'Reactions': ['😂', '😮', '😢', '😡', '👀', '🙌', '👏', '🤯'],
    'Flirty': ['😏', '😉', '💋', '🔥', '😈', '👅', '💦', '🍑'],
    'Hearts': ['❤️', '🧡', '💛', '💚', '💙', '💜', '🖤', '🤍'],
    'Celebrations': ['🎉', '🎊', '🥳', '🍾', '🎂', '🎈', '🏆', '✨'],
  };

  // --------------------------------------------------------------
  // MEMES
  // --------------------------------------------------------------

  static const List<Map<String, String>> _memes = [
    {'emoji': '😂', 'label': 'LOL'},
    {'emoji': '🙈', 'label': 'Oops'},
    {'emoji': '🤦', 'label': 'Facepalm'},
    {'emoji': '😏', 'label': 'Sus'},
    {'emoji': '🫠', 'label': 'Melting'},
    {'emoji': '🤡', 'label': 'Clown'},
    {'emoji': '💀', 'label': 'Dead'},
    {'emoji': '🥴', 'label': 'Woozy'},
    {'emoji': '🙄', 'label': 'Whatever'},
    {'emoji': '😤', 'label': 'Fuming'},
  ];

  // --------------------------------------------------------------
  // EFFECTS
  // --------------------------------------------------------------

  static const List<Map<String, String>> _effects = [
    {'emoji': '🎊', 'label': 'Effect'},
    {'emoji': '❤️', 'label': 'Heart Rain'},
    {'emoji': '🌹', 'label': 'Rose Petals'},
    {'emoji': '🎈', 'label': 'Balloons'},
    {'emoji': '✨', 'label': 'Sparkles'},
    {'emoji': '🎆', 'label': 'Fireworks'},
    {'emoji': '💖', 'label': 'Love Burst'},
    {'emoji': '🦋', 'label': 'Butterflies'},
    {'emoji': '⭐', 'label': 'Stars'},
    {'emoji': '🥂', 'label': 'Cheers'},
  ];

  // --------------------------------------------------------------
  // GIF CATEGORIES
  // --------------------------------------------------------------

  static const List<String> _gifCategories = [
    'Romance',
    'Flirty',
    'Say hi',
    'Miss you',
    'Good night',
  ];

  // --------------------------------------------------------------
  // GIF SEARCH QUERIES
  // --------------------------------------------------------------

  static const Map<String, String> _gifSearchQueries = {
    'Romance': 'romance love romantic couple',
    'Flirty': 'flirty wink kiss love',
    'Say hi': 'hello hi hey greeting',
    'Miss you': 'miss you missing you love',
    'Good night': 'good night sweet dreams sleep',
  };

  // --------------------------------------------------------------
  // GIF PREVIEW EMOJIS
  // --------------------------------------------------------------

  static const Map<String, List<String>> _gifPreviewItems = {
    'Romance': ['❤️', '💋', '🥰', '🌹'],
    'Flirty': ['😉', '😏', '💋', '🔥'],
    'Say hi': ['👋', '😊', '🙌', '🥳'],
    'Miss you': ['🥺', '💔', '😢', '🫶'],
    'Good night': ['🌙', '😴', '⭐', '💤'],
  };

  // --------------------------------------------------------------
  // GIFTS
  // --------------------------------------------------------------

  static const List<String> _giftCategories = [
    'Flowers',
    'Treats',
    'Cute Gifts',
    'Jewellery',
    'Fashion',
  ];

  static const Map<String, List<GiftItem>> _gifts = {
    'Flowers': [
      GiftItem('Single rose', '🌹', 10),
      GiftItem('Bouquet', '💐', 50),
      GiftItem('Tulips', '🌷', 35),
      GiftItem('Blossoms', '🌸', 30),
      GiftItem('Dried rose', '🥀', 15),
      GiftItem('Lotus', '🪷', 40),
      GiftItem('Sunflower', '🌻', 25),
      GiftItem('White rose', '🤍', 20),
      GiftItem('Red tulip', '🌷', 30),
      GiftItem('Lavender', '🪻', 35),
      GiftItem('Cherry blossom', '🌸', 45),
      GiftItem('Orchid', '🌺', 55),
      GiftItem('Flower crown', '💐', 70),
      GiftItem('Golden rose', '🌹', 100),
      GiftItem('Heart flowers', '💮', 65),
      GiftItem('Spring bouquet', '🌼', 80),
    ],
    'Treats': [
      GiftItem('Cake', '🍰', 25),
      GiftItem('Chocolate', '🍫', 15),
      GiftItem('Ice cream', '🍨', 20),
      GiftItem('Coffee', '☕', 10),
      GiftItem('Donut', '🍩', 12),
      GiftItem('Cookies', '🍪', 18),
      GiftItem('Cupcake', '🧁', 20),
      GiftItem('Candy', '🍬', 10),
      GiftItem('Lollipop', '🍭', 15),
      GiftItem('Macaron', '🍡', 28),
      GiftItem('Strawberry', '🍓', 16),
      GiftItem('Pizza', '🍕', 22),
      GiftItem('Sushi', '🍣', 35),
      GiftItem('Hot chocolate', '☕', 18),
      GiftItem('Sweet box', '🍱', 45),
      GiftItem('Birthday cake', '🎂', 60),
    ],
    'Cute Gifts': [
      GiftItem('Teddy bear', '🧸', 45),
      GiftItem('Balloon', '🎈', 15),
      GiftItem('Bunny', '🐰', 60),
      GiftItem('Puppy', '🐶', 70),
      GiftItem('Kitten', '🐱', 65),
      GiftItem('Panda', '🐼', 55),
      GiftItem('Koala', '🐨', 50),
      GiftItem('Penguin', '🐧', 48),
      GiftItem('Unicorn', '🦄', 75),
      GiftItem('Baby chick', '🐥', 35),
      GiftItem('Duckling', '🦆', 32),
      GiftItem('Frog', '🐸', 30),
      GiftItem('Monkey', '🐵', 42),
      GiftItem('Panda hug', '🤗', 58),
      GiftItem('Cute hearts', '🥰', 65),
      GiftItem('Magic star', '🌟', 80),
    ],
    'Jewellery': [
      GiftItem('Ring', '💍', 200),
      GiftItem('Necklace', '📿', 150),
      GiftItem('Bracelet', '📿', 100),
      GiftItem('Earrings', '💎', 90),
      GiftItem('Crown', '👑', 250),
      GiftItem('Watch', '⌚', 180),
      GiftItem('Diamond', '💎', 300),
      GiftItem('Gold ring', '💍', 280),
      GiftItem('Pearl', '🫧', 220),
      GiftItem('Ruby', '🔴', 350),
      GiftItem('Sapphire', '🔵', 360),
      GiftItem('Gold chain', '⛓️', 275),
      GiftItem('Tiara', '👸', 240),
      GiftItem('Silver ring', '💠', 190),
      GiftItem('Luxury gem', '🔶', 400),
      GiftItem('Diamond box', '🎁', 450),
    ],
    'Fashion': [
      GiftItem('Dress', '👗', 120),
      GiftItem('Handbag', '👜', 140),
      GiftItem('Shoes', '👠', 110),
      GiftItem('Sunglasses', '🕶️', 60),
      GiftItem('Scarf', '🧣', 40),
      GiftItem('Hat', '👒', 35),
      GiftItem('Saree', '🥻', 160),
      GiftItem('Jacket', '🧥', 130),
      GiftItem('Heels', '👠', 145),
      GiftItem('Sneakers', '👟', 100),
      GiftItem('Tie', '👔', 75),
      GiftItem('Purse', '👛', 125),
      GiftItem('Watch band', '⌚', 95),
      GiftItem('Sunglasses gold', '🕶️', 110),
      GiftItem('Fashion crown', '👑', 200),
      GiftItem('Silk gloves', '🧤', 65),
    ],
  };

  // --------------------------------------------------------------
  // BUILD
  // --------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight:
              MediaQuery.of(context).size.height *
              (_mainTab == 5 ? 0.50 : 0.30),
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.line)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_mainTab != 5) ...[
              _buildMainTabBar(),
              const Divider(height: 1, color: AppColors.line),
            ],

            Flexible(child: _buildTabContent()),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------
  // MAIN TAB BAR
  // --------------------------------------------------------------

  Widget _buildMainTabBar() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        itemCount: _mainTabs.length,
        itemBuilder: (context, index) {
          final selected = index == _mainTab;
          final data = _mainTabs[index];

          return GestureDetector(
            onTap: () {
              setState(() {
                _mainTab = index;
              });
            },
            child: Container(
              width: MediaQuery.of(context).size.width / 4.65,
              padding: const EdgeInsets.symmetric(vertical: 8),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: selected ? AppColors.primarySoft : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(data['icon'], style: const TextStyle(fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(
                    data['label'],
                    textAlign: TextAlign.center,
                    style: AppText.pill.copyWith(
                      fontSize: 8,
                      color: selected ? AppColors.primary : AppColors.ink60,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --------------------------------------------------------------
  // TAB CONTENT
  // --------------------------------------------------------------

  Widget _buildTabContent() {
    switch (_mainTab) {
      case 0:
        return _emojiGrid();

      case 1:
        return _categorizedGrid(
          categories: _stickerCategories,
          selected: _stickerCategory,
          onCategory: (i) {
            setState(() {
              _stickerCategory = i;
            });
          },
          builder: () {
            return _emojiTileGrid(
              _stickers[_stickerCategories[_stickerCategory]]!,
              onTap: widget.onStickerSelected,
            );
          },
        );

      case 2:
        return _memeGrid();

      case 3:
        return _effectsGrid();

      case 4:
        return _gifPanel();

      case 5:
        return _giftPanel();

      default:
        return const SizedBox.shrink();
    }
  }

  // --------------------------------------------------------------
  // CATEGORY WRAPPER
  // --------------------------------------------------------------

  Widget _categorizedGrid({
    required List<String> categories,
    required int selected,
    required ValueChanged<int> onCategory,
    required Widget Function() builder,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final isSelected = index == selected;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => onCategory(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.canvas,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.line,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      categories[index],
                      style: AppText.pill.copyWith(
                        fontSize: 12.5,
                        color: isSelected ? Colors.white : AppColors.ink60,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        Flexible(child: builder()),
      ],
    );
  }

  // --------------------------------------------------------------
  // EMOJI GRID
  // --------------------------------------------------------------

  Widget _emojiGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: _emojis.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
      ),
      itemBuilder: (context, index) {
        final emoji = _emojis[index];

        return GestureDetector(
          onTap: () {
            widget.onEmojiSelected(emoji);
          },
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 24)),
          ),
        );
      },
    );
  }

  // --------------------------------------------------------------
  // STICKER GRID
  // --------------------------------------------------------------

  Widget _emojiTileGrid(
    List<String> items, {
    required ValueChanged<String> onTap,
  }) {
    return GridView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final emoji = items[index];

        return GestureDetector(
          onTap: () => onTap(emoji),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.canvas,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 30)),
          ),
        );
      },
    );
  }

  // --------------------------------------------------------------
  // MEME GRID
  // --------------------------------------------------------------

  Widget _memeGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: _memes.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.95,
      ),
      itemBuilder: (context, index) {
        final meme = _memes[index];

        return GestureDetector(
          onTap: () {
            widget.onMemeSelected(meme['emoji']!, meme['label']!);
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.canvas,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(meme['emoji']!, style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 6),
                Text(
                  meme['label']!,
                  style: AppText.pill.copyWith(
                    fontSize: 11,
                    color: AppColors.ink60,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --------------------------------------------------------------
  // EFFECTS GRID
  // --------------------------------------------------------------

  Widget _effectsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: _effects.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.05,
      ),
      itemBuilder: (context, index) {
        final effect = _effects[index];

        return GestureDetector(
          onTap: () {
            widget.onEffectSelected(effect['emoji']!, effect['label']!);
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.canvas,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(effect['emoji']!, style: const TextStyle(fontSize: 26)),
                const SizedBox(height: 6),
                Text(
                  effect['label']!,
                  textAlign: TextAlign.center,
                  style: AppText.pill.copyWith(
                    fontSize: 11,
                    color: AppColors.ink60,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --------------------------------------------------------------
  // GIF PANEL
  // --------------------------------------------------------------
  Widget _gifPanel() {
    return Column(
      children: [
        // Category tabs
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            itemCount: _gifCategories.length,
            itemBuilder: (context, index) {
              final selected = index == _gifCategory;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _gifCategory = index;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.canvas,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.line,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      // ✅ IMPORTANT FIX
                      _gifCategories[index],
                      style: AppText.pill.copyWith(
                        fontSize: 12.5,
                        color: selected ? Colors.white : AppColors.ink60,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // GIF content
        Expanded(child: _gifCategoryContent(_gifCategories[_gifCategory])),
      ],
    );
  }

  // --------------------------------------------------------------
  // GIF CATEGORY CONTENT
  // --------------------------------------------------------------

  Widget _gifCategoryContent(String category) {
    final previewItems = _gifPreviewItems[category] ?? const [];

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.zero,
              itemCount: previewItems.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.25,
              ),
              itemBuilder: (context, index) {
                final emoji = previewItems[index];

                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.canvas,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Text(emoji, style: const TextStyle(fontSize: 34)),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton.icon(
              onPressed: () {
                _openGiphyPicker(category);
              },
              icon: const Text('🎬', style: TextStyle(fontSize: 18)),
              label: Text(
                'Browse $category GIFs',
                style: AppText.pill.copyWith(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------
  // OPEN GIPHY
  // --------------------------------------------------------------

  Future<void> _openGiphyPicker(String category) async {
    // if (_giphyApiKey == 'YOUR_GIPHY_API_KEY') {
    //   if (!mounted) return;

    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Please add your GIPHY API key first.')),
    //   );

    //   return;
    // }

    final config = GiphyUIConfig(
      apiKey: _giphyApiKey,
      // useSafeArea: true,
      // useAlertDialog:
      //     MediaQuery.sizeOf(context).width > 600,
    );

    final result = await showGiphyPicker(context, config);

    if (!mounted || result == null) {
      return;
    }

    // Send selected GIF URL to ChatDetailScreen.
    // widget.onGifSelected(result.url, category);
  }

  // --------------------------------------------------------------
  // GIFTS GRID
  // --------------------------------------------------------------

  Widget _giftPanel() {
    if (_giftLoading) return const Center(child: CircularProgressIndicator());
    if (_giftError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Unable to load gifts'),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: _loadGifts, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_apiGiftCategories.isEmpty) {
      return Center(
        child: OutlinedButton(
          onPressed: _loadGifts,
          child: const Text('Load Gifts'),
        ),
      );
    }
    final category =
        _apiGiftCategories[_giftCategory.clamp(
          0,
          _apiGiftCategories.length - 1,
        )];
    final gifts = _apiGifts
        .where((g) => g.categoryId == category.id)
        .map(GiftItem.fromApi)
        .toList();
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFE9F3), Color(0xFFF0EDFF)],
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Image.asset('assets/gift.png', height: 56, width: 56),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Send a Gift', style: AppText.h2),
                        const SizedBox(height: 2),
                        Text(
                          'Choose a gift to send to your match',
                          style: AppText.sub.copyWith(fontSize: 11.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 35,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _apiGiftCategories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, index) {
                    final selected = index == _giftCategory;
                    return GestureDetector(
                      onTap: () => setState(() {
                        _giftCategory = index;
                        _selectedGift = null;
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primaryDark
                              : Colors.white70,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _apiGiftCategories[index].name,
                          style: AppText.pill.copyWith(
                            fontSize: 11,
                            color: selected ? Colors.white : AppColors.ink60,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: gifts.isEmpty
              ? const Center(child: Text('No gifts available'))
              : _giftTileGrid(gifts),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          child: SizedBox(
            width: double.infinity,
            height: 44,
            child: FilledButton(
              onPressed: _selectedGift == null
                  ? null
                  : () => widget.onGiftSelected(_selectedGift!),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                disabledBackgroundColor: AppColors.soft,
                foregroundColor: Colors.white,
                disabledForegroundColor: AppColors.muted,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                _selectedGift == null
                    ? 'Select a gift'
                    : 'Send ${_selectedGift!.name}',
                style: AppText.pill.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _giftTileGrid(List<GiftItem> items) {
    return GridView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (_, index) {
        final gift = items[index];
        final selected =
            _selectedGift?.categoryId == gift.categoryId &&
            _selectedGift?.name == gift.name;
        return GestureDetector(
          onTap: () => setState(() => _selectedGift = gift),
          child: Container(
            decoration: BoxDecoration(
              color: selected ? AppColors.primarySoft : const Color(0xFFFFFDFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.line,
                width: selected ? 2 : 1,
              ),
            ),
            // padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: gift.image.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                          child: Image.network(
                            gift.image,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.card_giftcard_rounded,
                              size: 34,
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            gift.emoji.isEmpty ? '🎁' : gift.emoji,
                            style: const TextStyle(fontSize: 30),
                          ),
                        ),
                ),
                const SizedBox(height: 15),
                Text(
                  gift.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.pill.copyWith(
                    fontSize: 11.5,
                    color: AppColors.ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🪙', style: TextStyle(fontSize: 11)),
                    const SizedBox(width: 3),
                    Text(
                      '${gift.coins}',
                      style: AppText.pill.copyWith(
                        fontSize: 11.5,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        );
      },
    );
  }
}

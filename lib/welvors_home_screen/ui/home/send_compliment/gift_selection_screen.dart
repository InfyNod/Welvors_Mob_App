import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'package:velvors/onbording_allpage/theme/app_colors.dart';
import 'package:velvors/onbording_allpage/theme/app_text.dart';

class SelectedGift {
  final int id;
  final String name;
  final String emoji;
  final int coins;
  final String message;

  const SelectedGift({
    required this.id,
    required this.name,
    required this.emoji,
    required this.coins,
    this.message = '',
  });
}

class GiftSelectionScreen extends StatefulWidget {
  final String? recipientName;

  const GiftSelectionScreen({super.key, this.recipientName});

  @override
  State<GiftSelectionScreen> createState() => _GiftSelectionScreenState();
}

class _GiftSelectionScreenState extends State<GiftSelectionScreen> {
  static const _categories = ['Romantic', 'Luxury', 'Cute', 'Experiences'];
  static const _categoryIcons = ['🌹', '💎', '🧸', '🎟️'];

  static const _giftsByCategory = <String, List<SelectedGift>>{
    'Romantic': [
      SelectedGift(id: 1, name: 'Red Roses', emoji: '🌹', coins: 850),
      SelectedGift(id: 2, name: 'Love Letter', emoji: '💌', coins: 300),
      SelectedGift(id: 3, name: 'Diamond Heart', emoji: '💖', coins: 2800),
      SelectedGift(id: 4, name: 'Heart Balloon', emoji: '🎈', coins: 450),
      SelectedGift(id: 5, name: 'Rose Bouquet', emoji: '💐', coins: 1500),
      SelectedGift(id: 6, name: 'Couple Rings', emoji: '💑', coins: 2200),
      SelectedGift(id: 7, name: 'Love Crown', emoji: '💕', coins: 1750),
    ],
    'Luxury': [
      SelectedGift(id: 8, name: 'Diamond Ring', emoji: '💍', coins: 2550),
      SelectedGift(id: 9, name: 'Luxury Watch', emoji: '⌚', coins: 3200),
      SelectedGift(id: 10, name: 'Gold Bracelet', emoji: '✨', coins: 2550),
      SelectedGift(id: 11, name: 'Gemstone Pendant', emoji: '💎', coins: 2400),
      SelectedGift(id: 12, name: 'Diamond Necklace', emoji: '📿', coins: 4200),
      SelectedGift(id: 13, name: 'Crown', emoji: '👑', coins: 5000),
      SelectedGift(id: 14, name: 'Diamond Earrings', emoji: '💎', coins: 3800),
    ],
    'Cute': [
      SelectedGift(id: 15, name: 'Teddy Bear', emoji: '🧸', coins: 1200),
      SelectedGift(id: 16, name: 'Bunny', emoji: '🐰', coins: 950),
      SelectedGift(id: 17, name: 'Cute Puppy', emoji: '🐶', coins: 1100),
      SelectedGift(id: 18, name: 'Kitten', emoji: '🐱', coins: 1000),
      SelectedGift(id: 19, name: 'Sweet Cake', emoji: '🎂', coins: 750),
      SelectedGift(id: 20, name: 'Love Bear', emoji: '💝', coins: 1450),
      SelectedGift(id: 21, name: 'Rainbow', emoji: '🌈', coins: 600),
    ],
    'Experiences': [
      SelectedGift(id: 22, name: 'Designer Bag', emoji: '👜', coins: 3600),
      SelectedGift(id: 23, name: 'Perfume', emoji: '🌸', coins: 1900),
      SelectedGift(id: 24, name: 'Champagne', emoji: '🍾', coins: 1800),
      SelectedGift(id: 25, name: 'Luxury Chocolate', emoji: '🍫', coins: 650),
      SelectedGift(id: 26, name: 'Dinner Date', emoji: '🍽️', coins: 2500),
      SelectedGift(id: 27, name: 'Movie Night', emoji: '🎬', coins: 1300),
      SelectedGift(id: 28, name: 'Beach Trip', emoji: '🏖️', coins: 4800),
    ],
  };

  int _selectedCategory = 1;
  SelectedGift? _selectedGift;
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();

  List<SelectedGift> get _visibleGifts =>
      _giftsByCategory[_categories[_selectedCategory]]!;

  final Map<int, GlobalKey> _categoryKeys = {};

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _categories.length; i++) {
      _categoryKeys[i] = GlobalKey();
    }
    _messageFocusNode.addListener(() {
      setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCategory(_selectedCategory);
    });
  }

  void _scrollToCategory(int index) {
    final key = _categoryKeys[index];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        alignment: 0.5,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black87,
                size: 16,
              ),
            ),
          ),
        ),
        actions: [
          Container(
            height: 35,
            margin: const EdgeInsets.only(right: 18, top: 7),
            padding: const EdgeInsets.only(left: 12, right: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                const Text('🪙', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 5),
                Text('5,258', style: AppText.pill.copyWith(fontSize: 16)),
                const SizedBox(width: 8),
                Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 18),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Gradient (smoothly fading to white)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 350,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFE9F3), Color(0xFFF0EDFF), Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),
          Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 110, 24, 16),
                child: Column(
                  children: [
                    Lottie.asset(
                      'assets/Referral.json',
                      height: 100,
                      width: 100,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Send a Gift',
                      style: AppText.h1.copyWith(fontSize: 25),
                    ),
                    const SizedBox(height: 5),
                    Text.rich(
                      TextSpan(
                        text: 'to ',
                        style: AppText.body.copyWith(
                          color: AppColors.ink60,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                        children: [
                          TextSpan(
                            text: widget.recipientName ?? 'them',
                            style: AppText.body.copyWith(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                          TextSpan(
                            text: ' · they’ll get a notification',
                            style: AppText.body.copyWith(
                              color: AppColors.ink60,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Categories List (Animated and centering)
              SizedBox(
                height: 36,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: List.generate(_categories.length, (index) {
                      final selected = index == _selectedCategory;
                      final primaryPink = const Color(0xFFE43A6A);

                      return GestureDetector(
                        key: _categoryKeys[index],
                        onTap: () {
                          setState(() {
                            _selectedCategory = index;
                            _selectedGift = null;
                          });
                          _scrollToCategory(index);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selected ? primaryPink : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected
                                  ? Colors.transparent
                                  : Colors.grey.shade200,
                            ),
                            boxShadow: selected
                                ? null
                                : [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                          ),
                          child: Row(
                            children: [
                              Text(
                                _categoryIcons[index],
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _categories[index],
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: selected
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  itemCount: _visibleGifts.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: .75,
                  ),
                  itemBuilder: (context, index) {
                    final gift = _visibleGifts[index];
                    final selected = gift.id == _selectedGift?.id;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedGift = gift),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected
                                ? const Color(0xFFE43A6A)
                                : Colors.grey.shade100,
                            width: selected ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: selected 
                                  ? const Color(0xFFE43A6A).withValues(alpha: 0.3)
                                  : Colors.black.withValues(alpha: 0.07),
                              blurRadius: selected ? 18 : 10,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  gradient: selected
                                      ? const LinearGradient(
                                          colors: [Color(0xFFFFF0F5), Color(0xFFFFE4EE)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : const LinearGradient(
                                          colors: [Color(0xFFF9F9F9), Color(0xFFF1F1F1)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(19),
                                  ),
                                ),
                                child: AnimatedScale(
                                  scale: selected ? 1.15 : 1.0,
                                  duration: const Duration(milliseconds: 200),
                                  child: Text(
                                    gift.emoji,
                                    style: const TextStyle(fontSize: 42),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
                              child: Column(
                                children: [
                                  Text(
                                    gift.name,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF9E6),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text('🪙', style: TextStyle(fontSize: 11)),
                                        const SizedBox(width: 3),
                                        Text(
                                          '${gift.coins}',
                                          style: const TextStyle(
                                            color: Color(0xFFD4AF37),
                                            fontWeight: FontWeight.w800,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: _selectedGift == null
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: _messageFocusNode.hasFocus
                                ? const Color(0xFFFFF0F5)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: _messageFocusNode.hasFocus
                                    ? const Color(0xFFE43A6A).withValues(alpha: 0.2)
                                    : Colors.black.withValues(alpha: 0.06),
                                blurRadius: _messageFocusNode.hasFocus ? 14 : 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: _messageFocusNode.hasFocus
                                  ? const Color(0xFFE43A6A)
                                  : Colors.grey.shade200,
                              width: _messageFocusNode.hasFocus ? 1.5 : 1,
                            ),
                          ),
                          child: TextField(
                            controller: _messageController,
                            focusNode: _messageFocusNode,
                            maxLines: 1,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                            decoration: InputDecoration(
                              hintText: 'Add a cute message (optional)',
                              hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                              prefixIcon: const Icon(
                                Icons.favorite_border_rounded,
                                size: 18,
                                color: Color(0xFFE43A6A),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                          ),
                        ),
                      ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: _selectedGift == null
                          ? null
                          : () => Navigator.pop(
                              context,
                              SelectedGift(
                                id: _selectedGift!.id,
                                name: _selectedGift!.name,
                                emoji: _selectedGift!.emoji,
                                coins: _selectedGift!.coins,
                                message: _messageController.text.trim(),
                              ),
                            ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        disabledBackgroundColor: AppColors.soft,
                        disabledForegroundColor: AppColors.muted,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        _selectedGift == null
                            ? 'Select a gift'
                            : 'Select ${_selectedGift!.name}',
                        style: AppText.pill.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _selectedGift == null ? null : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

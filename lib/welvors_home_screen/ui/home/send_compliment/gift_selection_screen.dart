import 'package:flutter/material.dart';

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
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 290,
            padding: const EdgeInsets.fromLTRB(24, 110, 24, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFE9F3), Color(0xFFF0EDFF)],
              ),
            ),
            child: Column(
              children: [
                Image.asset('assets/gift.png', height: 78, width: 78),
                const SizedBox(height: 19),
                Text('Send a Gift', style: AppText.h1.copyWith(fontSize: 25)),
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
          SizedBox(
            height: 70, // Increased to accommodate padding and shadow
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final selected = index == _selectedCategory;
                final primaryPink = const Color(0xFFE43A6A);
                
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedCategory = index;
                    _selectedGift = null;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? primaryPink : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected ? Colors.transparent : Colors.grey.shade200,
                      ),
                      boxShadow: selected
                          ? null
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
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
                            color: selected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              itemCount: _visibleGifts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: .82,
              ),
              itemBuilder: (context, index) {
                final gift = _visibleGifts[index];
                final selected = gift.id == _selectedGift?.id;
                return GestureDetector(
                  onTap: () => setState(() => _selectedGift = gift),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.line,
                        width: selected ? 2 : 1,
                      ),
                      boxShadow: AppColors.shadow,
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primarySoft
                                  : const Color(0xFFF7F2F0),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(17),
                              ),
                            ),
                            child: Text(
                              gift.emoji,
                              style: const TextStyle(fontSize: 58),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                          child: Column(
                            children: [
                              Text(
                                gift.name,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppText.h4,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '🪙 ${gift.coins}',
                                style: AppText.pill.copyWith(
                                  color: AppColors.gold,
                                  fontWeight: FontWeight.w700,
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: SizedBox(
              height: 30,
              child: TextField(
                controller: _messageController,
                focusNode: _messageFocusNode,
                maxLines: 1,
                textAlignVertical: TextAlignVertical.center,
                style: const TextStyle(fontSize: 13, height: 1.0),
                decoration: InputDecoration(
                  hintText: 'Add a message (optional)',
                  hintStyle: const TextStyle(fontSize: 13, height: 1.0),
                  prefixIcon: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 15,
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 35,
                    minHeight: 30,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 10,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF3EEE8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Container(
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
    );
  }
}

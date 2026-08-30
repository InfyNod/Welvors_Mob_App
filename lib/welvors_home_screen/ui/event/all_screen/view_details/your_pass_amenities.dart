import 'package:flutter/material.dart';

class YourPassAndAmenitiesSection extends StatelessWidget {
  final String price;
  final Map<String, dynamic>? eventData;
  final String userGender;
  final List<dynamic>? safetyFeatures;
  final List<dynamic>? amenities;

  const YourPassAndAmenitiesSection({
    super.key,
    required this.price,
    this.eventData,
    this.userGender = 'woman',
    this.safetyFeatures,
    this.amenities,
  });

  @override
  Widget build(BuildContext context) {
    final String gender = userGender.toLowerCase();

    // Parse prices
    double originalPrice = 0;
    double discountedPrice = 0;

    if (eventData != null) {
      if (gender == 'woman') {
        originalPrice =
            double.tryParse(eventData!['womenEntryPrice']?.toString() ?? '0') ??
            0;
        discountedPrice =
            double.tryParse(
              eventData!['womenDiscountedPrice']?.toString() ?? '0',
            ) ??
            0;
      } else if (gender == 'man') {
        originalPrice =
            double.tryParse(eventData!['menEntryPrice']?.toString() ?? '0') ??
            0;
        discountedPrice =
            double.tryParse(
              eventData!['menDiscountedPrice']?.toString() ?? '0',
            ) ??
            0;
      } else {
        originalPrice =
            double.tryParse(eventData!['otherEntryPrice']?.toString() ?? '0') ??
            0;
        discountedPrice =
            double.tryParse(
              eventData!['otherDiscountedPrice']?.toString() ?? '0',
            ) ??
            0;
      }
    }

    if (originalPrice == 0 && discountedPrice == 0) {
      // fallback to the `price` string if not found, stripping ₹
      final num = double.tryParse(price.replaceAll(RegExp(r'[^0-9.]'), ''));
      if (num != null) originalPrice = num;
      discountedPrice = originalPrice;
    }

    final bool hasDiscount =
        discountedPrice < originalPrice && discountedPrice > 0;
    final String displayPrice = hasDiscount
        ? '₹${discountedPrice.toStringAsFixed(0)}'
        : (discountedPrice > 0
              ? '₹${discountedPrice.toStringAsFixed(0)}'
              : (originalPrice > 0
                    ? '₹${originalPrice.toStringAsFixed(0)}'
                    : price));
    final String originalPriceText = hasDiscount
        ? '₹${originalPrice.toStringAsFixed(0)}'
        : '';
    final String discountPercentage =
        eventData?['discountPercentage']?.toString() ?? '';

    IconData genderIcon = Icons.female;
    String genderLabel = 'Woman';

    if (gender == 'man') {
      genderIcon = Icons.male;
      genderLabel = 'Man';
    } else if (gender != 'woman') {
      genderIcon = Icons.transgender;
      genderLabel = 'Other';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Your Pass
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Your Pass',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Premium Pass Card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFFF0F5), // Very light soft pink
                Colors.white,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE43A6A).withOpacity(0.15),
                blurRadius: 24,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: const Color(0xFFE43A6A).withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Section (Ticket Info)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFE43A6A,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons
                                      .confirmation_num_outlined, // Premium Ticket Icon
                                  color: Color(0xFFE43A6A),
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Standard Pass',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black87,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Welcome drink + all access',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Gender Badge with subtle premium look
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE43A6A).withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(
                          color: const Color(0xFFE43A6A).withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            genderIcon,
                            color: const Color(0xFFE43A6A),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            genderLabel,
                            style: const TextStyle(
                              color: Color(0xFFE43A6A),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Premium Dashed Divider
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: List.generate(
                        (constraints.constrainWidth() / 8).floor(),
                        (index) => SizedBox(
                          width: 4,
                          height: 1.5,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: const Color(0xFFE43A6A).withOpacity(0.3),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Bottom Section (Price Info)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.end,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.end,
                      spacing: 8,
                      children: [
                        Text(
                          displayPrice,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.black87,
                            letterSpacing: -1,
                          ),
                        ),
                        if (hasDiscount) ...[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Text(
                              originalPriceText,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black45,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                          if (discountPercentage.isNotEmpty &&
                              discountPercentage != '0')
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFE43A6A),
                                      Color(0xFFFF758C),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFFE43A6A,
                                      ).withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '$discountPercentage% OFF',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 6),
                      child: Text(
                        'Price for your profile',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Amenities
        if (amenities != null && amenities!.isNotEmpty) ...[
          const SizedBox(height: 25),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Amenities',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: amenities!.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent: 60, // Fixed height for cards
              ),
              itemBuilder: (context, index) {
                final amenityName =
                    amenities![index]['name'] ??
                    amenities![index]['title'] ??
                    '';
                final iconName =
                    amenities![index]['icon']?.toString().toLowerCase() ?? '';

                final iconData = _getAmenityIcon(iconName);

                return _buildAmenityCard(iconData, amenityName);
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSafetyItem(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            color: Color(0xFFFFF0F3),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 14, color: const Color(0xFFE43A6A)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  IconData _getAmenityIcon(String? iconName) {
    switch (iconName?.toLowerCase()) {
      case 'drink':
      case 'cocktail':
      case 'bar':
        return Icons.local_bar;
      case 'music':
      case 'dj':
      case 'band':
        return Icons.music_note;
      case 'food':
      case 'meal':
      case 'appetizer':
        return Icons.restaurant;
      case 'photo':
      case 'camera':
        return Icons.camera_alt;
      case 'park':
      case 'car':
        return Icons.directions_car;
      case 'host':
      case 'staff':
      case 'team':
        return Icons.person;
      case 'users':
        return Icons.people;
      case 'building':
        return Icons.business;
      case 'star':
        return Icons.star_border;
      case 'check':
        return Icons.check;
      default:
        return Icons.star;
    }
  }

  Widget _buildAmenityCard(IconData iconData, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFF8F9FA),
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, size: 20, color: const Color(0xFFE43A6A)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class YourPassAndAmenitiesSection extends StatelessWidget {
  final String price;
  final List<dynamic>? safetyFeatures;
  final List<dynamic>? amenities;

  const YourPassAndAmenitiesSection({
    super.key, 
    required this.price,
    this.safetyFeatures,
    this.amenities,
  });

  @override
  Widget build(BuildContext context) {
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
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE43A6A), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE43A6A).withOpacity(0.12),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Standard Entry',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Welcome drink + all access',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE43A6A)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.female,
                          color: Color(0xFFE43A6A),
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Woman',
                          style: TextStyle(
                            color: Color(0xFFE43A6A),
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(height: 1, color: Colors.grey.shade200),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        price,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),

                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Text(
                      'Price for your profile',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Safety & Security
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text('🛡️', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  Text(
                    'Safety & Security',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: (safetyFeatures != null && safetyFeatures!.isNotEmpty) ? safetyFeatures!.length : 4,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 12,
                  mainAxisExtent: 32, // Height for safety item
                ),
                itemBuilder: (context, index) {
                  if (safetyFeatures != null && safetyFeatures!.isNotEmpty) {
                    return _buildSafetyItem(Icons.check_circle_outline, safetyFeatures![index]['title'] ?? '');
                  }
                  // Dummy data
                  final dummy = [
                    {'icon': Icons.shield_outlined, 'text': 'Verified Staff'},
                    {'icon': Icons.lock_outline, 'text': 'Secure Entry'},
                    {'icon': Icons.verified_user_outlined, 'text': 'ID Verification'},
                    {'icon': Icons.visibility_outlined, 'text': 'Private Venue'},
                  ];
                  return _buildSafetyItem(dummy[index]['icon'] as IconData, dummy[index]['text'] as String);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 25),

        // Amenities
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
            itemCount: (amenities != null && amenities!.isNotEmpty) ? amenities!.length : 6,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: 60, // Fixed height for cards
            ),
            itemBuilder: (context, index) {
              if (amenities != null && amenities!.isNotEmpty) {
                final amenityName = amenities![index]['name'] ?? amenities![index]['title'] ?? '';
                final iconName = amenities![index]['icon']?.toString().toLowerCase() ?? '';
                
                String emoji = '✨';
                if (iconName.contains('drink') || iconName.contains('cocktail') || iconName.contains('bar')) emoji = '🍸';
                else if (iconName.contains('music') || iconName.contains('dj') || iconName.contains('band')) emoji = '🎷';
                else if (iconName.contains('food') || iconName.contains('meal') || iconName.contains('appetizer')) emoji = '🍽️';
                else if (iconName.contains('photo') || iconName.contains('camera')) emoji = '📸';
                else if (iconName.contains('park') || iconName.contains('car')) emoji = '🅿️';
                else if (iconName.contains('host') || iconName.contains('staff') || iconName.contains('team')) emoji = '👩';

                return _buildAmenityCard(emoji, amenityName);
              }
              // Dummy data
              final dummy = [
                {'emoji': '🍸', 'text': 'Welcome cocktail'},
                {'emoji': '🎷', 'text': 'Live jazz band'},
                {'emoji': '🍽️', 'text': 'Gourmet\nappetizers'},
                {'emoji': '📸', 'text': 'Photo corner'},
                {'emoji': '🅿️', 'text': 'Valet parking'},
                {'emoji': '👩', 'text': 'Female-led host\nteam'},
              ];
              return _buildAmenityCard(dummy[index]['emoji']!, dummy[index]['text']!);
            },
          ),
        ),
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

  Widget _buildAmenityCard(String emoji, String text) {
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
            child: Text(emoji, style: const TextStyle(fontSize: 18)),
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

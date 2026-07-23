import re
import os

source_file = '/Users/salauddinansari/StudioProjects/Velvors/lib/welvors_home_screen/ui/drawer_files/dating/my_boosts/boost/boost_screen.dart'
dest_file = '/Users/salauddinansari/StudioProjects/Velvors/lib/welvors_home_screen/ui/drawer_files/dating/my_boosts/super_boost/super_boost_screen.dart'

# Ensure directory exists
os.makedirs(os.path.dirname(dest_file), exist_ok=True)

with open(source_file, 'r') as f:
    content = f.read()

# Replace class names
content = content.replace('BoostScreen', 'SuperBoostScreen')
content = content.replace('availableBoosts', 'availableSuperBoosts')

# Change packages
new_packages = '''
  final List<Map<String, dynamic>> _packages = [
    {
      'title': '10',
      'subtitle': 'Super Boosts',
      'pricePerItem': '₹399/each',
      'discount': 'Save 48%',
      'oldPrice': '₹766/each',
      'totalPrice': '₹3,990 total',
      'tag': 'BEST VALUE',
    },
    {
      'title': '05',
      'subtitle': 'Super Boosts',
      'pricePerItem': '₹499/each',
      'discount': 'Save 35%',
      'oldPrice': '₹766/each',
      'totalPrice': '₹2,495 total',
      'tag': 'POPULAR',
    },
    {
      'title': '01',
      'subtitle': 'Super Boosts',
      'pricePerItem': '₹766/each',
      'discount': null,
      'oldPrice': null,
      'totalPrice': '₹766 total',
      'tag': null,
    },
  ];
'''
content = re.sub(r'final List<Map<String, dynamic>> _packages = \[.*?\];', new_packages.strip(), content, flags=re.DOTALL)

# Hero Banner
hero_pattern = r'Widget _buildHeroBanner.*?return Container.*?\]\),\n\s*\]\),\n\s*\);\n\s*\}'
new_hero = '''
  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF2E222A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // Background star graphic
          Positioned(
            right: -20,
            top: -20,
            child: Icon(Icons.star, size: 160, color: const Color(0xFFCBA164).withOpacity(0.5)),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, size: 12, color: Color(0xFFCBA164)),
                      SizedBox(width: 4),
                      Text(
                        '3 HOURS • CITYWIDE',
                        style: TextStyle(
                          color: Color(0xFFCBA164),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Be the top profile\\nin your city',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Get 10x more views, advanced targeting and\\nverified-only mode for 3 full hours.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem('10x', 'MORE VIEWS'),
                    _buildStatItem('5x', 'MORE MATCHES'),
                    _buildStatItem('3h', 'DURATION'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
'''
content = re.sub(hero_pattern, new_hero.strip(), content, flags=re.DOTALL)

# Bottom bar styling
content = content.replace('Color(0xFFFDF0F3)', 'Colors.white') # Selected package background
# Replace pink borders with black for selected package
content = content.replace('color: isSelected\n                    ? const Color(0xFFE43A6A)\n                    : Colors.grey.shade200,', 'color: isSelected ? Colors.black : Colors.grey.shade200,')
content = content.replace('color: isSelected\n                              ? const Color(0xFFE43A6A)\n                              : Colors.grey.shade300,', 'color: isSelected ? Colors.black : Colors.grey.shade300,')
content = content.replace('color: isSelected\n                            ? const Color(0xFFE43A6A)\n                            : Colors.transparent,', 'color: isSelected ? Colors.black : Colors.transparent,')
content = content.replace('const Color(0xFFE43A6A).withOpacity(0.1)', 'Colors.black.withOpacity(0.1)')

# Bottom Bar
content = content.replace('BOOSTS · 30 MIN EACH', 'SUPER BOOSTS · 3 HOURS EACH')
# The bottom bar button styling
content = content.replace('backgroundColor: const Color(0xFFE43A6A),', 'backgroundColor: Colors.black,')
# Icon in button
content = content.replace("Icon(Icons.bolt, color: Colors.white, size: 20)", "Icon(Icons.star, color: Colors.white, size: 20)")
# GetBoostsDrawer -> GetSuperBoostsDrawer (Will break if drawer is not created yet, we can omit drawer logic for now)
content = content.replace('GetBoostsDrawer', 'GetSuperBoostsDrawer')
content = content.replace('get_boosts_drawer.dart', 'get_super_boosts_drawer.dart')

# Best Value Tag Gradient
content = content.replace("package['tag'] == 'BEST VALUE'\n                      ? [const Color(0xFFFFD54F), const Color(0xFFF6B042)]\n                      : [const Color(0xFFFA6A85), const Color(0xFFDE2957)]", "package['tag'] == 'BEST VALUE'\n                      ? [Colors.black87, Colors.black]\n                      : [const Color(0xFFFA6A85), const Color(0xFFDE2957)]")
# Best value shadow
content = content.replace("color: package['tag'] == 'BEST VALUE'\n                        ? const Color(0xFFF6B042).withOpacity(0.3)\n                        : const Color(0xFFDE2957).withOpacity(0.3),", "color: package['tag'] == 'BEST VALUE'\n                        ? Colors.black.withOpacity(0.3)\n                        : const Color(0xFFDE2957).withOpacity(0.3),")

# Best value text color
content = content.replace("color: package['tag'] == 'BEST VALUE'\n                      ? Colors.black87\n                      : Colors.white,", "color: Colors.white,")


with open(dest_file, 'w') as f:
    f.write(content)

print("SuperBoostScreen generated successfully!")

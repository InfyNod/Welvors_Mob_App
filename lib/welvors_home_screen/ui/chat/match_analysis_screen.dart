import 'package:flutter/material.dart';

class MatchAnalysisScreen extends StatelessWidget {
  const MatchAnalysisScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Match Analysis',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileCard(),
            const SizedBox(height: 20),
            _buildTopHighlights(),
            const SizedBox(height: 24),
            const Text(
              'Detailed Match Breakdown',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildBreakdownItem('Values & Beliefs', 0.95, '95%'),
            _buildBreakdownItem('Lifestyle & Habits', 0.88, '88%'),
            _buildBreakdownItem('Communication Style', 0.92, '92%'),
            _buildBreakdownItem('Relationship Intent', 0.98, '98%'),
            _buildBreakdownItem('Interests & Hobbies', 0.82, '82%'),
            const SizedBox(height: 32),
            _buildActionButtons(context),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 70,
                height: 70,
                child: CircularProgressIndicator(
                  value: 0.91,
                  strokeWidth: 6,
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFE91E63),
                  ),
                ),
              ),
              const CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage(
                  'https://via.placeholder.com/150',
                ), // Replace with actual image path
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '91% Match Score',
                  style: TextStyle(
                    color: Color(0xFFE91E63),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'You & Sarah share exceptional alignment across core values and life goals.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHighlights() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Core Highlights',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildHighlightTile(
            Icons.favorite,
            'Both seeking long-term commitment',
          ),
          _buildHighlightTile(
            Icons.menu_book,
            'Shared interest in reading & arts',
          ),
          _buildHighlightTile(
            Icons.fitness_center,
            'Active lifestyle & outdoors',
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightTile(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFE91E63), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownItem(String label, double progress, String percentage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Text(
                percentage,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFE91E63),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              // Action for starting chat or sending icebreaker
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E63),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              'Send Icebreaker',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              'Back to Chat',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

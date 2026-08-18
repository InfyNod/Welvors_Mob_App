import 'package:flutter/material.dart';

class AboutHostAndFAQSection extends StatelessWidget {
  const AboutHostAndFAQSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // About the Host
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'About the Host',
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
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFDDE6), // Slightly darker pink
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('🥂', style: TextStyle(fontSize: 24)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Flexible(
                              child: Text(
                                'Spark Official Events',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.verified,
                              color: const Color(0xFFE43A6A),
                              size: 16,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Curating singles events since 2021 · Mumbai',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _buildStatItem('128', 'EVENTS HOSTED')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildStatItem('4.8 ⭐', 'AVG RATING')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildStatItem('9.2k', 'GUESTS MET')),
                ],
              ),
              const SizedBox(height: 24),
              _buildReview(
                name: 'Ananya',
                age: '27',
                review:
                    '"Actually met someone I clicked with. Felt safe the whole time — staff were great."',
                imageUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
              ),
              const SizedBox(height: 16),
              _buildReview(
                name: 'Karan',
                age: '30',
                review:
                    '"Way better than swiping. Good crowd, well organised, icebreakers weren\'t cringe."',
                imageUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Invite a match
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFEEF3), Color(0xFFFFF0F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE43A6A).withOpacity(0.15),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.8),
                blurRadius: 10,
                offset: const Offset(-5, -5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text('💗', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 8),
                  Text(
                    'Invite a match to meet here',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                  children: [
                    TextSpan(
                      text:
                          'Chatting with someone? Invite them to this event — a ',
                    ),
                    TextSpan(
                      text: 'safe, verified public venue ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text:
                          'with trained staff is the perfect place for a first meeting.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE43A6A),
                    elevation: 8,
                    shadowColor: const Color(0xFFE43A6A).withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    '💌 Invite a Match',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900, // Extra bold
                      fontSize: 15,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Frequently Asked
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Frequently Asked',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const FaqExpandableCard(
                question: 'Can I come alone?',
                answer:
                    'Yes! Most of our guests come solo. Our icebreakers are designed to make it easy to meet everyone.',
              ),
              const SizedBox(height: 12),
              const FaqExpandableCard(
                question: 'What\'s the refund policy?',
                answer:
                    'Full refund on cancellations made 3+ days before the event.',
              ),
              const SizedBox(height: 12),
              const FaqExpandableCard(
                question: 'Is alcohol included?',
                answer:
                    'Yes, standard entry includes one welcome cocktail. Additional drinks can be purchased at the bar.',
              ),
              const SizedBox(height: 12),
              const FaqExpandableCard(
                question: 'Is there a dress code?',
                answer:
                    'Smart casual is recommended. Right of admission is reserved by the venue.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // TERMS & CONDITIONS
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TERMS & CONDITIONS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 114, 113, 113),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              _buildTermText(
                'Entry only with valid photo ID matching your verified profile',
              ),
              _buildTermText(
                'Full refund on cancellations made 3+ days before the event',
              ),
              _buildTermText(
                'Dress code: Smart casual · Right of admission reserved',
              ),
              _buildTermText(
                'Zero-tolerance policy for harassment — instant removal',
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildStatItem(String val, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200, width: 0.5),
      ),
      child: Column(
        children: [
          Text(
            val,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReview({
    required String name,
    required String age,
    required String review,
    required String imageUrl,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(radius: 16, backgroundImage: NetworkImage(imageUrl)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '$name, $age',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: List.generate(
                      5,
                      (index) => const Icon(
                        Icons.star,
                        size: 10,
                        color: Color(0xFFFFC107),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                review,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTermText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FaqExpandableCard extends StatefulWidget {
  final String question;
  final String answer;

  const FaqExpandableCard({
    super.key,
    required this.question,
    required this.answer,
  });

  @override
  State<FaqExpandableCard> createState() => _FaqExpandableCardState();
}

class _FaqExpandableCardState extends State<FaqExpandableCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isExpanded
              ? const Color(0xFFE43A6A).withOpacity(0.3)
              : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.question,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.remove : Icons.add,
                  color: const Color(0xFFE43A6A),
                  size: 20,
                ),
              ],
            ),
            if (_isExpanded) ...[
              const SizedBox(height: 12),
              Text(
                widget.answer,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'commitment_bloc/commitment_bloc.dart';
import 'commitment_bloc/commitment_event.dart';
import 'commitment_bloc/commitment_state.dart';
import 'request_received.dart';
import 'end_status.dart';

class CommitmentScreen extends StatelessWidget {
  const CommitmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CommitmentBloc()..add(LoadCommitmentData()),
      child: const _CommitmentScreenView(),
    );
  }
}

class _CommitmentScreenView extends StatelessWidget {
  const _CommitmentScreenView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black87,
                size: 16,
              ),
            ),
          ),
        ),
        title: Column(
          children: const [
            Text(
              'WELVORS',
              style: TextStyle(
                color: Color(0xFFC73A5E),
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
              ),
            ),
            Text(
              'Commitment Management',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: BlocBuilder<CommitmentBloc, CommitmentState>(
        builder: (context, state) {
          if (state is CommitmentLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color.fromRGBO(223, 44, 89, 1),
              ),
            );
          } else if (state is CommitmentLoaded) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildProfileCard(state),
                        const SizedBox(height: 24),
                        _buildLoyaltyCard(context, state),
                        const SizedBox(height: 24),
                        _buildInfoFooter(),
                        const SizedBox(height: 24),
                        const RequestsSection(),
                        const SizedBox(height: 0),
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDFDFD),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          offset: const Offset(0, -4),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: _buildEndExclusiveButton(context, state),
                  ),
                ),
              ],
            );
          } else if (state is CommitmentEnded) {
            return EndStatusBody(
              partnerName: state.partnerName,
              userName: state.userName,
            );
          } else if (state is CommitmentSingle) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSingleProfileCard(),
                        const SizedBox(height: 24),
                        _buildInfoFooter(),
                        const SizedBox(height: 24),
                        const RequestsSection(),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else if (state is CommitmentError) {
            return Center(
              child: Text(state.message, style: TextStyle(color: Colors.red)),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildSingleProfileCard() {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF0F5), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.7],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD1DC), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD1DC).withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -24,
            right: -24,
            child: Icon(
              Icons.favorite,
              color: const Color(0xFFFFE4EB).withOpacity(0.6),
              size: 140,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFC73A5E).withOpacity(0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    image: const DecorationImage(
                      image: NetworkImage(
                        'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?ixlib=rb-4.0.3&auto=format&fit=crop&w=150&q=80',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'You\'re single',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1F1F1F),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Open to new matches again',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6A655F),
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9EAEF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'Single',
                          style: TextStyle(
                            color: Color(0xFF8B6B78),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
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
    );
  }

  Widget _buildProfileCard(CommitmentLoaded state) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF0F5), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.7], // More white space on the right
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD1DC), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD1DC).withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Faint Heart Watermark in top right
          Positioned(
            top: -24,
            right: -24,
            child: Icon(
              Icons.favorite,
              color: const Color(0xFFFFE4EB).withOpacity(0.6),
              size: 140,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Overlapping Image Avatars with Glow
                    Container(
                      width: 104,
                      height: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFC73A5E).withOpacity(0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            left: 40, // More overlap gap
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                image: DecorationImage(
                                  image: NetworkImage(
                                    state.imageUrl,
                                  ), // Woman (Priya)
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                image: const DecorationImage(
                                  image: NetworkImage(
                                    'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?ixlib=rb-4.0.3&auto=format&fit=crop&w=150&q=80',
                                  ), // Man
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 2),
                          Text(
                            'Together with ${state.partnerName}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1F1F1F),
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Exclusive — hidden from new\nmatches', // Force a small break or let it wrap nicely
                            style: TextStyle(
                              fontSize: 13,
                              color: const Color(0xFF6A655F),
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (state.isIdentityVerified)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(230, 244, 235, 1),
                                borderRadius: BorderRadius.circular(
                                  16,
                                ), // Softer pill shape
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.check,
                                    color: Color.fromRGBO(96, 88, 81, 1),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Identity verified',
                                    style: TextStyle(
                                      color: const Color.fromRGBO(
                                        96,
                                        88,
                                        81,
                                        1,
                                      ),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
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
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFFFD1DC)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      'Shared intent',
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF7A756D),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: state.intentColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(state.intentIcon, size: 13, color: state.intentTextColor),
                          const SizedBox(width: 6),
                          Text(
                            state.intent,
                            style: TextStyle(
                              color: state.intentTextColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFFFD1DC)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      'Since ',
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF5F5C56),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      state.duration,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1F1F1F),
                      ),
                    ),
                    Text(
                      ' · Mutually confirmed',
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF5F5C56),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoyaltyCard(BuildContext context, CommitmentLoaded state) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color.fromRGBO(254, 245, 230, 1),
                Color.fromRGBO(246, 210, 217, 1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF0E5D1), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top badge moved inside the card
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromRGBO(229, 155, 70, 1),
                        Color.fromRGBO(213, 93, 101, 1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.white, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        'Loyalty Reward',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Real love deserves a reward. 💍',
                style: TextStyle(
                  color: const Color(0xFF4A3B46),
                  fontSize: 20,
                  fontFamily: 'Georgia', // Premium serif look
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF6A655F),
                    height: 1.4,
                  ),
                  children: [
                    TextSpan(text: 'Hold on to ${state.partnerName} for '),
                    TextSpan(
                      text: '3 years',
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFFB8860B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(
                      text:
                          ', say "I do" on Welvors — and we\'ll bless your forever with ',
                    ),
                    TextSpan(
                      text: '₹5 Lakh.',
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFFB8860B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildRewardItem(
                icon: '✈️',
                title: '₹5 Lakh',
                subtitle: 'Fully-paid dream honeymoon for you both',
                borderColor: const Color(0xFFF0E5D1),
              ),
              const SizedBox(height: 16),
              _buildRewardItem(
                icon: '💝',
                title: '₹5,000/mo',
                subtitle:
                    'Shopping allowance for ${state.partnerName}, 3 years after marriage',
                badgeText: 'FOR HER',
                borderColor: const Color(0xFFFFD1DC), // Soft pink border
              ),
              const SizedBox(height: 24),
              // See what you'll win button
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(
                      227,
                      58,
                      105,
                      1,
                    ), // Requested solid color
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromRGBO(227, 58, 105, 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "See what you'll win \u2192", // right arrow
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRewardItem({
    required String icon,
    required String title,
    required String subtitle,
    String? badgeText,
    required Color borderColor,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Color(0x05000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                child: Text(icon, style: const TextStyle(fontSize: 26)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Georgia',
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF4A3B46),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF6A655F),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (badgeText != null)
          Positioned(
            top: -7,
            left: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color.fromRGBO(229, 155, 70, 1),
                    Color.fromRGBO(213, 93, 101, 1),
                  ],
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                badgeText,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4EFEB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: const Color(0xFF6A655F),
            size: 16,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '"Verified" means Welvors confirmed each person\'s identity — not their relationship history.',
              style: TextStyle(
                color: const Color(0xFF6A655F),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEndExclusiveButton(
    BuildContext context,
    CommitmentLoaded state,
  ) {
    return GestureDetector(
      onTap: () {
        _showEndExclusiveBottomSheet(context, state);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color.fromRGBO(227, 58, 105, 0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(227, 58, 105, 0.1),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const Text(
          'End exclusive status',
          style: TextStyle(
            color: Color.fromRGBO(227, 58, 105, 1),
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  void _showEndExclusiveBottomSheet(
    BuildContext context,
    CommitmentLoaded state,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8DCD0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'End exclusive status?',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F1F1F),
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 12),
              Text(
                'Your profile reopens to new matches and ${state.partnerName} will be notified right away. You can do this anytime — no approval needed from anyone.',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6A655F),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6A655F),
                    height: 1.4,
                  ),
                  children: [
                    TextSpan(text: 'Want to talk it through first? '),
                    TextSpan(
                      text: 'Visit support',
                      style: TextStyle(
                        color: Color.fromRGBO(227, 58, 105, 1),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(text: ' — optional, never required.'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  context.read<CommitmentBloc>().add(
                    EndExclusiveStatusRequested(),
                  );
                },
                child: Container(
                  height: 54,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(223, 44, 89, 1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'End status',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                },
                child: Container(
                  height: 54,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE8DCD0)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Keep it',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F1F1F),
                    ),
                  ),
                ),
              ),
              SafeArea(top: false, child: const SizedBox(height: 16)),
            ],
          ),
        );
      },
    );
  }
}

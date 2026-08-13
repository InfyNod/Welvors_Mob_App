import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'commitment_bloc/commitment_bloc.dart';
import 'commitment_bloc/commitment_event.dart';
import 'commitment_bloc/commitment_state.dart';

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
              child: CircularProgressIndicator(color: const Color(0xFFC73A5E)),
            );
          } else if (state is CommitmentLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProfileCard(state),
                  const SizedBox(height: 24),
                  _buildLoyaltyCard(context, state),
                  const SizedBox(height: 24),
                  _buildInfoFooter(),
                  const SizedBox(height: 40),
                ],
              ),
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

  Widget _buildProfileCard(CommitmentLoaded state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFECE6DC)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              // Overlapping Avatars Placeholder
              SizedBox(
                width: 64,
                height: 44,
                child: Stack(
                  children: [
                    Positioned(
                      left: 20,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFC73A5E).withOpacity(0.1),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: const Color(0xFFC73A5E),
                          size: 24,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF3DA9FF).withOpacity(0.1),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: const Color(0xFF3DA9FF),
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Together with ${state.partnerName}',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Exclusive — hidden from new matches',
                      style: TextStyle(
                        fontSize: 11,
                        color: const Color(0xFF5F5C56),
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (state.isIdentityVerified)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F8EF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check,
                              color: const Color(0xFF2EAF6B),
                              size: 10,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Identity verified',
                              style: TextStyle(
                                color: const Color(0xFF2EAF6B),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
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
          const Divider(height: 1, color: const Color(0xFFECE6DC)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Shared intent',
                style: TextStyle(fontSize: 12, color: const Color(0xFF5F5C56)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8A53D).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Text('💍', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      state.intent,
                      style: TextStyle(
                        color: const Color(0xFFE8A53D),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: const Color(0xFFECE6DC)),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Since ',
                style: TextStyle(fontSize: 12, color: const Color(0xFF5F5C56)),
              ),
              Text(
                state.duration,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              Text(
                ' · Mutually confirmed',
                style: TextStyle(fontSize: 12, color: const Color(0xFF5F5C56)),
              ),
            ],
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
            color: const Color(0xFFFDFBF7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE8A53D).withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 14,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Real love deserves a reward. 💍',
                      style: TextStyle(
                        color: const Color(
                          0xFF8B4657,
                        ), // A deep red/brown as seen in image
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF5F5C56),
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(text: 'Hold on to Priya for '),
                    TextSpan(
                      text: '3 years',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFFE8A53D),
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
                        fontSize: 12,
                        color: const Color(0xFFE8A53D),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildRewardItem(
                icon: '✈️',
                title: '₹5 Lakh',
                subtitle: 'Fully-paid dream honeymoon for you both',
              ),
              const SizedBox(height: 12),
              _buildRewardItem(
                icon: '💝',
                title: '₹5,000/mo',
                subtitle:
                    'Shopping allowance for Priya, 3 years after marriage',
                badgeText: 'FOR HER',
              ),
              const SizedBox(height: 24),
              // End exclusive button
              GestureDetector(
                onTap: () {
                  context.read<CommitmentBloc>().add(
                    EndExclusiveStatusRequested(),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFC73A5E).withOpacity(0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFC73A5E).withOpacity(0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'End exclusive status',
                    style: TextStyle(
                      color: const Color(0xFFC73A5E),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Top floating badge
        Positioned(
          top: -12,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE87A65), Color(0xFFD64D6F)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.white, size: 10),
                  const SizedBox(width: 4),
                  Text(
                    'Loyalty Reward',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
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
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE8A53D).withOpacity(0.2)),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFFCF7F3),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(icon, style: const TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: const Color(0xFF5F5C56),
                        height: 1.3,
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
            top: -8,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFE8A53D),
                borderRadius: BorderRadius.circular(8),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.info_outline,
          color: const Color(0xFF8A8680),
          size: 14,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '"Verified" means Welvors confirmed each person\'s identity — not their relationship history.',
            style: TextStyle(
              color: const Color(0xFF8A8680),
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

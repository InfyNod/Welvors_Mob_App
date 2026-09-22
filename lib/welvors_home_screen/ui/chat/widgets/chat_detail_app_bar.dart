import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:velvors/onbording_allpage/theme/app_colors.dart';
import 'package:velvors/onbording_allpage/theme/app_text.dart';

/// Top AppBar for ChatDetailScreen showing user details, online status, and actions.
class ChatDetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String liveImage;
  final String liveName;
  final int liveAge;
  final String livePackageType;
  final bool isUserOnline;
  final VoidCallback onMoreTap;
  final VoidCallback? onBackTap;

  const ChatDetailAppBar({
    super.key,
    required this.liveImage,
    required this.liveName,
    required this.liveAge,
    required this.livePackageType,
    required this.isUserOnline,
    required this.onMoreTap,
    this.onBackTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Row(
        children: [
          const SizedBox(width: 12),
          _buildBackButton(context),
          const SizedBox(width: 10),
          _buildAvatarWithStatus(
            context,
            liveImage,
            size: 44,
            name: liveName,
            age: liveAge.toString(),
            isOnline: isUserOnline,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        liveAge > 0 ? '$liveName, $liveAge' : liveName,
                        style: AppText.h2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 7),
                    _buildBadge(livePackageType.toUpperCase()),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: isUserOnline ? AppColors.green : AppColors.muted,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isUserOnline ? 'Online' : 'Offline',
                      style: AppText.body.copyWith(
                        color: isUserOnline ? AppColors.green : AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: onMoreTap,
          icon: const Icon(Icons.more_vert, color: AppColors.ink),
        ),
      ],
    );
  }

  Widget  _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: onBackTap ?? () => Navigator.of(context).maybePop(),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.arrow_back_ios_new,
            size: 16,
            color: AppColors.ink,
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarWithStatus(
    BuildContext context,
    String url, {
    double size = 44,
    required String name,
    required String age,
    required bool isOnline,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _buildAvatar(
          context,
          url,
          size: size,
          name: name,
          age: age,
        ),
        if (isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  static Widget buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.darkChip,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        text,
        style: AppText.pill.copyWith(
          color: const Color(0xFFFFD34D),
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildBadge(String text) => buildBadge(text);

  Widget _buildAvatar(
    BuildContext context,
    String url, {
    double size = 58,
    required String name,
    required String age,
  }) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          barrierColor: Colors.black.withValues(alpha: 0.8),
          builder: (dialogCtx) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(20),
              child: SizedBox(
                width: 400,
                height: 440,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 400,
                      height: 440,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: url,
                              width: 400,
                              height: 400,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => const SizedBox(
                                width: 400,
                                height: 400,
                                child: ColoredBox(color: AppColors.soft),
                              ),
                              errorWidget: (_, _, _) => const SizedBox(
                                width: 400,
                                height: 400,
                                child: ColoredBox(
                                  color: AppColors.soft,
                                  child: Center(
                                    child: Icon(
                                      Icons.person,
                                      color: AppColors.muted,
                                      size: 80,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 40,
                            child: Center(
                              child: Text(
                                '$name${int.tryParse(age) != null && int.tryParse(age)! > 0 ? ", $age yrs" : ""}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: -12,
                      right: -12,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(dialogCtx),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary, width: 2),
        ),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.cover,
            placeholder: (_, __) => const ColoredBox(
              color: AppColors.soft,
              child: SizedBox.expand(),
            ),
            errorWidget: (_, _, _) => const ColoredBox(
              color: AppColors.soft,
              child: Icon(Icons.person, color: AppColors.muted),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:velvors/welvors_home_screen/ui/date_now/profile/profile_detail.dart';
import 'package:velvors/welvors_home_screen/ui/date_now/date_api_service/date_now_api_service.dart';

class MyPlanRequesterProfileScreen extends StatefulWidget {
  final Map<String, dynamic> request;

  const MyPlanRequesterProfileScreen({super.key, required this.request});

  @override
  State<MyPlanRequesterProfileScreen> createState() =>
      _MyPlanRequesterProfileScreenState();
}

class _MyPlanRequesterProfileScreenState
    extends State<MyPlanRequesterProfileScreen> {
  bool _isLoading = false;

  void _showSnackBar(
    String title,
    String subtitle,
    Color color,
    IconData icon,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(subtitle),
              ],
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If the request doesn't have a valid userId, fallback to displaying a message or a generic profile
    final userId = widget.request['userId']?.toString() ?? '';

    return ProfileDetailScreen(
      userId: userId,
      profileImageUrl: widget.request['avatar'],
      profileName: widget.request['name'],
      customBottomWidget: _buildBottomActions(context),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).padding.bottom > 0
            ? MediaQuery.of(context).padding.bottom
            : 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Show the message if provided
          if (widget.request['message'] != null &&
              widget.request['message'] != '"No message attached."')
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F4EF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '“${widget.request['message']}”',
                style: const TextStyle(
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  color: Colors.black87,
                ),
              ),
            ),

          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            widget.request['status'] == 'approved'
                ? GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFA6A85), Color(0xFFDE2957)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Message ${widget.request['name']}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            setState(() => _isLoading = true);
                            final requestId =
                                widget.request['id'] ?? 'DUMMY_ID';
                            final success =
                                await DateNowApiService.declineRequest(
                                  requestId,
                                );
                            if (mounted) {
                              setState(() => _isLoading = false);
                              if (success) {
                                Navigator.pop(context, 'decline');
                                _showSnackBar(
                                  'Declined',
                                  'You have declined this request.',
                                  Colors.red,
                                  Icons.close,
                                );
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: Text(
                                'Decline',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            setState(() => _isLoading = true);
                            final requestId =
                                widget.request['id'] ?? 'DUMMY_ID';
                            final success =
                                await DateNowApiService.approveRequest(
                                  requestId,
                                );
                            if (mounted) {
                              setState(() => _isLoading = false);
                              if (success) {
                                Navigator.pop(context, 'approve');
                                _showSnackBar(
                                  'Approved!',
                                  'You can now message ${widget.request['name']}.',
                                  Colors.green,
                                  Icons.check_circle_outline,
                                );
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFA6A85), Color(0xFFDE2957)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: Text(
                                'Approve Request',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
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

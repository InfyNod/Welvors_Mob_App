import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:velvors/onbording_allpage/theme/app_colors.dart';
import 'package:velvors/onbording_allpage/theme/app_text.dart';
import 'package:velvors/welvors_home_screen/ui/chat/chat_image_pdf_viewer_screen.dart';
import 'package:velvors/welvors_home_screen/ui/chat/shared_bloc/shared_item_bloc.dart';

import 'shared_bloc/shared_item_model.dart';
import 'shared_bloc/shared_item_repository.dart';

class ChatMediaLinksDocsScreen extends StatefulWidget {
  final String conversationId;
  final String userName;

  const ChatMediaLinksDocsScreen({
    super.key,
    required this.conversationId,
    required this.userName,
  });

  @override
  State<ChatMediaLinksDocsScreen> createState() =>
      _ChatMediaLinksDocsScreenState();
}

class _ChatMediaLinksDocsScreenState extends State<ChatMediaLinksDocsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          SharedItemBloc(repository: SharedItemRepository())
            ..add(LoadSharedItems(widget.conversationId)),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F8F8),

        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,

          title: Text('Media, Links & Docs', style: AppText.h2),

          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: BlocBuilder<SharedItemBloc, SharedItemState>(
              builder: (context, state) {
                final data = state.data;

                return TabBar(
                  controller: _tabController,
                  isScrollable: true,

                  labelColor: AppColors.primary,
                  unselectedLabelColor: Colors.grey.shade600,

                  indicatorColor: AppColors.primary,
                  indicatorWeight: 2.5,

                  tabs: [
                    Tab(text: 'All ${data?.all.length ?? 0}'),
                    Tab(text: 'Photos ${data?.images.length ?? 0}'),
                    // Tab(text: 'Videos ${data?.videos.length ?? 0}'),
                    // Tab(text: 'Audio ${data?.audios.length ?? 0}'),
                    Tab(text: 'Docs ${data?.documents.length ?? 0}'),
                    Tab(text: 'Links ${data?.links.length ?? 0}'),
                  ],
                );
              },
            ),
          ),
        ),

        body: BlocBuilder<SharedItemBloc, SharedItemState>(
          builder: (context, state) {
            debugPrint(
              'SHARED UI => '
              'loading=${state.loading}, '
              'error=${state.error}',
            );

            if (state.data != null) {
              debugPrint(
                'SHARED UI => '
                'all=${state.data!.all.length}, '
                'images=${state.data!.images.length}, '
                'videos=${state.data!.videos.length}, '
                'audio=${state.data!.audios.length}, '
                'documents=${state.data!.documents.length}, '
                'links=${state.data!.links.length}',
              );
            }

            if (state.loading && state.data == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.error != null && state.data == null) {
              return _errorView(context, state.error!);
            }

            final data =
                state.data ??
                const SharedItemsBundle(media: [], documents: [], links: []);

            return TabBarView(
              controller: _tabController,
              children: [
                _allTab(context, data),
                _photoTab(context, data),
                // _videoTab(context, data),
                // _audioTab(context, data),
                _documentTab(context, data),
                _linkTab(context, data),
              ],
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // ALL
  // ============================================================

  Widget _allTab(BuildContext context, SharedItemsBundle data) {
    final items = data.all;

    if (items.isEmpty) {
      return _empty();
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = items[index];

        return _allItemTile(context, item);
      },
    );
  }

  Widget _allItemTile(BuildContext context, SharedItem item) {
    final type = item.messageType.toUpperCase();

    // IMAGE
    if (type == 'IMAGE') {
      return _roundedTile(
        icon: Icons.photo_outlined,
        title: 'Photo',
        subtitle: _formatDate(item.createdAt),

        leading: _imageThumbnail(item.mediaUrl),

        onTap: () {
          _openImage(context, item);
        },
      );
    }

    // VIDEO
    if (type == 'VIDEO') {
      return _roundedTile(
        icon: Icons.play_circle_outline,
        title: 'Video',
        subtitle: _formatDate(item.createdAt),
        onTap: () {
          _openExternal(item.mediaUrl);
        },
      );
    }

    // AUDIO
    if (type == 'AUDIO') {
      return _roundedTile(
        icon: Icons.audiotrack_outlined,
        title: 'Audio',
        subtitle: _formatDate(item.createdAt),
        onTap: () {
          _openExternal(item.mediaUrl);
        },
      );
    }

    // FILE / DOCUMENT
    if (type == 'FILE' || type == 'DOCUMENT' || type == 'PDF') {
      return _roundedTile(
        icon: Icons.picture_as_pdf_outlined,
        title: _documentName(item),
        subtitle: _formatDate(item.createdAt),
        onTap: () {
          _openDocument(context, item);
        },
      );
    }

    // LINK
    if (type == 'LINK' || type == 'LINKS') {
      final url = _linkUrl(item);

      return _roundedTile(
        icon: Icons.link_rounded,
        title: url.isEmpty ? 'Shared Link' : url,
        subtitle: 'Shared link',
        onTap: () {
          _openExternal(url);
        },
      );
    }

    return _roundedTile(
      icon: Icons.insert_drive_file_outlined,
      title: type.isEmpty ? 'Shared Item' : type,
      subtitle: _formatDate(item.createdAt),
      onTap: () {
        _openExternal(item.mediaUrl);
      },
    );
  }

  // ============================================================
  // PHOTOS
  // ============================================================

  Widget _photoTab(BuildContext context, SharedItemsBundle data) {
    final photos = data.images;

    debugPrint('PHOTO TAB COUNT = ${photos.length}');

    if (photos.isEmpty) {
      return _empty();
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),

      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),

      itemCount: photos.length,

      itemBuilder: (context, index) {
        final item = photos[index];

        debugPrint(
          'PHOTO [$index] => '
          '${item.mediaUrl}',
        );

        return GestureDetector(
          onTap: () {
            _openImage(context, item);
          },

          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),

            child: Image.network(
              item.mediaUrl ?? '',
              fit: BoxFit.cover,

              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }

                return const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                );
              },

              errorBuilder: (context, error, stackTrace) {
                debugPrint('PHOTO LOAD ERROR => $error');

                return Container(
                  color: Colors.grey.shade200,
                  child: const Icon(
                    Icons.broken_image_outlined,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // VIDEOS
  // ============================================================

  Widget _videoTab(BuildContext context, SharedItemsBundle data) {
    final videos = data.videos;

    if (videos.isEmpty) {
      return _empty();
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: videos.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = videos[index];

        return _roundedTile(
          icon: Icons.play_circle_outline,
          title: 'Video',
          subtitle: _formatDate(item.createdAt),
          onTap: () {
            _openExternal(item.mediaUrl);
          },
        );
      },
    );
  }

  // ============================================================
  // AUDIO
  // ============================================================

  Widget _audioTab(BuildContext context, SharedItemsBundle data) {
    final audios = data.audios;

    if (audios.isEmpty) {
      return _empty();
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: audios.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = audios[index];

        return _roundedTile(
          icon: Icons.audiotrack_outlined,
          title: 'Audio',
          subtitle: _formatDate(item.createdAt),
          onTap: () {
            _openExternal(item.mediaUrl);
          },
        );
      },
    );
  }

  // ============================================================
  // DOCUMENTS
  // ============================================================

  Widget _documentTab(BuildContext context, SharedItemsBundle data) {
    final documents = data.documents;

    if (documents.isEmpty) {
      return _empty();
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: documents.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = documents[index];

        return _roundedTile(
          icon: Icons.picture_as_pdf_outlined,
          title: _documentName(item),
          subtitle: _formatDate(item.createdAt),
          onTap: () {
            _openDocument(context, item);
          },
        );
      },
    );
  }

  // ============================================================
  // LINKS
  // ============================================================

  Widget _linkTab(BuildContext context, SharedItemsBundle data) {
    final links = data.links;

    if (links.isEmpty) {
      return _empty();
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: links.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = links[index];

        final url = _linkUrl(item);

        return _roundedTile(
          icon: Icons.link_rounded,
          title: url.isEmpty ? 'Shared Link' : url,
          subtitle: 'Shared link',
          onTap: () {
            _openExternal(url);
          },
        );
      },
    );
  }

  // ============================================================
  // IMAGE OPEN
  // ============================================================

  void _openImage(BuildContext context, SharedItem item) {
    final url = item.mediaUrl?.trim() ?? '';

    if (url.isEmpty) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatImageViewerScreen(imageUrl: url)),
    );
  }

  // ============================================================
  // PDF OPEN
  // ============================================================

  void _openDocument(BuildContext context, SharedItem item) {
    final url = item.mediaUrl?.trim() ?? '';

    if (url.isEmpty) {
      return;
    }

    final lowerUrl = url.toLowerCase();

    final isPdf = lowerUrl.split('?').first.endsWith('.pdf');

    if (isPdf) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ChatPdfViewerScreen(pdfUrl: url, title: _documentName(item)),
        ),
      );

      return;
    }

    // Non-PDF documents
    _openExternal(url);
  }

  // ============================================================
  // EXTERNAL URL
  // ============================================================

  Future<void> _openExternal(String? rawUrl) async {
    final url = rawUrl?.trim() ?? '';

    if (url.isEmpty) {
      return;
    }

    final uri = Uri.tryParse(url);

    if (uri == null) {
      return;
    }

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('OPEN URL ERROR => $e');
    }
  }

  // ============================================================
  // LINK URL
  // ============================================================

  String _linkUrl(SharedItem item) {
    final content = item.content?.trim() ?? '';

    if (content.isNotEmpty) {
      return content;
    }

    return item.mediaUrl?.trim() ?? '';
  }

  // ============================================================
  // DOCUMENT NAME
  // ============================================================

  String _documentName(SharedItem item) {
    final url = item.mediaUrl?.trim() ?? '';

    if (url.isEmpty) {
      return 'Document';
    }

    final uri = Uri.tryParse(url);

    if (uri != null) {
      final segments = uri.pathSegments;

      if (segments.isNotEmpty) {
        final name = segments.last;

        if (name.isNotEmpty) {
          return name;
        }
      }
    }

    return 'Document';
  }

  // ============================================================
  // IMAGE THUMBNAIL
  // ============================================================

  Widget _imageThumbnail(String? url) {
    final imageUrl = url?.trim() ?? '';

    if (imageUrl.isEmpty) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.image_outlined),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        imageUrl,
        width: 56,
        height: 56,
        fit: BoxFit.cover,

        errorBuilder: (_, __, ___) {
          return Container(
            width: 56,
            height: 56,
            color: Colors.grey.shade200,
            child: const Icon(Icons.broken_image_outlined),
          );
        },
      ),
    );
  }

  // ============================================================
  // COMMON TILE
  // ============================================================

  Widget _roundedTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? leading,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.white,

      borderRadius: BorderRadius.circular(16),

      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),

        child: Padding(
          padding: const EdgeInsets.all(12),

          child: Row(
            children: [
              leading ??
                  Container(
                    width: 48,
                    height: 48,

                    decoration: BoxDecoration(
                      color: AppColors.soft,
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: Icon(icon, color: AppColors.primary),
                  ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              if (onTap != null)
                const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _empty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Icon(
            Icons.perm_media_outlined,
            size: 52,
            color: Colors.grey.shade400,
          ),

          const SizedBox(height: 12),

          Text(
            'No shared items yet',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _errorView(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Icon(Icons.error_outline, size: 52, color: Colors.red.shade300),

            const SizedBox(height: 12),

            Text(message, textAlign: TextAlign.center),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
                // context.read<SharedItemBloc>().add(
                //   LoadSharedItems(widget.conversationId),
                // );
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DATE
  // ============================================================

  String _formatDate(String? value) {
    if (value == null || value.isEmpty) {
      return '';
    }

    try {
      final date = DateTime.parse(value);

      final local = date.toLocal();

      return '${local.day.toString().padLeft(2, '0')}/'
          '${local.month.toString().padLeft(2, '0')}/'
          '${local.year} '
          '${local.hour.toString().padLeft(2, '0')}:'
          '${local.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return value;
    }
  }
}

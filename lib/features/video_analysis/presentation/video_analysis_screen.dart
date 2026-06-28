import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gradient_button.dart';
import '../data/video_analysis_service.dart';
import '../providers/video_analysis_providers.dart';

class VideoAnalysisScreen extends ConsumerStatefulWidget {
  final String playerId;
  final String playerName;

  const VideoAnalysisScreen({
    super.key,
    required this.playerId,
    required this.playerName,
  });

  @override
  ConsumerState<VideoAnalysisScreen> createState() => _VideoAnalysisScreenState();
}

class _VideoAnalysisScreenState extends ConsumerState<VideoAnalysisScreen> {
  final _sports = ['Cricket', 'Football', 'Tennis', 'Badminton', 'Swimming', 'Basketball'];
  String _selectedSport = 'Cricket';
  bool _isUploading = false;

  Future<void> _pickAndUploadVideo() async {
    final picker = ImagePicker();
    final video = await picker.pickVideo(source: ImageSource.gallery);
    if (video == null) return;

    setState(() => _isUploading = true);
    try {
      final service = ref.read(videoAnalysisServiceProvider);
      await service.uploadVideo(
        playerId: widget.playerId,
        sport: _selectedSport,
        filePath: video.path,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video uploaded! Analysis in progress.'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final videosAsync = ref.watch(playerVideosProvider(widget.playerId));
    final latestAsync = ref.watch(latestVideoProvider(widget.playerId));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('AI Video Analysis', style: AppTextStyles.headlineMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('Record practice, get instant form feedback', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Upload Practice Video', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _selectedSport,
                            decoration: const InputDecoration(
                              labelText: 'Sport',
                              prefixIcon: Icon(Icons.sports_rounded),
                              isDense: true,
                            ),
                            items: _sports.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                            onChanged: (v) => setState(() => _selectedSport = v ?? 'Cricket'),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: GradientButton(
                              onPressed: _isUploading ? null : _pickAndUploadVideo,
                              isLoading: _isUploading,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.videocam_rounded, color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  Text('Pick Video from Gallery', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn().slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 16),
                  latestAsync.when(
                    data: (latest) {
                      if (latest == null) return const SizedBox.shrink();
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Latest Analysis', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 12),
                              _buildAnalysisResult(theme, latest),
                            ],
                          ),
                        ),
                      ).animate().fadeIn().slideY(begin: 0.2, end: 0);
                    },
                    loading: () => const SizedBox(height: 80, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 16),
                  Text('History', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  videosAsync.when(
                    data: (videos) {
                      if (videos.isEmpty) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.videocam_off_rounded, size: 48, color: AppColors.textDim),
                                  const SizedBox(height: 8),
                                  Text('No videos uploaded yet', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                      return Column(
                        children: videos.map((v) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Card(
                            margin: EdgeInsets.zero,
                            child: ListTile(
                              leading: Container(
                                width: 44, height: 44,
                                decoration: BoxDecoration(
                                  color: _getStatusColor(v.status).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  v.status == 'completed' ? Icons.check_circle_rounded : Icons.hourglass_empty_rounded,
                                  color: _getStatusColor(v.status),
                                ),
                              ),
                              title: Text(v.sport, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                              subtitle: Text(
                                DateFormat('MMM d, yyyy').format(v.uploadedAt),
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                              ),
                              trailing: v.status == 'completed'
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${v.poseScore?.toStringAsFixed(0) ?? '?'}/100',
                                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                                      ),
                                    )
                                  : Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.warning.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        v.status == 'processing' ? 'Processing' : 'Pending',
                                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.warning, fontSize: 10),
                                      ),
                                    ),
                            ),
                          ),
                        )).toList(),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    error: (e, __) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('Failed to load videos', style: TextStyle(color: AppColors.error)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisResult(ThemeData theme, VideoAnalysisResult result) {
    if (result.status == 'processing') {
      return Row(
        children: [
          const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
          const SizedBox(width: 12),
          Text('AI is analyzing your form...', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
        ],
      );
    }
    if (result.poseScore == null) return const SizedBox.shrink();
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: result.poseScore! >= 70 ? AppColors.gradientPrimary : AppColors.gradientAccent),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text('${result.poseScore!.toInt()}', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Form Score', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 2),
                  Text(result.sport, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: result.poseScore! >= 70 ? AppColors.success.withValues(alpha: 0.1) : AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                result.poseScore! >= 70 ? 'Good Form' : 'Needs Work',
                style: AppTextStyles.labelSmall.copyWith(
                  color: result.poseScore! >= 70 ? AppColors.success : AppColors.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        if (result.feedback != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline_rounded, size: 18, color: AppColors.accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(result.feedback!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary)),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return AppColors.success;
      case 'processing':
        return AppColors.warning;
      case 'pending_review':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/empty_state.dart';
import '../data/messages_repository.dart';
import '../domain/app_message.dart';

class MessagesPage extends ConsumerWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(messagesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesan'),
        actions: [
          IconButton(
            tooltip: 'Refresh pesan',
            onPressed: () => ref.invalidate(messagesProvider),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => ref.refresh(messagesProvider.future),
        child: messages.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              EmptyState(
                title: 'Pesan belum tersedia',
                message:
                    'Koneksi sedang bermasalah. Tarik layar untuk mencoba lagi.',
                icon: Icons.mail_outline_rounded,
              ),
            ],
          ),
          data: (items) => items.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 100),
                    EmptyState(
                      title: 'Belum ada pesan',
                      message:
                          'Pesan dari Booboo Pet Care akan muncul di sini.',
                      icon: Icons.mark_email_unread_outlined,
                    ),
                  ],
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _MessageTile(
                    message: items[index],
                    onTap: () => _showMessage(context, items[index]),
                  ),
                ),
        ),
      ),
    );
  }

  void _showMessage(BuildContext context, AppMessage message) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MessageSheet(message: message),
    );
  }
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({required this.message, required this.onTap});

  final AppMessage message;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final date = _formatDate(message.createdAt);

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: message.isRead
                ? AppColors.surface
                : AppColors.softPurple.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: message.isRead
                  ? AppColors.border
                  : AppColors.primary.withValues(alpha: 0.28),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: message.photo.isEmpty
                    ? Icon(
                        message.type == 'broadcast'
                            ? Icons.campaign_outlined
                            : Icons.mail_outline_rounded,
                        color: AppColors.primary,
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          message.photo,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.mail_outline_rounded,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            message.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (!message.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _plainText(message.message),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                    if (date.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        date,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageSheet extends StatelessWidget {
  const _MessageSheet({required this.message});

  final AppMessage message;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 680),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                message.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              if (_formatDate(message.createdAt).isNotEmpty)
                Text(
                  _formatDate(message.createdAt),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              const SizedBox(height: 18),
              Text(
                _plainText(message.message),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Tutup'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _plainText(String value) =>
    value.replaceAll(RegExp(r'<[^>]*>'), '').trim();

String _formatDate(String value) {
  final date = DateTime.tryParse(value);
  if (date == null) return value;
  return DateFormat('dd/MM/yyyy HH:mm').format(date.toLocal());
}

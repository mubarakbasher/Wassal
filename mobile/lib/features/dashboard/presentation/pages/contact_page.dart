import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/constants/app_colors.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  bool _sending = false;
  List<dynamic> _messages = [];
  bool _loadingMessages = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMessages();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      final apiClient = context.read<ApiClient>();
      final response = await apiClient.get(ApiEndpoints.contactMessages);
      if (mounted && response.statusCode == 200) {
        setState(() {
          _messages = response.data is List ? response.data : [];
          _loadingMessages = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingMessages = false);
    }
  }

  Future<void> _sendMessage() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sending = true);
    try {
      final apiClient = context.read<ApiClient>();
      final response = await apiClient.post(
        ApiEndpoints.contactMessages,
        data: {
          'subject': _subjectController.text.trim(),
          'message': _messageController.text.trim(),
        },
      );
      if (mounted && response.statusCode == 201) {
        _subjectController.clear();
        _messageController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.messageSent),
            backgroundColor: AppColors.success,
          ),
        );
        _tabController.animateTo(1);
        _loadMessages();
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = (e is Exception)
            ? AppLocalizations.of(context)!.sendMessageFailed
            : AppLocalizations.of(context)!.sendMessageFailed;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.contactUs),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(text: l10n.sendMessage),
            Tab(text: l10n.myMessages),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSendTab(l10n),
          _buildMessagesTab(l10n),
        ],
      ),
    );
  }

  Widget _buildSendTab(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.support_agent, color: Colors.white, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    l10n.contactUs,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.contactUsSubtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _subjectController,
              decoration: InputDecoration(
                labelText: l10n.subject,
                prefixIcon: const Icon(Icons.subject),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l10n.subjectRequired : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: l10n.message,
                prefixIcon: const Icon(Icons.message_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l10n.messageRequired : null,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _sending ? null : _sendMessage,
                icon: _sending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send),
                label: Text(
                  l10n.sendMessage,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesTab(AppLocalizations l10n) {
    if (_loadingMessages) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              l10n.noMessages,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadMessages,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final msg = _messages[index];
          return _buildMessageCard(msg, l10n);
        },
      ),
    );
  }

  Widget _buildMessageCard(dynamic msg, AppLocalizations l10n) {
    final status = msg['status'] as String? ?? 'UNREAD';
    final hasReply = status == 'REPLIED';

    Color statusColor;
    String statusText;
    switch (status) {
      case 'REPLIED':
        statusColor = AppColors.success;
        statusText = l10n.replied;
        break;
      case 'READ':
        statusColor = AppColors.info;
        statusText = l10n.read;
        break;
      default:
        statusColor = AppColors.warning;
        statusText = l10n.unread;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: const Border(),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            hasReply ? Icons.mark_email_read : Icons.email_outlined,
            color: statusColor,
          ),
        ),
        title: Text(
          msg['subject'] ?? '',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Row(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _formatDate(msg['createdAt']),
                style: TextStyle(color: Colors.grey[500], fontSize: 11),
              ),
            ),
          ],
        ),
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              msg['message'] ?? '',
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
          ),
          if (hasReply && msg['reply'] != null) ...[
            const Divider(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.admin_panel_settings,
                          size: 16, color: AppColors.success),
                      const SizedBox(width: 6),
                      Text(
                        l10n.adminReply,
                        style: TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    msg['reply'],
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return '';
    }
  }
}

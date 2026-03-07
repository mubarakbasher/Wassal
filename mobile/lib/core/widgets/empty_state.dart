import 'package:flutter/material.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';
import '../../features/dashboard/presentation/pages/subscription_page.dart';

/// Empty state widget with illustration and message
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon illustration
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: (iconColor ?? Theme.of(context).primaryColor).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 60,
                color: iconColor ?? Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            
            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            // Message
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            // Action button
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty state for routers list
class EmptyRoutersState extends StatelessWidget {
  final VoidCallback? onAddRouter;

  const EmptyRoutersState({
    super.key,
    this.onAddRouter,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return EmptyStateWidget(
      icon: Icons.router_outlined,
      title: l10n.noRoutersYet,
      message: l10n.noRoutersMessage,
      actionLabel: l10n.addRouter,
      onAction: onAddRouter,
      iconColor: Colors.blue,
    );
  }
}

/// Empty state for vouchers list
class EmptyVouchersState extends StatelessWidget {
  final VoidCallback? onCreateVoucher;

  const EmptyVouchersState({
    super.key,
    this.onCreateVoucher,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return EmptyStateWidget(
      icon: Icons.confirmation_number_outlined,
      title: l10n.noVouchersYet,
      message: l10n.noVouchersMessage,
      actionLabel: l10n.createVoucher,
      onAction: onCreateVoucher,
      iconColor: Colors.green,
    );
  }
}

/// Empty state for sales list
class EmptySalesState extends StatelessWidget {
  const EmptySalesState({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return EmptyStateWidget(
      icon: Icons.shopping_cart_outlined,
      title: l10n.noSalesYet,
      message: l10n.noSalesMessage,
      iconColor: Colors.orange,
    );
  }
}

/// Empty state for sessions list
class EmptySessionsState extends StatelessWidget {
  const EmptySessionsState({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return EmptyStateWidget(
      icon: Icons.people_outline,
      title: l10n.noActiveSessions,
      message: l10n.noActiveSessionsMessage,
      iconColor: Colors.purple,
    );
  }
}

/// Empty search results state
class EmptySearchState extends StatelessWidget {
  final String searchQuery;

  const EmptySearchState({
    super.key,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return EmptyStateWidget(
      icon: Icons.search_off,
      title: l10n.noResultsFound,
      message: l10n.noResultsMessage(searchQuery),
      iconColor: Colors.grey,
    );
  }
}

/// Error state widget
class ErrorStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  const ErrorStateWidget({
    super.key,
    this.title = 'Something Went Wrong',
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 60,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(height: 24),
            
            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            // Message
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            // Retry button
            if (onRetry != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(AppLocalizations.of(context)!.tryAgain),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[400],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Subscription required state - shown when user has no active subscription
class SubscriptionRequiredWidget extends StatelessWidget {
  final String? message;

  const SubscriptionRequiredWidget({
    super.key,
    this.message,
  });

  /// Check if an error message indicates a subscription is required
  static bool isSubscriptionError(String message) {
    return message.startsWith('[SUBSCRIPTION_REQUIRED]');
  }

  /// Extract the clean message without the marker prefix
  static String cleanMessage(String message) {
    return message.replaceFirst('[SUBSCRIPTION_REQUIRED]', '');
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lock icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                size: 60,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              AppLocalizations.of(context)!.subscriptionRequiredTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Message
            Text(
              message ?? AppLocalizations.of(context)!.subscriptionRequiredBody,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Go to Subscriptions button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SubscriptionPage()),
                );
              },
              icon: const Icon(Icons.subscriptions_outlined),
              label: Text(AppLocalizations.of(context)!.goToSubscriptions),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Network error state
class NetworkErrorState extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkErrorState({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ErrorStateWidget(
      icon: Icons.wifi_off,
      title: l10n.noInternetConnection,
      message: l10n.checkInternetConnection,
      onRetry: onRetry,
    );
  }
}

/// Server error state
class ServerErrorState extends StatelessWidget {
  final VoidCallback? onRetry;

  const ServerErrorState({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ErrorStateWidget(
      icon: Icons.cloud_off,
      title: l10n.serverErrorTitle,
      message: l10n.serverErrorMessage,
      onRetry: onRetry,
    );
  }
}

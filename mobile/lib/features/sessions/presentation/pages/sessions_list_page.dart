import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/snackbar_utils.dart';
import '../../../../core/widgets/loading_widgets.dart';
import '../bloc/session_bloc.dart';
import '../bloc/session_event.dart';
import '../bloc/session_state.dart';
import '../widgets/session_card.dart';
import '../widgets/session_statistics_card.dart';
import 'session_details_page.dart';

class SessionsListPage extends StatefulWidget {
  final String? routerId;

  const SessionsListPage({super.key, this.routerId});

  @override
  State<SessionsListPage> createState() => _SessionsListPageState();
}

class _SessionsListPageState extends State<SessionsListPage> {
  bool _showActiveOnly = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  void _loadSessions() {
    if (widget.routerId != null) {
      context.read<SessionBloc>().add(
            LoadSessionsByRouterEvent(widget.routerId!, activeOnly: _showActiveOnly),
          );
    } else {
      context.read<SessionBloc>().add(LoadSessionsEvent(activeOnly: _showActiveOnly));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Active Sessions',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.card,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          // Active/All toggle
          PopupMenuButton<bool>(
            icon: Icon(
              _showActiveOnly ? Icons.filter_alt : Icons.filter_alt_outlined,
              color: AppColors.card,
            ),
            onSelected: (value) {
              setState(() {
                _showActiveOnly = value;
              });
              _loadSessions();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: true,
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: _showActiveOnly ? AppColors.primary : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text('Active Only'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: false,
                child: Row(
                  children: [
                    Icon(
                      Icons.list,
                      color: !_showActiveOnly ? AppColors.primary : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text('All Sessions'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocConsumer<SessionBloc, SessionState>(
        listener: (context, state) {
          if (state is SessionError) {
            SnackBarUtils.showError(
              context,
              state.message,
              onRetry: _loadSessions,
            );
          }
          if (state is SessionTerminated) {
            SnackBarUtils.showSuccess(context, state.message);
            _loadSessions();
          }
        },
        builder: (context, state) {
          // Loading state - Show shimmer
          if (state is SessionLoading) {
            return Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: ShimmerCard(height: 150),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return const ShimmerListTile(height: 120);
                    },
                  ),
                ),
              ],
            );
          }

          // Error state - Show error widget
          if (state is SessionError) {
            return ErrorStateWidget(
              message: state.message,
              onRetry: _loadSessions,
            );
          }

          // Loaded state
          if (state is SessionsLoaded) {
            // Empty state - Show empty widget
            if (state.sessions.isEmpty) {
              return const EmptySessionsState();
            }

            // Success state - Show list with statistics
            return CustomRefreshIndicator(
              onRefresh: () async {
                _loadSessions();
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Statistics card
                  if (state.statistics != null)
                    FadeInWidget(
                      child: SessionStatisticsCard(
                        statistics: state.statistics!,
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Session count header
                  FadeInWidget(
                    delay: const Duration(milliseconds: 100),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        '${state.sessions.length} ${_showActiveOnly ? "Active" : ""} Session${state.sessions.length != 1 ? "s" : ""}',
                        style: AppTextStyles.headlineSmall,
                      ),
                    ),
                  ),

                  // Sessions list
                  ...state.sessions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final session = entry.value;
                    return FadeInWidget(
                      delay: Duration(milliseconds: 150 + (index * 50)),
                      child: SessionCard(
                        session: session,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => SessionDetailsPage(session: session),
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                ],
              ),
            );
          }

          // Default state
          return const LoadingIndicator(
            message: 'Loading sessions...',
          );
        },
      ),
    );
  }
}

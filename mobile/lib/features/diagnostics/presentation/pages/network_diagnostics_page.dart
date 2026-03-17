import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:mobile/l10n/generated/app_localizations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

enum _CheckStatus { pending, running, passed, failed, skipped }

class _DiagResult {
  _CheckStatus status = _CheckStatus.pending;
  String? detail;
  int? durationMs;
}

class NetworkDiagnosticsPage extends StatefulWidget {
  const NetworkDiagnosticsPage({super.key});

  @override
  State<NetworkDiagnosticsPage> createState() => _NetworkDiagnosticsPageState();
}

class _NetworkDiagnosticsPageState extends State<NetworkDiagnosticsPage> {
  bool _isRunning = false;
  String _summary = '';

  final _wifi = _DiagResult();
  final _dnsApi = _DiagResult();
  final _dnsGoogle = _DiagResult();
  final _httpHealth = _DiagResult();
  final _ipVersion = _DiagResult();

  @override
  void initState() {
    super.initState();
    _runDiagnostics();
  }

  Future<void> _runDiagnostics() async {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
      _summary = '';
      _wifi.status = _CheckStatus.running;
      _dnsApi.status = _CheckStatus.pending;
      _dnsGoogle.status = _CheckStatus.pending;
      _httpHealth.status = _CheckStatus.pending;
      _ipVersion.status = _CheckStatus.pending;
      _wifi.detail = null;
      _dnsApi.detail = null;
      _dnsGoogle.detail = null;
      _httpHealth.detail = null;
      _ipVersion.detail = null;
      _wifi.durationMs = null;
      _dnsApi.durationMs = null;
      _dnsGoogle.durationMs = null;
      _httpHealth.durationMs = null;
      _ipVersion.durationMs = null;
    });

    // 1. WiFi/Cellular
    await _checkWifi();

    if (_wifi.status == _CheckStatus.failed) {
      setState(() {
        _dnsApi.status = _CheckStatus.skipped;
        _dnsGoogle.status = _CheckStatus.skipped;
        _httpHealth.status = _CheckStatus.skipped;
        _ipVersion.status = _CheckStatus.skipped;
        _summary = _l10n?.diagSummaryNoInternet ?? 'No internet connection detected.';
        _isRunning = false;
      });
      return;
    }

    // 2. DNS for api.wassal.tech
    await _checkDns('api.wassal.tech', _dnsApi);

    // 3. DNS for google.com
    await _checkDns('google.com', _dnsGoogle);

    // 4. IP version detection from dnsApi results
    _detectIpVersion();

    // 5. HTTP health
    await _checkHttpHealth();

    // Summary
    _buildSummary();

    setState(() => _isRunning = false);
  }

  AppLocalizations? get _l10n => AppLocalizations.of(context);

  Future<void> _checkWifi() async {
    final sw = Stopwatch()..start();
    try {
      final results = await Connectivity().checkConnectivity();
      sw.stop();
      final connected = results.isNotEmpty && !results.contains(ConnectivityResult.none);
      setState(() {
        _wifi.status = connected ? _CheckStatus.passed : _CheckStatus.failed;
        _wifi.durationMs = sw.elapsedMilliseconds;
        if (connected) {
          final types = results.map((r) => r.name).join(', ');
          _wifi.detail = types;
        } else {
          _wifi.detail = _l10n?.diagNoConnection;
        }
      });
    } catch (e) {
      sw.stop();
      setState(() {
        _wifi.status = _CheckStatus.failed;
        _wifi.durationMs = sw.elapsedMilliseconds;
        _wifi.detail = e.toString();
      });
    }
  }

  Future<void> _checkDns(String hostname, _DiagResult result) async {
    setState(() => result.status = _CheckStatus.running);
    final sw = Stopwatch()..start();
    try {
      final addresses = await InternetAddress.lookup(hostname)
          .timeout(const Duration(seconds: 10));
      sw.stop();
      if (addresses.isNotEmpty) {
        final ip = addresses.first.address;
        setState(() {
          result.status = _CheckStatus.passed;
          result.durationMs = sw.elapsedMilliseconds;
          result.detail = _l10n?.diagResolvedTo(ip) ?? 'Resolved to $ip';
        });
      } else {
        setState(() {
          result.status = _CheckStatus.failed;
          result.durationMs = sw.elapsedMilliseconds;
          result.detail = _l10n?.diagDnsFailed;
        });
      }
    } catch (e) {
      sw.stop();
      setState(() {
        result.status = _CheckStatus.failed;
        result.durationMs = sw.elapsedMilliseconds;
        result.detail = _l10n?.diagDnsFailed;
      });
    }
  }

  void _detectIpVersion() {
    if (_dnsApi.status != _CheckStatus.passed) {
      setState(() => _ipVersion.status = _CheckStatus.skipped);
      return;
    }

    try {
      // Re-use the detail which contains the resolved IP
      final detail = _dnsApi.detail ?? '';
      final hasV4 = RegExp(r'\d+\.\d+\.\d+\.\d+').hasMatch(detail);
      final hasV6 = detail.contains(':');

      setState(() {
        _ipVersion.status = _CheckStatus.passed;
        if (hasV4 && hasV6) {
          _ipVersion.detail = _l10n?.diagIpv4And6 ?? 'IPv4 + IPv6';
        } else if (hasV6) {
          _ipVersion.detail = _l10n?.diagIpv6 ?? 'IPv6';
        } else {
          _ipVersion.detail = _l10n?.diagIpv4 ?? 'IPv4';
        }
      });
    } catch (_) {
      setState(() => _ipVersion.status = _CheckStatus.skipped);
    }
  }

  Future<void> _checkHttpHealth() async {
    if (_dnsApi.status != _CheckStatus.passed) {
      setState(() {
        _httpHealth.status = _CheckStatus.skipped;
        _httpHealth.detail = _l10n?.diagDnsFailed;
      });
      return;
    }

    setState(() => _httpHealth.status = _CheckStatus.running);

    final dio = Dio(BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ));

    final sw = Stopwatch()..start();
    try {
      final response = await dio.get('/health');
      sw.stop();

      setState(() {
        _httpHealth.durationMs = sw.elapsedMilliseconds;
        if (response.statusCode == 200) {
          _httpHealth.status = _CheckStatus.passed;
          _httpHealth.detail =
              '${_l10n?.diagServerOk ?? 'Server is reachable'} (${sw.elapsedMilliseconds}ms)';
        } else {
          _httpHealth.status = _CheckStatus.failed;
          _httpHealth.detail = 'HTTP ${response.statusCode}';
        }
      });
    } catch (e) {
      sw.stop();
      setState(() {
        _httpHealth.status = _CheckStatus.failed;
        _httpHealth.durationMs = sw.elapsedMilliseconds;
        _httpHealth.detail = _l10n?.diagServerUnreachable ?? 'Server is unreachable';
      });
    } finally {
      dio.close();
    }
  }

  void _buildSummary() {
    final l10n = _l10n;
    if (_wifi.status == _CheckStatus.failed) {
      _summary = l10n?.diagSummaryNoInternet ??
          'No internet connection detected.';
    } else if (_dnsApi.status == _CheckStatus.failed && _dnsGoogle.status == _CheckStatus.passed) {
      _summary = l10n?.diagSummaryDnsIssue ??
          'DNS resolution failed. Your network may be blocking this domain.';
    } else if (_dnsApi.status == _CheckStatus.failed && _dnsGoogle.status == _CheckStatus.failed) {
      _summary = l10n?.diagSummaryNoInternet ??
          'No internet connection detected.';
    } else if (_httpHealth.status == _CheckStatus.failed) {
      _summary = l10n?.diagSummaryServerDown ??
          'DNS works but the server is unreachable.';
    } else {
      _summary = l10n?.diagSummaryAllGood ??
          'All checks passed.';
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = _l10n!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.networkDiagnostics),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCheckTile(l10n.diagWifiConnectivity, Icons.wifi, _wifi),
          _buildCheckTile(l10n.diagDnsApi, Icons.dns, _dnsApi),
          _buildCheckTile(l10n.diagDnsGoogle, Icons.public, _dnsGoogle),
          _buildCheckTile(l10n.diagIpVersion, Icons.language, _ipVersion),
          _buildCheckTile(l10n.diagHttpHealth, Icons.cloud, _httpHealth),
          const SizedBox(height: 24),
          if (_summary.isNotEmpty) _buildSummaryCard(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isRunning ? null : _runDiagnostics,
              icon: _isRunning
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.refresh),
              label: Text(_isRunning ? l10n.runningDiagnostics : l10n.diagRunAgain),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckTile(String title, IconData icon, _DiagResult result) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: _buildStatusIcon(result.status),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: result.detail != null
            ? Text(
                result.detail!,
                style: TextStyle(
                  color: result.status == _CheckStatus.failed
                      ? AppColors.error
                      : AppColors.textSecondary,
                  fontSize: 13,
                ),
              )
            : null,
        trailing: result.durationMs != null
            ? Text(
                '${result.durationMs}ms',
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 12,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildStatusIcon(_CheckStatus status) {
    switch (status) {
      case _CheckStatus.pending:
        return Icon(Icons.circle_outlined, color: AppColors.textTertiary, size: 24);
      case _CheckStatus.running:
        return const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case _CheckStatus.passed:
        return const Icon(Icons.check_circle, color: AppColors.success, size: 24);
      case _CheckStatus.failed:
        return const Icon(Icons.cancel, color: AppColors.error, size: 24);
      case _CheckStatus.skipped:
        return Icon(Icons.remove_circle_outline, color: AppColors.textTertiary, size: 24);
    }
  }

  Widget _buildSummaryCard() {
    final allPassed = _wifi.status == _CheckStatus.passed &&
        _dnsApi.status == _CheckStatus.passed &&
        _httpHealth.status == _CheckStatus.passed;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: allPassed
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: allPassed
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            allPassed ? Icons.check_circle_outline : Icons.warning_amber_rounded,
            color: allPassed ? AppColors.success : AppColors.error,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _summary,
              style: TextStyle(
                color: allPassed ? AppColors.success : AppColors.error,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

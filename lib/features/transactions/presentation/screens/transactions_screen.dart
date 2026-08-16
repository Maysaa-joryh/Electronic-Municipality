import 'package:flutter/material.dart' hide Text;

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/di.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/repositories/auth_repository.dart';
import '../../../../l10n/localized_text.dart';
import '../../../../shared/widgets/citizen_verification_notice.dart';
import '../../../../shared/widgets/municipality_widgets.dart';
import '../../data/models/service_request_models.dart';
import '../../domain/service_requests_repository.dart';
import 'service_catalog_screen.dart';
import 'service_request_details_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({
    super.key,
    this.repository,
    this.authRepository,
  });

  final ServiceRequestsRepository? repository;
  final AuthRepository? authRepository;

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  late final ServiceRequestsRepository _repository;
  late final AuthRepository _authRepository;

  CitizenVerificationStatus? _verificationStatus;
  List<MunicipalServiceRequest> _requests = const [];
  bool _loading = true;
  String? _error;
  int _filter = 0;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? DI.serviceRequests;
    _authRepository = widget.authRepository ?? DI.auth;
    final user = _authRepository.currentUser;
    _verificationStatus = user?.isCitizen == true
        ? user!.citizenVerificationStatus
        : null;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final requests = await _repository.getAllRequests();
      if (!mounted) return;
      setState(() => _requests = requests);
    } catch (error) {
      if (mounted) setState(() => _error = _messageFor(error));
    }
    await _refreshVerificationStatus();
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _refreshVerificationStatus() async {
    final user = _authRepository.currentUser;
    if (user == null || !user.isCitizen) return;
    try {
      final fresh = await _authRepository.getCurrentUser();
      if (mounted) {
        setState(() => _verificationStatus = fresh.citizenVerificationStatus);
      }
    } catch (_) {
      // Laravel remains authoritative when a request is submitted.
    }
  }

  Future<void> _openVerification() async {
    await Navigator.of(context).pushNamed(AppRoutes.profile);
    if (mounted) await _refreshVerificationStatus();
  }

  Future<void> _openCatalog() async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => ServiceCatalogScreen(repository: _repository),
      ),
    );
    if (changed == true && mounted) await _load();
  }

  Future<void> _openRequest(MunicipalServiceRequest request) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => ServiceRequestDetailsScreen(
          requestId: request.id,
          repository: _repository,
        ),
      ),
    );
    if (changed == true && mounted) await _load();
  }

  List<MunicipalServiceRequest> get _filteredRequests {
    return _requests.where((request) {
      final code = request.status?.code;
      return switch (_filter) {
        1 => code == 'draft',
        2 => _activeStatusCodes.contains(code),
        3 => request.status?.isTerminal == true,
        _ => true,
      };
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final verificationStatus = _verificationStatus;
    final requests = _filteredRequests;
    return Material(
      color: Colors.transparent,
      child: RefreshIndicator(
        onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
        children: [
          const PageHeader(
            title: 'المعاملات',
            subtitle: 'أنشئ معاملاتك الرسمية وتابع حالتها من مكان واحد.',
          ),
          if (verificationStatus != null &&
              verificationStatus != CitizenVerificationStatus.verified) ...[
            const SizedBox(height: 14),
            CitizenVerificationNotice(
              status: verificationStatus,
              onAction: verificationStatus == CitizenVerificationStatus.pending
                  ? _refreshVerificationStatus
                  : _openVerification,
            ),
          ],
          const SizedBox(height: 18),
          _NewRequestBanner(onPressed: _openCatalog),
          const SizedBox(height: 22),
          _RequestFilterBar(
            selected: _filter,
            onChanged: (value) => setState(() => _filter = value),
            total: _requests.length,
          ),
          const SizedBox(height: 14),
          if (_loading)
            const _TransactionsLoading()
          else if (_error != null)
            _TransactionsError(message: _error!, onRetry: _load)
          else if (requests.isEmpty)
            _TransactionsEmpty(onCreate: _openCatalog)
          else
            ...requests.map(
              (request) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _TransactionCard(
                  request: request,
                  onTap: () => _openRequest(request),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const Set<String> _activeStatusCodes = <String>{
  'submitted',
  'under_review',
  'pending_engineering_approval',
  'pending_mayor_approval',
};

class _NewRequestBanner extends StatelessWidget {
  const _NewRequestBanner({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(.18),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleIcon(
            icon: Icons.add_task_rounded,
            color: Color(0x1FFFFFFF),
            iconColor: Colors.white,
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تقديم معاملة جديدة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'اختر الخدمة واملأ نموذجها الإلكتروني.',
                  style: TextStyle(color: Color(0xD9FFFFFF), height: 1.4),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onPressed,
            tooltip: 'تقديم معاملة جديدة',
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
            ),
            icon: const Icon(Icons.arrow_forward_rounded),
          ),
          ],
        ),
      ),
    );
  }
}

class _RequestFilterBar extends StatelessWidget {
  const _RequestFilterBar({
    required this.selected,
    required this.onChanged,
    required this.total,
  });

  final int selected;
  final ValueChanged<int> onChanged;
  final int total;

  @override
  Widget build(BuildContext context) {
    const labels = <String>['الكل', 'مسودات', 'قيد المتابعة', 'منتهية'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'طلباتي',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
              ),
            ),
            Text(
              '$total',
              translate: false,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List<Widget>.generate(labels.length, (index) {
              return Padding(
                padding: EdgeInsetsDirectional.only(
                  end: index == labels.length - 1 ? 0 : 8,
                ),
                child: ChoiceChip(
                  label: Text(labels[index]),
                  selected: selected == index,
                  onSelected: (_) => onChanged(index),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.request, required this.onTap});

  final MunicipalServiceRequest request;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final status = request.status;
    final color = _statusColor(status?.code);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AppPanel(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleIcon(
                icon: _statusIcon(status?.code),
                color: color.withOpacity(.13),
                iconColor: color,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.serviceType?.name ?? 'معاملة بلدية',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'رقم المعاملة #${request.id}',
                      style: const TextStyle(color: AppColors.muted),
                    ),
                    if (request.updatedAt != null) ...[
                      const SizedBox(height: 5),
                      Text(
                        'آخر تحديث: ${_dateText(request.updatedAt!)}',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (status != null)
                    StatusPill(label: status.displayName, color: color),
                  const SizedBox(height: 18),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: AppColors.muted,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionsLoading extends StatelessWidget {
  const _TransactionsLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 48),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _TransactionsError extends StatelessWidget {
  const _TransactionsError({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded, size: 44, color: AppColors.gold),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}

class _TransactionsEmpty extends StatelessWidget {
  const _TransactionsEmpty({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const CircleIcon(
            icon: Icons.assignment_outlined,
            color: AppColors.surfaceMuted,
            iconColor: AppColors.primary,
          ),
          const SizedBox(height: 14),
          const Text(
            'لا توجد معاملات ضمن هذا التصنيف.',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text(
            'يمكنك بدء معاملة جديدة من دليل الخدمات البلدية.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted, height: 1.45),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add_rounded),
            label: const Text('تقديم معاملة جديدة'),
          ),
        ],
      ),
    );
  }
}

Color _statusColor(String? code) => switch (code) {
      'draft' => AppColors.gold,
      'submitted' || 'under_review' || 'pending_engineering_approval' ||
      'pending_mayor_approval' => const Color(0xFF376FBA),
      'approved_and_document_issued' => AppColors.primary,
      'rejected' => const Color(0xFFC9472A),
      _ => AppColors.muted,
    };

IconData _statusIcon(String? code) => switch (code) {
      'draft' => Icons.edit_note_outlined,
      'approved_and_document_issued' => Icons.verified_outlined,
      'rejected' => Icons.cancel_outlined,
      _ => Icons.hourglass_top_rounded,
    };

String _dateText(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

String _messageFor(Object error) {
  if (error is ApiException) return error.message;
  return 'تعذر تحميل المعاملات. حاول مرة أخرى.';
}

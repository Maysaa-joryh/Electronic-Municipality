import 'package:flutter/material.dart' hide Text;

import '../../../../app/theme/app_colors.dart';
import '../../../../core/di.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/localized_text.dart';
import '../../../../shared/widgets/municipality_widgets.dart';
import '../../data/models/service_request_models.dart';
import '../../domain/service_requests_repository.dart';
import '../service_request_file_opener.dart';
import 'service_request_editor_screen.dart';

class ServiceRequestDetailsScreen extends StatefulWidget {
  const ServiceRequestDetailsScreen({
    super.key,
    required this.requestId,
    this.repository,
  });

  final int requestId;
  final ServiceRequestsRepository? repository;

  @override
  State<ServiceRequestDetailsScreen> createState() =>
      _ServiceRequestDetailsScreenState();
}

class _ServiceRequestDetailsScreenState extends State<ServiceRequestDetailsScreen> {
  late final ServiceRequestsRepository _repository;
  MunicipalServiceRequest? _request;
  MunicipalServiceType? _service;
  bool _loading = true;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? DI.serviceRequests;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final request = await _repository.getRequest(widget.requestId);
      MunicipalServiceType? service;
      final serviceId = request.serviceType?.id;
      if (serviceId != null) {
        try {
          service = await _repository.getService(serviceId);
        } catch (_) {
          // The request remains readable even if the current catalog entry was archived.
        }
      }
      if (!mounted) return;
      setState(() {
        _request = request;
        _service = service;
      });
    } catch (error) {
      if (mounted) setState(() => _error = _messageFor(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _editDraft() async {
    final request = _request;
    final service = _service;
    if (request == null || service == null) return;
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => ServiceRequestEditorScreen(
          service: service,
          draft: request,
          repository: _repository,
        ),
      ),
    );
    if (changed == true && mounted) {
      await _load();
      if (!mounted) return;
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _submitDraft() async {
    final request = _request;
    if (request == null || _busy) return;
    setState(() => _busy = true);
    try {
      await _repository.submitDraft(request.id);
      if (!mounted) return;
      _snack('تم إرسال المعاملة بنجاح.');
      await _load();
    } catch (error) {
      if (mounted) _showError(_messageFor(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deleteDraft() async {
    final request = _request;
    if (request == null || _busy) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المسودة'),
        content: const Text(
          'سيتم حذف هذه المسودة وجميع مرفقاتها نهائيًا. هل تريد المتابعة؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFC9472A)),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await _repository.deleteDraft(request.id);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) _showError(_messageFor(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openAttachment(ServiceRequestAttachment attachment) async {
    final request = _request;
    if (request == null || _busy) return;
    setState(() => _busy = true);
    try {
      final bytes = await _repository.downloadAttachment(
        requestId: request.id,
        attachmentId: attachment.id,
      );
      await ServiceRequestFileOpener.saveAndOpen(
        bytes: bytes,
        fileName: attachment.originalName,
      );
    } catch (error) {
      if (mounted) _showError(_messageFor(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openDocument() async {
    final request = _request;
    final document = request?.document;
    if (request == null || document == null || _busy) return;
    setState(() => _busy = true);
    try {
      final bytes = await _repository.downloadDocument(request.id);
      await ServiceRequestFileOpener.saveAndOpen(
        bytes: bytes,
        fileName: 'municipality-document-${document.documentNumber}.pdf',
      );
    } catch (error) {
      if (mounted) _showError(_messageFor(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: const Color(0xFFC9472A)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = _request;
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل المعاملة'),
        actions: [
          IconButton(
            tooltip: 'تحديث',
            onPressed: _loading || _busy ? null : _load,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : request == null
              ? _DetailsError(message: _error ?? 'تعذر تحميل المعاملة.', onRetry: _load)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
                    children: [
                      _RequestHero(request: request),
                      const SizedBox(height: 16),
                      _RequestSummary(request: request),
                      if (_service != null) ...[
                        const SizedBox(height: 20),
                        const _SectionTitle('بيانات المعاملة'),
                        const SizedBox(height: 10),
                        _DataPanel(request: request, service: _service!),
                      ],
                      if (request.attachments.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        const _SectionTitle('المرفقات'),
                        const SizedBox(height: 10),
                        _AttachmentsPanel(
                          attachments: request.attachments,
                          busy: _busy,
                          onOpen: _openAttachment,
                        ),
                      ],
                      if (request.document != null) ...[
                        const SizedBox(height: 20),
                        const _SectionTitle('الوثيقة الصادرة'),
                        const SizedBox(height: 10),
                        _IssuedDocumentPanel(
                          document: request.document!,
                          busy: _busy,
                          onOpen: _openDocument,
                        ),
                      ],
                      if (request.isDraft) ...[
                        const SizedBox(height: 24),
                        OutlinedButton.icon(
                          onPressed: _busy || _service == null ? null : _editDraft,
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('تعديل المسودة'),
                        ),
                        const SizedBox(height: 10),
                        FilledButton.icon(
                          onPressed: _busy ? null : _submitDraft,
                          icon: const Icon(Icons.send_rounded),
                          label: const Text('إرسال المعاملة'),
                        ),
                        const SizedBox(height: 10),
                        TextButton.icon(
                          onPressed: _busy ? null : _deleteDraft,
                          icon: const Icon(Icons.delete_outline_rounded),
                          label: const Text('حذف المسودة'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFC9472A),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }
}

class _RequestHero extends StatelessWidget {
  const _RequestHero({required this.request});

  final MunicipalServiceRequest request;

  @override
  Widget build(BuildContext context) {
    final status = request.status;
    return AppPanel(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          CircleIcon(
            icon: request.isDraft ? Icons.edit_note_outlined : Icons.description_outlined,
            color: _statusColor(status?.code).withOpacity(.14),
            iconColor: _statusColor(status?.code),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.serviceType?.name ?? 'معاملة بلدية',
                  style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 5),
                Text('رقم المعاملة #${request.id}', style: const TextStyle(color: AppColors.muted)),
              ],
            ),
          ),
          if (status != null)
            StatusPill(label: status.displayName, color: _statusColor(status.code)),
        ],
      ),
    );
  }
}

class _RequestSummary extends StatelessWidget {
  const _RequestSummary({required this.request});

  final MunicipalServiceRequest request;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _SummaryLine('تاريخ الإنشاء', _dateText(request.createdAt)),
          const Divider(height: 22),
          _SummaryLine('آخر تحديث', _dateText(request.updatedAt)),
          if (request.submittedAt != null) ...[
            const Divider(height: 22),
            _SummaryLine('تاريخ الإرسال', _dateText(request.submittedAt)),
          ],
          if (request.serviceType?.municipalityName != null) ...[
            const Divider(height: 22),
            _SummaryLine('البلدية', request.serviceType!.municipalityName!),
          ],
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(color: AppColors.muted))),
        Flexible(child: Text(value, textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.w700))),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.value);

  final String value;

  @override
  Widget build(BuildContext context) {
    return Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800));
  }
}

class _DataPanel extends StatelessWidget {
  const _DataPanel({required this.request, required this.service});

  final MunicipalServiceRequest request;
  final MunicipalServiceType service;

  @override
  Widget build(BuildContext context) {
    final fields = service.activeVersion?.fields.where((field) => !field.isFile).toList() ?? const <ServiceFormField>[];
    return AppPanel(
      padding: const EdgeInsets.all(16),
      child: fields.isEmpty
          ? const Text('لا توجد بيانات نصية مسجلة لهذه المعاملة.')
          : Column(
              children: [
                for (var index = 0; index < fields.length; index++) ...[
                  _SummaryLine(
                    fields[index].label,
                    _displayValue(request.data[fields[index].fieldKey]),
                  ),
                  if (index < fields.length - 1) const Divider(height: 22),
                ],
              ],
            ),
    );
  }
}

class _AttachmentsPanel extends StatelessWidget {
  const _AttachmentsPanel({
    required this.attachments,
    required this.busy,
    required this.onOpen,
  });

  final List<ServiceRequestAttachment> attachments;
  final bool busy;
  final ValueChanged<ServiceRequestAttachment> onOpen;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: attachments
            .map(
              (attachment) => ListTile(
                leading: const CircleIcon(
                  icon: Icons.attach_file_rounded,
                  color: AppColors.surfaceMuted,
                  iconColor: AppColors.primary,
                  size: 38,
                ),
                title: Text(attachment.originalName, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(_formatBytes(attachment.fileSize)),
                trailing: IconButton(
                  tooltip: 'فتح المرفق',
                  onPressed: busy ? null : () => onOpen(attachment),
                  icon: const Icon(Icons.download_outlined),
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _IssuedDocumentPanel extends StatelessWidget {
  const _IssuedDocumentPanel({
    required this.document,
    required this.busy,
    required this.onOpen,
  });

  final ServiceRequestDocument document;
  final bool busy;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleIcon(
                icon: Icons.verified_outlined,
                color: AppColors.surfaceMuted,
                iconColor: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'وثيقة رقم ${document.documentNumber}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _SummaryLine('رمز التحقق', document.verificationCode),
          const SizedBox(height: 8),
          _SummaryLine('تاريخ الإصدار', _dateText(document.issuedAt)),
          const SizedBox(height: 14),
          FilledButton.tonalIcon(
            onPressed: busy ? null : onOpen,
            icon: const Icon(Icons.download_rounded),
            label: const Text('تنزيل الوثيقة'),
          ),
        ],
      ),
    );
  }
}

class _DetailsError extends StatelessWidget {
  const _DetailsError({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: AppPanel(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
        ),
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

String _displayValue(Object? value) {
  if (value == null || value.toString().trim().isEmpty) return '—';
  if (value == true) return 'نعم';
  if (value == false) return 'لا';
  return value.toString();
}

String _dateText(DateTime? value) {
  if (value == null) return '—';
  return '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
}

String _formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes بايت';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} كيلوبايت';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} ميغابايت';
}

String _messageFor(Object error) {
  if (error is ApiException) return error.message;
  return 'تعذر تنفيذ العملية. حاول مرة أخرى.';
}

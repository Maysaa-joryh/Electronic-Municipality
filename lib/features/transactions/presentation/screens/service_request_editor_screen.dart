import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' hide Text;

import '../../../../app/theme/app_colors.dart';
import '../../../../core/di.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/localized_text.dart';
import '../../../../shared/widgets/municipality_widgets.dart';
import '../../data/models/service_request_models.dart';
import '../../domain/service_requests_repository.dart';

class ServiceRequestEditorScreen extends StatefulWidget {
  const ServiceRequestEditorScreen({
    super.key,
    required this.service,
    this.draft,
    this.repository,
  });

  final MunicipalServiceType service;
  final MunicipalServiceRequest? draft;
  final ServiceRequestsRepository? repository;

  @override
  State<ServiceRequestEditorScreen> createState() =>
      _ServiceRequestEditorScreenState();
}

class _ServiceRequestEditorScreenState extends State<ServiceRequestEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final ServiceRequestsRepository _repository;
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, Object?> _values = {};

  MunicipalServiceType? _service;
  MunicipalServiceRequest? _draft;
  bool _loading = true;
  bool _busy = false;
  String? _error;
  Map<String, String> _fieldErrors = const {};

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? DI.serviceRequests;
    _draft = widget.draft;
    _load();
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final service = await _repository.getService(widget.service.id);
      if (!mounted) return;
      _service = service;
      _hydrateValues();
    } catch (error) {
      if (!mounted) return;
      _service = widget.service;
      _hydrateValues();
      _error = _messageFor(error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _hydrateValues() {
    final fields = _service?.activeVersion?.fields ?? const <ServiceFormField>[];
    final draftData = _draft?.data ?? const <String, dynamic>{};
    for (final field in fields) {
      if (field.isFile) continue;
      final value = draftData[field.fieldKey];
      if (field.type == ServiceFormFieldType.checkbox) {
        _values[field.fieldKey] = value == true || value == 1 || value == '1';
        continue;
      }
      if (field.type == ServiceFormFieldType.select ||
          field.type == ServiceFormFieldType.radio) {
        final selected = value?.toString();
        _values[field.fieldKey] = field.options.contains(selected) ? selected : null;
        continue;
      }
      _controllers[field.fieldKey] = TextEditingController(
        text: value?.toString() ?? '',
      );
    }
  }

  Map<String, dynamic> _data() {
    final service = _service;
    if (service == null) return const <String, dynamic>{};
    final result = <String, dynamic>{};
    for (final field in service.activeVersion?.fields ?? const <ServiceFormField>[]) {
      if (field.isFile) continue;
      switch (field.type) {
        case ServiceFormFieldType.checkbox:
          result[field.fieldKey] = _values[field.fieldKey] == true;
        case ServiceFormFieldType.select:
        case ServiceFormFieldType.radio:
          final value = _values[field.fieldKey];
          if (value != null) result[field.fieldKey] = value;
        default:
          final value = _controllers[field.fieldKey]?.text.trim() ?? '';
          if (value.isNotEmpty) result[field.fieldKey] = value;
      }
    }
    return result;
  }

  Map<String, String> _clientFieldErrors({required bool submitting}) {
    if (!submitting) return const {};
    final errors = <String, String>{};
    final attachmentsByField = <String, ServiceRequestAttachment>{
      for (final attachment in _draft?.attachments ?? const <ServiceRequestAttachment>[])
        attachment.fieldKey: attachment,
    };
    for (final field in _service?.activeVersion?.fields ?? const <ServiceFormField>[]) {
      if (!field.isRequired) continue;
      if (field.isFile) {
        if (!attachmentsByField.containsKey(field.fieldKey)) {
          errors[field.fieldKey] = 'هذا المرفق مطلوب.';
        }
        continue;
      }
      final value = _data()[field.fieldKey];
      final empty = value == null || (value is String && value.trim().isEmpty);
      if (empty) errors[field.fieldKey] = 'هذا الحقل مطلوب.';
    }
    return errors;
  }

  Future<MunicipalServiceRequest?> _saveDraft({
    required bool submitting,
    bool showSuccess = true,
  }) async {
    if (_busy) return _draft;
    final service = _service;
    if (service?.activeVersion == null) {
      setState(() => _error = 'تعذر تحميل نموذج الخدمة المحددة.');
      return null;
    }

    final fieldErrors = _clientFieldErrors(submitting: submitting);
    if (fieldErrors.isNotEmpty) {
      setState(() {
        _fieldErrors = fieldErrors;
        _error = 'أكمل الحقول والمرفقات المطلوبة قبل الإرسال.';
      });
      return null;
    }

    setState(() {
      _busy = true;
      _error = null;
      _fieldErrors = const {};
    });
    try {
      final current = _draft;
      final request = current == null
          ? await _repository.createDraft(
              serviceTypeVersionId: service!.activeVersion!.id,
              data: _data(),
            )
          : await _repository.updateDraft(
              requestId: current.id,
              data: _data(),
            );
      if (!mounted) return request;
      setState(() => _draft = request);

      if (submitting) {
        final submitted = await _repository.submitDraft(request.id);
        if (!mounted) return submitted;
        setState(() => _draft = submitted);
        _snack('تم إرسال المعاملة بنجاح.');
        Navigator.of(context).pop(true);
      } else if (showSuccess) {
        _snack('تم حفظ المسودة. يمكنك إكمالها وإرسالها لاحقًا.');
      }
      return request;
    } catch (error) {
      if (!mounted) return null;
      setState(() {
        _error = _messageFor(error);
        _fieldErrors = _errorsFrom(error);
      });
      return null;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickFile(ServiceFormField field) async {
    if (_busy) return;
    try {
      final selected = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
        withData: true,
      );
      final file = selected?.files.singleOrNull;
      if (file == null || file.bytes == null) return;
      if (file.bytes!.length > 10 * 1024 * 1024) {
        setState(() => _fieldErrors = <String, String>{
              ..._fieldErrors,
              field.fieldKey: 'حجم الملف يجب ألا يتجاوز 10 ميغابايت.',
            });
        return;
      }

      final draft = await _saveDraft(submitting: false, showSuccess: false);
      if (draft == null || !mounted) return;
      setState(() {
        _busy = true;
        _error = null;
      });
      final attachment = await _repository.uploadAttachment(
        requestId: draft.id,
        fieldKey: field.fieldKey,
        attachment: ServiceRequestAttachmentInput(
          name: file.name,
          bytes: file.bytes!,
        ),
      );
      if (!mounted) return;
      final current = _draft;
      if (current == null) return;
      final attachments = <ServiceRequestAttachment>[
        for (final item in current.attachments)
          if (item.fieldKey != field.fieldKey) item,
        attachment,
      ];
      setState(() {
        _draft = MunicipalServiceRequest(
          id: current.id,
          serviceType: current.serviceType,
          data: current.data,
          status: current.status,
          attachments: attachments,
          submittedAt: current.submittedAt,
          document: current.document,
          createdAt: current.createdAt,
          updatedAt: current.updatedAt,
        );
        _fieldErrors = Map<String, String>.from(_fieldErrors)
          ..remove(field.fieldKey);
      });
      _snack('تم رفع المرفق بنجاح.');
    } catch (error) {
      if (mounted) setState(() => _error = _messageFor(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _removeAttachment(ServiceRequestAttachment attachment) async {
    final draft = _draft;
    if (draft == null || _busy) return;
    setState(() => _busy = true);
    try {
      await _repository.deleteAttachment(
        requestId: draft.id,
        attachmentId: attachment.id,
      );
      if (!mounted) return;
      setState(() {
        _draft = MunicipalServiceRequest(
          id: draft.id,
          serviceType: draft.serviceType,
          data: draft.data,
          status: draft.status,
          attachments: draft.attachments
              .where((item) => item.id != attachment.id)
              .toList(growable: false),
          submittedAt: draft.submittedAt,
          document: draft.document,
          createdAt: draft.createdAt,
          updatedAt: draft.updatedAt,
        );
      });
    } catch (error) {
      if (mounted) setState(() => _error = _messageFor(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final service = _service;
    return Scaffold(
      appBar: AppBar(
        title: Text(_draft == null ? 'تقديم معاملة' : 'تعديل المسودة'),
        actions: [
          if (!_loading)
            IconButton(
              tooltip: 'حفظ المسودة',
              onPressed: _busy ? null : () => _saveDraft(submitting: false),
              icon: const Icon(Icons.save_outlined),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : service == null || service.activeVersion == null
              ? _EditorError(message: _error ?? 'تعذر تحميل نموذج الخدمة.', onRetry: _load)
              : _buildForm(service),
      bottomNavigationBar: service == null || service.activeVersion == null
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(24, 10, 24, 18),
              child: FilledButton.icon(
                key: const ValueKey('service_request_submit_button'),
                onPressed: _busy ? null : () => _saveDraft(submitting: true),
                icon: _busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_rounded),
                label: Text(_busy ? 'جارٍ الحفظ...' : 'إرسال المعاملة'),
              ),
            ),
    );
  }

  Widget _buildForm(MunicipalServiceType service) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
        children: [
          AppPanel(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                if (service.description.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    service.description,
                    style: const TextStyle(color: AppColors.muted, height: 1.5),
                  ),
                ],
                if (service.municipalityName != null) ...[
                  const SizedBox(height: 12),
                  _EditorMunicipality(service.municipalityName!),
                ],
              ],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 14),
            _EditorMessage(message: _error!),
          ],
          const SizedBox(height: 18),
          const Text(
            'بيانات المعاملة',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          ...service.activeVersion!.fields.map(
            (field) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _fieldWidget(field),
            ),
          ),
          const SizedBox(height: 92),
        ],
      ),
    );
  }

  Widget _fieldWidget(ServiceFormField field) {
    final error = _fieldErrors[field.fieldKey];
    final label = field.isRequired ? '${field.label} *' : field.label;
    switch (field.type) {
      case ServiceFormFieldType.text:
      case ServiceFormFieldType.number:
      case ServiceFormFieldType.textarea:
        return TextField(
          controller: _controllers[field.fieldKey],
          keyboardType: field.type == ServiceFormFieldType.number
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          maxLines: field.type == ServiceFormFieldType.textarea ? 4 : 1,
          decoration: InputDecoration(
            labelText: label,
            errorText: error,
            alignLabelWithHint: field.type == ServiceFormFieldType.textarea,
          ),
        );
      case ServiceFormFieldType.date:
        return TextField(
          controller: _controllers[field.fieldKey],
          readOnly: true,
          onTap: () => _pickDate(field),
          decoration: InputDecoration(
            labelText: label,
            errorText: error,
            suffixIcon: const Icon(Icons.calendar_month_outlined),
          ),
        );
      case ServiceFormFieldType.select:
        return DropdownButtonFormField<String>(
          value: _values[field.fieldKey] as String?,
          decoration: InputDecoration(labelText: label, errorText: error),
          isExpanded: true,
          items: field.options
              .map((option) => DropdownMenuItem(value: option, child: Text(option)))
              .toList(growable: false),
          onChanged: _busy
              ? null
              : (value) => setState(() {
                    _values[field.fieldKey] = value;
                    _fieldErrors = Map<String, String>.from(_fieldErrors)
                      ..remove(field.fieldKey);
                  }),
        );
      case ServiceFormFieldType.radio:
        return _RadioField(
          label: label,
          error: error,
          value: _values[field.fieldKey] as String?,
          options: field.options,
          onChanged: _busy
              ? null
              : (value) => setState(() {
                    _values[field.fieldKey] = value;
                    _fieldErrors = Map<String, String>.from(_fieldErrors)
                      ..remove(field.fieldKey);
                  }),
        );
      case ServiceFormFieldType.checkbox:
        return AppPanel(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            children: [
              SwitchListTile.adaptive(
                title: Text(label),
                value: _values[field.fieldKey] == true,
                onChanged: _busy
                    ? null
                    : (value) => setState(() {
                          _values[field.fieldKey] = value;
                          _fieldErrors = Map<String, String>.from(_fieldErrors)
                            ..remove(field.fieldKey);
                        }),
              ),
              if (error != null)
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(start: 16, bottom: 9),
                    child: Text(
                      error,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
        );
      case ServiceFormFieldType.file:
        return _FileField(
          label: label,
          error: error,
          attachment: _attachmentFor(field.fieldKey),
          busy: _busy,
          onPick: () => _pickFile(field),
          onRemove: _attachmentFor(field.fieldKey) == null
              ? null
              : () => _removeAttachment(_attachmentFor(field.fieldKey)!),
        );
    }
  }

  ServiceRequestAttachment? _attachmentFor(String fieldKey) {
    for (final attachment in _draft?.attachments ?? const <ServiceRequestAttachment>[]) {
      if (attachment.fieldKey == fieldKey) return attachment;
    }
    return null;
  }

  Future<void> _pickDate(ServiceFormField field) async {
    final controller = _controllers[field.fieldKey]!;
    final parsed = DateTime.tryParse(controller.text);
    final selected = await showDatePicker(
      context: context,
      initialDate: parsed ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (selected == null || !mounted) return;
    setState(() {
      controller.text =
          '${selected.year.toString().padLeft(4, '0')}-${selected.month.toString().padLeft(2, '0')}-${selected.day.toString().padLeft(2, '0')}';
      _fieldErrors = Map<String, String>.from(_fieldErrors)..remove(field.fieldKey);
    });
  }
}

class _RadioField extends StatelessWidget {
  const _RadioField({
    required this.label,
    required this.error,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String? error;
  final String? value;
  final List<String> options;
  final ValueChanged<String?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final validationError = error;
    return AppPanel(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          ...options.map(
            (option) => RadioListTile<String>(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(option),
              value: option,
              groupValue: value,
              onChanged: onChanged,
            ),
          ),
          if (validationError != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                validationError,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}

class _FileField extends StatelessWidget {
  const _FileField({
    required this.label,
    required this.error,
    required this.attachment,
    required this.busy,
    required this.onPick,
    required this.onRemove,
  });

  final String label;
  final String? error;
  final ServiceRequestAttachment? attachment;
  final bool busy;
  final VoidCallback onPick;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final attached = attachment;
    final validationError = error;
    return AppPanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 5),
          const Text(
            'الصيغ المدعومة: PDF أو JPG أو PNG، بحجم لا يتجاوز 10 ميغابايت.',
            style: TextStyle(color: AppColors.muted, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 12),
          if (attached == null)
            OutlinedButton.icon(
              onPressed: busy ? null : onPick,
              icon: const Icon(Icons.attach_file_rounded),
              label: const Text('إرفاق ملف'),
            )
          else
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.description_outlined, color: AppColors.primary),
                title: Text(attached.originalName, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(_formatBytes(attached.fileSize)),
                trailing: IconButton(
                  tooltip: 'حذف المرفق',
                  onPressed: busy ? null : onRemove,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ),
            ),
          if (validationError != null) ...[
            const SizedBox(height: 8),
            Text(
              validationError,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

class _EditorMunicipality extends StatelessWidget {
  const _EditorMunicipality(this.name);

  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.location_city_outlined, size: 17, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(name, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _EditorMessage extends StatelessWidget {
  const _EditorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1EE),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFC9472A)),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: const TextStyle(color: Color(0xFF9C321D)))),
        ],
      ),
    );
  }
}

class _EditorError extends StatelessWidget {
  const _EditorError({required this.message, required this.onRetry});

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
              const Icon(Icons.error_outline_rounded, size: 44, color: AppColors.gold),
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

Map<String, String> _errorsFrom(Object error) {
  if (error is ApiException) {
    return error.errors.map(
      (key, messages) => MapEntry(key, messages.join('\n')),
    );
  }
  return const <String, String>{};
}

String _messageFor(Object error) {
  if (error is ApiException) return error.message;
  return 'تعذر تنفيذ العملية. حاول مرة أخرى.';
}

String _formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes بايت';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} كيلوبايت';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} ميغابايت';
}

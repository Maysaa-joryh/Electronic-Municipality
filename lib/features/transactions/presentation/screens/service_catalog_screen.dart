import 'package:flutter/material.dart' hide Text;

import '../../../../app/theme/app_colors.dart';
import '../../../../core/di.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/localized_text.dart';
import '../../../../shared/widgets/municipality_widgets.dart';
import '../../data/models/service_request_models.dart';
import '../../domain/service_requests_repository.dart';
import 'service_request_editor_screen.dart';

class ServiceCatalogScreen extends StatefulWidget {
  const ServiceCatalogScreen({
    super.key,
    this.repository,
  });

  final ServiceRequestsRepository? repository;

  @override
  State<ServiceCatalogScreen> createState() => _ServiceCatalogScreenState();
}

class _ServiceCatalogScreenState extends State<ServiceCatalogScreen> {
  final _search = TextEditingController();
  late final ServiceRequestsRepository _repository;

  List<MunicipalServiceType> _services = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? DI.serviceRequests;
    _search.addListener(_onSearchChanged);
    _load();
  }

  @override
  void dispose() {
    _search
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _onSearchChanged() => setState(() {});

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final services = await _repository.getAllServices();
      if (!mounted) return;
      setState(() => _services = services);
    } catch (error) {
      if (mounted) setState(() => _error = _messageFor(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openService(MunicipalServiceType service) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => ServiceRequestEditorScreen(
          service: service,
          repository: _repository,
        ),
      ),
    );
    if (changed == true && mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.text.trim().toLowerCase();
    final services = _services.where((service) {
      if (query.isEmpty) return true;
      return service.name.toLowerCase().contains(query) ||
          service.description.toLowerCase().contains(query) ||
          (service.municipalityName?.toLowerCase().contains(query) ?? false);
    }).toList(growable: false);

    return Scaffold(
      appBar: AppBar(title: const Text('دليل الخدمات')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
          children: [
            const PageHeader(
              title: 'الخدمات البلدية',
              subtitle: 'اختر الخدمة المناسبة وابدأ معاملتك الرسمية.',
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _search,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'ابحث باسم الخدمة...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _search.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: _search.clear,
                        icon: const Icon(Icons.close_rounded),
                        tooltip: 'مسح البحث',
                      ),
              ),
            ),
            const SizedBox(height: 18),
            if (_loading)
              const _CatalogLoading()
            else if (_error != null)
              _CatalogError(message: _error!, onRetry: _load)
            else if (services.isEmpty)
              const _CatalogEmpty()
            else
              ...services.map(
                (service) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ServiceCatalogCard(
                    service: service,
                    onTap: () => _openService(service),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ServiceCatalogCard extends StatelessWidget {
  const _ServiceCatalogCard({
    required this.service,
    required this.onTap,
  });

  final MunicipalServiceType service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fieldsCount = service.activeVersion?.fields.length ?? 0;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AppPanel(
          padding: const EdgeInsets.all(18),
          child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleIcon(
            icon: Icons.account_balance_outlined,
            color: AppColors.surfaceMuted,
            iconColor: AppColors.primary,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (service.description.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    service.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.muted, height: 1.45),
                  ),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 7,
                  children: [
                    if (service.municipalityName != null)
                      _InfoChip(
                        icon: Icons.location_city_outlined,
                        label: service.municipalityName!,
                      ),
                    _InfoChip(
                      icon: Icons.format_list_bulleted_rounded,
                      label: 'حقول الخدمة: $fieldsCount',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios_rounded, size: 17),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: AppColors.primary),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CatalogLoading extends StatelessWidget {
  const _CatalogLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 56),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _CatalogError extends StatelessWidget {
  const _CatalogError({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return AppPanel(
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded, size: 42, color: AppColors.gold),
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

class _CatalogEmpty extends StatelessWidget {
  const _CatalogEmpty();

  @override
  Widget build(BuildContext context) {
    return const AppPanel(
      child: Column(
        children: [
          Icon(Icons.inventory_2_outlined, size: 46, color: AppColors.muted),
          SizedBox(height: 12),
          Text(
            'لا توجد خدمات متاحة حاليًا ضمن بلديتك.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

String _messageFor(Object error) {
  if (error is ApiException) return error.message;
  return 'تعذر الاتصال بالخدمات البلدية. حاول مرة أخرى.';
}

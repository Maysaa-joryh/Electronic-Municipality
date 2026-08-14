import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:electronic_municipality/features/complaints/data/models/complaint_models.dart';
import 'package:electronic_municipality/features/complaints/domain/complaints_repository.dart';
import 'package:electronic_municipality/features/complaints/presentation/screens/complaint_location_picker_screen.dart';
import 'package:electronic_municipality/features/complaints/presentation/screens/complaints_screen.dart';

void main() {
  testWidgets('creates draft, uploads by report id, then submits', (
    WidgetTester tester,
  ) async {
    final repository = _ComplaintsRepositoryFake();
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ComplaintsScreen(
            repository: repository,
            municipalityId: 12,
            locationSelector: (_, __) async => const ComplaintLocation(
              latitude: 33.5138,
              longitude: 36.2765,
            ),
            imagePicker: () async => <ComplaintAttachment>[
              ComplaintAttachment(
                name: 'evidence.jpg',
                bytes: Uint8List(20),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('complaint_category_group_field')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('المياه والصرف الصحي').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('complaint_category_field')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تسرب مياه').last);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('complaint_title_field')),
      'انقطاع المياه',
    );
    await tester.enterText(
      find.byKey(const ValueKey('complaint_description_field')),
      'انقطاع المياه منذ الصباح',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    final complaintsList = find.byType(ListView);

    final selectLocation =
        find.byKey(const ValueKey('select_complaint_location'));
    await tester.dragUntilVisible(
      selectLocation,
      complaintsList,
      const Offset(0, -200),
    );
    await tester.tap(selectLocation);
    await tester.pumpAndSettle();
    expect(find.text('33.513800, 36.276500'), findsOneWidget);

    final pickImages = find.byKey(const ValueKey('pick_complaint_images'));
    await tester.dragUntilVisible(
      pickImages,
      complaintsList,
      const Offset(0, -200),
    );
    await tester.tap(pickImages);
    await tester.pumpAndSettle();

    final submit = find.byKey(const ValueKey('submit_complaint'));
    await tester.dragUntilVisible(
      submit,
      complaintsList,
      const Offset(0, -200),
    );
    await tester.tap(submit);
    await tester.pumpAndSettle();

    expect(
      repository.mutations,
      <String>[
        'create:12:16',
        'upload:51:1',
        'submit:51',
      ],
    );
    expect(repository.createdInput?.latitude, 33.5138);
    expect(repository.createdInput?.longitude, 36.2765);
    expect(find.text('مرسلة'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('edit_complaint_51')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('delete_complaint_51')),
      findsNothing,
    );
  });
}

class _ComplaintsRepositoryFake implements ComplaintsRepository {
  final List<String> mutations = <String>[];
  ComplaintDraftInput? createdInput;
  ComplaintReport? _report;

  static const _waterLeak = ComplaintCategory(
    id: 16,
    parentId: 15,
    name: 'تسرب مياه',
  );

  static const _water = ComplaintCategory(
    id: 15,
    name: 'المياه والصرف الصحي',
    children: <ComplaintCategory>[_waterLeak],
  );

  @override
  Future<List<ComplaintCategory>> getCategories() async {
    return const <ComplaintCategory>[_water];
  }

  @override
  Future<List<ComplaintReport>> getReports() async {
    return <ComplaintReport>[if (_report != null) _report!];
  }

  @override
  Future<ComplaintReport> getReport(int reportId) async {
    return _report!;
  }

  @override
  Future<ComplaintReport> createDraft(ComplaintDraftInput input) async {
    createdInput = input;
    mutations.add(
      'create:${input.municipalityId}:${input.categoryId}',
    );
    _report = ComplaintReport(
      id: 51,
      status: const ComplaintStatus(key: 'draft', label: 'مسودة'),
      images: const <ComplaintImage>[],
      municipalityId: input.municipalityId,
      categoryId: input.categoryId,
      category: _waterLeak,
      title: input.title?.trim(),
      description: input.description?.trim(),
      textLocation: input.textLocation?.trim(),
      latitude: input.latitude,
      longitude: input.longitude,
      serverCanEdit: true,
    );
    return _report!;
  }

  @override
  Future<ComplaintReport> updateDraft({
    required ComplaintReport report,
    required ComplaintDraftInput input,
  }) async {
    mutations.add('update:${report.id}');
    return report;
  }

  @override
  Future<void> uploadImages({
    required ComplaintReport report,
    required List<ComplaintAttachment> images,
  }) async {
    mutations.add('upload:${report.id}:${images.length}');
    _report = ComplaintReport(
      id: report.id,
      status: report.status,
      images: const <ComplaintImage>[
        ComplaintImage(id: 7, url: 'images/evidence.jpg'),
      ],
      municipalityId: report.municipalityId,
      categoryId: report.categoryId,
      category: report.category,
      title: report.title,
      description: report.description,
      textLocation: report.textLocation,
      latitude: report.latitude,
      longitude: report.longitude,
      serverCanEdit: true,
    );
  }

  @override
  Future<ComplaintReport> submitDraft(ComplaintReport report) async {
    mutations.add('submit:${report.id}');
    _report = ComplaintReport(
      id: report.id,
      status: const ComplaintStatus(key: 'submitted', label: 'مرسلة'),
      images: report.images,
      municipalityId: report.municipalityId,
      categoryId: report.categoryId,
      category: report.category,
      title: report.title,
      description: report.description,
      textLocation: report.textLocation,
      latitude: report.latitude,
      longitude: report.longitude,
      serverCanEdit: false,
    );
    return _report!;
  }

  @override
  Future<void> deleteDraft(ComplaintReport report) async {
    mutations.add('delete:${report.id}');
    _report = null;
  }

  @override
  Future<void> deleteImage({
    required ComplaintReport report,
    required int imageId,
  }) async {
    mutations.add('delete-image:${report.id}:$imageId');
  }
}

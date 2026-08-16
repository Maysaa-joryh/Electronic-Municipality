import 'dart:io';
import 'dart:typed_data';

import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class ServiceRequestFileOpener {
  const ServiceRequestFileOpener._();

  static Future<void> saveAndOpen({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final directory = await getTemporaryDirectory();
    final safeName = fileName.trim().replaceAll(RegExp(r'[/\\]'), '_');
    final target = File(
      '${directory.path}${Platform.pathSeparator}'
      '${safeName.isEmpty ? 'municipality-document.pdf' : safeName}',
    );
    await target.writeAsBytes(bytes, flush: true);

    final result = await OpenFilex.open(target.path);
    if (result.type != ResultType.done) {
      throw StateError(result.message);
    }
  }
}

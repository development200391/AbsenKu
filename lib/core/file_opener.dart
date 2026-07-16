import 'dart:io';

import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

/// Writes [bytes] to a temp file and hands it off to whatever app the OS
/// considers the default viewer for that file type (PDF reader, gallery,
/// Office app, etc). [uniqueId] (e.g. a document's server id) is prefixed
/// onto [fileName] so two attachments that happen to share a name never
/// collide in the temp folder.
///
/// Returns a human-readable error message on failure (e.g. "No app found to
/// open this file"), or `null` on success.
Future<String?> openDownloadedFile(List<int> bytes, String fileName, {required Object uniqueId}) async {
  final dir = await getTemporaryDirectory();
  final safeFileName = '$uniqueId-$fileName';
  final file = File('${dir.path}/$safeFileName');
  await file.writeAsBytes(bytes, flush: true);

  final result = await OpenFilex.open(file.path);
  return result.type == ResultType.done ? null : result.message;
}

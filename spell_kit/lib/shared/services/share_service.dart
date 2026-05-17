import 'dart:typed_data';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ShareService {
  Future<void> shareImage(Uint8List imageBytes, String text) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/achievement.png');
    await file.writeAsBytes(imageBytes);
    await Share.shareXFiles(
      [XFile(file.path)],
      text: text,
    );
  }
}

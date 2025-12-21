import 'dart:io';
import 'package:injectable/injectable.dart';
import '../../domain/entities/lyric_line.dart';

@injectable
class LyricsRepository {
  Future<List<LyricLine>?> getLyrics(String songPath) async {
    try {
      // 1. Determine .lrc path
      // Handle both .mp3 and .flac or others. We just replace the extension.
      // But safer to replace from last dot.
      final int lastDot = songPath.lastIndexOf('.');
      if (lastDot == -1) return null;

      final String lrcPath = '${songPath.substring(0, lastDot)}.lrc';
      final File lrcFile = File(lrcPath);

      if (!await lrcFile.exists()) {
        return null;
      }

      // 2. Read lines
      final List<String> lines = await lrcFile.readAsLines();
      final List<LyricLine> lyrics = [];

      // 3. Parse lines
      // Format: [mm:ss.xx]Text or [mm:ss.xxx]Text
      // Regex to capture timestamp and text
      final RegExp regExp = RegExp(r'^\[(\d{2}):(\d{2})\.(\d{2,3})\](.*)');

      for (final line in lines) {
        final match = regExp.firstMatch(line);
        if (match != null) {
          final minutes = int.parse(match.group(1)!);
          final seconds = int.parse(match.group(2)!);
          final millisecondsPart = match.group(3)!;
          
          // Normalize milliseconds (xx -> x00, xxx -> xxx)
          // Actually usually .xx is 1/100ths? standard lrc is mm:ss.xx (centiseconds)
          // So .12 => 120ms. .5 => 500ms? No, usually it's fixed digits.
          // If 2 digits: 0.12s = 120ms.
          // If 3 digits: 0.123s = 123ms.
          int milliseconds = int.parse(millisecondsPart);
          if (millisecondsPart.length == 2) {
            milliseconds *= 10;
          }

          final duration = Duration(
             minutes: minutes, 
             seconds: seconds, 
             milliseconds: milliseconds
          );
          
          final text = match.group(4)?.trim() ?? '';
          
          if (text.isNotEmpty) {
             lyrics.add(LyricLine(time: duration, text: text));
          }
        }
      }

      // Sort by time just in case
      lyrics.sort((a, b) => a.time.compareTo(b.time));

      return lyrics;
    } catch (e) {
      // Logic failure or file error
      return null;
    }
  }
}

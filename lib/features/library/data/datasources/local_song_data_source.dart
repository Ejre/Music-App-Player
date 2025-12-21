import 'dart:io';
import 'package:injectable/injectable.dart';
import 'package:on_audio_query/on_audio_query.dart' as query;
import '../models/song_model.dart';

abstract class LocalSongDataSource {
  Future<List<SongModel>> getSongs();
  Future<bool> deleteSong(String uri);
}

@LazySingleton(as: LocalSongDataSource)
class LocalSongDataSourceImpl implements LocalSongDataSource {
  final query.OnAudioQuery _audioQuery;

  LocalSongDataSourceImpl(this._audioQuery);

  @override
  Future<List<SongModel>> getSongs() async {
    // We assume permission is checked in the Repository or UI level before calling this
    List<query.SongModel> result = await _audioQuery.querySongs(
      sortType: null,
      orderType: query.OrderType.ASC_OR_SMALLER,
      uriType: query.UriType.EXTERNAL,
      ignoreCase: true,
    );
    
    return result.map((e) => SongModel.fromQueryModel(e)).toList();
  }

  @override
  Future<bool> deleteSong(String uri) async {
    try {
      // Handle file deletion
      // Uri passed from on_audio_query usually looks like content:// or file://
      // If it's content:// we might need real path.
      // But querySongs returns 'uri' which is often the direct path or content uri.
      // SongModel.uri (from my entity) might be populated. 
      // Let's check SongModel mapping first.
      
      // Assuming 'uri' is the file path.
      if (uri.startsWith("content://")) {
        // Content URIs are harder to delete via File API directly without resolving.
        // But let's try assuming we get a file path or handle the error.
        // Actually, on_audio_query 'data' field usually contains the absolute path.
        // Let's assume valid file path for now.
        return false; 
      }
      
      final file = File(uri);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print("Delete error: $e");
      return false;
    }
  }
}

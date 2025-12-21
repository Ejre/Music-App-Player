import 'package:on_audio_query/on_audio_query.dart' as query;
import '../../domain/entities/song.dart';

class SongModel extends Song {
  const SongModel({
    required super.id,
    required super.title,
    required super.artist,
    super.album,
    super.albumId,
    super.uri,
    super.duration,
    super.dateAdded,
  });

  factory SongModel.fromQueryModel(query.SongModel model) {
    return SongModel(
      id: model.id,
      title: model.title,
      artist: model.artist ?? "Unknown Artist",
      album: model.album,
      albumId: model.albumId,
      uri: model.data,
      duration: model.duration,
      dateAdded: model.dateAdded?.toString(),
    );
  }
}

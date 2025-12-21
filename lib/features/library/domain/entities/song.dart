import 'package:equatable/equatable.dart';

class Song extends Equatable {
  final int id;
  final String title;
  final String artist;
  final String? album;
  final int? albumId; // For artwork
  final String? uri;
  final int? duration;
  final String? dateAdded;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    this.albumId,
    this.uri,
    this.duration,
    this.dateAdded,
  });

  @override
  List<Object?> get props => [id, title, artist, album, albumId, uri, duration, dateAdded];
}

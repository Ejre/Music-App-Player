import 'package:hive/hive.dart';

part 'playlist_model.g.dart';

@HiveType(typeId: 1) // Ensure typeId is unique. Check other models if any.
class PlaylistModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<int> songIds;

  @HiveField(3)
  final DateTime createdAt;

  PlaylistModel({
    required this.id,
    required this.name,
    required this.songIds,
    required this.createdAt,
  });

  PlaylistModel copyWith({
    String? id,
    String? name,
    List<int>? songIds,
    DateTime? createdAt,
  }) {
    return PlaylistModel(
      id: id ?? this.id,
      name: name ?? this.name,
      songIds: songIds ?? this.songIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

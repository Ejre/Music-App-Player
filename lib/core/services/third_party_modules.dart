import 'package:injectable/injectable.dart';
import 'package:audio_service/audio_service.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../features/player/data/services/audio_player_handler.dart';

@module
abstract class ThirdPartyModules {
  @lazySingleton
  OnAudioQuery get audioQuery => OnAudioQuery();

  @preResolve
  Future<AudioHandler> get audioHandler async => await AudioService.init(
    builder: () => AudioPlayerHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.ezra.musicplayer.channel.audio',
      androidNotificationChannelName: 'Music Playback',
      androidNotificationOngoing: true,
    ),
  );
}

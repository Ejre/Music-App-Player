import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/services/service_locator.dart';
import 'features/library/presentation/bloc/library_bloc.dart';
import 'features/library/presentation/bloc/library_event.dart';
import 'features/player/presentation/bloc/player_bloc.dart';
import 'features/favorites/presentation/bloc/favorite_bloc.dart';
import 'features/favorites/presentation/bloc/favorite_event.dart';
import 'features/library/presentation/pages/library_page.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Initialize Dependencies
  await configureDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<LibraryBloc>()..add(LoadSongsEvent())),
        BlocProvider(create: (_) => getIt<PlayerBloc>()),
        BlocProvider(create: (_) => getIt<FavoriteBloc>()..add(LoadFavorites())), 
      ],
      child: MaterialApp(
        title: 'μRhythm',
        theme: AppTheme.darkTheme,
        home: const LibraryPage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

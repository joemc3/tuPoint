import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/supabase_likes_repository.dart';
import '../../data/repositories/supabase_points_repository.dart';
import '../../data/repositories/supabase_profile_repository.dart';
import '../../domain/repositories/i_likes_repository.dart';
import '../../domain/repositories/i_points_repository.dart';
import '../../domain/repositories/i_profile_repository.dart';

/// Provides the Supabase client singleton instance
///
/// This provider gives access to the initialized Supabase client
/// throughout the application. The client is initialized in main()
/// before the app starts.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Provides the Profile repository implementation
///
/// Returns a [SupabaseProfileRepository] instance that implements
/// [IProfileRepository]. This repository handles all profile-related
/// operations including creation, fetching, and updates.
///
/// Dependencies:
/// - [supabaseClientProvider]: Supabase client for API calls
final profileRepositoryProvider = Provider<IProfileRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return SupabaseProfileRepository(supabaseClient);
});

/// Provides the Points repository implementation
///
/// Returns a [SupabasePointsRepository] instance that implements
/// [IPointsRepository]. This repository handles all point-related
/// operations including creation, fetching, updates, and soft deletion.
///
/// Key features:
/// - PostGIS geometry handling for location data
/// - Client-side 5km radius filtering support
/// - RLS-aware error mapping
///
/// Dependencies:
/// - [supabaseClientProvider]: Supabase client for API calls
final pointsRepositoryProvider = Provider<IPointsRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return SupabasePointsRepository(supabaseClient);
});

/// Provides the Likes repository implementation
///
/// Returns a [SupabaseLikesRepository] instance that implements
/// [ILikesRepository]. This repository handles all like-related
/// operations including liking, unliking, and fetching like counts.
///
/// Key features:
/// - Composite key handling (point_id + user_id)
/// - Duplicate like prevention
/// - Efficient count queries
///
/// Dependencies:
/// - [supabaseClientProvider]: Supabase client for API calls
final likesRepositoryProvider = Provider<ILikesRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return SupabaseLikesRepository(supabaseClient);
});

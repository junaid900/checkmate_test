
import 'package:checkmate/modals/story_comment.dart';
import 'package:checkmate/providers/blocked_user/blocked_user_provider.dart';
import 'package:checkmate/providers/chat/conversation_provider.dart';
import 'package:checkmate/providers/common/city_provider.dart';
import 'package:checkmate/providers/common/states_provider.dart';
import 'package:checkmate/providers/firebase/firebase_live_stream_provider.dart';
import 'package:checkmate/providers/home/home_post_provider.dart';
import 'package:checkmate/providers/live_stream/live_stream_provider.dart';
import 'package:checkmate/providers/main/app_setting_provider.dart';
import 'package:checkmate/providers/notification/notification_provider.dart';
import 'package:checkmate/providers/post/create_post_provider.dart';
import 'package:checkmate/providers/post/post_comment_provider.dart';
import 'package:checkmate/providers/post/post_provider.dart';
import 'package:checkmate/providers/post/saved_post_provider.dart';
import 'package:checkmate/providers/search/search_post_provider.dart';
import 'package:checkmate/providers/story/saved_story_provider.dart';
import 'package:checkmate/providers/story/story_comment_provider.dart';
import 'package:checkmate/providers/story/story_provider.dart';
import 'package:checkmate/providers/story/today_story_provider.dart';
import 'package:checkmate/providers/support/support_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/single_child_widget.dart';
import 'package:provider/provider.dart';
import 'firebase/firebase_local_notification_provider.dart';
import 'settings/language_provider.dart';
import 'user/profile_provider.dart';

List<SingleChildWidget> providers = [
  ...independentProviders,
  ...proxyProviders
];

List<SingleChildWidget> independentProviders = [
  ChangeNotifierProvider<LanguageProvider>(create: (_) => LanguageProvider()),
  ChangeNotifierProvider<ProfileProvider>(create: (_) => ProfileProvider()),
  ChangeNotifierProvider<HomePostProvider>(create: (_) => HomePostProvider()),
  ChangeNotifierProvider<AppSettingProvider>(create:(_) => AppSettingProvider()),
  ChangeNotifierProvider<StatesProvider>(create:(_) => StatesProvider()),
  ChangeNotifierProvider<CityProvider>(create:(_) => CityProvider()),
  ChangeNotifierProvider<CreatePostProvider>(create:(_) => CreatePostProvider()),
  ChangeNotifierProvider<PostCommentProvider>(create:(_) => PostCommentProvider()),
  ChangeNotifierProvider<PostProvider>(create:(_) => PostProvider()),
  ChangeNotifierProvider<SavedPostProvider>(create:(_) => SavedPostProvider()),
  ChangeNotifierProvider<ConversationProvider>(create:(_) => ConversationProvider()),
  ChangeNotifierProvider<StoryProvider>(create:(_) => StoryProvider()),
  ChangeNotifierProvider<StoryCommentProvider>(create:(_) => StoryCommentProvider()),
  ChangeNotifierProvider<SavedStoryProvider>(create:(_) => SavedStoryProvider()),
  ChangeNotifierProvider<LiveStreamProvider>(create:(_) => LiveStreamProvider()),
  ChangeNotifierProvider<NotificationProvider>(create:(_) => NotificationProvider()),
  ChangeNotifierProvider<FirebaseLiveStreamProvider>(create:(_) => FirebaseLiveStreamProvider()),
  ChangeNotifierProvider<FirebaseLocalNotificationProvider>(create:(_) => FirebaseLocalNotificationProvider()),
  ChangeNotifierProvider<SupportProvider>(create:(_) => SupportProvider()),
  ChangeNotifierProvider<BlockedUserProvider>(create:(_) => BlockedUserProvider()),
  ChangeNotifierProvider<SearchPostProvider>(create:(_) => SearchPostProvider()),
  ChangeNotifierProvider<TodayStoryProvider>(create:(_) => TodayStoryProvider()),
];
List<SingleChildWidget> proxyProviders = [
  // ChangeNotifierProxyProvider<ProfileProvider, FirebaseLiveStreamProvider>(
  //   update: (context, profile, previousLiveStreams) => FirebaseLiveStreamProvider(profile.profile),
  //   create: (BuildContext context) => FirebaseLiveStreamProvider(null),
  // ),
];
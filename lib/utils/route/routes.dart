import 'package:checkmate/ui/auth/forget_password_screen.dart';
import 'package:checkmate/ui/common/video_player_screen.dart';
import 'package:checkmate/ui/auth/otp_screen.dart';
import 'package:checkmate/ui/auth/phone_number_screen.dart';
import 'package:checkmate/ui/auth/signup_screen.dart';
import 'package:checkmate/ui/auth/welcome_auth_screen.dart';
import 'package:checkmate/ui/chat/chat_detail/conversation_detail.dart';
import 'package:checkmate/ui/chat/conversation/conversation_screen.dart';
import 'package:checkmate/ui/create_post/create_post_screen.dart';
import 'package:checkmate/ui/create_post/pages/post_story_screen.dart';
import 'package:checkmate/ui/home/search_screen.dart';
import 'package:checkmate/ui/live_stream/create_live_stream_screen.dart';
import 'package:checkmate/ui/live_stream/live_stream_screen.dart';
import 'package:checkmate/ui/post_detail/post_attachment_screen.dart';
import 'package:checkmate/ui/post_detail/post_detail_screen.dart';
import 'package:checkmate/ui/profile/edit_profile/edit_profile_screen.dart';
import 'package:checkmate/ui/profile/followers_screen.dart';
import 'package:checkmate/ui/profile/view_profile_screen.dart';
import 'package:checkmate/ui/saved_reviews/saved_reviews_screen.dart';
import 'package:checkmate/ui/saved_story/saved_story_screen.dart';
import 'package:checkmate/ui/setting/blocked_users/blocked_users_screen.dart';
import 'package:checkmate/ui/setting/change_password/change_password_screen.dart';
import 'package:checkmate/ui/setting/help/help_screen.dart';
import 'package:checkmate/ui/setting/notification/notification_setting_screen.dart';
import 'package:checkmate/ui/storytelling/today_story_screen.dart';
import 'package:flutter/material.dart';
import '../../ui/auth/login_screen.dart';
import '../../ui/main/main_screen.dart';
import '../../ui/setting/setting_screen.dart';
import '../../ui/splash/splash_screen.dart';
import 'animate_route.dart';
import 'route_names.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(builder: (BuildContext buildContext) {
        return SplashScreen();
      });
    case JRoutes.welcomeAuth:
      print(settings.name);
      return routeOne(
          settings: settings,
          widget: WelcomeAuthScreen(),
          routeName: JRoutes.welcomeAuth);
    case JRoutes.login:
      print(settings.name);
      return routeOne(
          settings: settings, widget: LoginScreen(), routeName: JRoutes.login);
    case JRoutes.signup:
      print(settings.name);
      return routeOne(
          settings: settings,
          widget: SignupScreen(),
          routeName: JRoutes.signup);
    case JRoutes.otpScreen:
      print(settings.name);
      return routeOne(
          settings: settings,
          widget: OtpVerificationScreen(),
          routeName: JRoutes.otpScreen);
    case JRoutes.phoneNumberScreen:
      print(settings.name);
      return routeOne(
          settings: settings,
          widget: PhoneNumberScreen(),
          routeName: JRoutes.phoneNumberScreen);
    case JRoutes.main:
      print(settings.name);
      return routeOne(
          settings: settings, widget: MainScreen(), routeName: JRoutes.main);
    case JRoutes.conversationScreen:
      print(settings.name);
      return routeOne(
          settings: settings,
          widget: ConversationScreen(),
          routeName: JRoutes.conversationScreen);
    case JRoutes.conversationDetail:
      print(settings.name);
      return routeOne(
          settings: settings,
          widget: ConversationDetailScreen(),
          routeName: JRoutes.conversationDetail);
    case JRoutes.postDetail:
      print(settings.name);
      return routeOne(
          settings: settings,
          widget: PostDetailScreen(),
          routeName: JRoutes.postDetail);
    case JRoutes.attachmentScreen:
      print(settings.name);
      return routeOne(
          settings: settings,
          widget: PostAttachmentScreen(),
          routeName: JRoutes.attachmentScreen);
    case JRoutes.videoPlayerScreen:
      print(settings.name);
      return routeOne(
          settings: settings,
          widget: VideoPlayerScreen(),
          routeName: JRoutes.videoPlayerScreen);
    case JRoutes.createPost:
      print(settings.name);
      return routeOne(
          settings: settings,
          widget: CreatePostScreen(),
          routeName: JRoutes.createPost);
    case JRoutes.viewProfileScreen:
      print(settings.name);
      return routeOne(
          settings: settings,
          widget: ViewProfileScreen(),
          routeName: JRoutes.viewProfileScreen);
    case JRoutes.editProfileScreen:
      print(settings.name);
      return routeOne(
          settings: settings,
          widget: EditProfileScreen(),
          routeName: JRoutes.editProfileScreen);
    case JRoutes.setting:
      print(settings.name);
      return routeOne(
          settings: settings,
          widget: SettingScreen(),
          routeName: JRoutes.setting);
    case JRoutes.savedReviews:
      print(settings.name);
      return routeOne(
          settings: settings,
          widget: SavedReviewsScreen(),
          routeName: JRoutes.savedReviews);
    case JRoutes.postStoryScreen:
      print(settings.name);
      return routeOne(
          settings: settings,
          widget: PostStoryScreen(),
          routeName: JRoutes.postStoryScreen);
    case JRoutes.savedStoryScreen:
      print(settings.name);
      return routeOne(
          settings: settings,
          widget: SavedStoryScreen(),
          routeName: JRoutes.savedStoryScreen);
    case JRoutes.createLiveStreamScreen:
      print(settings.name);
      return routeOne(
          settings: settings,
          widget: CreateLiveStreamScreen(),
          routeName: JRoutes.createLiveStreamScreen);
    case JRoutes.liveStreamScreen:
      print(settings.name);
      return routeOne(
          settings: settings,
          widget: LiveStreamScreen(),
          routeName: JRoutes.liveStreamScreen);
    case JRoutes.notificationSettingScreen:
      print(settings.name);
      return routeOne(
          settings: settings,
          widget: NotificationSettingScreen(),
          routeName: JRoutes.notificationSettingScreen);
    case JRoutes.changePasswordScreen:
      print(settings.name);
      return routeOne(
          settings: settings,
          widget: ChangePasswordScreen(),
          routeName: JRoutes.changePasswordScreen);
    case JRoutes.helpScreen:
      print(settings.name);
      return routeOne(
          settings: settings,
          widget: HelpScreen(),
          routeName: JRoutes.helpScreen);
    case JRoutes.blockedUsersScreen:
      print(settings.name);
      return routeOne(
          settings: settings,
          widget: BlockedUsersScreen(),
          routeName: JRoutes.blockedUsersScreen);
    case JRoutes.forgetPasswordScreen:
      print(settings.name);
      return routeOne(
          settings: settings,
          widget: ForgetPasswordScreen(),
          routeName: JRoutes.forgetPasswordScreen);
    case JRoutes.followersScreen:
      print(settings.name);
      return routeOne(
          settings: settings,
          widget: FollowersScreen(),
          routeName: JRoutes.followersScreen);
    case JRoutes.searchScreen:
      print(settings.name);
      return routeOne(
          settings: settings,
          widget: SearchScreen(),
          routeName: JRoutes.searchScreen);
    case JRoutes.todayStoriesScreen:
      print(settings.name);
      return routeOne(
          settings: settings,
          widget: TodayStoryScreen(),
          routeName: JRoutes.todayStoriesScreen);
    default:
      print("default");
      return routeOne(
          settings: settings,
          widget: WelcomeAuthScreen(),
          routeName: JRoutes.welcomeAuth);
  }
}

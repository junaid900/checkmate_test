import 'package:firebase_core/firebase_core.dart';

class ImagePaths {
  String postProfileImage = "profile_image";
  String postDocument = "post_document";
  String videoDocument = "post_video_document";
  String userProfileImage = "user_profile";
  String userProfileCover = "user_profile_cover";
  String chatImages = "chat_images";
  String storyVideo = "story_video";

}

class JVar {
  static String APP_URL = "https://checkmate.mjcoders.com/";
  static String FILE_URL = "${APP_URL}get_file/";

  static String appLogoIcon = "assets/icons/app_icon_small.png";

  // ALERTS
  static String infoIcon = 'assets/icons/alert/info.png';
  static String successIcon = 'assets/icons/alert/success.png';
  static String warningIcon = 'assets/icons/alert/warning.png';
  static String errorIcon = 'assets/icons/alert/error.png';

  static String PLACEHOLDER_IMAGE_PATH = "assets/images/placeholder_image.png";

//   IMAGES PATHs
  static ImagePaths imagePaths = ImagePaths();

//
static Map deepAr = {
  "ios":"146d202e34e5fb127a37a4a81e059fb9b207a8255196e91693c7996a46785fee2ce74a5ed71b1efb",
  "android": "716f7f7cdab328ee78ab36e79b880b129619f4f23494b6447d914a9644e4cda1a96adef5f305422c"
};
static const String agoraAppId = "50fb5976296c4da19fa263771781ad94";
static const String agoraAppCertificate = "38cd252cb8524f319ed21dceb6b15906";
  static String firebaseClientId =
      "683321328914-cdfbisp8fo2v8lukqokk4hm1kkf1beeq.apps.googleusercontent.com";
  static FirebaseOptions firebaseIOSOptions = FirebaseOptions(
      databaseURL: 'https://checkmate-4eb44-default-rtdb.firebaseio.com/',
      apiKey: 'AIzaSyAaZLvcSlASFTiVyfMj4IilSMUtx8QP1I8',
      appId: '1:683321328914:ios:6ac03e03b0947c03ca9fcb',
      messagingSenderId: '683321328914',
      projectId: 'checkmate-4eb44',
      storageBucket: 'checkmate-4eb44.appspot.com',
      iosClientId:
          "com.googleusercontent.apps.683321328914-9nqc1h1pfqhnn57sm7447f7uhfut5l9t",
      androidClientId:
          "683321328914-ahu01n081hmu4dqu4r8mnfk9nelprief.apps.googleusercontent.com");
  static FirebaseOptions firebaseAndroidOptions = FirebaseOptions(
      databaseURL: 'https://checkmate-4eb44-default-rtdb.firebaseio.com/',
      apiKey: 'AIzaSyDN9t78FXbI0rHbfpMIaZBdNPNj9CTFzYI',
      appId: '1:683321328914:android:772ae5f9db4617a7ca9fcb',
      messagingSenderId: '683321328914',
      projectId: 'checkmate-4eb44',
      storageBucket: 'checkmate-4eb44.appspot.com',
      iosClientId:
          "com.googleusercontent.apps.683321328914-9nqc1h1pfqhnn57sm7447f7uhfut5l9t",
      androidClientId:
          "683321328914-cdfbisp8fo2v8lukqokk4hm1kkf1beeq.apps.googleusercontent.com");
}

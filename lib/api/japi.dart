import '../constraints/j_var.dart';

class JApi{
  static String BASE_URL = "${JVar.APP_URL}api/";
  static String LOGIN = "auth/login";
  static String CHECK_PHONE_NUMBER = "auth/phone/check";
  static String LOGIN_BY_PHONE = "auth/phone/login";
  static String GOOGLE_LOGIN = "auth/google/login";
  static String SIGNUP = "auth/register";
  static String PROFILE = "profile/get";
  static String STATES = "state/get";
  static String CITIES = "city/get";
  static String UPLOAD_FILE = "upload/file";
  static String CREATE_POST = "post/create";
  static String UPDATE_POST_FILES = "post/update/files";
  static String GET_POSTS = "post/get";
  static String GET_COMMENTS = "post/get_comments";
  static String GET_REPLY_COMMENTS = "post/get_reply_comments";
  static String EDIT_POST_COMMENTS = "post/edit_comment";
  static String DELETE_POST_COMMENTS = "post/delete_comment";
  static String LIKE_POST_COMMENTS = "post/comment_like";

  static String ADD_COMMENT = "post/add_comment";
  static String REPLY_COMMENT = "post/reply_comment";
  static String SAVE_POST = "post/save";
  static String GET_SAVED_POSTS = "post/save/get";
  static String GET_PROFILE = "user/profile";
  static String FOLLOW = "user/follow";
  static String UPDATE_PROFILE = "user/update";
  static String CHECK_CHAT = "chat/check";
  static String UPDATE_CHAT = "chat/update";
  static String GET_CHAT = "chat/get";
  static String CHAT_LIST = "chat/list";

  static String CREAT_STORY = "story/create";
  static String GET_STORIES = "story/get";
  static String GET_TODAT_STORIES = "story/get_today";
  static String GET_STORY_COMMENTS = "story/get_comments";
  static String ADD_STORY_COMMENT = "story/add_comment";
  static String REPLY_STORY_COMMENT = "story/reply_comment";
  static String EDIT_STORY_COMMENT = "story/edit_comment";
  static String DELETE_STORY_COMMENT = "story/delete_comment";

  static String GET_STORY_REPLY_COMMENTS = "story/get_reply_comments";
  static String LIKE_STORY_COMMENTS = "story/comment_like";

  static String SAVE_STORY = "story/save";
  static String GET_SAVED_STORIES = "story/save/get";
  static String LIKE_STORY = "story/like";

  static String CREAT_LIVE_STREAM = "livestream/create";
  static String UPDATE_LIVE_STREAM = "livestream/update";
  static String GET_LIVESTREAMS = "livestream/get";

  static String GET_NOTIFICATIONS = "notification/get";
  static String SEND_NOTIFICATION = "notification/send";
  static String NOTIFICATION_COUNT = "notification/count";
  static String READ_NOTIFICATION = "notification/read";

  static String GET_SUPPORT = "support/get";
  static String ADD_SUPPORT = "support/add";

  static String BLOCK_UNBLOCK_USER = "user/block";
  static String GET_BLOCKED_USERS = "user/get_blocked";
  static String GET_USERS = "user/get";

  static String GET_FOLLOWERS = "user/followers";



}
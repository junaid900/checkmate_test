import 'package:checkmate/modals/post_comment.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

import '../../api/japi.dart';
import '../../api/japi_service.dart';
import '../../constraints/helpers/helper.dart';

class PostCommentProvider extends ChangeNotifier {
  RefreshController refreshController = RefreshController();
  int _maxPages = 0;
  int _currentPage = 0;
  bool _isLoading = false;
  List<PostComment> _list = [];
  List<PostComment> replyList = [];
  int _currentPost = 0;
  bool _isSending = false;

  bool get isSending => _isSending;

  set isSending(bool value) {
    _isSending = value;
    notifyListeners();
  }

  int get currentPost => _currentPost;

  set currentPost(int value) {
    _currentPost = value;
    notifyListeners();
  }

  int get maxPages => _maxPages;

  set maxPages(int value) {
    _maxPages = value;
  }

  int get currentPage => _currentPage;

  set currentPage(int value) {
    _currentPage = value;
  }

  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  List<PostComment> get list => _list;

  set list(List<PostComment> value) {
    _list = value;
    notifyListeners();
  }

  send(PostComment comment) async {
    isSending = true;
    JApiService apiService = JApiService();
    var response = await apiService.postRequest(JApi.ADD_COMMENT, {
      "user_id": comment.user!.id,
      "comment": comment.comment,
      "post_id": comment.postId,
    });
    isSending = false;
    if (response != null) {
      try {
        PostComment newComment = PostComment.fromJson(response);
        if (newComment.id != null) {
          _list.insert(0, newComment);
          notifyListeners();
        }
      } catch (e) {
        return;
      }
    }
  }

  replyComment(
      PostComment comment, PostComment replyComment, comment_id) async {
    isSending = true;
    JApiService apiService = JApiService();
    var response = await apiService.postRequest(JApi.REPLY_COMMENT, {
      "user_id": comment.user!.id,
      "comment": comment.comment,
      "post_id": comment.postId,
      "comment_id": comment_id,
      "parent_id": replyComment.id,
      "reply_to": replyComment.userId,
    });
    isSending = false;
    if (response != null) {
      try {
        PostComment newComment = PostComment.fromJson(response);
        if (newComment.id != null) {
          // _list.insert(0, newComment)
          int index = _list.indexWhere(
              (element) => comment_id.toString() == element.id.toString());
          print("here +" + index.toString());
          if (index < 0) {
            print("here1 " + comment_id);
            return;
          }
          print("here2");
          _list[index].replies.add(newComment);
          _list[index].repliesCount = _list[index].repliesCount + 1;
          // replyList.insert(replyList.length - 1, newComment);
          notifyListeners();
        }
      } catch (e) {
        return;
      }
    }
  }

  reset(postId) async {
    currentPage = 0;
    currentPost = postId;
    maxPages = 0;
    list = [];
    isLoading = false;
    refreshController.footerMode!.value = LoadStatus.idle;
    bool res = await load(currentPost);
    return res;
  }

  Future<bool> load(post_id) async {
    if (currentPost < 1) {
      return false;
    }
    JApiService apiService = JApiService();
    isLoading = true;
    var response =
        await apiService.getRequest(JApi.GET_COMMENTS + "/${currentPost}");
    isLoading = false;
    list = [];
    notifyListeners();
    if (response != null) {
      if (response.length > 0) {
        list = [];
        for (int i = 0; i < response['data'].length; i++) {
          list.add(PostComment.fromJson(response['data'][i]));
        }
        currentPage = response['current_page'];
        maxPages = response['last_page'];
        list = list;
        notifyListeners();
      }
    } else {
      showToast("cannot load states");
    }
    return true;
  }

  Future<bool> loadMoreData() async {
    if (currentPost < 1) {
      return false;
    }
    refreshController.footerMode!.value = LoadStatus.loading;
    int page = currentPage + 1;
    if (page > maxPages) {
      refreshController.footerMode!.value = LoadStatus.noMore;
      return false;
    }
    var response = await JApiService()
        .getRequest(JApi.GET_COMMENTS + "/${currentPost}" + "?page=${page}");
    refreshController.footerMode!.value = LoadStatus.idle;
    // context.read<PostProvider>().isLoading = false;
    if (response != null) {
      List<PostComment> moreList = [];
      for (int i = 0; i < response['data'].length; i++) {
        moreList.add(PostComment.fromJson(response['data'][i]));
      }
      currentPage = response['current_page'];
      maxPages = response['last_page'];
      addMore(moreList);
    }
    return true;
  }

  addMore(List<PostComment> moreList) {
    list.addAll(moreList);
    notifyListeners();
  }

  Future<int> editComment(commentId, comment) async {
    JApiService apiService = JApiService();
    // isSaving = true;
    // int index = getStoryIndexById(storyId);
    // setSaved(index, !_list[index].isSaved);
    var response = await apiService.postRequest(JApi.EDIT_POST_COMMENTS,
        {"post_comment_id": commentId.toString(), "comment": comment});
    // isSaving = false;
    if (response != null) {
      try {
        if (response["edited"] == 1) {
          int index = list.indexWhere(
              (element) => element.id.toString() == commentId.toString());
          if (index > -1) {
            PostComment newComment = _list[index];
            newComment.comment = comment;
            _list[index] = newComment;
            notifyListeners();
            return 1;
          }
        }
        return 2;
      } catch (e) {
        return -1;
      }
    }
    return -1;
  }

  Future<int> deleteComment(PostComment comment) async {
    JApiService apiService = JApiService();
    // isSaving = true;
    // int index = getStoryIndexById(storyId);
    // setSaved(index, !_list[index].isSaved);
    var response = await apiService.postRequest(JApi.DELETE_POST_COMMENTS, {
      "post_comment_id": comment.toString(),
    });
    // isSaving = false;
    if (response != null) {
      try {
        if (response["deleted"] == 1) {
          // int index = list.indexWhere(
          //     (element) => element.id.toString() == comment.toString());
          deleteCommentFromList(comment.id, comment.commentId);

          // if (index > -1) {
          //   deleteCommentFromList(_list[index].id, _list[index].parentId);
          //   notifyListeners();
          return 1;
          // }
        }
        return 2;
      } catch (e) {
        return -1;
      }
    }
    return -1;
  }

  Future<bool> loadCommentReplies(commentId) async {
    print("load more");
    if (convertNumber(commentId) < 1) {
      return false;
    }
    print("load more");
    int index = _list
        .indexWhere((element) => element.id.toString() == commentId.toString());
    if (index < 0) {
      return false;
    }
    _list[index].replies = [];
    _list[index].noMore = false;
    notifyListeners();
    JApiService apiService = JApiService();
    _list[index].isReplyLoading = true;
    notifyListeners();
    var response =
        await apiService.getRequest(JApi.GET_REPLY_COMMENTS + "/${commentId}");
    _list[index].isReplyLoading = false;
    notifyListeners();
    _list[index].replies = [];
    notifyListeners();
    if (response != null) {
      if (response.length > 0) {
        _list[index].replies = [];
        for (int i = 0; i < response['data'].length; i++) {
          _list[index].replies.add(PostComment.fromJson(response['data'][i]));
        }
        _list[index].currentPage = response['current_page'];
        _list[index].maxPages = response['last_page'];
        _list[index].replies = list[index].replies;
        notifyListeners();
      }
    } else {
      showToast("cannot load states");
    }
    return true;
  }

  Future<bool> loadMoreRepliesData(commentId) async {
    if (convertNumber(commentId) < 1) {
      return false;
    }
    int index = _list.indexWhere((element) => element.id == commentId);
    if (index < 0) {
      return false;
    }
    int page = _list[index].currentPage + 1;
    if (page > _list[index].maxPages) {
      _list[index].noMore = true;
      return false;
    }
    _list[index].isReplyLoading = true;
    notifyListeners();
    var response = await JApiService().getRequest(
        JApi.GET_REPLY_COMMENTS + "/${commentId}" + "?page=${page}");
    _list[index].isReplyLoading = false;
    notifyListeners();
    // context.read<PostProvider>().isLoading = false;
    if (response != null) {
      List<PostComment> moreList = [];
      for (int i = 0; i < response['data'].length; i++) {
        moreList.add(PostComment.fromJson(response['data'][i]));
      }
      _list[index].currentPage = response['current_page'];
      _list[index].maxPages = response['last_page'];
      _list[index].replies.addAll(moreList);
      notifyListeners();
    }
    return true;
  }

  Future<int> commentLike(commentId, String? parentCommentId) async {
    JApiService apiService = JApiService();
    // isSaving = true;
    int mIndex = -9;
    if (parentCommentId != "0") {
      int index = _list.indexWhere((element) => element.id == parentCommentId);
      if (index < 0) {
        return -1;
      }
      mIndex = index;
    }
    var response =
        await apiService.getRequest(JApi.LIKE_POST_COMMENTS + "/$commentId");
    // isSaving = false;
    if (response != null) {
      try {
        if (response["liked"] == 1) {
          if (mIndex == -9) {
            int index = _list.indexWhere((element) => element.id == commentId);
            if (index < 0) {
              return -1;
            }
            _list[index].isLike = true;
            _list[index].commentLikesCount = _list[index].commentLikesCount + 1;
          } else {
            if (mIndex >= _list.length) return -1;
            int index = _list[mIndex]
                .replies
                .indexWhere((element) => element.id == commentId);
            if (index < 0) {
              return -1;
            }
            _list[mIndex].replies[index].isLike = true;
            _list[mIndex].replies[index].commentLikesCount =
                _list[mIndex].replies[index].commentLikesCount + 1;
          }
          notifyListeners();
          return 1;
        } else if (response["liked"] == 0) {
          if (mIndex == -9) {
            int index = _list.indexWhere((element) => element.id == commentId);
            if (index < 0) {
              return -1;
            }
            _list[index].isLike = false;
            _list[index].commentLikesCount = _list[index].commentLikesCount - 1;
          } else {
            if (mIndex >= _list.length) return -1;
            int index = _list[mIndex]
                .replies
                .indexWhere((element) => element.id == commentId);
            if (index < 0) {
              return -1;
            }
            _list[mIndex].replies[index].isLike = false;
            _list[mIndex].replies[index].commentLikesCount =
                _list[mIndex].replies[index].commentLikesCount - 1;
          }
          notifyListeners();
          return 0;
        }
        return 2;
      } catch (e) {
        return -1;
      }
    }
    return -1;
  }

  setViewReplies(commentId, bool viewReplies) {
    int index = _list.indexWhere((element) => element.id == commentId);
    if (index < 0) {
      return;
    }
    _list[index].viewReplies = viewReplies;
    notifyListeners();
  }

  deleteCommentFromList(commentId, parentCommentId) {
    try {
      print(parentCommentId + " " + commentId);
      int mIndex = -9;
      if (parentCommentId != "0") {
        int index =
            _list.indexWhere((element) => element.id == parentCommentId);
        if (index < 0) {
          print("mindex"+index.toString());
          notifyListeners();
          return -1;
        }
        mIndex = index;
      }
      if (mIndex == -9) {
        int index = _list.indexWhere((element) => element.id == commentId);
        if (index < 0) {
          return -1;
        }
        _list.removeAt(index);
      } else {
        print("mindex");
        print(mIndex);
        if (mIndex >= _list.length) {
          notifyListeners();
          return -1;
        }
        print(mIndex);
        int index = _list[mIndex]
            .replies
            .indexWhere((element) => element.id == commentId);
        if (index < 0) {
          return -1;
        }
        _list[mIndex].replies.removeAt(index);
        _list[index].repliesCount = _list[index].repliesCount - 1;
      }
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }
}

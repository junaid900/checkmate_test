import 'package:checkmate/constraints/helpers/helper.dart';
import 'package:checkmate/modals/cmpost.dart';
import 'package:checkmate/providers/post/saved_post_provider.dart';
import 'package:checkmate/providers/user/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

import '../../constraints/helpers/app_methods.dart';
import '../../constraints/j_var.dart';
import '../../modals/User.dart';
import '../../utils/route/route_names.dart';
import '../common/functional_widgets.dart';
import '../common/jempty_layout.dart';
import '../home/components/post_item.dart';

class SavedReviewsScreen extends StatefulWidget {
  const SavedReviewsScreen({super.key});

  @override
  State<SavedReviewsScreen> createState() => _SavedReviewsScreenState();
}

class _SavedReviewsScreenState extends State<SavedReviewsScreen> {
  User? user;

  getPageData() async {
    var profileProvider = context.read<ProfileProvider>();
    var savedPostProvider = context.read<SavedPostProvider>();
    user = profileProvider.profile;
    if (user != null) {
      savedPostProvider.reset(user!.id);
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getPageData();
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Saved Reviews"),
        ),
        body: Consumer<SavedPostProvider>(builder: (key, provider, child) {
          return !provider.isLoading && provider.list.isEmpty
              ? JEmptyLayout(
                  text: "No Saved Review",
                  width: 120,
                  height: 120,
                )
              : user == null
                  ? JEmptyLayout(
                      text: "Cannot load saved reviews",
                      width: 120,
                      height: 120,
                    )
                  : Container(
                      height: getHeight(context),
                      width: getWidth(context),
                      child: provider.isLoading && provider.list.length < 1
                          ? SingleChildScrollView(
                          child: Column(children: List.generate(10, (index) => postItemShimmer(context)),))
                          : !provider.isLoading && provider.list.length < 1
                              ? JEmptyLayout(
                                  height: 120,
                                  width: 120,
                                  text: "No Post Found",
                                )
                              : SmartRefresher(
                                  enablePullDown: true,
                                  enablePullUp: true,
                                  controller: provider.refreshController,
                                  onLoading: () async {
                                    bool res =
                                        await provider.loadMoreData(user!.id);
                                  },
                                  onRefresh: () async {
                                    bool res = await provider.reset(user!.id);
                                    provider.refreshController
                                        .refreshCompleted();
                                    provider.refreshController =
                                        provider.refreshController;
                                  },
                                  footer: ClassicFooter(),
                                  child: ListView(
                                    children: [
                                      ...provider.list.map(
                                        (savedPost) {
                                          if (savedPost.post == null) {
                                            return SizedBox();
                                          }
                                          CMPost e = savedPost.post!;
                                          return PostItem(
                                            post: e,
                                            profileImage:
                                                "${JVar.FILE_URL}${JVar.imagePaths.userProfileImage}/${e.user!.profileImage}",
                                            profileUserName:
                                                "${e.user != null ? e.user!.fname : ''}",
                                            date: postFormatDateString(
                                                e.createdAt),
                                            postImage:
                                                "${JVar.FILE_URL}${JVar.imagePaths.postProfileImage}/${e.profileImage}",
                                            desc: "${e.description}",
                                            rating: calculateAvgRating(
                                                    communicationRating:
                                                        convertDouble(e
                                                            .ratingCommunication),
                                                    behaviourRating:
                                                        convertDouble(
                                                            e.ratingBehaviour),
                                                    timeRating: convertDouble(
                                                        e.ratingTime),
                                                    loyaltyRating:
                                                        convertDouble(
                                                            e.ratingLoyalty))
                                                .toString(),
                                            onProfileTap: () {
                                              Navigator.of(context).pushNamed(
                                                  JRoutes.viewProfileScreen);
                                            },
                                            onPostTap: () {
                                              Navigator.of(context).pushNamed(
                                                  JRoutes.postDetail,
                                                  arguments: e);
                                            },
                                            postTitle: '${e.name}', userId: '${e.userId}',
                                          );
                                        },
                                      ).toList(),
                                    ],
                                  ),
                                ),
                    );
        }));
  }
}

import 'package:checkmate/providers/search/search_post_provider.dart';
import 'package:checkmate/ui/common/touchable_opacity.dart';
import 'package:checkmate/ui/home/components/people_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

import '../../constraints/helpers/app_methods.dart';
import '../../constraints/helpers/helper.dart';
import '../../constraints/j_var.dart';
import '../../constraints/jcolor.dart';
import '../../utils/route/route_names.dart';
import '../common/functional_widgets.dart';
import '../common/jempty_layout.dart';
import 'components/post_item.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  FocusNode myFocusNode = FocusNode(canRequestFocus: true);
  TextEditingController search = TextEditingController();
  TabController? tabController;
  int selectedTab = 0;
  bool isSearchStarted = false;

  getPageData() async {
    tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    tabController!.addListener(() {});
    var searchProvider = context.read<SearchPostProvider>();
    searchProvider.searchQuery = '';
    searchProvider.reset();
    searchProvider.peopleReset();
    setState(() {});
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      myFocusNode.requestFocus();
      getPageData();
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // toolbarHeight: 0,
        // elevation: 0,
        leadingWidth: 0,
        leading: SizedBox(),
        title: Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Image.asset(
                "assets/icons/circle_border_back.png",
                width: 46,
              ),
            ),
            Expanded(
              child: Container(
                  // width: getWidth(context),
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: JColor.searchBorderColor)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: search,
                          autofocus: true,
                          textInputAction: TextInputAction.search,
                          onSubmitted: (value){
                            setState(() {
                              isSearchStarted = true;
                            });
                            var searchProvider =
                            context.read<SearchPostProvider>();
                            searchProvider.searchQuery = search.text;
                            searchProvider.reset();
                            searchProvider.peopleReset();
                          },
                          // hintText: "",
                          // focusNode: myFocusNode,
                          onChanged: (val) {
                            setState(() {});
                            // var homePostProvider = context.read<HomePostProvider>();

                            // if (_debounce?.isActive ?? false)
                            //   _debounce?.cancel();
                            // _debounce =
                            //     Timer(const Duration(milliseconds: 500), () {
                            //       var homePostProvider =
                            //       context.read<HomePostProvider>();
                            //       homePostProvider.searchQuery = val;
                            //       homePostProvider.reset();
                            //       // do something with query
                            //     });
                          },

                          decoration: InputDecoration(
                            hintText: "Search for People and Reviews",
                            hintStyle: TextStyle(
                                color: JColor.greyTextColor, fontSize: 14),
                            contentPadding: EdgeInsets.only(left: 14),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      if (search.text.isNotEmpty)
                        TouchableOpacity(
                          onTap: () {
                            var searchProvider =
                                context.read<SearchPostProvider>();
                            search.text = '';
                            searchProvider.searchQuery = search.text;
                            searchProvider.reset();
                            searchProvider.peopleReset();
                          },
                          child: Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(50)),
                              child: Icon(
                                Icons.close,
                                size: 18,
                              )),
                        ),
                      SizedBox(
                        width: 6,
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            isSearchStarted = true;
                          });
                          var searchProvider =
                              context.read<SearchPostProvider>();
                          searchProvider.searchQuery = search.text;
                          searchProvider.reset();
                          searchProvider.peopleReset();
                        },
                        icon: Image.asset(
                          "assets/icons/search.png",
                          height: 25,
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                    ],
                  )),
            ),
          ],
        ),
        bottom: (tabController == null)
            ? null
            : TabBar(
                controller: tabController,
                isScrollable: true,
                padding: EdgeInsets.zero,
                indicatorPadding: EdgeInsets.only(top: 18),
                labelPadding: EdgeInsets.only(left: 10, right: 10),
                tabAlignment: TabAlignment.center,
                tabs: [
                    Tab(
                      text: "Reviews",
                    ),
                    Tab(
                      text: "People",
                    )
                  ]),
      ),
      body: Container(
        width: getWidth(context),
        // padding: EdgeInsets.symmetric(
        //   horizontal: 10,
        // ),
        child: Consumer<SearchPostProvider>(builder: (key, provider, child) {
          return //if (tabController != null)
              ((search.text.isEmpty || !isSearchStarted) &&
                      provider.peopleList.isEmpty &&
                      provider.list.isEmpty)
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: getHeight(context) * .2,
                        ),
                        Image.asset(
                          "assets/images/search.gif",
                          width: 130,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text("Search People & Reviews")
                      ],
                    )
                  : TabBarView(controller: tabController, children: [
                      Container(
                        // height: getHeight(context) - 600,
                        child: provider.isLoading && provider.list.length < 1
                            ? SingleChildScrollView(
                                child: Column(
                                children: List.generate(
                                    10, (index) => postItemShimmer(context)),
                              ))
                            : !provider.isLoading && provider.list.length < 1
                                ? JEmptyLayout(
                                    height: 120,
                                    width: 120,
                                    text: "No Reviews Found",
                                  )
                                : SmartRefresher(
                                    enablePullDown: true,
                                    enablePullUp: true,
                                    controller: provider.refreshController,
                                    onLoading: () async {
                                      bool res = await provider.loadMoreData();
                                    },
                                    onRefresh: () async {
                                      bool res = await provider.reset();
                                      provider.refreshController
                                          .refreshCompleted();
                                      provider.refreshController =
                                          provider.refreshController;
                                    },
                                    footer: ClassicFooter(),
                                    child: ListView(
                                      children: provider.list
                                          .map(
                                            (e) => PostItem(
                                              post: e,
                                              profileImage:
                                                  "${JVar.FILE_URL}${JVar.imagePaths.userProfileImage}/${e.user!.profileImage}",
                                              profileUserName:
                                                  "${e.user!.fname}",
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
                                                          convertDouble(e
                                                              .ratingBehaviour),
                                                      timeRating: convertDouble(
                                                          e.ratingTime),
                                                      loyaltyRating:
                                                          convertDouble(
                                                              e.ratingLoyalty))
                                                  .toString(),
                                              onProfileTap: () {
                                                Navigator.of(context).pushNamed(
                                                    JRoutes.viewProfileScreen,
                                                    arguments: e.userId);
                                              },
                                              onPostTap: () {
                                                Navigator.of(context).pushNamed(
                                                    JRoutes.postDetail,
                                                    arguments: e);
                                              },
                                              postTitle: '${e.name}',
                                              userId: e.userId.toString(),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                      ),
                      // +==============+> PEOPLE VIEW <===========================
                      Container(
                        // height: getHeight(context) - 600,
                        child: provider.isPeopleLoading && provider.peopleList.length < 1
                            ? SingleChildScrollView(
                                child: Column(
                                children: List.generate(
                                    10, (index) => followerItemShimmer()),
                              ))
                            : !provider.isPeopleLoading && provider.peopleList.length < 1
                                ? JEmptyLayout(
                                    height: 120,
                                    width: 120,
                                    text: "No People Found",
                                  )
                                : SmartRefresher(
                                    enablePullDown: true,
                                    enablePullUp: true,
                                    controller: provider.refreshPeopleController,
                                    onLoading: () async {
                                      bool res = await provider.loadMorePeopleData();
                                    },
                                    onRefresh: () async {
                                      bool res = await provider.peopleReset();
                                      provider.refreshPeopleController
                                          .refreshCompleted();
                                      provider.refreshPeopleController =
                                          provider.refreshPeopleController;
                                    },
                                    footer: ClassicFooter(),
                                    child: ListView(
                                      children: provider.peopleList
                                          .map(
                                            (e) => PeopleItem(userData: e),
                                          )
                                          .toList(),
                                    ),
                                  ),
                      ),
                    ]);
        }),
      ),
    );
  }
}

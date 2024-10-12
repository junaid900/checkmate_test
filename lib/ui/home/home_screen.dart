import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:checkmate/constraints/constants.dart';
import 'package:checkmate/ui/common/app_color_button.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

import '../../constraints/helpers/app_methods.dart';
import '../../constraints/helpers/helper.dart';
import '../../constraints/j_var.dart';
import '../../constraints/jcolor.dart';
import '../../providers/home/home_post_provider.dart';
import '../../providers/main/app_setting_provider.dart';
import '../../providers/user/profile_provider.dart';
import '../../services/notifications_service.dart';
import '../../utils/route/route_names.dart';
import '../common/functional_widgets.dart';
import '../common/jempty_layout.dart';
import '../common/placeholder_image.dart';
import '../common/touchable_opacity.dart';
import '../create_post/create_post_screen.dart';
import 'components/home_filter_item.dart';
import 'components/post_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  Timer? _debounce;
  TabController? tabController;
  int currentTab = 0;

  getPageData() {
    var homePostProvider = context.read<HomePostProvider>();
    if (homePostProvider.list.length < 1) {
      homePostProvider.reset();
    }
    if (homePostProvider.folList.length < 1) {
      homePostProvider.folReset();
    }
    tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    tabController!.addListener(() {
      if (tabController!.indexIsChanging) {
        print("tab chanaged");
        currentTab = tabController!.index;
        if (tabController!.index == 1) {
          homePostProvider.folingMaxPages = 0;
          homePostProvider.folCurrentPage = 0;
          homePostProvider.folLoad();
        }
        setState(() {});
      }
    });
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getPageData();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Consumer<ProfileProvider>(builder: (key, profileProvider, child) {
          return Flex(
            direction: Axis.horizontal,
            children: [
              TouchableOpacity(
                onTap: () {
                  var appSettingProvider = context.read<AppSettingProvider>();
                  appSettingProvider.toggleDrawer();
                },
                child: Container(
                  // padding: EdgeInsets.only(left: 6),
                  child: Image.asset(
                    "assets/icons/menu.png",
                    width: 28,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Expanded(
                flex: 6,
                child: TouchableOpacity(
                  onTap: () {
                    Navigator.of(context).pushNamed(JRoutes.searchScreen);
                  },
                  child: Container(
                      width: getWidth(context),
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: JColor.searchBorderColor)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: IgnorePointer(
                              child: TextField(
                                // hintText: "",
                                onChanged: (val) {
                                  // var homePostProvider = context.read<HomePostProvider>();

                                  if (_debounce?.isActive ?? false)
                                    _debounce?.cancel();
                                  _debounce = Timer(
                                      const Duration(milliseconds: 500), () {
                                    var homePostProvider =
                                        context.read<HomePostProvider>();
                                    homePostProvider.searchQuery = val;
                                    homePostProvider.reset();
                                    // do something with query
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: "Search for People and Reviews",
                                  hintStyle: TextStyle(
                                      color: JColor.greyTextColor,
                                      fontSize: 14),
                                  contentPadding: EdgeInsets.only(left: 14),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 6,
                          ),
                          Image.asset(
                            "assets/icons/search.png",
                            height: 20,
                          ),
                          SizedBox(
                            width: 14,
                          ),
                        ],
                      )),
                ),
              ),
              TouchableOpacity(
                onTap: () {
                  Navigator.of(context).pushNamed(JRoutes.viewProfileScreen);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: ImageWithPlaceholder(
                    image: "${profileProvider.profile.profileImage}",
                    prefix:
                        '${JVar.FILE_URL}${JVar.imagePaths.userProfileImage}/',
                    fit: BoxFit.cover,
                    width: 50,
                    height: 50,
                  ),
                ),
              )
            ],
          );
        }),
        bottom: (tabController == null)
            ? null
            : PreferredSize(
              preferredSize: Size.fromHeight(50),
              child: Container(
                color: Colors.white,
                child: TabBar(
                    controller: tabController,
                    // splashBorderRadius: BorderRadius.circular(radius),
                    isScrollable: true,
                    // physics: S(),
                    // padding: EdgeInsets.zero,
                    indicatorPadding: EdgeInsets.only(top: 4),
                    labelPadding: EdgeInsets.only(left: 10, right: 10, bottom: 4),
                    tabAlignment: TabAlignment.center,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey[700],
                    splashFactory: NoSplash.splashFactory,
                    labelStyle:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    dividerColor: Colors.transparent,
                    indicator: DotIndicator(),
                    tabs: [
                        Tab(
                          text: "For You",
                        ),
                        Tab(
                          text: "Following",
                        ),
                      ]),
              ),
            ),
      ),
      body: Consumer<HomePostProvider>(builder: (key, provider, child) {
        return Container(
          height: getHeight(context),
          child: Flex(
            direction: Axis.vertical,
            children: [
              Container(
                height: 60,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child:
                    Consumer<HomePostProvider>(builder: (key, provider, child) {
                  return ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      HomeFilterItem(
                        title: "All",
                        onTap: () {
                          provider.clearFilters();
                        },
                        isAll: provider.selectedAge.isEmpty &&
                            provider.selectedGender.isEmpty &&
                            provider.selectedRace.isEmpty &&
                            provider.selectedEthnicity.isEmpty,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      HomeFilterItem(
                          title: "Age ${provider.selectedAge}",
                          isAll: provider.selectedAge.isNotEmpty,
                          onTap: () {
                            _showAgeBottomSheet();
                          }),
                      SizedBox(
                        width: 10,
                      ),
                      HomeFilterItem(
                          title: "Gender ${provider.selectedGender}",
                          isAll: provider.selectedGender.isNotEmpty,
                          onTap: () {
                            _showGenderBottomSheet();
                          }),
                      SizedBox(
                        width: 10,
                      ),
                      HomeFilterItem(
                          title: "Ethnicity ${provider.selectedEthnicity}",
                          isAll: provider.selectedEthnicity.isNotEmpty,
                          onTap: () {
                            _showEthnicityBottomSheet();
                          }),
                      SizedBox(
                        width: 10,
                      ),
                      HomeFilterItem(
                          key: UniqueKey(),
                          title: "Race ${provider.selectedRace}",
                          isAll: provider.selectedRace.isNotEmpty,
                          onTap: () {
                            _showRaceBottomSheet();
                          }),
                      SizedBox(
                        width: 10,
                      ),
                      // HomeFilterItem(
                      //     title: "Location ${provider.selectedLocation}",
                      //     onTap: () {
                      //       _showLocationBottomSheet();
                      //     }),
                    ],
                  );
                }),
              ),
              // s
              Expanded(
                child: Container(
                  height: getHeight(context) - 600,
                  child: tabController == null
                      ? SizedBox()
                      : TabBarView(
                          controller: tabController,
                          children: [
                            provider.isLoading && provider.list.length < 1
                                ? SingleChildScrollView(
                                    child: Column(
                                    children: List.generate(10,
                                        (index) => postItemShimmer(context)),
                                  ))
                                : !provider.isLoading &&
                                        provider.list.length < 1
                                    ? JEmptyLayout(
                                        height: 120,
                                        width: 120,
                                        text: "No Reviews Found",
                                      )
                                    : Container(
                                        height: getHeight(context),
                                        child: SmartRefresher(
                                          enablePullDown: true,
                                          enablePullUp: true,
                                          controller:
                                              provider.refreshController,
                                          onLoading: () async {
                                            bool res =
                                                await provider.loadMoreData();
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
                                                            timeRating:
                                                                convertDouble(e
                                                                    .ratingTime),
                                                            loyaltyRating:
                                                                convertDouble(e
                                                                    .ratingLoyalty))
                                                        .toString(),
                                                    onProfileTap: () {
                                                      Navigator.of(context)
                                                          .pushNamed(
                                                              JRoutes
                                                                  .viewProfileScreen,
                                                              arguments:
                                                                  e.userId);
                                                    },
                                                    onPostTap: () {
                                                      Navigator.of(context)
                                                          .pushNamed(
                                                              JRoutes
                                                                  .postDetail,
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
                            // Container(),
                            // FOLLOWING TAB
                            provider.folUsLoading && provider.folList.length < 1
                                ? SingleChildScrollView(
                                    child: Column(
                                    children: List.generate(10,
                                        (index) => postItemShimmer(context)),
                                  ))
                                : !provider.folUsLoading &&
                                        provider.folList.length < 1
                                    ? JEmptyLayout(
                                        height: 120,
                                        width: 120,
                                        text: "No Reviews Found",
                                      )
                                    : SmartRefresher(
                                        enablePullDown: true,
                                        enablePullUp: true,
                                        controller:
                                            provider.folRefreshController,
                                        onLoading: () async {
                                          bool res =
                                              await provider.loadFolMoreData();
                                        },
                                        onRefresh: () async {
                                          bool res = await provider.folReset();
                                          provider.folRefreshController
                                              .refreshCompleted();
                                          provider.folRefreshController =
                                              provider.folRefreshController;
                                        },
                                        footer: ClassicFooter(),
                                        child: ListView(
                                          children: provider.folList
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
                                                          timeRating:
                                                              convertDouble(
                                                                  e.ratingTime),
                                                          loyaltyRating:
                                                              convertDouble(e
                                                                  .ratingLoyalty))
                                                      .toString(),
                                                  onProfileTap: () {
                                                    Navigator.of(context)
                                                        .pushNamed(
                                                            JRoutes
                                                                .viewProfileScreen,
                                                            arguments:
                                                                e.userId);
                                                  },
                                                  onPostTap: () {
                                                    Navigator.of(context)
                                                        .pushNamed(
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
                          ],
                        ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  _showAgeBottomSheet() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        constraints: BoxConstraints(
          maxHeight: getHeight(context) * .7,
        ),
        scrollControlDisabledMaxHeightRatio: 1,
        builder: (context) {
          return Consumer<HomePostProvider>(builder: (key, provider, child) {
            return CustomFilterBottomSheetContainer(
              title: 'Select Age',
              selectedItem: provider.selectedAge,
              items: Constants.ageList,
              onTap: (e) {
                provider.selectedAge = e;
                provider.reset();
                provider.folReset();
                Navigator.of(context).pop();
              },
            );
          });
        });
  }

  _showGenderBottomSheet() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Consumer<HomePostProvider>(builder: (key, provider, child) {
            return CustomFilterBottomSheetContainer(
              title: 'Select Gender',
              selectedItem: provider.selectedGender,
              items: Constants.genderList,
              onTap: (e) {
                provider.selectedGender = e;
                provider.reset();
                provider.folReset();
                Navigator.of(context).pop();
              },
            );
          });
        });
  }

  _showEthnicityBottomSheet() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Consumer<HomePostProvider>(builder: (key, provider, child) {
            return CustomFilterBottomSheetContainer(
              selectedItem: provider.selectedEthnicity,
              title: 'Select Ethnicity',
              items: Constants.ethnicityList,
              onTap: (e) {
                provider.selectedEthnicity = e;
                provider.reset();
                provider.folReset();
                Navigator.of(context).pop();
              },
            );
          });
        });
  }

  _showRaceBottomSheet() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        constraints: BoxConstraints(
          maxHeight: getHeight(context) * .7,
        ),
        builder: (context) {
          return Consumer<HomePostProvider>(builder: (key, provider, child) {
            return CustomFilterBottomSheetContainer(
              title: 'Select Race',
              selectedItem: provider.selectedRace,
              items: Constants.raceList,
              onTap: (e) {
                provider.selectedRace = e;
                provider.reset();
                provider.folReset();
                Navigator.of(context).pop();
              },
            );
          });
        });
  }

  _showLanguageBottomSheet() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Consumer<HomePostProvider>(builder: (key, provider, child) {
            return CustomFilterBottomSheetContainer(
              title: 'Select Ethnicity',
              selectedItem: provider.selectedLanguage,
              items: const [
                "English",
                "Spanish",
                "Chinese",
                "Tagalog",
                "Vietnamese",
                "Arabic",
                "French",
                "Korean",
                "Russian",
                "Portuguese",
              ],
              onTap: (e) {
                provider.selectedLanguage = e;
                provider.reset();
                provider.folReset();
                Navigator.of(context).pop();
              },
            );
          });
        });
  }

  _showLocationBottomSheet() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Consumer<HomePostProvider>(builder: (key, provider, child) {
            return CustomFilterBottomSheetContainer(
              title: 'Select Location',
              selectedItem: provider.selectedLocation,
              items: const [
                "within 5 miles",
                "25 miles",
                "50 miles",
                "100 miles",
                "500 miles",
                "1000 miles"
              ],
              onTap: (e) {
                provider.selectedLocation = e;
                provider.reset();
                provider.folReset();
                Navigator.of(context).pop();
              },
            );
          });
        });
  }
}

class CustomFilterBottomSheetContainer extends StatefulWidget {
  final String title;
  final List<String> items;
  final Function onTap;
  final String selectedItem;

  const CustomFilterBottomSheetContainer(
      {super.key,
      required this.title,
      required this.items,
      required this.selectedItem,
      required this.onTap});

  @override
  State<CustomFilterBottomSheetContainer> createState() =>
      _CustomFilterBottomSheetContainerState();
}

class _CustomFilterBottomSheetContainerState
    extends State<CustomFilterBottomSheetContainer> {
  String selectedItem = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        width: getWidth(context),
        // height: getHeight(context),
        decoration: BoxDecoration(
            color: JColor.white, borderRadius: BorderRadius.circular(16)),
        child: Flex(
          direction: Axis.vertical,
          children: [
            Expanded(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          "${widget.title}",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      Row(
                        children: [
                          TextButton(
                              onPressed: () {
                                widget.onTap("");
                              },
                              child: Text("Reset")),
                          IconButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              icon: Icon(Icons.close)),
                        ],
                      )
                    ],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          ...widget.items.map((e) {
                            return TouchableOpacity(
                              onTap: () {
                                // widget.onTap(e);
                                setState(() {
                                  selectedItem = e;
                                });
                              },
                              child: Stack(
                                alignment: Alignment.centerRight,
                                children: [
                                  Container(
                                    width: getWidth(context),
                                    margin: EdgeInsets.only(bottom: 10),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: selectedItem != e
                                          ? JColor.lighterGrey.withOpacity(.4)
                                          : JColor.primaryColor.withOpacity(.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                        child: Text(
                                      e,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    )),
                                  ),
                                  if (selectedItem == e)
                                    Container(
                                      margin: EdgeInsets.only(
                                          bottom: 10, right: 10),
                                      child: Image.asset(
                                        'assets/icons/circle_tick.png',
                                        width: 25,
                                        height: 25,
                                        color: JColor.primaryColor,
                                      ),
                                    )
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AppColorButton(
              name: "Done",
              color: JColor.primaryColor,
              elevation: 0,
              onPressed: () {
                widget.onTap(selectedItem);
              },
            )
          ],
        ),
      ),
    );
  }
}
//
// class CustomFilterBottomSheetContainer extends StatelessWidget {
//   final String title;
//   final List<String> items;
//   final Function onTap;
//   final String selectedItem;
//
//   const CustomFilterBottomSheetContainer(
//       {super.key,
//       required this.title,
//       required this.items,
//       required this.selectedItem,
//       required this.onTap});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//       color: Colors.transparent,
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
//         width: getWidth(context),
//         height: getHeight(context),
//         decoration: BoxDecoration(
//             color: JColor.white, borderRadius: BorderRadius.circular(16)),
//         child: Column(
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Flexible(
//                   child: Text(
//                     "${title}",
//                     style: TextStyle(fontSize: 20),
//                   ),
//                 ),
//                 Row(
//                   children: [
//                     TextButton(
//                         onPressed: () {
//                           onTap("");
//                         },
//                         child: Text("Reset")),
//                     IconButton(
//                         onPressed: () {
//                           Navigator.of(context).pop();
//                         },
//                         icon: Icon(Icons.close)),
//                   ],
//                 )
//               ],
//             ),
//             SingleChildScrollView(
//               child: Column(
//                 children: [
//                   ...items.map((e) {
//                     return TouchableOpacity(
//                       onTap: () {
//                         onTap(e);
//                       },
//                       child: Container(
//                         width: getWidth(context),
//                         margin: EdgeInsets.only(bottom: 10),
//                         padding:
//                             EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                         decoration: BoxDecoration(
//                           color: selectedItem != e
//                               ? JColor.lighterGrey.withOpacity(.6)
//                               : JColor.primaryColor.withOpacity(.6),
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: Center(
//                             child: Text(
//                           e,
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 16,
//                           ),
//                         )),
//                       ),
//                     );
//                   }),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class DotIndicator extends Decoration {
  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _DotPainter(this, onChanged);
  }
}

class _DotPainter extends BoxPainter {
  final DotIndicator decoration;

  _DotPainter(this.decoration, VoidCallback? onChanged) : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final paint = Paint()
      ..color = JColor.accentColor // Dot color
      ..style = PaintingStyle.fill;

    final double radius = 6.0; // Dot size
    final Offset circleOffset = Offset(
      configuration.size!.width / 2 + offset.dx,
      configuration.size!.height - radius, // Dot position at the bottom center
    );

    canvas.drawCircle(circleOffset, radius, paint);
  }
}

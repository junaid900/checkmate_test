import 'package:carousel_slider/carousel_slider.dart';
import 'package:checkmate/constraints/helpers/helper.dart';
import 'package:checkmate/constraints/jcolor.dart';
import 'package:checkmate/ui/common/touchable_opacity.dart';
import 'package:checkmate/ui/create_post/pages/create_post_page.dart';
import 'package:flutter/material.dart';

import 'pages/post_story_page.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen>
    with TickerProviderStateMixin {
  TabController? tabController;
  CarouselController carouselController = CarouselController();
  int currentPage = 0;
  List<Widget> page = [
    PostStoryPage(),
    CreatePostPage(),
    Container(),
  ];

  getPageData() async {
    tabController =
        TabController(length: 3, vsync: this, initialIndex: currentPage);
    tabController!.addListener(() {
      if (tabController!.indexIsChanging) {
        print("tab chanaged");
        currentPage = tabController!.index;
        setState(() {});
      }
    });
    setState(() {});
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
        backgroundColor: JColor.black,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: page[currentPage],
      bottomNavigationBar: Container(
        width: getWidth(context),
        height: 90,
        padding: EdgeInsets.only(
          top: 10,
        ),
        decoration: BoxDecoration(color: JColor.black),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // AppBar()
            // CarouselSlider(
            //   carouselController: carouselController,
            //     options: CarouselOptions(
            //       height: 22.0,
            //       viewportFraction: .26,
            //       // aspectRatio: 1,
            //       initialPage: currentPage,
            //       onPageChanged: (index, _) {
            //         print(index);
            //       },
            //       enableInfiniteScroll: false,
            //     ),
            //     items: [
            //       TouchableOpacity(
            //         onTap: () {
            //           setState(() {
            //             carouselController.animateToPage(0);
            //             currentPage = 0;
            //           });
            //         },
            //         child: Text(
            //           "Story",
            //           style: TextStyle(fontSize: 16, color: JColor.white),
            //         ),
            //       ),
            //       TouchableOpacity(
            //         onTap: () {
            //           carouselController.animateToPage(1);
            //           setState(() {
            //             currentPage = 1;
            //           });
            //         },
            //         child: Text(
            //           "Post",
            //           style: TextStyle(fontSize: 16, color: JColor.white),
            //         ),
            //       ),
            //       TouchableOpacity(
            //         onTap: () {
            //           carouselController.animateToPage(2);
            //           setState(() {
            //             currentPage = 2;
            //           });
            //         },
            //         child: Text(
            //           "Promotional",
            //           style: TextStyle(fontSize: 16, color: JColor.white),
            //         ),
            //       ),
            //     ]),
            if (tabController != null)
              TabBar(
                  controller: tabController,
                  // splashBorderRadius: BorderRadius.circular(radius),
                  isScrollable: true,
                  // physics: S(),
                  // padding: EdgeInsets.zero,
                  indicatorPadding: EdgeInsets.only(top: 4),
                  labelPadding: EdgeInsets.only(left: 10, right: 10),
                  tabAlignment: TabAlignment.center,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey[700],
                  labelStyle: TextStyle(
                    fontSize: 16,
                  ),
                  dividerColor: Colors.transparent,
                  indicator: DotIndicator(),
                  tabs: [
                    Tab(
                      text: "Story",
                    ),
                    Tab(
                      text: "Post",
                    ),
                    Tab(
                      text: "Promotional",
                    )
                  ]),
            SizedBox(
              height: 20,
            ),
            // Container(
            //   width: 8,
            //   height: 8,
            //   decoration: BoxDecoration(
            //       borderRadius: BorderRadius.circular(50), color: JColor.white),
            // )
          ],
        ),
      ),
    );
  }
}

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
      ..color = Colors.white // Dot color
      ..style = PaintingStyle.fill;

    final double radius = 4.0; // Dot size
    final Offset circleOffset = Offset(
      configuration.size!.width / 2 + offset.dx,
      configuration.size!.height - radius, // Dot position at the bottom center
    );

    canvas.drawCircle(circleOffset, radius, paint);
  }
}

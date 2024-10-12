import 'package:checkmate/modals/cmpost.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../../constraints/helpers/helper.dart';
import '../../../constraints/jcolor.dart';

class PostInfoTab extends StatelessWidget {
  CMPost post;
  PostInfoTab({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width:getWidth(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                "${post.description}"),
            const SizedBox(
              height: 10,
            ),
            Container(
              width: getWidth(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,

                children: [
                  Container(
                    child: const Text("Rating",
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold
                      ),),
                  ),
                  const SizedBox(
                    height:8,
                  ),
                  const Text(
                      "Communication"
                  ),
                  RatingBar.builder(
                    initialRating: convertDouble(post.ratingCommunication),
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemSize: 30,
                    itemCount: 5,
                    ignoreGestures: true,
                    itemPadding:EdgeInsets.symmetric(horizontal: 1.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: JColor.accentColor,
                    ), onRatingUpdate: (double value) {  },
                  ),
                  Text(
                      "Time"
                  ),
                  RatingBar.builder(
                    initialRating: convertDouble(post.ratingTime),
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemSize: 30,
                    itemCount: 5,
                    ignoreGestures: true,
                    itemPadding:EdgeInsets.symmetric(horizontal: 1.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: JColor.accentColor,
                    ), onRatingUpdate: (double value) {  },
                  ),
                  const Text(
                      "Behaviour"
                  ),
                  RatingBar.builder(
                    initialRating: convertDouble(post.ratingBehaviour),
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemSize: 30,
                    itemCount: 5,
                    ignoreGestures: true,
                    itemPadding:EdgeInsets.symmetric(horizontal: 1.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: JColor.accentColor,
                    ), onRatingUpdate: (double value) {  },
                  ),
                  const Text(
                      "Loyalty"
                  ),
                  RatingBar.builder(
                    initialRating: convertDouble(post.ratingLoyalty),
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemSize: 30,
                    itemCount: 5,
                    ignoreGestures: true,
                    itemPadding:EdgeInsets.symmetric(horizontal: 1.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: JColor.accentColor,
                    ), onRatingUpdate: (double value) {  },
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

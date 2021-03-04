import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AccountQueryLoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Shimmer.fromColors(
        baseColor: Colors.grey[800],
        highlightColor: Colors.grey[700],
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              width: MediaQuery.of(context).size.width,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 8.0, right: 8.0, top: 4.0),
              width: MediaQuery.of(context).size.width,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

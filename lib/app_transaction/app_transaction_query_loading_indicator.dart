import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class TransactionQueryLoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
      removeTop: true,
      context: context,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[800],
        highlightColor: Colors.grey[700],
        child: Column(
          children: new List<Widget>.generate(
            (MediaQuery.of(context).size.width ~/ 100),
            (_) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                  width: MediaQuery.of(context).size.width / 3,
                  height: 24.0,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                  width: MediaQuery.of(context).size.width,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

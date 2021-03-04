import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class TransactionFilterLoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800],
      highlightColor: Colors.grey[700],
      child: ButtonBar(
        alignment: MainAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 2.0, vertical: 4.0),
            width: MediaQuery.of(context).size.width / 5,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(32.0),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 2.0, vertical: 4.0),
            width: MediaQuery.of(context).size.width / 5,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(32.0),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 2.0, vertical: 4.0),
            width: MediaQuery.of(context).size.width / 5,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(32.0),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';

class ShimmerLoadingList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300],
          highlightColor: Colors.grey[100],
          child: Column(
            children: [0, 1, 2, 3, 4, 5, 6]
                .map((_) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 48.0,
                            height: 48.0,
                            color: Colors.white,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 8.0,
                                  color: Colors.white,
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 2.0),
                                ),
                                Container(
                                  width: double.infinity,
                                  height: 8.0,
                                  color: Colors.white,
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 2.0),
                                ),
                                Container(
                                  width: 40.0,
                                  height: 8.0,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}

class ShimmerCustomTilePenerimaan extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300],
          highlightColor: Colors.grey[100],
          child: Column(
              children: [0, 1, 2]
                  .map((f) => Container(
                        padding: EdgeInsets.all(10.0),
                        child: Column(
                          children: <Widget>[
                            Container(
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                      color: Colors.white,
                                      height: 12.0,
                                      margin: EdgeInsets.all(5.0),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 5,
                                    child: Container(
                                      color: Colors.white,
                                      height: 12.0,
                                      margin: EdgeInsets.all(5.0),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                      color: Colors.white,
                                      height: 12.0,
                                      margin: EdgeInsets.all(5.0),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 5,
                                    child: Container(
                                      color: Colors.white,
                                      height: 12.0,
                                      margin: EdgeInsets.all(5.0),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                      color: Colors.white,
                                      height: 12.0,
                                      margin: EdgeInsets.all(5.0),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 5,
                                    child: Container(
                                      color: Colors.white,
                                      height: 12.0,
                                      margin: EdgeInsets.all(5.0),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Column(
                                      children: <Widget>[
                                        Container(
                                          child: Container(
                                            color: Colors.white,
                                            height: 12.0,
                                            margin: EdgeInsets.all(5.0),
                                            width: 100.0,
                                          ),
                                        ),
                                        Container(
                                          child: Container(
                                            color: Colors.white,
                                            height: 12.0,
                                            margin: EdgeInsets.all(5.0),
                                            width: 50.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      children: <Widget>[
                                        Container(
                                          child: Container(
                                            color: Colors.white,
                                            height: 12.0,
                                            margin: EdgeInsets.all(5.0),
                                            width: 100.0,
                                          ),
                                        ),
                                        Container(
                                          child: Container(
                                            color: Colors.white,
                                            height: 12.0,
                                            margin: EdgeInsets.all(5.0),
                                            width: 50.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ))
                  .toList()),
        ),
      ),
    );
  }
}

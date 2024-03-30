import 'package:fe/src/models/screen_params.dart';
import 'package:flutter/material.dart';

class Bbox extends StatelessWidget {
  const Bbox({
    super.key,
    required this.box,
    required this.name,
    required this.score,
  });
  final List<double> box;
  final String name;
  final double score;

  @override
  Widget build(BuildContext context) {
    final double width = box[2] * ScreenParams.screenSize.width;
    final double height = box[3] * ScreenParams.screenSize.height;
    final double left = (box[0] * ScreenParams.screenSize.width) - (width / 2);
    final double top = (box[1] * ScreenParams.screenSize.height) - (height / 2);
    debugPrint('$box $name $score');
    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: FittedBox(
            child: Container(
              color: Colors.black38,
              width: width,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      flex: 2,
                      child: Text(
                        name,
                        style: const TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Text(
                        ' ${score.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

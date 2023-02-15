import 'package:flutter/material.dart';

class ContainerSpeedWidget extends StatelessWidget {
  const ContainerSpeedWidget(
      {Key? key, required this.speed, required this.type})
      : super(key: key);

  final String type;
  final String speed;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 15,
          right: 15,
        ),
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.only(
              top: 15,
              bottom: 15,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_drop_down_rounded, color: Colors.white),
                    Text(
                      type,
                      style: TextStyle(
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                          fontSize: 17),
                    ),
                    const SizedBox(
                      width: 15,
                    )
                  ],
                ),
                const SizedBox(
                  height: 6,
                ),
                Text(
                  (int.parse(speed) / 1024).toStringAsFixed(2) + " kB",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w300),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

@immutable
class PatientClipboard extends StatelessWidget {
  final dynamic screen;
  final Color overlayColor;
  const PatientClipboard(this.screen, {Color this.overlayColor, Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) => GestureDetector(
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(
            overlayColor ?? Colors.transparent, BlendMode.srcATop),
        child: Image.asset("assets/images/icon.png", width: 4.h),
      ),
      onTap: () => showModalBottomSheet<void>(
            elevation: 20.0,
            isDismissible: false,
            isScrollControlled: true,
            barrierColor: Colors.black.withAlpha(20),
            backgroundColor: Colors.transparent,
            context: context,
            builder: (context) => SizedBox.expand(
              child: DraggableScrollableSheet(
                initialChildSize: 0.75,
                builder:
                    (BuildContext context, ScrollController scrollController) {
                  return BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      height: 75.h,
                      decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30.0),
                            topRight: Radius.circular(30.0),
                          ),
                          color: Theme.of(context).cardColor),
                      child: SingleChildScrollView(
                          controller: scrollController, child: screen),
                    ),
                  );
                },
              ),
            ),
          ));
}

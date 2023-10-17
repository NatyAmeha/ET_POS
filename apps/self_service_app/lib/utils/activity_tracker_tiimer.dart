import 'dart:async';

import 'package:flutter/material.dart';
import 'package:self_service_app/const/app_constant.dart';
import 'package:self_service_app/ui/widgets/activity_time_tracker.dart';
import 'package:self_service_app/utils/ui_helper.dart';

class ActivityTrackerTimer {
  int timeToCompleteOrderInSecond;
  int timeToShowTrackerDialogInSecond;

  late int savedTimeToCompleteOrder;
  late int savedTimeToShowDialog;
  ActivityTrackerTimer({
    this.timeToCompleteOrderInSecond =
        AppConstant.MAX_TIME_FOR_INACTIVITY_IN_SECOND,
    this.timeToShowTrackerDialogInSecond =
        AppConstant.TIME_TO_SHOW_INACTIVITY_DIALOG,
  }) {
    savedTimeToCompleteOrder = timeToCompleteOrderInSecond;
    savedTimeToShowDialog = timeToShowTrackerDialogInSecond;
  }
  // timer related fields
  var trackTimer = false;
  BuildContext? timerContext; // special context, must be Material app's context
  var trackerDialogShowed = false;

  Timer? timer;

  initializedTimerContext(BuildContext context) {
    timerContext = context;
  }

  startTimerToShowActivityDialog(
      {Function(int remainingSeconds)? onTimeTick,
      Function(BuildContext context)? onTimerCanceled,
      Function(BuildContext context)? onTimeToShowDialog}) {
    trackTimer = true;
    if (timer != null) {
      stopTimer();
    }
    if (timerContext != null) {
      timer = Timer.periodic(
        Duration(seconds: 1),
        (timer) {
          if (timeToCompleteOrderInSecond > 0) {
            timeToCompleteOrderInSecond = timeToCompleteOrderInSecond - 1;
            onTimeTick?.call(timeToCompleteOrderInSecond);
            if (timeToCompleteOrderInSecond < timeToShowTrackerDialogInSecond &&
                !trackerDialogShowed) {
              UiHelper.showModal(
                  timerContext!,
                  ActivityTimeTracker(
                    onOrderReturn: () {
                      Navigator.of(timerContext!).pop();
                      restartTimer(
                        onTimeTick: (remainingSeconds) {
                          onTimeTick?.call(remainingSeconds);
                        },
                      );
                    },
                    onCancelOrder: () {
                      Navigator.of(timerContext!).pop();
                      onTimerCanceled?.call(timerContext!);
                      trackTimer = false;
                      trackerDialogShowed = false;
                      timeToCompleteOrderInSecond = savedTimeToCompleteOrder; 
                      timeToShowTrackerDialogInSecond = savedTimeToShowDialog;
                      timer.cancel();
                    },
                  ));
              trackerDialogShowed = true;
            }
          }
          if (timeToCompleteOrderInSecond == 0) {
            Navigator.of(timerContext!).pop();
            onTimerCanceled?.call(timerContext!);
            trackTimer = false;
            trackerDialogShowed = false;
            timeToCompleteOrderInSecond = savedTimeToCompleteOrder;
            timeToShowTrackerDialogInSecond = savedTimeToShowDialog;
            timer.cancel();
          }
        },
      );
    }
  }

  stopTimer() {
    timer!.cancel();
  }

  restartTimer({Function(int remainingSeconds)? onTimeTick , Function(BuildContext context)? onTimerCanceled}) {
    timeToCompleteOrderInSecond = savedTimeToCompleteOrder;
    timeToShowTrackerDialogInSecond = timeToShowTrackerDialogInSecond;
    trackerDialogShowed = false;
    if (timerContext != null && trackTimer) {
      startTimerToShowActivityDialog(
        onTimeTick: (remainingSeconds) {
          if(trackTimer){
          onTimeTick?.call(remainingSeconds);
          }
          else {
            timer?.cancel();
          }
        },
        onTimerCanceled: (context) {
          onTimerCanceled?.call(context);
        },
      );
    }
  }
}

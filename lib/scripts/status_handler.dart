import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StatusHandler {
  static List<Column> collectionStatusBuilder(int numberCollected, int totalMessages, int millisElapsed) {
    double secondsElapsed = millisElapsed / 1000;
    double collectionsPerSecond = numberCollected / secondsElapsed;
    String collectionsPerSecondString = collectionsPerSecond.toStringAsPrecision(4);

    String timeElapsed = secondsElapsed > 60
        ? '${secondsElapsed ~/ 60} minutes, ${(secondsElapsed % 60).toInt()} seconds elapsed'
        : '${secondsElapsed.toInt()} seconds elapsed';
    
    int messagesRemaining = totalMessages - numberCollected;
    int estimatedSecondsRemaining = messagesRemaining ~/ collectionsPerSecond;
    String estimatedTimeRemaining = estimatedSecondsRemaining > 60
        ? '${estimatedSecondsRemaining ~/ 60} minutes, ${estimatedSecondsRemaining % 60} seconds remaining'
        : '$estimatedSecondsRemaining seconds remaining';

    List<Column> widgetList = [
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text('Collected $numberCollected of $totalMessages messages, $collectionsPerSecondString/s')],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text(timeElapsed)]
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text(estimatedTimeRemaining)],
          )
        ]
      )
    ];
    
    return widgetList;
  }

  static List<Column> stringStatusBuilder(String statusMessage) {
    List<Column> widgetList = [
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text(statusMessage)]
          )
        ]
      )
    ];

    return widgetList;
  }

  static List<Column> doneProcessingBuilder(BuildContext context) {
    List<Column> widgetList = [
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Done processing'),
            ],
          ),
          const Padding(padding: EdgeInsets.only(top: 20)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                child: const Text('Next page'),
                onPressed: () => context.go('/flagger'),
              ),
            ],
          )
        ],
      ),
    ];
    return widgetList;
  }

  static List<Column> flagHandlerStatusBuilder(List<String> statusLines) {
    List<Row> wrappedStatusLines = [];
    for (String line in statusLines) {
      Row wrappedLine = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(line),
          const Padding(padding: EdgeInsets.only(top: 10))
        ],
      );
      wrappedStatusLines.add(wrappedLine);
    }

    List<Column> widgetList = [
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: wrappedStatusLines,
      )
    ];

    return widgetList;
  }
}
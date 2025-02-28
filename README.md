# tap_on_scroll
A Flutter package that solves the common issue of missed tap events on items while scrolling. tap_interceptor intercepts tap events during scroll interactions, temporarily locks the scroll position, and reliably dispatches tap events to registered tappable areas in both regular and sliver-based layouts.

## Features
- Reliable Tap Detection: Prevents missed tap events while scrolling.
- Tappable Areas: Easily designate areas that should respond to tap events using TappableArea.
- Seamless Integration: Works with existing scrollable widgets and slivers.
- Simple API: Minimal setup to enhance tap responsiveness in your Flutter apps.

## Usage
Wrap your scrollable widget with TapInterceptor and pass in the scroll controller. Then, wrap your tappable items with either TappableArea or SliverTappableArea:

Regular List Example
```dart
import 'package:flutter/material.dart';
import 'package:tap_interceptor/tap_interceptor.dart'; // Adjust the import as necessary

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'tap_interceptor Demo',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('tap_interceptor Demo'),
        ),
        body: TapInterceptor(
          scrollController: _scrollController,
          child: ListView.builder(
            controller: _scrollController,
            itemCount: 20,
            itemBuilder: (context, index) {
              return TappableArea(
                onTap: () => print('Tapped item $index'),
                child: ListTile(
                  title: Text('Item $index'),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
```
## How It Works
TapInterceptor intercepts tap events and checks if a tap falls within any registered tappable areas. When a tap is detected, it temporarily locks the scroll offset (by jumping to the current position) to prevent any scroll-induced misalignment and then dispatches the tap to the appropriate TappableArea or SliverTappableArea.

This approach allows you to continue scrolling while ensuring that any tap on an item is reliably detected.

Contributing
Contributions are welcome! If you encounter issues or have suggestions for improvements, please open an issue or submit a pull request.

## License
This project is licensed under the MIT License - see the LICENSE file for details.
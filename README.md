# tap_on_scroll

[![pub package](https://img.shields.io/pub/v/tap_on_scroll.svg)](https://pub.dev/packages/tap_on_scroll)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

A Flutter package that solves the common issue of missed tap events on items while scrolling. `tap_on_scroll` intercepts tap events during scroll interactions and reliably dispatches them to registered tappable areas in both regular and sliver-based layouts.

## 📱 Demo

Here's how tap_on_scroll solves the problem of unresponsive taps during scrolling:

<img src="https://raw.githubusercontent.com/00Adnan00/tap-on-scroll/main/assets/gifs/dmo.gif" alt="tap_on_scroll demo" style="padding-left:60px; width:400px; height:auto;">

_Demonstration of tap_on_scroll functionality showing how it ensures reliable tap detection even during active scrolling._

## 🚀 Features

- **Reliable Tap Detection**: Prevents missed tap events while scrolling
- **Tappable Areas**: Easily designate areas that should respond to tap events using `TappableArea`
- **Seamless Integration**: Works with existing scrollable widgets
- **Simple API**: Minimal setup to enhance tap responsiveness in your Flutter apps
- **Zero Dependencies**: Only depends on Flutter core libraries
- **Perfect for Pinned Headers**: Makes PinnedHeaderSlivers consistently tappable even during scroll

## 📋 Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  tap_on_scroll: ^0.0.2
```

Or install it directly from the command line:

```bash
flutter pub add tap_on_scroll
```

## 🎯 Usage

Wrap your scrollable widget with `TapInterceptor` and wrap your tappable items with `TappableArea`:

### Basic Example

```dart
import 'package:flutter/material.dart';
import 'package:tap_on_scroll/tap_on_scroll.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'tap_on_scroll Demo',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('tap_on_scroll Demo'),
        ),
        body: TapInterceptor(
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

### Using with GridView

```dart
TapInterceptor(
  child: GridView.builder(
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
    ),
    itemCount: 20,
    itemBuilder: (context, index) {
      return TappableArea(
        onTap: () => print('Tapped grid item $index'),
        child: Card(
          child: Center(
            child: Text('Grid Item $index'),
          ),
        ),
      );
    },
  ),
)
```

### Using with Pinned Headers (SliverAppBar)

This is an especially useful application of tap_on_scroll, as pinned headers often lose tap responsiveness during scroll:

```dart
TapInterceptor(
  child: CustomScrollView(
    slivers: [
      // Pinned SliverAppBar with TappableArea for title and actions
      SliverAppBar(
        pinned: true,
        expandedHeight: 150.0,
        // Make the title tappable
        flexibleSpace: FlexibleSpaceBar(
          title: TappableArea(
            onTap: () => print('Pinned header title tapped!'),
            child: Text('Pinned Header'),
          ),
          background: Image.network(
            'https://example.com/image.jpg',
            fit: BoxFit.cover,
          ),
        ),
        // CRUCIAL USE CASE: Make action buttons tappable during scroll
        actions: [
          TappableArea(
            onTap: () => print('Search button tapped during scroll!'),
            child: IconButton(
              icon: Icon(Icons.search),
              onPressed: () {}, // This might not work reliably during scroll
            ),
          ),
          TappableArea(
            onTap: () => print('Favorite button tapped during scroll!'),
            child: IconButton(
              icon: Icon(Icons.favorite),
              onPressed: () {}, // This might not work reliably during scroll
            ),
          ),
          TappableArea(
            onTap: () => print('Menu button tapped during scroll!'),
            child: IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () {}, // This might not work reliably during scroll
            ),
          ),
        ],
      ),

      // Section header that remains tappable
      SliverPersistentHeader(
        pinned: true,
        delegate: YourHeaderDelegate(
          child: TappableArea(
            onTap: () => print('Section header tapped!'),
            child: Container(
              color: Colors.teal,
              child: Center(
                child: Text('Always Tappable Section Header'),
              ),
            ),
          ),
        ),
      ),

      // Regular list items
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return TappableArea(
              onTap: () => print('Item $index tapped'),
              child: ListTile(title: Text('Item $index')),
            );
          },
          childCount: 50,
        ),
      ),
    ],
  ),
)
```

## 🔍 How It Works

`TapInterceptor` intercepts tap events and checks if a tap falls within any registered tappable areas. When a tap is detected:

1. It identifies which `TappableArea` was tapped
2. Dispatches the tap event to the appropriate area
3. Triggers the `onTap` callback you provided

This approach ensures that taps are reliably detected even during scroll momentum, solving a common issue with pinned headers and other interactive elements during scrolling.

### Implementation Details

The package is designed with simplicity in mind:

- `TapInterceptor` doesn't require a scroll controller - it works automatically with any scrollable widget
- `TappableArea` registers itself with the nearest `TapInterceptor` ancestor
- The tap detection works by computing the global position of each tappable area and checking if tap events fall within that area
- Perfect for pinned headers because it resolves the conflict between scroll gestures and tap interactions that often causes unresponsiveness

## 🧪 Example

Check out the [example app](https://github.com/00Adnan00/tap-on-scroll/tree/main/example) for a complete implementation showing how to use `tap_on_scroll` in a real-world scenario, including a dedicated example of making pinned headers tappable during scrolling.

## 🤝 Contributing

Contributions are welcome! If you encounter issues or have suggestions for improvements, please:

1. Open an issue describing the bug or feature request
2. Submit a pull request with your changes
3. Ensure your code follows the project's coding standards

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📱 Compatibility

- Dart SDK: ^3.7.0
- Flutter: ">=1.17.0"

## 👥 Authors

- Adnan Aljafarey - Initial work - [GitHub](https://github.com/00Adnan00)

---

If you find this package helpful, please consider giving it a star ⭐ on [GitHub](https://github.com/00Adnan00/tap-on-scroll)!

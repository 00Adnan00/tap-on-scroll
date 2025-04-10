import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// A widget that intercepts taps and determines if a registered TappableArea was tapped.
/// This widget is designed to solve the common issue of missed tap events on items
/// while scrolling in Flutter applications.
class TapInterceptor extends StatefulWidget {
  /// The child widget to render.
  final Widget child;

  /// The scroll controller that manages the scrollable widget.
  final ScrollController scrollController;

  const TapInterceptor({
    super.key,
    required this.child,
    required this.scrollController,
  });

  @override
  State<TapInterceptor> createState() => _TapInterceptorState();
}

class _TapInterceptorState extends State<TapInterceptor> {
  // Use a Set to hold the currently registered tappable areas.
  final Set<_TappableAreaState> _registeredAreas = {};

  /// Called by TappableArea to register itself.
  void registerArea(_TappableAreaState area) {
    _registeredAreas.add(area);
  }

  /// Called by TappableArea to unregister itself.
  void unregisterArea(_TappableAreaState area) {
    _registeredAreas.remove(area);
  }

  /// Handle a tap by checking all registered tappable areas.
  ///
  /// This method is optimized for performance during fast scrolling by:
  /// 1. Checking if the scroll controller has clients
  /// 2. Preventing scroll changes with jumpTo
  /// 3. Efficiently checking tap position against registered areas
  /// 4. Simulating pointer events for better gesture integration
  void _handleTapUp(TapUpDetails details) {
    if (!widget.scrollController.hasClients) return;

    // Prevent any scroll changes by jumping to the current offset.
    // This ensures the tap is processed at the current position.
    widget.scrollController.jumpTo(widget.scrollController.offset);

    final tapPosition = details.globalPosition;

    // Optimize by checking the most likely areas first if possible
    for (final area in _registeredAreas) {
      final rect = area.getRect();
      if (rect.contains(tapPosition)) {
        // Simulate pointer events for better gesture integration
        GestureBinding.instance.handlePointerEvent(
          PointerDownEvent(position: tapPosition),
        );
        GestureBinding.instance.handlePointerEvent(
          PointerUpEvent(position: tapPosition),
        );
        area.onTap();
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _TapInterceptorScope(
      state: this,
      child: GestureDetector(
        onTapUp: _handleTapUp,
        behavior: HitTestBehavior.translucent,
        child: widget.child,
      ),
    );
  }
}

/// InheritedWidget to provide the [_TapInterceptorState] to descendant widgets.
class _TapInterceptorScope extends InheritedWidget {
  final _TapInterceptorState state;

  const _TapInterceptorScope({required this.state, required super.child});

  static _TapInterceptorState? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_TapInterceptorScope>()
        ?.state;
  }

  @override
  bool updateShouldNotify(_TapInterceptorScope oldWidget) =>
      state != oldWidget.state;
}

/// A widget that registers itself with the nearest TapInterceptor and computes its own bounds.
///
/// This widget is responsible for:
/// 1. Registering itself with the nearest TapInterceptor
/// 2. Computing its own global bounds
/// 3. Handling tap events dispatched from the TapInterceptor
///
/// Use this widget to wrap any element that should remain tappable during scroll interactions.
class TappableArea extends StatefulWidget {
  /// The child widget to render.
  final Widget child;

  /// Callback function that's called when this area is tapped.
  final VoidCallback? onTap;

  const TappableArea({super.key, required this.child, this.onTap});

  @override
  State<TappableArea> createState() => _TappableAreaState();
}

class _TappableAreaState extends State<TappableArea> {
  _TapInterceptorState? _interceptorState;

  /// Returns the global bounding rectangle of this widget.
  ///
  /// This method calculates the widget's position in global coordinates,
  /// which is used by the TapInterceptor to determine if a tap event
  /// occurred within this area.
  Rect getRect() {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final offset = box.localToGlobal(Offset.zero);
    return offset & box.size;
  }

  /// Called by TapInterceptor when a tap is detected inside this area.
  ///
  /// This method invokes the onTap callback provided to the TappableArea widget.
  void onTap() {
    widget.onTap?.call();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Look up the nearest TapInterceptor.
    final newInterceptor = _TapInterceptorScope.of(context);
    if (_interceptorState != newInterceptor) {
      _interceptorState?.unregisterArea(this);
      _interceptorState = newInterceptor;
      _interceptorState?.registerArea(this);
    }
  }

  @override
  void dispose() {
    _interceptorState?.unregisterArea(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Simply render the child.
    return widget.child;
  }
}

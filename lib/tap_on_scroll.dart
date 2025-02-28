import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// A widget that intercepts taps and determines if a registered TappableArea was tapped.
class TapInterceptor extends StatefulWidget {
  final Widget child;
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
  void _handleTapUp(TapUpDetails details) {
    if (!widget.scrollController.hasClients) return;

    // Prevent any scroll changes by jumping to the current offset.
    widget.scrollController.jumpTo(widget.scrollController.offset);

    final tapPosition = details.globalPosition;
    // Check each registered tappable area.
    for (final area in _registeredAreas) {
      final rect = area.getRect();
      if (rect.contains(tapPosition)) {
        // Optionally, simulate pointer events.
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

  const _TapInterceptorScope({
    required this.state,
    required super.child,
  });

  static _TapInterceptorState? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_TapInterceptorScope>()?.state;
  }

  @override
  bool updateShouldNotify(_TapInterceptorScope oldWidget) => state != oldWidget.state;
}

/// A widget that registers itself with the nearest TapInterceptor and computes its own bounds.
class TappableArea extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const TappableArea({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  State<TappableArea> createState() => _TappableAreaState();
}

class _TappableAreaState extends State<TappableArea> {
  _TapInterceptorState? _interceptorState;

  /// Returns the global bounding rectangle of this widget.
  Rect getRect() {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final offset = box.localToGlobal(Offset.zero);
    return offset & box.size;
  }

  /// Called by TapInterceptor when a tap is detected inside this area.
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

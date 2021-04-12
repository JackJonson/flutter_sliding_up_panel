import 'package:flutter/material.dart';

/// On panel status changed
typedef OnSlidingUpPanelStatusChanged = void Function(
    SlidingUpPanelStatus status);

/// On drag down when user drag down this panel
typedef OnSlidingUpPanelDragDown = void Function(DragDownDetails details);

/// On drag start when user start drag this panel
typedef OnSlidingUpPanelDragStart = void Function(DragStartDetails details);

/// On drag cancel when user cancel drag this panel
typedef OnSlidingUpPanelDragCancel = void Function();

/// On drag update when user drag this panel
typedef OnSlidingUpPanelDragUpdate = void Function(DragUpdateDetails details);

/// On drag end when user drag this panel
typedef OnSlidingUpPanelDragEnd = void Function(DragEndDetails details);

const Duration _kSlidingUpPanelDuration = Duration(milliseconds: 400);
const double _kMinFlingVelocity = 100.0;
const double _kCloseProgressThreshold = 0.2;

/// Sliding up panel status enum
enum SlidingUpPanelStatus {
  /// The panel is fully expanded
  expanded,

  /// The panel is collapsed
  collapsed,

  /// The panel is anchored
  anchored,

  /// The panel is hidden
  hidden,

  /// The panel is dragging
  dragging,
}

/// Sliding up panel widget
class SlidingUpPanelWidget extends StatefulWidget {
  /// Child widget
  final Widget child;

  /// The height of the widget to drag
  final double controlHeight;

  /// The animation that controls the bottom sheet's position.
  ///
  /// The BottomSheet widget will manipulate the position of this animation, it
  /// is not just a passive observer.
  final AnimationController animationController;

  /// The controller of the panel
  final SlidingUpPanelController panelController;

  /// Called when the bottom sheet begins to close.
  ///
  /// The panel might be prevented from closing (e.g., by user
  /// interaction) even after this callback is called. For this reason, this
  /// callback might be call multiple times for a given bottom sheet.
  final OnSlidingUpPanelStatusChanged onStatusChanged;

  /// Void callback when click control bar
  final VoidCallback onTap;

  /// Enable the tap callback for control bar
  final bool enableOnTap;

  /// Elevation of the panel
  final double elevation;

  /// Panel status
  final SlidingUpPanelStatus panelStatus;

  /// Anchor
  final double anchor;

  /// Drag down listener
  final OnSlidingUpPanelDragDown dragDown;

  /// Drag start listener
  final OnSlidingUpPanelDragStart dragStart;

  /// Drag start listener
  final OnSlidingUpPanelDragCancel dragCancel;

  /// Drag update listener
  final OnSlidingUpPanelDragUpdate dragUpdate;

  /// Drag end listener
  final OnSlidingUpPanelDragEnd dragEnd;

  SlidingUpPanelWidget({
    @required this.child,
    @required this.controlHeight,
    this.animationController,
    @required this.panelController,
    this.onStatusChanged,
    this.onTap,
    this.enableOnTap = true,
    this.elevation = 0.0,
    this.panelStatus = SlidingUpPanelStatus.collapsed,
    this.anchor = 0.5,
    this.dragDown,
    this.dragCancel,
    this.dragStart,
    this.dragUpdate,
    this.dragEnd,
  });

  @override
  State<StatefulWidget> createState() {
    return _SlidingUpPanelWidgetState();
  }

  static SlidingUpPanelWidget of(BuildContext context) {
    return context.findAncestorWidgetOfExactType<SlidingUpPanelWidget>();
  }

  /// Creates an animation controller suitable for controlling a [SlidingUpPanelWidget].
  static AnimationController createAnimationController(TickerProvider vsync) {
    return AnimationController(
      duration: _kSlidingUpPanelDuration,
      debugLabel: 'SlidingUpPanelWidget',
      vsync: vsync,
    );
  }
}

class _SlidingUpPanelWidgetState extends State<SlidingUpPanelWidget>
    with SingleTickerProviderStateMixin<SlidingUpPanelWidget> {
  Animation<Offset> animation;

  final GlobalKey _childKey =
      GlobalKey(debugLabel: 'SlidingUpPanelWidget child');

  double get _childHeight {
    final RenderBox renderBox = _childKey.currentContext.findRenderObject();
    return renderBox.size.height;
  }

  AnimationController _animationController;

  double upperBound = 1.0;

  double anchorFraction = 0.5;

  double collapseFraction = 0.0;

  @override
  void initState() {
    upperBound = 1.0;
    widget.panelController?.addListener(handlePanelStatusChanged);
    if (widget.animationController == null) {
      _animationController =
          SlidingUpPanelWidget.createAnimationController(this);
    } else {
      _animationController = widget.animationController;
    }
    animation = _animationController.drive(
      Tween(begin: Offset(0.0, upperBound), end: Offset.zero).chain(
        CurveTween(
          curve: Curves.linear,
        ),
      ),
    );
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initData(context));
  }

  void _initData(BuildContext context) {
    collapseFraction =
        widget.controlHeight / MediaQuery.of(context).size.height;
    anchorFraction = widget.anchor * upperBound;

    widget.panelController?.value = widget.panelStatus;
    switch (widget.panelController?.status) {
      case SlidingUpPanelStatus.anchored:
        _animationController.value = anchorFraction;
        break;
      case SlidingUpPanelStatus.collapsed:
        _animationController.value = collapseFraction;
        break;
      case SlidingUpPanelStatus.expanded:
        _animationController.value = 1.0;
        break;
      case SlidingUpPanelStatus.hidden:
        _animationController.value = 0.0;
        break;
      default:
        _animationController.value = collapseFraction;
        break;
    }
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: MediaQuery.removePadding(
        context: context,
        removeTop: false,
        removeBottom: true,
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (BuildContext context, Widget child) {
              return SlideTransition(
                child: child,
                position: animation,
              );
            },
            child: GestureDetector(
              onVerticalDragUpdate: _handleDragUpdate,
              onVerticalDragEnd: _handleDragEnd,
              onVerticalDragStart: _handleDragStart,
              onVerticalDragCancel: _handleDragCancel,
              onVerticalDragDown: _handleDragDown,
              child: Material(
                key: _childKey,
                color: Colors.transparent,
                elevation: widget.elevation,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: widget.child,
                ),
              ),
              excludeFromSemantics: true,
            ),
          ),
        ),
      ),
      onTap: widget.enableOnTap
          ? (widget.onTap ??
              () {
                if (SlidingUpPanelStatus.anchored ==
                    widget.panelController.status) {
                  collapse();
                } else if (SlidingUpPanelStatus.collapsed ==
                    widget.panelController.status) {
                  anchor();
                } else if (SlidingUpPanelStatus.expanded ==
                    widget.panelController.status) {
                  collapse();
                } else {
                  collapse();
                }
              })
          : null,
    );
  }

  ///Handle method when user start drag
  void _handleDragStart(DragStartDetails details) {
    widget.dragStart?.call(details);
  }

  ///Handle method when user drag down
  void _handleDragDown(DragDownDetails details) {
    widget.dragDown?.call(details);
  }

  ///Handle method when user cancel drag
  void _handleDragCancel() {
    widget.dragCancel?.call();
  }

  ///Handle method when user drag the panel
  void _handleDragUpdate(DragUpdateDetails details) {
    _animationController.value -=
        details.primaryDelta / (_childHeight ?? details.primaryDelta);
    widget.panelController.value = SlidingUpPanelStatus.dragging;
    widget.onStatusChanged?.call(widget.panelController.status);
    widget.dragUpdate?.call(details);
  }

  ///Handle method when user release drag.
  void _handleDragEnd(DragEndDetails details) {
    if (details.velocity.pixelsPerSecond.dy < -_kMinFlingVelocity) {
      if (SlidingUpPanelStatus.collapsed == widget.panelController.status) {
        anchor();
      } else if ((SlidingUpPanelStatus.anchored ==
          widget.panelController.status)) {
        expand();
      } else {
        expand();
      }
    } else if (details.velocity.pixelsPerSecond.dy > _kMinFlingVelocity) {
      if (SlidingUpPanelStatus.expanded == widget.panelController.status) {
        anchor();
      } else if ((SlidingUpPanelStatus.anchored ==
          widget.panelController.status)) {
        collapse();
      } else {
        collapse();
      }
    } else if (_animationController.value < _kCloseProgressThreshold) {
      collapse();
    } else if ((_animationController.value >=
        (anchorFraction + upperBound) / 2)) {
      expand();
    } else if (_animationController.value >= _kCloseProgressThreshold &&
        _animationController.value < (anchorFraction + upperBound) / 2) {
      anchor();
    } else {
      collapse();
    }
    widget.dragEnd?.call(details);
  }

  ///Collapse the panel
  void collapse() {
    _animationController?.animateTo(collapseFraction,
        curve: Curves.linearToEaseOut, duration: _kSlidingUpPanelDuration);
    widget.panelController.value = SlidingUpPanelStatus.collapsed;
    widget.onStatusChanged?.call(widget.panelController.status);
  }

  ///Expand the panel
  void expand() {
    _animationController?.animateTo(1.0,
        curve: Curves.linearToEaseOut, duration: _kSlidingUpPanelDuration);
    widget.panelController.value = SlidingUpPanelStatus.expanded;
    widget.onStatusChanged?.call(widget.panelController.status);
  }

  ///Anchor the panel
  void anchor() {
    _animationController?.animateTo(anchorFraction,
        curve: Curves.linearToEaseOut, duration: _kSlidingUpPanelDuration);
    widget.panelController.value = SlidingUpPanelStatus.anchored;
    widget.onStatusChanged?.call(widget.panelController.status);
  }

  ///Hide the panel
  void hide() {
    _animationController?.animateTo(0.0,
        curve: Curves.linearToEaseOut, duration: _kSlidingUpPanelDuration);
    widget.panelController.value = SlidingUpPanelStatus.hidden;
    widget.onStatusChanged?.call(widget.panelController.status);
  }

  ///Handle the status changed of panel
  void handlePanelStatusChanged() {
    if (widget.panelController == null) {
      return;
    }
    widget.onStatusChanged?.call(widget.panelController.value);
    switch (widget.panelController.value) {
      case SlidingUpPanelStatus.anchored:
        anchor();
        break;
      case SlidingUpPanelStatus.collapsed:
        collapse();
        break;
      case SlidingUpPanelStatus.expanded:
        expand();
        break;
      case SlidingUpPanelStatus.hidden:
        hide();
        break;
      case SlidingUpPanelStatus.dragging:
        break;
      default:
        collapse();
        break;
    }
  }

  void setStateSafe(VoidCallback callback) {
    if (mounted) {
      setState(callback);
    }
  }
}

///The controller of SlidingUpPanelWidget
class SlidingUpPanelController extends ValueNotifier<SlidingUpPanelStatus> {
  SlidingUpPanelController({SlidingUpPanelStatus value})
      : super(value != null ? value : SlidingUpPanelStatus.collapsed);

  SlidingUpPanelStatus get status => value;

  ///Collapse the panel
  void collapse() {
    value = SlidingUpPanelStatus.collapsed;
  }

  ///Expand the panel
  void expand() {
    value = SlidingUpPanelStatus.expanded;
  }

  ///Anchor the panel
  void anchor() {
    value = SlidingUpPanelStatus.anchored;
  }

  ///Hide the panel
  void hide() {
    value = SlidingUpPanelStatus.hidden;
  }
}

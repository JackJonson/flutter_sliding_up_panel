# flutter_sliding_up_panel

A sliding up panel widget which can be used to show or hide content, beautiful and simple.


## demo

<img src="https://raw.githubusercontent.com/JackJonson/flutter_sliding_up_panel/master/screenshots/demo.gif" width="50%">


## Getting Started

```yaml
dependencies:
  flutter_sliding_up_panel: ^0.0.3
```

```dart
import 'package:flutter_sliding_up_panel/flutter_sliding_up_panel.dart';
```

```dart
Stack(
  children: <Widget>[
    Scaffold(
      body: Container(),
    ),
    SlidingUpPanelWidget(
      child: Container(),
      controlHeight: 50.0,
      anchor: 0.4,
      panelController: panelController,
    ),
  ],
)
```


### SlidingUpPanelWidget param

property            | description
--------------------|----------------------------
child               | Widget (Not Null)(required)
controlHeight       | double (Not Null)(required)   
animationController | AnimationController 
panelController     | SlidingUpPanelController (Not Null)(required)
onStatusChanged     | OnSlidingUpPanelStatusChanged 
elevation           | double (default 8.0)   
panelStatus         | SlidingUpPanelStatus (default SlidingUpPanelStatus.collapsed)   
anchor              | double (default 0.5)   


## Example
[example](https://github.com/JackJonson/flutter_sliding_up_panel/blob/master/example/lib/main.dart)



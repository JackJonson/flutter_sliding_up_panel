# flutter_sliding_up_panel

A sliding up panel widget which can be used to show or hide content, beautiful and simple.


## demo

<img src="https://raw.githubusercontent.com/JackJonson/flutter_sliding_up_panel/master/screenshots/demo.gif" width="50%">


## Getting Started

## Null safety
```yaml
dependencies:
  flutter_sliding_up_panel: ^2.1.1
```

## Previous version
```yaml
dependencies:
  flutter_sliding_up_panel: ^1.2.1
```



```dart
import 'package:flutter_sliding_up_panel/flutter_sliding_up_panel.dart';
```

```dart
Stack(
  children: <Widget>[
    Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              widget.onSetting?.call();
            },
          )
        ],
      ),
      body: Container(
        child:Center(
          child:Text('This is content'),
        ),
      ),
    ),
    SlidingUpPanelWidget(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 15.0),
        decoration: ShapeDecoration(
          color: Colors.white,
          shadows: [BoxShadow(blurRadius: 5.0,spreadRadius: 2.0,color: const Color(0x11000000))],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.0),
              topRight: Radius.circular(10.0),
            ),
          ),
        ),
        child: Column(
          children: <Widget>[
            Container(
              color: Colors.white,
              alignment: Alignment.center,
              height: 50.0,
              child: Row(
                children: <Widget>[
                  Icon(Icons.menu,size: 30,),
                  Padding(
                    padding: EdgeInsets.only(left: 8.0,),
                  ),
                  Text(
                    'click or drag',
                  )
                ],
                mainAxisAlignment: MainAxisAlignment.center,
              ),
            ),
            Divider(
              height: 0.5,
              color: Colors.grey[300],
            ),
            Flexible(
              child: Container(
                child: ListView.separated(
                  controller: scrollController,
                  physics: ClampingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text('list item $index'),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Divider(
                      height: 0.5,
                    );
                  },
                  shrinkWrap: true,
                  itemCount: 20,
                ),
                color: Colors.white,
              ),
            ),
          ],
          mainAxisSize: MainAxisSize.min,
        ),
      ),
      controlHeight: 50.0,
      anchor: 0.4,
      panelController: panelController,
      onTap: (){
         ///Customize the processing logic
         if(SlidingUpPanelStatus.expanded==panelController.status){
            panelController.collapse();
         }else{
            panelController.expand();
         }
      },  //Pass a onTap callback to customize the processing logic when user click control bar.
      enableOnTap: true,//Enable the onTap callback for control bar.
      dragDown: (details){
         print('dragDown');
      },
      dragStart: (details){
         print('dragStart');
      },
      dragCancel: (){
         print('dragCancel');
      },
      dragUpdate: (details){
         print('dragUpdate,${panelController.status==SlidingUpPanelStatus.dragging?'dragging':''}');
      },
      dragEnd: (details){
         print('dragEnd');
      },
    ),
  ],
);
```


### SlidingUpPanelWidget param

property            | description
--------------------|----------------------------
child               | Widget (Not Null)(required) (Child widget)
controlHeight       | double (Not Null)(required) (The height of the control bar which could be used to drag or click to control this panel)   
animationController | AnimationController  (The animation that controls the bottom sheet's position.)
panelController     | SlidingUpPanelController (Not Null)(required) (The controller to control panel)
onStatusChanged     | OnSlidingUpPanelStatusChanged  (Called when the this panel status changed)
elevation           | double (default 8.0) (Elevation of the panel)  
panelStatus         | SlidingUpPanelStatus (default SlidingUpPanelStatus.collapsed) (Panel status)  
anchor              | double (default 0.5) (The fraction of anchor position, which is from 0 to 1.0)
onTap               | VoidCallback (default is a build-in callback) (Void callback when click control bar)
enableOnTap         | bool (Not Null)(default is true) (Enable or disable the tap callback for control bar) 
dragDown            | OnSlidingUpPanelDragDown (default is null) (Drag down listener) 
dragStart           | OnSlidingUpPanelDragStart (default is null) (Drag start listener) 
dragUpdate          | OnSlidingUpPanelDragUpdate (default is null) (Drag update listener) 
dragCancel          | OnSlidingUpPanelDragCancel (default is null) (Drag cancel listener) 
dragEnd             | OnSlidingUpPanelDragEnd (default is null) (Drag end listener) 

## Example
[example](https://github.com/JackJonson/flutter_sliding_up_panel/blob/master/example/lib/main.dart)



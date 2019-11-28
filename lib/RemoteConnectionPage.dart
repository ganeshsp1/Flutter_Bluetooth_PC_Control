import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:control_pad/control_pad.dart';
import 'package:holding_gesture/holding_gesture.dart';
import 'package:sensors/sensors.dart';
import 'package:vibration/vibration.dart';
import 'dart:convert';

class RemoteConnectionPage extends StatefulWidget {
  final BluetoothDevice server;

  const RemoteConnectionPage({this.server});

  @override
  _RemoteConnectionPageState createState() => new _RemoteConnectionPageState();
}

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class _RemoteConnectionPageState extends State<RemoteConnectionPage> {
  static final clientID = 0;
  static final maxMessageLength = 4096 - 3;

  StreamSubscription<Uint8List> _streamSubscription;

  List<_Message> messages = List<_Message>();
  String _messageBuffer = '';

  final TextEditingController textEditingController =
      new TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  bool isConnecting = true;
  // bool get isConnected => _streamSubscription != null;
  bool isConnected = false;
  bool doubleTapped = false;
  bool _condition = true;
  bool _isJoystick = false;
  double dx = 0.0;
  double dy = 0.0;

  bool isGyroOn = false;

  bool _onHold = false;
  @override
  void initState() {
    super.initState();

    accelerometerEvents.listen((event) {
      //use the below one if you don't want gyro to be on without holding the touch pad
      // if (isGyroOn && _onHold) {
       if (isGyroOn) {
        // print(event);
        _sendMessage('*#*Offset(${event.x * -1}, ${event.y * -1})*@*');
      }
    });
    if (widget.server.isConnected) {
      isConnected = true;
      isConnecting = false;
    }
    // gyroscopeEvents.listen((event) {
    //   if (isOn) {
    // print(event);
    // _sendMessage('*#*Offset(${event.x*100}, ${event.y*100})*@*');
    //   }
    // });
    // RawKeyboard.instance
    //     .addListener((rawKeyEvent) => handleKeyListener(rawKeyEvent));

    connectToBluetooth();
  }

  // handleKeyListener(RawKeyEvent rawKeyEvent) {
  //   // print("Event runtimeType is ${rawKeyEvent.runtimeType}");
  //   if (rawKeyEvent.runtimeType.toString() == 'RawKeyDownEvent') {
  //     print('***********************************' +
  //         rawKeyEvent.physicalKey.debugName);
  //     RawKeyEventDataAndroid data = rawKeyEvent.data as RawKeyEventDataAndroid;
  //     String _keyCode;
  //     _keyCode = data.keyCode.toString();
  //   }
  // }

  BluetoothConnection _bluetoothConnection;
  connectToBluetooth() async {
    if (!isConnected) {
      _bluetoothConnection =
          await BluetoothConnection.toAddress(widget.server.address);

      isConnecting = false;
      this._bluetoothConnection = _bluetoothConnection;
      // Subscribe for incoming data after connecting
      _streamSubscription = _bluetoothConnection.input.listen(_onDataReceived);
      setState(() {
        isConnected = true;
        /* Update for `isConnecting`, since depends on `_streamSubscription` */
      });

      // Subscribe for remote disconnection
      _streamSubscription.onDone(() {
        print('we got disconnected by remote!');
        _streamSubscription = null;
        setState(() {
          isConnected = false;
          /* Update for `isConnected`, since is depends on `_streamSubscription` */
        });
      });
    }
    // BluetoothConnection.toAddress(widget.server.address)
    //     .then((_bluetoothConnection) {
    //   // @TODO ? shouldn't be done via `.listen()`?

    // });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      _streamSubscription.cancel();
      print('we are disconnecting locally!');
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Row> list = messages.map((_message) {
      return Row(
        children: <Widget>[
          Container(
            child: Text(
                (text) {
                  return text == '/shrug' ? '¯\\_(ツ)_/¯' : text;
                }(_message.text.trim()),
                style: TextStyle(color: Colors.white)),
            padding: EdgeInsets.all(12.0),
            margin: EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
            width: 222.0,
            decoration: BoxDecoration(
                color:
                    _message.whom == clientID ? Colors.blueAccent : Colors.grey,
                borderRadius: BorderRadius.circular(7.0)),
          ),
        ],
        mainAxisAlignment: _message.whom == clientID
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
      );
    }).toList();

    return Scaffold(
        appBar: AppBar(
          title: (isConnecting
              ? Text('Connecting to ' + widget.server.name + '...')
              : isConnected
                  ? Text('Connected with ' + widget.server.name)
                  : Text('Disconnected with ' + widget.server.name)),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () => close(),
            ),
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: isConnected ? null : () => connectToBluetooth(),
            ),
          ],
        ),
        body: SafeArea(
            child: Column(children: <Widget>[
          _isJoystick
              ? Container(
                  color: Colors.white,
                  child: JoystickView(
                    interval: Duration(
                      milliseconds: 50,
                    ),
                    onDirectionChanged: (degrees, distance) =>
                        directionChanged(degrees, distance),
                  ),
                )
              : Flexible(
                  child: Row(
                    children: <Widget>[
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onVerticalDragUpdate: (dragUpdate) => zoom(dragUpdate),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 8.0),
                          child: Container(
                            width: MediaQuery.of(context).size.width * (1 / 6),
                            height: MediaQuery.of(context).size.height - 40,
                            // color: Colors.red,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                HoldDetector(
                                  onHold: () => zoom(DragUpdateDetails(
                                      delta: Offset(0.0, -1.0),
                                      globalPosition: null)),
                                  holdTimeout: Duration(milliseconds: 200),
                                  enableHapticFeedback: true,
                                  child: IconButton(
                                    onPressed: () => zoom(DragUpdateDetails(
                                        delta: Offset(0.0, -1.0),
                                        globalPosition: null)),
                                    icon: Icon(
                                      Icons.zoom_in,
                                      color: Colors.white,
                                    ),
                                    iconSize: 50,
                                  ),
                                ),
                                HoldDetector(
                                  onHold: () => zoom(DragUpdateDetails(
                                      delta: Offset(0.0, 1.0),
                                      globalPosition: null)),
                                  holdTimeout: Duration(milliseconds: 200),
                                  enableHapticFeedback: true,
                                  child: IconButton(
                                    onPressed: () => zoom(DragUpdateDetails(
                                        delta: Offset(0.0, 1.0),
                                        globalPosition: null)),
                                    icon: Icon(
                                      Icons.zoom_out,
                                      color: Colors.white,
                                    ),
                                    iconSize: 50,
                                  ),
                                ),
                              ],
                            ),
                            // Align(
                            //   alignment: Alignment.center,
                            //   child: RotatedBox(
                            //     quarterTurns: 3,
                            //     child: Text(
                            //       'ZOOM',
                            //       style: TextStyle(
                            //         color: Colors.white,
                            //         fontSize: 50,
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              gradient: LinearGradient(
                                begin: Alignment.bottomRight,
                                end: Alignment.topLeft,
                                stops: [0.1, 0.5, 0.7, 0.9],
                                colors: [
                                  Color.fromARGB(255, 238, 112, 2),
                                  Color.fromARGB(220, 238, 112, 2),
                                  Color.fromARGB(200, 238, 112, 2),
                                  Color.fromARGB(150, 238, 112, 2),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      isGyroOn
                          ? HoldDetector(
                              onHold: () => setState(() {
                                _onHold = true;
                              }),
                              onCancel: () => setState(() {
                                _onHold = false;
                              }),
                              onTap: () => leftClickMouse(),
                              holdTimeout: Duration(milliseconds: 200),
                              enableHapticFeedback: true,
                              child: TouchArea(
                                dx: dx,
                                dy: dy,
                              ),
                            )
                          : GestureDetector(
                              //To Do - Add scrolling gesture detector
                              // onLongPressStart: (tap) => {
                              //   print('onLongPressStart'),
                              // },
                              // onLongPressEnd: (tap) => {
                              //   print('onLongPressEnd'),
                              // },
                              // onLongPressMoveUpdate: (tap) => {
                              //   print('onLongPressEnd'),
                              // },
                              // onSecondaryTapUp: (tap) => {
                              //   print('onSecondaryTapUp'),
                              // },
                              // onSecondaryTapCancel: () => {
                              //   print('onSecondaryTapCancel'),
                              // },
                              // onForcePressStart: (tap) => {
                              //   print('onForcePressStart'),
                              // },
                              // onTapUp: (tap) => {
                              //   print('onTapUp'),
                              // },
                              // onTapCancel: () async => {
                              //   print('onTapCancel'),
                              //   if (await Vibration.hasVibrator())
                              //     {
                              //       Vibration.vibrate(duration: 100),
                              //     }
                              // },
                              // onTapDown: (tap) => {
                              //   print('onTapDown'),
                              //   if (!_dragEnabled)
                              //     {
                              //       _leftClick = true,
                              //       // _sendMessage("*#*LC*@*"),
                              //       // Timer(Duration(seconds: 1), () {
                              //       //   _leftClick = _dragEnabled;
                              //       // }),
                              //     }
                              // },
                              behavior: HitTestBehavior.translucent,
                              onTap: () => leftClickMouse(),
                              onDoubleTap: () => {
                                doubleTapped = true,
                                print('Double Tapped'),
                              },
                              // onPanUpdate: (dragUpdate) => onPan(dragUpdate),
                              onScaleUpdate: _condition
                                  ? (dragUpdate) => onScale(dragUpdate)
                                  : null,
                              onScaleEnd: (scaleEndDetails) => onScaleEnd(),
                              child: TouchArea(
                                dx: dx,
                                dy: dy,
                              ),
                            ),
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onVerticalDragUpdate: (dragUpdate) =>
                            scroll(dragUpdate),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 8.0),
                          child: Container(
                            width:
                                MediaQuery.of(context).size.width * (1 / 6) - 2,
                            height: MediaQuery.of(context).size.height - 40,
                            // color: Colors.deepPurpleAccent,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                HoldDetector(
                                  onHold: () => scroll(DragUpdateDetails(
                                      delta: Offset(0.0, -1.0),
                                      globalPosition: null)),
                                  holdTimeout: Duration(milliseconds: 200),
                                  enableHapticFeedback: true,
                                  child: IconButton(
                                    onPressed: () => scroll(DragUpdateDetails(
                                        delta: Offset(0.0, -1.0),
                                        globalPosition: null)),
                                    icon: Icon(
                                      Icons.arrow_drop_up,
                                      color: Colors.white,
                                    ),
                                    iconSize: 50,
                                  ),
                                ),
                                HoldDetector(
                                  onHold: () => scroll(DragUpdateDetails(
                                      delta: Offset(0.0, 1.0),
                                      globalPosition: null)),
                                  holdTimeout: Duration(milliseconds: 200),
                                  enableHapticFeedback: true,
                                  child: IconButton(
                                    onPressed: () => scroll(DragUpdateDetails(
                                        delta: Offset(0.0, 1.0),
                                        globalPosition: null)),
                                    icon: Icon(
                                      Icons.arrow_drop_down,
                                      color: Colors.white,
                                    ),
                                    iconSize: 50,
                                  ),
                                ),
                              ],
                            ), // child: Align(
                            //   alignment: Alignment.center,
                            //   child: RotatedBox(
                            //     quarterTurns: 3,
                            //     child: Text(
                            //       'SCROLL',
                            //       style: TextStyle(
                            //         color: Colors.white,
                            //         fontSize: 50,
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              gradient: LinearGradient(
                                begin: Alignment.bottomRight,
                                end: Alignment.topLeft,
                                stops: [0.1, 0.5, 0.7, 0.9],
                                colors: [
                                  Color.fromARGB(255, 238, 112, 2),
                                  Color.fromARGB(220, 238, 112, 2),
                                  Color.fromARGB(200, 238, 112, 2),
                                  Color.fromARGB(150, 238, 112, 2),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

          // Flexible(
          //   child: ListView(
          //     padding: const EdgeInsets.all(12.0),
          //     controller: listScrollController,
          //     children: list
          //   )
          // ),
          Row(
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.computer),
                iconSize: (MediaQuery.of(context).size.width / 5) - 16,
                onPressed: isConnected ? () => present() : null,
                tooltip: 'Present from beginning',
              ),
              IconButton(
                icon: const Icon(Icons.desktop_windows),
                iconSize: (MediaQuery.of(context).size.width / 5) - 16,
                onPressed: isConnected ? () => presentCurrent() : null,
                tooltip: 'Present from current slide',
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left),
                iconSize: (MediaQuery.of(context).size.width / 5) - 16,
                onPressed: isConnected ? () => goLeft() : null,
                tooltip: 'Next slide',
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                iconSize: (MediaQuery.of(context).size.width / 5) - 16,
                onPressed: isConnected ? () => goRight() : null,
                tooltip: 'Previous slide',
              ),
              IconButton(
                icon: const Icon(Icons.close),
                iconSize: (MediaQuery.of(context).size.width / 5) - 16,
                onPressed: isConnected ? () => exit() : null,
                tooltip: 'Close',
              ),
            ],
          ),
          // Row(
          //   children: <Widget>[
          //     SwitchListTile(
          //         onChanged: (isOn) => accelerometerControl(isOn), value: false)
          //   ],
          // ),

          SwitchListTile(
              title: Text('Gyro'),
              onChanged: (isOn) => accelerometerControl(isOn),
              value: isGyroOn),
          Row(children: <Widget>[
            Flexible(
                child: Container(
                    margin: const EdgeInsets.only(left: 16.0),
                    child: TextField(
                      style: const TextStyle(fontSize: 15.0),
                      controller: textEditingController,
                      decoration: InputDecoration.collapsed(
                        hintText: (isConnecting
                            ? 'Wait until connected...'
                            : isConnected
                                ? 'Type on PC...'
                                : 'BT got disconnected'),
                        hintStyle: const TextStyle(color: Colors.grey),
                      ),
                      enabled: isConnected,
                    ))),
            Container(
              margin: const EdgeInsets.all(8.0),
              child: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: isConnected
                      ? () => _sendStringToType(textEditingController.text)
                      : null),
            ),
          ])
        ])));
  }

  void close() {
    if (isConnected) {
      _streamSubscription = null;
      _bluetoothConnection.finish();
      setState(() {
        isConnected = false;
        /* Update for `isConnected`, since is depends on `_streamSubscription` */
      });
      // FlutterBluetoothSerial.instance.disconnect();
      // _streamSubscription.cancel();
      // _streamSubscription = null;
      print('we are disconnecting locally!');
      // isConnected = false;
      // setState(() {});
    }
  }

  void present() {
    _sendMessage("*#*F5*@*");
  }

  void exit() {
    _sendMessage("*#*esc*@*");
  }

  void presentCurrent() {
    _sendMessage("*#*SHIFT+F5*@*");
  }

  void goRight() {
    _sendMessage("*#*RIGHT*@*");
  }

  void goLeft() {
    _sendMessage("*#*LEFT*@*");
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    if (~index != 0) {
      // \r\n
      setState(() {
        messages.add(_Message(
            1,
            backspacesCounter > 0
                ? _messageBuffer.substring(
                    0, _messageBuffer.length - backspacesCounter)
                : _messageBuffer + dataString.substring(0, index)));
        _messageBuffer = dataString.substring(index);
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
  }

  void _sendMessage(String text) {
    if (text != null) {
      text = text.trim();
      if (text.length > 0) {
        textEditingController.clear();
        _bluetoothConnection.output.add(ascii.encode(text + "\r\n"));
      }
    }
  }

  directionChanged(double degrees, double distance) {
    print(degrees.toString() + " " + distance.toString());
    _sendMessage(
        "*#*JOYSTICK" + degrees.toString() + " " + distance.toString() + "*@*");
  }

  bool _leftClick = false;
  bool _dragEnabled = false;
  leftClickMouse() {
    print("Left Click");
    _sendMessage("*#*LC*@*");
  }

  onPan(DragUpdateDetails dragUpdate) {
    // dragUpdate.delta
    print("Cordinates:${dragUpdate.delta}");
    // _sendMessage("*#*LC*@*");
  }

  scroll(DragUpdateDetails dragUpdate) {
    _sendMessage("*#*SCROLL${dragUpdate.delta.dy.toString()}*@*");
    print(dragUpdate);
  }

  zoom(DragUpdateDetails dragUpdate) {
    _sendMessage("*#*ZOOM${dragUpdate.delta.dy.toString()}*@*");
    print(dragUpdate);
  }

  onScale(ScaleUpdateDetails dragUpdate) {
    setState(() => _condition = false);
    if (dragUpdate.scale != 1) {
      if (prevScale == 0) {
        prevScale = dragUpdate.scale;
        setState(() => _condition = true);
        return;
      }
      print("${dragUpdate.scale - prevScale}");
      _sendMessage("*#*ZOOM${dragUpdate.scale - prevScale}*@*");
      prevScale = dragUpdate.scale;
      setState(() => _condition = true);
      return;
    }
    if (prevFocalPoint == null) {
      prevFocalPoint = dragUpdate.focalPoint;
      setState(() => _condition = true);
      return;
    }
    // dragUpdate.delta
    // print("Scale Cordinates:${dragUpdate.scale}+${dragUpdate.rotation}+${dragUpdate.focalPoint.toString()}");

    double halfWidth = (MediaQuery.of(context).size.width) / 2;
    double halfHeight = (MediaQuery.of(context).size.height) / 2;
    setState(() => {
          dx = (dragUpdate.focalPoint.dx - halfWidth) / halfWidth,
          dy = (dragUpdate.focalPoint.dy - halfHeight) / halfHeight,
        });
    // print((dragUpdate.focalPoint - prevFocalPoint).toString());
    _dragEnabled = _leftClick;
    _sendMessage(
        "*#*${(_leftClick ? 'DRAG' : '') + (dragUpdate.focalPoint - prevFocalPoint).toString()}*@*");
    prevFocalPoint = dragUpdate.focalPoint;
    setState(() => _condition = true);
  }

  onScaleEnd() {
    _sendMessage(_dragEnabled ? "*#*DRAGENDED*@*" : null);
    _dragEnabled = false;
    _leftClick = false;
    prevFocalPoint = null;
    doubleTapped = false;
    prevScale = 0;
    setState(() {
      dx = 0;
      dy = 0;
    });
  }

  Offset prevFocalPoint;
  double prevScale;

  _sendStringToType(String text) {
    _sendMessage("*#*TYPE$text*@*");
  }

  void accelerometerControl(bool isOn) {
    setState(() {
      this.isGyroOn = isOn;
    });
  }
}

class TouchArea extends StatelessWidget {
  TouchArea({this.dx, this.dy});
  final double dx, dy;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: MediaQuery.of(context).size.width * (4 / 6) - 16,
        height: MediaQuery.of(context).size.height - 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          gradient: SweepGradient(
            center: Alignment(dx, dy),
            tileMode: TileMode.repeated,
            colors: [
              Color.fromARGB(150, 2, 130, 238),
              Color.fromARGB(220, 2, 130, 238),
              Color.fromARGB(255, 2, 130, 238),
              Color.fromARGB(220, 2, 130, 238),
              Color.fromARGB(150, 2, 130, 238),
            ],
          ),
        ),
      ),
    );
  }
}

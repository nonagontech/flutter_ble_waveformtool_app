import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math';
import '../../common/utils/utils.dart';

import '../common/style/color.dart';
import '../common/components/radar/radar.dart';
import '../common/utils/storage.dart';
import '../common/value/server.dart';
import '../common/utils/ble.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// @file  add_ble_device
/// @author https://aiflutter.com/
/// @description 整个页面的布局可以是垂直分区的，上半部分是设备扫描区，下半部分是设备列表区。
/// @createDate 2025-04-25 13:32:05
class AddBleDevice extends StatefulWidget {
  const AddBleDevice({super.key});

  @override
  State<AddBleDevice> createState() => _AddBleDeviceState();
}

class _AddBleDeviceState extends State<AddBleDevice>
    with TickerProviderStateMixin {
  List devices = [];
  bool scaning = false; // 是否正在扫描
  var _connectionSubscription;
  bool isConnected = false;
  var connectStatus = BluetoothConnectionState.disconnected;
  List deviceList = [];
  var _sacnSubscription;
  AnimationController? waterRippleController;
  AnimationController? radarViewController;
  Ble ble = Ble();

  @override
  void initState() {
    super.initState();
    _initAction();
  }

  @override
  void dispose() {
    _closeAction();

    super.dispose();
  }

  void _initAction() async {
    customCode2();
  }

  void _closeAction() async {
    customCode3();
  }

  // Custom Code: customCode
  customCode1() {
    Get.toNamed("/SetBleName");
  }

// Custom Code: 设备列表初始化
  customCode2() {
    waterRippleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    radarViewController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    ble.onScanResults(callbackLast: (event) {
      String name = event.advertisementData.advName;
      String DEVICE_NAME = StorageUtil().read('DEVICE_NAME') ?? '';

      if ((DEVICE_NAME.isNotEmpty &&
              (name == '' || !name.contains(DEVICE_NAME))) ||
          devices.contains(event)) {
        return;
      }

      Map<int, List<int>> manufacturerData =
          event.advertisementData.manufacturerData;
      List<int> manufacturerDataArr = [];
      manufacturerData.forEach((key, value) {
        String data16 = key.toRadixString(16);
        while (data16.length < 4) {
          data16 = "0$data16";
        }
        int two = int.parse(data16.substring(0, 2), radix: 16);
        int one = int.parse(data16.substring(2, 4), radix: 16);

        manufacturerDataArr.add(one);
        manufacturerDataArr.add(two);
        manufacturerDataArr.addAll(value);
      });
      String mac = "";
      if (manufacturerDataArr.length > 7) {
        for (int i = 2; i < 8; i++) {
          String str = manufacturerDataArr[i].toRadixString(16);
          if (str.length < 2) {
            str = "0$str";
          }
          if (i == 7) {
            mac += str;
          } else {
            mac += "$str:";
          }
        }
      }
      print("广播内容:${mac}");
      devices.add(event);
      if (mounted) {
        setState(() {
          deviceList.add({
            "name": event.device.platformName,
            "rssi": event.rssi,
            "mac": mac,
            "raw": event
          });
        });
      }
    });
    _connectionSubscription?.cancel();
    _connectionSubscription = ble.connectController.stream.listen((event) {
      if (event is BluetoothConnectionState) {
        if (mounted) {
          setState(() {
            connectStatus = event;
            switch (event) {
              case BluetoothConnectionState.connected:
                isConnected = true;
                break;
              case BluetoothConnectionState.disconnected:
                Timer(const Duration(milliseconds: 400), () {
                  if (connectStatus == BluetoothConnectionState.disconnected) {
                    //400毫秒后还是未连接才代表断开了连接
                    isConnected = false;
                  }
                });

                break;
              default:
            }
          });
        }
      }
    });
    _sacnSubscription?.cancel();
    ble.isScaning((event) {
      if (mounted) {
        setState(() {
          scaning = event;
        });
        if (event) {
          waterRippleController?.repeat();
          radarViewController?.repeat();
        } else {
          waterRippleController?.stop();
          radarViewController?.stop();
        }
      }
    });
    ble.status(timeout: const Duration(seconds: 8));
  }

// Custom Code: 销毁处理
  customCode3() {
    _sacnSubscription?.cancel();
    _connectionSubscription?.cancel();
    // waterRippleController.dispose();
    // radarViewController.dispose();

    //这里做了返回就断开连接
    if (isConnected) {
      ble.disconnect();
    }
  }

// Custom Code: 重新扫描
  customCode4() async {
    EasyLoading.dismiss();
    if (mounted) {
      await ble.disconnect();
      setState(() {
        devices.clear();
        deviceList.clear();
      });
      ble.status(timeout: const Duration(seconds: 8));
    }
  }

// Custom Code: 蓝牙连接
  customCode5(index) {
    if (scaning) {
      ble.stopScan();
    }
    EasyLoading.show();
    ble.connect(deviceList[index]['raw'].device,
        serviceUUID: StorageUtil().read("serviceUUID") ?? '',
        readCharacteristicUUID:
            StorageUtil().read("readCharacteristicUUID") ?? '',
        writeCharacteristicUUID:
            StorageUtil().read("writeCharacteristicUUID") ?? '',
        notifyCallBcak: () async {
      // EasyLoading.showSuccess("添加成功".tr);
      Map<String, dynamic> json = {
        "name": deviceList[index]['name'],
        "mac": deviceList[index]['mac']
      };
      EasyLoading.dismiss();
      await Get.toNamed('/DeviceNetWork', arguments: json);
      ble.disconnect();
    });
  }

  @override
  Widget build(BuildContext context) {
    // 获取当前主题的亮度
    Brightness brightness = Theme.of(context).brightness;
    bool isDark = brightness == Brightness.dark;

    return SafeArea(
      child: Scaffold(
        floatingActionButton: null,
        drawer: null,
        endDrawer: null,
        appBar: AppBar(
          backgroundColor: Color(4278218751),
          title: Text(
            "蓝牙连接".tr,
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18,
              decoration: TextDecoration.none,
              fontWeight: FontWeight.w500,
              color: Color(4294967295),
              height: null,
              fontStyle: FontStyle.normal,
            ),
          ),
          actions: [
            Container(
              margin: EdgeInsets.zero,
              width: 40,
              height: 40,
              child: ElevatedButton(
                onPressed: () async {
                  customCode1();
                },
                style: ButtonStyle(
                  minimumSize: WidgetStateProperty.all(Size.zero),
                  backgroundColor: WidgetStateProperty.all(Color(13158600)),
                  padding: WidgetStateProperty.all(
                      EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0)),
                  elevation: WidgetStateProperty.all(0),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(),
                  ),
                  side: WidgetStateProperty.all(BorderSide.none),
                ),
                child: Container(
                  padding: EdgeInsets.zero,
                  margin: EdgeInsets.zero,
                  child: Icon(IconData(58751, fontFamily: 'MaterialIcons'),
                      size: 24, color: Color(4294967295)),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isDark
            ? DarkAppColor.primaryBackground
            : AppColor.primaryBackground,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          verticalDirection: VerticalDirection.down,
          children: [
            Container(
              clipBehavior: Clip.none,
              width: double.infinity,
              height: 750,
              alignment: Alignment(-1, -1),
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.zero,
              decoration: BoxDecoration(
                color: Color(13158600),
                gradient: null,
                border: Border.all(
                  color: Colors.black,
                  width: 0,
                  style: BorderStyle.none,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                verticalDirection: VerticalDirection.down,
                children: [
                  Container(
                    width: 320,
                    height: 320,
                    child: Stack(children: [
                      RadarPage(
                          width: double.infinity,
                          waterRippleColor: Color(484895980),
                          radarViewColor: Color(4278208397),
                          count: 3,
                          radar: true,
                          isFill: true,
                          waterRippleController: waterRippleController,
                          radarViewController: radarViewController,
                          gradient: RadialGradient(
                              colors: [Color(2017524400), Color(4294967295)],
                              stops: [0, 1],
                              radius: 0.5,
                              center: Alignment.center)),
                      RadarPoint(
                        onTap: (data) async {},
                        devices: deviceList,
                        size: 15,
                        pointColor: Color(4282070455),
                      ),
                    ]),
                  ),
                  Container(
                    clipBehavior: Clip.none,
                    width: double.infinity,
                    height: 40,
                    alignment: Alignment(0, 0),
                    padding: EdgeInsets.zero,
                    margin: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      color: Color(13158600),
                      gradient: null,
                      border: Border.all(
                        color: Colors.black,
                        width: 0,
                        style: BorderStyle.none,
                      ),
                    ),
                    child: Builder(builder: (context) {
                      if (scaning == false) {
                        return Visibility(
                          child: Container(
                            margin: EdgeInsets.zero,
                            width: 120,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () async {
                                customCode4();
                              },
                              style: ButtonStyle(
                                minimumSize: WidgetStateProperty.all(Size.zero),
                                backgroundColor:
                                    WidgetStateProperty.all(Color(13158600)),
                                padding: WidgetStateProperty.all(
                                    EdgeInsets.only(
                                        left: 0, right: 0, top: 0, bottom: 0)),
                                elevation: WidgetStateProperty.all(0),
                                shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(),
                                ),
                                side: WidgetStateProperty.all(BorderSide.none),
                              ),
                              child: Text(
                                "重新扫描".tr,
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 18,
                                  decoration: TextDecoration.none,
                                  fontWeight: FontWeight.w500,
                                  color: Color(4278218751),
                                  height: null,
                                  fontStyle: FontStyle.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      } else {
                        return Visibility(
                          child: Text(
                            "正在扫描".tr,
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 18,
                              decoration: TextDecoration.none,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? DarkAppColor.primaryText
                                  : AppColor.primaryText,
                              height: null,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                        );
                      }
                    }),
                  ), //Container
                  RawScrollbar(
                    thickness: 4,
                    thumbVisibility: false,
                    trackVisibility: false,
                    radius: Radius.circular(12),
                    child: SizedBox(
                      width: double.infinity,
                      height: 350,
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        reverse: false,
                        shrinkWrap: false,
                        padding: EdgeInsets.zero,
                        itemCount: deviceList.length,
                        itemBuilder: (context, index) => Container(
                          clipBehavior: Clip.none,
                          width: double.infinity,
                          height: 80,
                          alignment: Alignment(-1, -1),
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.only(
                            top: 10,
                            right: 0,
                            bottom: 10,
                            left: 0,
                          ),
                          decoration: BoxDecoration(
                            color: Color(4294967295),
                            gradient: null,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.black,
                              width: 0,
                              style: BorderStyle.none,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            verticalDirection: VerticalDirection.down,
                            children: [
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                verticalDirection: VerticalDirection.down,
                                children: [
                                  Container(
                                    clipBehavior: Clip.none,
                                    width: 120,
                                    height: 20,
                                    alignment: Alignment(-1, -1),
                                    padding: EdgeInsets.zero,
                                    margin: EdgeInsets.zero,
                                    decoration: BoxDecoration(
                                      color: Color(13158600),
                                      gradient: null,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 0,
                                        style: BorderStyle.none,
                                      ),
                                    ),
                                    child: Text(
                                      "${deviceList[index]["name"] == '' ? '未知' : deviceList[index]["name"]}",
                                      textAlign: TextAlign.left,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 16,
                                        decoration: TextDecoration.none,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? DarkAppColor.primaryText
                                            : AppColor.primaryText,
                                        height: null,
                                        fontStyle: FontStyle.normal,
                                      ),
                                    ),
                                  ), //Container
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    verticalDirection: VerticalDirection.down,
                                    children: [
                                      Container(
                                        clipBehavior: Clip.none,
                                        width: 180,
                                        height: 20,
                                        alignment: Alignment(-1, -1),
                                        padding: EdgeInsets.zero,
                                        margin: EdgeInsets.zero,
                                        decoration: BoxDecoration(
                                          color: Color(13158600),
                                          gradient: null,
                                          border: Border.all(
                                            color: Colors.black,
                                            width: 0,
                                            style: BorderStyle.none,
                                          ),
                                        ),
                                        child: Text(
                                          "Mac: ${deviceList[index]['mac']}",
                                          textAlign: TextAlign.left,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 14,
                                            decoration: TextDecoration.none,
                                            fontWeight: FontWeight.w500,
                                            color: Color(4288256409),
                                            height: null,
                                            fontStyle: FontStyle.normal,
                                          ),
                                        ),
                                      ), //Container
                                      Container(
                                        clipBehavior: Clip.none,
                                        width: 80,
                                        height: 20,
                                        alignment: Alignment(-1, -1),
                                        padding: EdgeInsets.zero,
                                        margin: EdgeInsets.zero,
                                        decoration: BoxDecoration(
                                          color: Color(13158600),
                                          gradient: null,
                                          border: Border.all(
                                            color: Colors.black,
                                            width: 0,
                                            style: BorderStyle.none,
                                          ),
                                        ),
                                        child: Text(
                                          "RSSI: ${deviceList[index]["rssi"]}",
                                          textAlign: TextAlign.left,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 14,
                                            decoration: TextDecoration.none,
                                            fontWeight: FontWeight.w500,
                                            color: Color(4288256409),
                                            height: null,
                                            fontStyle: FontStyle.normal,
                                          ),
                                        ),
                                      ), //Container
                                    ],
                                  ), //Row
                                ],
                              ), //Column
                              Container(
                                margin: EdgeInsets.zero,
                                width: 60,
                                height: 40,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    customCode5(index);
                                  },
                                  style: ButtonStyle(
                                    minimumSize:
                                        WidgetStateProperty.all(Size.zero),
                                    backgroundColor: WidgetStateProperty.all(
                                        Color(13158600)),
                                    padding: WidgetStateProperty.all(
                                        EdgeInsets.only(
                                            left: 0,
                                            right: 0,
                                            top: 0,
                                            bottom: 0)),
                                    elevation: WidgetStateProperty.all(0),
                                    shape: WidgetStateProperty.all(
                                      RoundedRectangleBorder(),
                                    ),
                                    side: WidgetStateProperty.all(
                                        BorderSide.none),
                                  ),
                                  child: Text(
                                    "连接".tr,
                                    textAlign: TextAlign.left,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      decoration: TextDecoration.none,
                                      fontWeight: FontWeight.w500,
                                      color: Color(4278218751),
                                      height: null,
                                      fontStyle: FontStyle.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ), //Row
                        ), //Container
                      ),
                    ),
                  ),
                ],
              ), //Column
            ), //Container
          ],
        ), //Column
      ),
    );
  }
}

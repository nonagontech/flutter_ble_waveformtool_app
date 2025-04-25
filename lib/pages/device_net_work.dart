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
import 'package:flutter/services.dart';
import 'data_visualization.dart';
import 'package:intl/intl.dart';
import '../common/utils/storage.dart';
import '../common/value/server.dart';
import '../common/utils/ble.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// @file  device_net_work
/// @author https://aiflutter.com/
/// @description 整个页面的布局可以是垂直分区的，上半部分是数据接收区，下半部分是数据发送区。
/// @createDate 2025-04-25 13:32:05
class DeviceNetWork extends StatefulWidget {
  const DeviceNetWork({super.key});

  @override
  State<DeviceNetWork> createState() => _DeviceNetWorkState();
}

class _DeviceNetWorkState extends State<DeviceNetWork> {
  var _connectionSubscription;
  var _getData;
  var connectStatus = BluetoothConnectionState.disconnected;
  var timer;
  var disconnectTimer;
  String wifiname = "";
  bool isScanding = false;
  bool isConnected = true;
  List password = [];
  var wifinameController = TextEditingController();
  Ble ble = Ble();

  @override
  void initState() {
    super.initState();
    _initAction();
    wifinameController.text = wifiname;
  }

  @override
  void dispose() {
    _closeAction();

    super.dispose();
  }

  void _initAction() async {
    customCode1();
  }

  void _closeAction() async {
    customCode2();
  }

  // Custom Code: 页面初始化操作
  customCode1() {
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
                disconnectTimer?.cancel();
                disconnectTimer = Timer(const Duration(milliseconds: 400), () {
                  if (connectStatus == BluetoothConnectionState.disconnected) {
                    //400毫秒后还是未连接才代表断开了连接,回到以前的界面
                    print("400毫秒后还是未连接才代表断开了连接,回到以前的界面");
                    EasyLoading.showError("设备断开了连接");

                    Get.offNamed('/');
                  }
                });

                break;

              default:
            }
          });
        }
      }
    });

    _getData?.cancel();
    _getData = ble.getBleDateController.stream.listen((event) {
      if (event is List<int> && event.length != 0) {
        List<int> newArr = event;
        print("蓝牙发送过来的数据_netWork:$newArr");
        List<String> dataArr = [];
        for (var i = 0; i < newArr.length; i++) {
          var element = newArr[i];
          String str = '';
          str = element.toRadixString(16);
          str = str.length == 1 ? "0$str" : str;
          dataArr.add(str);
        }
        password.add({
          "type": "接收",
          "data": dataArr.join(),
          "time": DateFormat("HH:mm:ss").format(DateTime.now()),
        });
        setState(() {});
      }
    }); // todo
    setState(() {
      isScanding = true;
    });
  }

// Custom Code: 页面销毁
  customCode2() {
    disconnectTimer?.cancel();
    _connectionSubscription?.cancel();
    _getData?.cancel();
    timer?.cancel();
  }

// Custom Code: 设置WIFI
  customCode3() async {
    int nameIndex = -1;
    if (wifiname == null) {
      EasyLoading.showError("请输入数据".tr);
      return;
    }

    List<int> intArray = [];
    for (int i = 0; i < wifiname.length; i += 2) {
      String hexPair = wifiname.substring(i, i + 2);
      intArray.add(int.parse(hexPair, radix: 16));
    }
    password.add({
      "type": "发送",
      "data": wifiname,
      "time": DateFormat("HH:mm:ss").format(DateTime.now()),
    });
    setState(() {});
    await ble.writeWithOut(intArray);
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
            "数据收发".tr,
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
                  Get.to(const DataVisualization(),
                      transition: Transition.native,
                      duration: const Duration(milliseconds: 0));
                },
                style: ButtonStyle(
                  minimumSize: WidgetStateProperty.all(Size.zero),
                  backgroundColor: WidgetStateProperty.all(Color(16579836)),
                  padding: WidgetStateProperty.all(
                      EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0)),
                  elevation: WidgetStateProperty.all(0),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(),
                  ),
                  side: WidgetStateProperty.all(BorderSide.none),
                ),
                child: Container(
                  width: 30,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/statistic.png"),
                      fit: BoxFit.scaleDown,
                      alignment: Alignment(0, 0),
                    ),
                    color: Colors.transparent,
                    border: Border.all(
                      color: Colors.black,
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isDark
            ? DarkAppColor.primaryBackground
            : AppColor.primaryBackground,
        body: SingleChildScrollView(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              hideKeyboard(context);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              verticalDirection: VerticalDirection.down,
              children: [
                Container(
                  clipBehavior: Clip.none,
                  width: double.infinity,
                  height: 700,
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
                        clipBehavior: Clip.none,
                        width: double.infinity,
                        height: 30,
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
                          "连接状态: ${isConnected ? '已连接' : '未连接'}",
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            decoration: TextDecoration.none,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? DarkAppColor.primaryText
                                : AppColor.primaryText,
                            height: null,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                      ), //Container
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        verticalDirection: VerticalDirection.down,
                        children: [
                          Container(
                            clipBehavior: Clip.none,
                            width: double.infinity,
                            height: 40,
                            alignment: Alignment(-1, 0),
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
                              "数据收发内容".tr,
                              textAlign: TextAlign.left,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                decoration: TextDecoration.none,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? DarkAppColor.primaryText
                                    : AppColor.primaryText,
                                height: null,
                                fontStyle: FontStyle.normal,
                              ),
                            ),
                          ), //Container
                          Container(
                            clipBehavior: Clip.none,
                            width: double.infinity,
                            height: 300,
                            alignment: Alignment(-1, -1),
                            padding: EdgeInsets.zero,
                            margin: EdgeInsets.zero,
                            decoration: BoxDecoration(
                              color: Color(13158600),
                              gradient: null,
                              border: Border.all(
                                color: Color(4278190080),
                                width: 1,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              height: double.infinity,
                              child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                reverse: false,
                                shrinkWrap: false,
                                padding: EdgeInsets.zero,
                                itemCount: password.length,
                                itemBuilder: (context, index) => Text(
                                  "${password[index]['time']}${password[index]['type']}: ${password[index]['data']}",
                                  textAlign: TextAlign.left,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    decoration: TextDecoration.none,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? DarkAppColor.primaryText
                                        : AppColor.primaryText,
                                    height: null,
                                    fontStyle: FontStyle.normal,
                                  ),
                                ),
                              ),
                            ),
                          ), //Container
                          Container(
                            clipBehavior: Clip.none,
                            width: double.infinity,
                            height: 40,
                            alignment: Alignment(-1, 0),
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
                              "发送数据内容".tr,
                              textAlign: TextAlign.left,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                decoration: TextDecoration.none,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? DarkAppColor.primaryText
                                    : AppColor.primaryText,
                                height: null,
                                fontStyle: FontStyle.normal,
                              ),
                            ),
                          ), //Container
                          Container(
                            clipBehavior: Clip.none,
                            width: double.infinity,
                            height: 50,
                            alignment: Alignment(-1, -1),
                            padding: EdgeInsets.zero,
                            margin: EdgeInsets.zero,
                            decoration: BoxDecoration(
                              color: Color(13158600),
                              gradient: null,
                              border: Border(
                                top: BorderSide.none,
                                bottom: BorderSide(
                                  color: Color(4288256409),
                                  width: 1,
                                  style: BorderStyle.solid,
                                ),
                                left: BorderSide.none,
                                right: BorderSide.none,
                              ),
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: TextField(
                                style: TextStyle(
                                  fontSize: 14,
                                  decoration: TextDecoration.none,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? DarkAppColor.primaryText
                                      : AppColor.primaryText,
                                  height: null,
                                  fontStyle: FontStyle.normal,
                                ),
                                decoration: InputDecoration(
                                  hintStyle: TextStyle(
                                    fontSize: 14,
                                    decoration: TextDecoration.none,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? DarkAppColor.primaryText
                                        : AppColor.primaryText,
                                    height: null,
                                    fontStyle: FontStyle.normal,
                                  ),
                                  labelStyle: TextStyle(
                                    fontSize: 14,
                                    decoration: TextDecoration.none,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? DarkAppColor.primaryText
                                        : AppColor.primaryText,
                                    height: null,
                                    fontStyle: FontStyle.normal,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black,
                                          width: 1,
                                          style: BorderStyle.none),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(4.0))),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black,
                                          width: 1,
                                          style: BorderStyle.none),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(4.0))),
                                ),
                                keyboardType: TextInputType.text,
                                maxLength: null,
                                obscureText: false,
                                maxLengthEnforcement: MaxLengthEnforcement.none,
                                cursorColor: Color(4278218751),
                                readOnly: false,
                                controller: wifinameController,
                                onChanged: (p0) {
                                  this.wifiname = p0;
                                  setState(() {});
                                },
                              ),
                            ),
                          ), //Container
                        ],
                      ), //Column
                      Container(
                        clipBehavior: Clip.none,
                        width: double.infinity,
                        height: 30,
                        alignment: Alignment(-1, -1),
                        padding: EdgeInsets.zero,
                        margin: EdgeInsets.zero,
                        decoration: BoxDecoration(
                          color: Color(2960895),
                          gradient: null,
                          border: Border.all(
                            color: Colors.black,
                            width: 0,
                            style: BorderStyle.none,
                          ),
                        ),
                        child: Text(
                          "注意: 数据采用16进制格式发送，例如5aa5".tr,
                          textAlign: TextAlign.left,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            decoration: TextDecoration.none,
                            fontWeight: FontWeight.w500,
                            color: Color(4294901760),
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
                          color: Color(2500096),
                          gradient: null,
                          border: Border.all(
                            color: Colors.black,
                            width: 0,
                            style: BorderStyle.none,
                          ),
                        ),
                        child: Container(),
                      ), //Container
                      Container(
                        margin: EdgeInsets.zero,
                        width: 200,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () async {
                            customCode3();
                          },
                          style: ButtonStyle(
                            minimumSize: WidgetStateProperty.all(Size.zero),
                            backgroundColor:
                                WidgetStateProperty.all(Color(4278218751)),
                            padding: WidgetStateProperty.all(EdgeInsets.only(
                                left: 0, right: 0, top: 0, bottom: 0)),
                            elevation: WidgetStateProperty.all(4),
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            side: WidgetStateProperty.all(BorderSide.none),
                          ),
                          child: Text(
                            "发送数据".tr,
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              decoration: TextDecoration.none,
                              fontWeight: FontWeight.w500,
                              color: Color(4294967295),
                              height: null,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ), //Column
                ), //Container
              ],
            ), //Column
          ),
        ),
      ),
    );
  }
}

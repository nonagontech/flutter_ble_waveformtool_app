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
import '../common/utils/storage.dart';
import '../common/value/server.dart';

/// @file  set_ble_name
/// @author https://aiflutter.com/
/// @description 整个页面的布局可以是垂直分区的，从上到下依次为数据输入区（输入框），输入确认区（按钮）
/// @createDate 2025-04-25 13:32:05
class SetBleName extends StatefulWidget {
  const SetBleName({super.key});

  @override
  State<SetBleName> createState() => _SetBleNameState();
}

class _SetBleNameState extends State<SetBleName> {
  String DEVICE_NAME = "${StorageUtil().read("DEVICE_NAME") ?? ''}";
  String serviceUUID = "${StorageUtil().read("serviceUUID") ?? ''}";
  String readCharacteristicUUID =
      "${StorageUtil().read("readCharacteristicUUID") ?? ''}";
  String writeCharacteristicUUID =
      "${StorageUtil().read("writeCharacteristicUUID") ?? ''}";
  var DEVICE_NAMEController = TextEditingController();
  var serviceUUIDController = TextEditingController();
  var readCharacteristicUUIDController = TextEditingController();
  var writeCharacteristicUUIDController = TextEditingController();

  @override
  void initState() {
    super.initState();
    DEVICE_NAMEController.text = DEVICE_NAME;
    serviceUUIDController.text = serviceUUID;
    readCharacteristicUUIDController.text = readCharacteristicUUID;
    writeCharacteristicUUIDController.text = writeCharacteristicUUID;
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Custom Code: 设置蓝牙名称
  customCode1() {
    StorageUtil().write("DEVICE_NAME", DEVICE_NAME);

    StorageUtil().write("serviceUUID", serviceUUID);
    StorageUtil().write("readCharacteristicUUID", readCharacteristicUUID);
    StorageUtil().write("writeCharacteristicUUID", writeCharacteristicUUID);

    EasyLoading.showSuccess("设置成功");
    Get.back();
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
            "设置".tr,
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
                  height: 600,
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
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        verticalDirection: VerticalDirection.down,
                        children: [
                          Text(
                            "BLE名称".tr,
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
                                controller: DEVICE_NAMEController,
                                onChanged: (p0) {
                                  this.DEVICE_NAME = p0;
                                  setState(() {});
                                },
                              ),
                            ),
                          ), //Container
                          Text(
                            "注意: 输入BLE名称并确认后，蓝牙只会搜索该名称的设备".tr,
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
                          Container(
                            clipBehavior: Clip.none,
                            width: 80,
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
                            child: Container(),
                          ), //Container
                        ],
                      ), //Column
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        verticalDirection: VerticalDirection.down,
                        children: [
                          Text(
                            "服务UUID".tr,
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
                                controller: serviceUUIDController,
                                onChanged: (p0) {
                                  this.serviceUUID = p0;
                                  setState(() {});
                                },
                              ),
                            ),
                          ), //Container
                          Container(
                            clipBehavior: Clip.none,
                            width: 80,
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
                            child: Container(),
                          ), //Container
                        ],
                      ), //Column
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        verticalDirection: VerticalDirection.down,
                        children: [
                          Text(
                            "读特征UUID".tr,
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
                                controller: readCharacteristicUUIDController,
                                onChanged: (p0) {
                                  this.readCharacteristicUUID = p0;
                                  setState(() {});
                                },
                              ),
                            ),
                          ), //Container
                          Container(
                            clipBehavior: Clip.none,
                            width: 80,
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
                            child: Container(),
                          ), //Container
                        ],
                      ), //Column
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        verticalDirection: VerticalDirection.down,
                        children: [
                          Text(
                            "写特征UUID".tr,
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
                                controller: writeCharacteristicUUIDController,
                                onChanged: (p0) {
                                  this.writeCharacteristicUUID = p0;
                                  setState(() {});
                                },
                              ),
                            ),
                          ), //Container
                          Container(
                            clipBehavior: Clip.none,
                            width: 80,
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
                            child: Container(),
                          ), //Container
                        ],
                      ), //Column
                      Container(
                        margin: EdgeInsets.zero,
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () async {
                            customCode1();
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
                            "确认".tr,
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

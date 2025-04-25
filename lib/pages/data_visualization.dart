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
import 'package:fl_chart/fl_chart.dart';
import '../common/routes/pages.dart';
import 'package:path_provider/path_provider.dart';
import 'help.dart';
import '../common/utils/storage.dart';
import '../common/value/server.dart';
import 'package:share_plus/share_plus.dart';
import '../common/utils/ble.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// @file  data_visualization
/// @author https://aiflutter.com/
/// @description 用于展示和分析数据波形。该页面通过对接STAMP协议接收设备数据，并将这些数据以折线图的形式展示给用户。
/// @createDate 2025-04-25 13:53:16
class DataVisualization extends StatefulWidget {
  const DataVisualization({super.key});

  @override
  State<DataVisualization> createState() => _DataVisualizationState();
}

class _DataVisualizationState extends State<DataVisualization> {
  var disconnectTimer;
  List password = [];
  bool scaning = false;
  String data = "";
  List res = [];
  List selectData1 = [];
  var connectStatus = BluetoothConnectionState.disconnected;
  var _connectionSubscription;
  var _getData;
  bool isConnected = true;
  String wifiname = "";
  List selectData2 = [];
  List selectData3 = [];
  List selectData4 = [];
  bool isScanding = false;
  List selectData1X = [];
  List selectData2X = [];
  List selectData3X = [];
  List selectData4X = [];
  List rawData = [];
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

  // Custom Code: 分享文件
  customCode1() async {
    if (rawData.isEmpty) {
      EasyLoading.showInfo("没有数据");
    }

    EasyLoading.show();

    final tempDir = await getTemporaryDirectory();

    String csvFilePath = "${tempDir.path}/data.csv";
    List list = List.from(rawData);
    File(csvFilePath).writeAsStringSync(list.join('\n'));

    EasyLoading.dismiss();
    await Share.shareXFiles([XFile(csvFilePath)], text: "Share file");
  }

// Custom Code: 页面初始化操作
  customCode2() {
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
                    Get.offNamed("/");
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

        String text = String.fromCharCodes(newArr);

        RegExp regExp = RegExp(r'<(.+?)>\{(.+?)\}(.+)');
        // 使用正则表达式进行匹配
        Match? match = regExp.firstMatch(text);

        if (match != null) {
          // 提取匹配的部分
          var value1 = match.group(1)!;
          var value2 = match.group(2)!;
          var value3 = match.group(3)!;

          rawData.add("${value2},${value1},${value3}");

          List data = value3
              .split(",")
              .map((e) => {
                    'x': [double.parse(value1)],
                    'y': [double.tryParse(e) ?? 0]
                  })
              .toList();
          var item = null;
          for (var element in res) {
            if (element["name"] == value2) {
              item = element;
              print("找到了");
              break;
            }
          }

          if (item == null) {
            res.add({
              "name": value2,
              "data": data,
            });
            if (data.length >= 1) {
              selectData1 = data[0]['y'];
              selectData1X = data[0]['x'];
            }

            if (data.length >= 2) {
              selectData2 = data[1]['y'];
              selectData2X = data[1]['x'];
            }

            if (data.length >= 3) {
              selectData3 = data[2]['y'];
              selectData3X = data[2]['x'];
            }

            if (data.length >= 4) {
              selectData4 = data[3]['y'];
              selectData4X = data[3]['x'];
            }
          } else {
            for (int i = 0; i < min(item['data'].length, data.length); i++) {
              item['data'][i]['x'].addAll(data[i]['x']);
              item['data'][i]['y'].addAll(data[i]['y']);
            }

            var data1 = item['data'];
            if (data1.length >= 1) {
              selectData1 = data1[0]['y'];
              selectData1X = data1[0]['x'];
            }

            if (data1.length >= 2) {
              selectData2 = data1[1]['y'];
              selectData2X = data1[1]['x'];
            }

            if (data1.length >= 3) {
              selectData3 = data1[2]['y'];
              selectData3X = data1[2]['x'];
            }

            if (data1.length >= 4) {
              selectData4 = data1[3]['y'];
              selectData4X = data1[3]['x'];
            }
          }
        } else {
          print('没有匹配到任何内容');
        }

        int length = 100;
        print("object======${selectData1X.length}");
        if (selectData1X.length > length) {
          print("object======");
          selectData1.removeRange(0, selectData1.length - length);
          selectData1X.removeRange(0, selectData1X.length - length);
        }

        if (selectData2X.length > length) {
          selectData2X.removeRange(0, selectData2X.length - length);
          selectData2.removeRange(0, selectData2.length - length);
        }

        if (selectData3X.length > length) {
          selectData3X.removeRange(0, selectData3X.length - length);
          selectData3.removeRange(0, selectData3.length - length);
        }

        if (selectData4X.length > length) {
          selectData4X.removeRange(0, selectData4X.length - length);
          selectData4.removeRange(0, selectData4.length - length);
        }

        if (res.length >= length) {
          res.removeRange(0, res.length - length);
        }

        setState(() {});
      }
    });

    setState(() {
      isScanding = true;
    });
  }

// Custom Code: 页面销毁
  customCode3() {
    disconnectTimer?.cancel();
    _connectionSubscription?.cancel();
    _getData?.cancel();
  }

// Custom Code: 设置变量
  customCode4(index) {
    var data = res[index]['data'];

    if (data.length >= 1) {
      selectData1 = data[0]['y'];
      selectData1X = data[0]['x'];
    }

    if (data.length >= 2) {
      selectData2 = data[1]['y'];
      selectData2X = data[1]['x'];
    }

    if (data.length >= 3) {
      selectData3 = data[2]['y'];
      selectData3X = data[2]['x'];
    }

    if (data.length >= 4) {
      selectData4 = data[3]['y'];
      selectData4X = data[3]['x'];
    }

    setState(() {});
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
            "数据分窗".tr,
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
                  padding: EdgeInsets.zero,
                  margin: EdgeInsets.zero,
                  child: Icon(IconData(58189, fontFamily: 'MaterialIcons'),
                      size: 24, color: Color(4294967295)),
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
                  height: 750,
                  alignment: Alignment(-1, -1),
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.zero,
                  decoration: BoxDecoration(
                    color: Color(16777215),
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
                        height: 40,
                        alignment: Alignment(-1, -1),
                        padding: EdgeInsets.only(
                          top: 0,
                          right: 10,
                          bottom: 0,
                          left: 10,
                        ),
                        margin: EdgeInsets.zero,
                        decoration: BoxDecoration(
                          color: Color(16777215),
                          gradient: null,
                          borderRadius: BorderRadius.circular(120),
                          border: Border.all(
                            color: Color(4288651167),
                            width: 0,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          verticalDirection: VerticalDirection.down,
                          children: [
                            SizedBox(
                              width: 320,
                              height: 40,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                reverse: false,
                                shrinkWrap: false,
                                padding: EdgeInsets.zero,
                                itemCount: res.length,
                                itemBuilder: (context, index) => Container(
                                  margin: EdgeInsets.zero,
                                  width: 80,
                                  height: 40,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      customCode4(index);
                                    },
                                    style: ButtonStyle(
                                      minimumSize:
                                          WidgetStateProperty.all(Size.zero),
                                      backgroundColor: WidgetStateProperty.all(
                                          Color(4294769916)),
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
                                      side: WidgetStateProperty.all(BorderSide(
                                        color: Color(4288585374),
                                        width: 1,
                                        style: BorderStyle.solid,
                                      )),
                                    ),
                                    child: Text(
                                      "${res[index]['name']}",
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
                              ),
                            ),
                          ],
                        ), //Row
                      ), //Container
                      Container(
                        clipBehavior: Clip.none,
                        width: 340,
                        height: 160,
                        alignment: Alignment(-1, -1),
                        padding: EdgeInsets.zero,
                        margin: EdgeInsets.only(
                          top: 10,
                          right: 0,
                          bottom: 10,
                          left: 0,
                        ),
                        decoration: BoxDecoration(
                          color: Color(4294967295),
                          gradient: null,
                          border: Border.all(
                            color: Colors.black,
                            width: 0,
                            style: BorderStyle.none,
                          ),
                        ),
                        child: RawScrollbar(
                          thickness: 4,
                          thumbVisibility: false,
                          trackVisibility: false,
                          radius: Radius.circular(12),
                          child: SizedBox(
                            width: double.infinity,
                            height: double.infinity,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              reverse: false,
                              shrinkWrap: false,
                              padding: EdgeInsets.zero,
                              itemCount: 1,
                              itemBuilder: (context, index) => Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                verticalDirection: VerticalDirection.down,
                                children: [
                                  Container(
                                      width: selectData1.length > 100
                                          ? 300 +
                                              (selectData1.length - 100) /
                                                  100 *
                                                  300
                                          : 300,
                                      height: 100,
                                      child: Builder(builder: (context) {
                                        double xFlSpot = 0;
                                        return LineChart(
                                          duration:
                                              const Duration(milliseconds: 10),
                                          curve: Curves.linear,
                                          LineChartData(
                                            backgroundColor: Colors.transparent,
                                            titlesData: FlTitlesData(
                                              show: true,
                                              rightTitles: AxisTitles(),
                                              topTitles: AxisTitles(),
                                              leftTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  reservedSize: 60,
                                                ),
                                              ),
                                              bottomTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  reservedSize: 30,
                                                ),
                                              ),
                                            ),
                                            gridData: FlGridData(
                                              show: false,
                                            ),
                                            lineBarsData: [
                                              LineChartBarData(
                                                spots: List.generate(
                                                    min(selectData1X.length,
                                                        selectData1.length),
                                                    (i) => FlSpot(
                                                        selectData1X[i],
                                                        selectData1[i])),
                                                color: Color(4278583807),
                                                barWidth: 1,
                                                isCurved: true,
                                                dotData: FlDotData(
                                                  show: false,
                                                ),
                                                belowBarData: BarAreaData(
                                                  show: false,
                                                  color: Color(4294959234),
                                                  gradient: null,
                                                ),
                                              ),
                                            ],
                                            borderData: FlBorderData(
                                              show: false,
                                              border: Border.all(
                                                  color: Colors.black,
                                                  width: 1),
                                            ),
                                            lineTouchData: LineTouchData(
                                              enabled: false,
                                            ),
                                          ),
                                        );
                                      })),
                                ],
                              ), //Column
                            ),
                          ),
                        ),
                      ), //Container
                      Container(
                        clipBehavior: Clip.none,
                        width: 340,
                        height: 160,
                        alignment: Alignment(-1, -1),
                        padding: EdgeInsets.zero,
                        margin: EdgeInsets.only(
                          top: 10,
                          right: 0,
                          bottom: 10,
                          left: 0,
                        ),
                        decoration: BoxDecoration(
                          color: Color(4294967295),
                          gradient: null,
                          border: Border.all(
                            color: Colors.black,
                            width: 0,
                            style: BorderStyle.none,
                          ),
                        ),
                        child: RawScrollbar(
                          thickness: 4,
                          thumbVisibility: false,
                          trackVisibility: false,
                          radius: Radius.circular(12),
                          child: SizedBox(
                            width: double.infinity,
                            height: double.infinity,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              reverse: false,
                              shrinkWrap: false,
                              padding: EdgeInsets.zero,
                              itemCount: 1,
                              itemBuilder: (context, index) => Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                verticalDirection: VerticalDirection.down,
                                children: [
                                  Container(
                                      width: selectData2.length > 100
                                          ? 300 +
                                              (selectData2.length - 100) /
                                                  100 *
                                                  300
                                          : 300,
                                      height: 100,
                                      child: Builder(builder: (context) {
                                        double xFlSpot = 0;
                                        return LineChart(
                                          duration:
                                              const Duration(milliseconds: 10),
                                          curve: Curves.linear,
                                          LineChartData(
                                            backgroundColor: Colors.transparent,
                                            titlesData: FlTitlesData(
                                              show: true,
                                              rightTitles: AxisTitles(),
                                              topTitles: AxisTitles(),
                                              leftTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  reservedSize: 60,
                                                ),
                                              ),
                                              bottomTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  reservedSize: 30,
                                                ),
                                              ),
                                            ),
                                            gridData: FlGridData(
                                              show: false,
                                            ),
                                            lineBarsData: [
                                              LineChartBarData(
                                                spots: List.generate(
                                                    min(selectData2X.length,
                                                        selectData2.length),
                                                    (i) => FlSpot(
                                                        selectData2X[i],
                                                        selectData2[i])),
                                                color: Color(4278583807),
                                                barWidth: 1,
                                                isCurved: true,
                                                dotData: FlDotData(
                                                  show: false,
                                                ),
                                                belowBarData: BarAreaData(
                                                  show: false,
                                                  color: Color(4294959234),
                                                  gradient: null,
                                                ),
                                              ),
                                            ],
                                            borderData: FlBorderData(
                                              show: false,
                                              border: Border.all(
                                                  color: Colors.black,
                                                  width: 1),
                                            ),
                                            lineTouchData: LineTouchData(
                                              enabled: false,
                                            ),
                                          ),
                                        );
                                      })),
                                ],
                              ), //Column
                            ),
                          ),
                        ),
                      ), //Container
                      Container(
                        clipBehavior: Clip.none,
                        width: 340,
                        height: 160,
                        alignment: Alignment(-1, -1),
                        padding: EdgeInsets.zero,
                        margin: EdgeInsets.only(
                          top: 10,
                          right: 0,
                          bottom: 10,
                          left: 0,
                        ),
                        decoration: BoxDecoration(
                          color: Color(4294967295),
                          gradient: null,
                          border: Border.all(
                            color: Colors.black,
                            width: 0,
                            style: BorderStyle.none,
                          ),
                        ),
                        child: RawScrollbar(
                          thickness: 4,
                          thumbVisibility: false,
                          trackVisibility: false,
                          radius: Radius.circular(12),
                          child: SizedBox(
                            width: double.infinity,
                            height: double.infinity,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              reverse: false,
                              shrinkWrap: false,
                              padding: EdgeInsets.zero,
                              itemCount: 1,
                              itemBuilder: (context, index) => Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                verticalDirection: VerticalDirection.down,
                                children: [
                                  Container(
                                      width: selectData3.length > 100
                                          ? 300 +
                                              (selectData3.length - 100) /
                                                  100 *
                                                  300
                                          : 300,
                                      height: 100,
                                      child: Builder(builder: (context) {
                                        double xFlSpot = 0;
                                        return LineChart(
                                          duration:
                                              const Duration(milliseconds: 10),
                                          curve: Curves.linear,
                                          LineChartData(
                                            backgroundColor: Colors.transparent,
                                            titlesData: FlTitlesData(
                                              show: true,
                                              rightTitles: AxisTitles(),
                                              topTitles: AxisTitles(),
                                              leftTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  reservedSize: 60,
                                                ),
                                              ),
                                              bottomTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  reservedSize: 30,
                                                ),
                                              ),
                                            ),
                                            gridData: FlGridData(
                                              show: false,
                                            ),
                                            lineBarsData: [
                                              LineChartBarData(
                                                spots: List.generate(
                                                    min(selectData3X.length,
                                                        selectData3.length),
                                                    (i) => FlSpot(
                                                        selectData3X[i],
                                                        selectData3[i])),
                                                color: Color(4278583807),
                                                barWidth: 1,
                                                isCurved: true,
                                                dotData: FlDotData(
                                                  show: false,
                                                ),
                                                belowBarData: BarAreaData(
                                                  show: false,
                                                  color: Color(4294959234),
                                                  gradient: null,
                                                ),
                                              ),
                                            ],
                                            borderData: FlBorderData(
                                              show: false,
                                              border: Border.all(
                                                  color: Colors.black,
                                                  width: 1),
                                            ),
                                            lineTouchData: LineTouchData(
                                              enabled: false,
                                            ),
                                          ),
                                        );
                                      })),
                                ],
                              ), //Column
                            ),
                          ),
                        ),
                      ), //Container
                      Container(
                        clipBehavior: Clip.none,
                        width: 80,
                        height: 80,
                        alignment: Alignment(-1, -1),
                        padding: EdgeInsets.zero,
                        margin: EdgeInsets.zero,
                        decoration: BoxDecoration(
                          color: Color(7883338),
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
                        width: 40,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () async {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return help();
                              },
                            );
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
                                borderRadius: BorderRadius.circular(1200),
                              ),
                            ),
                            side: WidgetStateProperty.all(BorderSide.none),
                          ),
                          child: Container(
                            padding: EdgeInsets.zero,
                            margin: EdgeInsets.zero,
                            child: Icon(
                                IconData(984405, fontFamily: 'MaterialIcons'),
                                size: 24,
                                color: Color(4294967295)),
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

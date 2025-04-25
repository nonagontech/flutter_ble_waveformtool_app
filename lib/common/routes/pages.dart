import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'names.dart';
import 'observers.dart';

import '../../pages/data_visualization.dart';
import '../../pages/set_ble_name.dart';
import '../../pages/device_net_work.dart';
import '../../pages/add_ble_device.dart';
import '../../pages/tabs.dart';

class AppPages {
  static const INITIAL = AppRoutes.INITIAL;
  static final NavigatorObserver observer = RouteObservers();
  static List<String> history = [];
  static final List<GetPage> routes = [
    GetPage(
      name: '/DataVisualization',
      page: () => const DataVisualization(),
    ),
    GetPage(
      name: '/SetBleName',
      page: () => const SetBleName(),
    ),
    GetPage(
      name: '/DeviceNetWork',
      page: () => const DeviceNetWork(),
    ),
    GetPage(
      name: '/',
      page: () => const AddBleDevice(),
    ),
    GetPage(name: '/tabs', page: () => const Tabs()),
  ];

  ///判断当前页面是否是弹窗
  static bool currentIsPop() {
    // 判断最后一个路由是否是弹窗
    return history[history.length - 1] == 'popUp';
  }
}

import 'dart:io';

import 'package:blue_print_pos/models/blue_device.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart' as blue_thermal;
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// This class with static method to handler scanning in Android and iOS
class BlueScanner {
  const BlueScanner._();

  /// Provide list of bluetooth device, return as list of [BlueDevice]
  static Future<List<BlueDevice>> scan() async {
    List<BlueDevice> devices = <BlueDevice>[];
    if (Platform.isAndroid) {
      final blue_thermal.BlueThermalPrinter bluetoothAndroid =
          blue_thermal.BlueThermalPrinter.instance;
      final List<blue_thermal.BluetoothDevice> resultDevices =
          await bluetoothAndroid.getBondedDevices();
      devices = resultDevices
          .map(
            (blue_thermal.BluetoothDevice bluetoothDevice) => BlueDevice(
              name: bluetoothDevice.name ?? '',
              address: bluetoothDevice.address ?? '',
              type: bluetoothDevice.type,
            ),
          )
          .toList();
    } else if (Platform.isIOS) {
      final List<BluetoothDevice> resultDevices = <BluetoothDevice>[];

      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 5),
      );
      FlutterBluePlus.scanResults
          .listen((List<ScanResult> scanResults) {
        for (final ScanResult scanResult in scanResults) {
          resultDevices.add(scanResult.device);
        }
      });

      await FlutterBluePlus.stopScan();
      devices = resultDevices
          .toSet()
          .toList()
          .map(
            (BluetoothDevice bluetoothDevice) => BlueDevice(
              address: bluetoothDevice.id.id,
              name: bluetoothDevice.name,
              // type: bluetoothDevice.type.index,
            ),
          )
          .toList();
    }
    return devices;
  }
}

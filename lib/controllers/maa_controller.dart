import 'package:get/get.dart';
import 'package:maa_core/maa_core.dart';
import 'dart:async';
import 'dart:isolate';

class InstanceController extends GetxController {
  final String _libDir;
  InstanceController(this._libDir);
  late SendPort _sendPort;
  late Isolate _maaThread;
  final Map<String, MaaCore> _isolatedInstances = {};
  final RxList<String> _instanceNames = <String>[].obs;

  RxList<String> get instanceNames => _instanceNames;

  Future<void> initialize() async {
    ReceivePort receivePort = ReceivePort();
    _maaThread = await Isolate.spawn(_doInitialization, receivePort.sendPort);
    _sendPort = await receivePort.first;
  }

  Future<void> initMaaCore([bool reload = false]) async {
    await sendThenReceive('init', {'reload': reload, 'dir': _libDir});
  }

  Future<void> _doInitialization(SendPort sendPort) async {
    ReceivePort port = ReceivePort()
      ..listen((message) {
        isolateHandleMessage(
          message[0] as String,
          message[1] as Map<String, dynamic>,
          message[2] as SendPort,
        );
      });
    sendPort.send(port.sendPort);
  }

  void isolateHandleMessage(
      String event, Map<String, dynamic> args, SendPort replyTo) {
    // handleMessage is in spawnd isolate
    switch (event) {
      case "init":
        MaaCore.init(args['dir'] as String,
            reloadResource: args['reload'] as bool);
        replyTo.send(true);
        break;
      case 'createInstance':
        String adb = args['adb'];
        String address = args['address'];
        String config = args['config'];
        String alias = args['alias'];
        SendPort? subscripionPort = args['port'];
        _isolatedInstances[alias] = subscripionPort == null
            ? MaaCore(_libDir)
            : MaaCore(_libDir, (msg) => {subscripionPort.send(msg)});
        _isolatedInstances[alias]!.connect(adb, address, config);
        replyTo.send(alias);
        break;
      case 'getAllInstanceNames':
        replyTo.send(_isolatedInstances.keys.toList());
        break;
      case 'removeInstance':
        String name = args['name'];
        _isolatedInstances[name]!.destroy();
        replyTo.send(true);
        break;
    }
  }

  Future<dynamic> sendThenReceive(
      String event, Map<String, dynamic> args) async {
    ReceivePort port = ReceivePort();
    _sendPort.send([event, args, port.sendPort]);
    final res = await port.first;
    return res;
  }

  Future<String> createInstance({
    required String adb,
    required String address,
    String config = 'General',
    String? alias,
    void Function(String)? callback,
  }) async {
    ReceivePort? receivePort;
    if (callback != null) {
      receivePort = ReceivePort();
      receivePort.listen((msg) {
        callback(msg as String);
      });
    }
    String res = await sendThenReceive('createInstance', {
      'adb': adb,
      'address': address,
      'config': config,
      'alias': alias ?? 'address',
      'port': receivePort?.sendPort,
    });
    _instanceNames.add(res);
    return res;
  }

  Future<bool> removeInstance(String name) async {
    if (_instanceNames.contains(name)) {
      bool res = await sendThenReceive('removeInstance', {
        'name': name,
      });
      return res;
    }
    return false;
  }
}

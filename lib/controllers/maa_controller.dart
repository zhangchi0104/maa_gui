import 'package:get/get.dart';
import 'package:maa_core/maa_core.dart';
import 'dart:async';
import 'dart:isolate';

enum ConnectionStatus {
  notConnected,
  failed,
  connected,
  running,
}

typedef InstanceConnectionConfig = Map<String, String>;
typedef InstanceStatus = Map<String, ConnectionStatus>;

class InstanceManagerService extends GetxService {
  final String _libDir;
  InstanceManagerService(this._libDir);
  late Isolate _maaThread;
  late SendPort _sendPort;
  final Map<String, MaaCore> _isolatedInstances = {};

  final _instanceConfigs = <String, InstanceConnectionConfig>{};
  List<String> get instanceNames => _instanceConfigs.keys.toList();

  Future<void> initialize() async {
    ReceivePort receivePort = ReceivePort();
    _maaThread = await Isolate.spawn(_doInitialization, receivePort.sendPort);
    _sendPort = await receivePort.first;
  }

  Future<void> initMaaCore([bool reload = false]) async {
    bool res =
        await sendThenReceive('init', {'reload': reload, 'dir': _libDir});
    if (!res) {
      throw Exception('Failed to initialize MaaCore');
    }
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
        try {
          MaaCore.init(
            args['dir'] as String,
            reloadResource: args['reload'] as bool,
          );
          replyTo.send(true);
        } on Exception catch (err) {
          replyTo.send(false);
        }
        break;
      case 'createInstance':
        String alias = args['alias'];
        SendPort? subscriptionPort = args['port'];
        _isolatedInstances[alias] = subscriptionPort == null
            ? MaaCore(_libDir)
            : MaaCore(_libDir, (msg) => {subscriptionPort.send(msg)});
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
      'alias': alias ?? address,
      'port': receivePort?.sendPort,
    });
    _instanceConfigs[alias ?? address] = {
      'adb': adb,
      'address': address,
      'config': config,
    };
    return res;
  }

  Future<bool> removeInstance(String name) async {
    if (_instanceConfigs.keys.contains(name)) {
      bool res = await sendThenReceive('removeInstance', {
        'name': name,
      });
      _instanceConfigs.remove(name);
      return res;
    }
    return false;
  }

  void close() async {
    for (final instance in instanceNames) {
      await removeInstance(instance);
    }
    _maaThread.kill();
  }
}

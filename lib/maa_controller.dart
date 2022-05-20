import 'package:maa_core/maa_core.dart'; 
import 'dart:async';
import 'dart:isolate';

class MaaController {
  final String _libDir;
  MaaController(this._libDir);
  late SendPort _sendPort;
  late Isolate _maaThread;
  final Map<String, MaaCore> _instances = {};

  Future<void> initialize() async {
    ReceivePort receivePort = ReceivePort(); 
    _maaThread = await Isolate.spawn(_doInitialization, receivePort.sendPort);
    _sendPort = await receivePort.first;
  }

  Future<void> initMaaCore([bool reload = false]) async {
    await sendThenReceive('init', {'reload': reload, 'dir': _libDir}); 
  }

  Future<void> _doInitialization(SendPort sendPort) async {
    ReceivePort port = ReceivePort()..listen((message) {
      handleMessage(message[0] as String, message[1] as Map<String, dynamic>, message[2] as SendPort);
    });
    sendPort.send(port.sendPort);
  }


  void handleMessage(String event, Map<String, dynamic> args, SendPort replyTo) {

    // handleMessage is in spawnd isolate
    switch (event) {
      case "init":
        MaaCore.init(args['dir'] as String, reloadResource: args['reload'] as bool);
        replyTo.send(true);
        break;
      case 'createInstance':
        String adb = args['adb'];
        String address = args['address'];
        String config = args['config'];
        String alias = args['alias'];
        SendPort? subscripionPort = args['port'];
        _instances[alias] = subscripionPort == null ? MaaCore(_libDir): 
           MaaCore(_libDir, (msg) => {subscripionPort.send(msg)});
        _instances[alias]!.connect(adb, address, config);
        replyTo.send(alias);
        break;
      case 'getAllInstanceNames':
        replyTo.send(_instances.keys.toList());
        break;
    }
  }

  Future<dynamic> sendThenReceive(String event, Map<String, dynamic> args) async {
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
    String res = await sendThenReceive('createInstance',{
      'adb': adb,
      'address': address,
      'config': config,
      'alias': alias??'address',
      'port': receivePort?.sendPort,
    });
    return res;
  }

  Future<List<String>> getAllInstanceNames() async {
      final instances = await sendThenReceive('getAllInstanceNames', {});
      return instances as List<String>;
  }
 

  
}
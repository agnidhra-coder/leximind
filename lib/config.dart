import 'dart:async';
import 'dart:io';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  static const String apiKey = 'AIzaSyAGJY9wOf5xZwOdGjEUQkP53HB8_wiJqjA';
}

class SSH {
  late String _host;
  late String _port;
  late String _username;
  late String _passwordOrKey;
  late String _numberOfRigs;
  SSHClient? _client;


  Future<void> initConnectionDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _host = prefs.getString('ipAddress') ?? 'default_host';
    _port = prefs.getString('sshPort') ?? '22';
    _username = prefs.getString('username') ?? 'lg';
    _passwordOrKey = prefs.getString('password') ?? 'lg';
    _numberOfRigs = prefs.getString('numberOfRigs') ?? '3';
  }

  int get rigs => int.parse(_numberOfRigs);

  Future<bool?> connectToLG() async {
    await initConnectionDetails();

    try {
      _client = SSHClient(
        await SSHSocket.connect(_host, int.parse(_port)),
        username: _username,
        onPasswordRequest: () => _passwordOrKey,
      );

      return true;
    } on SocketException catch (e) {
      print('Failed to connect: $e');
      return false;
    }

  }

  SSHClient? get client => _client;

  Future<SSHSession?> execute(String content) async {
    try {
      if (_client == null) {
        print('SSH client is not initialized.');
        return null;
      }

      final execResult = await _client!.execute('echo "$content" > /tmp/query.txt');
      return execResult;

    } catch (e) {
      print('An error occurred while executing the command: $e');
      return null;
    }
  }

  upload(File inputFile, String filename) async {
    //await connect();
    //await Future.delayed(const Duration(seconds: 1));
    try {
      bool uploading = true;
      final sftp = await _client?.sftp();
      final file = await sftp?.open('/var/www/html/$filename',
          mode: SftpFileOpenMode.truncate |
              SftpFileOpenMode.create |
              SftpFileOpenMode.write);
      var fileSize = await inputFile.length();
      file?.write(inputFile.openRead().cast(), onProgress: (progress) {
        if (fileSize == progress) {
          uploading = false;
        }
      });
      // print(file);
      if (file == null) {
        print('null');
        return;
      }
      await waitWhile(() => uploading);
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }
  }

  Future waitWhile(bool Function() test,
      [Duration pollInterval = Duration.zero]) {
    var completer = Completer();
    check() {
      if (!test()) {
        completer.complete();
      } else {
        Timer(pollInterval, check);
      }
    }

    check();
    return completer.future;
  }


}
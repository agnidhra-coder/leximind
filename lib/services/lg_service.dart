import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:leximind/config.dart';
import 'package:leximind/entities/kml_entity.dart';
import 'package:leximind/entities/screen_overlay_entity.dart';
import 'package:leximind/services/file_service.dart';
import 'package:xml/xml.dart';

class LGService {
  static final LGService _instance = LGService._internal();
  
  factory LGService() {
    return _instance;
  }
  
  LGService._internal();

  int screenAmount = 3;

  int get logoScreen {
    if (screenAmount == 1) {
      return 1;
    }

    return (screenAmount / 2).floor() + 2;
  }

  static Future<void> sendKmlStatic(Map<String, dynamic> args) async {
    final RootIsolateToken rootIsolateToken = args['token'];
  final String kml = args['kml'];
  BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
    final service = LGService();
    await service.sendKml(kml);
  }

  Future<void> sendKml(String kml, {double long = 0, double lat = 0, double alt = 8000}) async{
    SSH ssh = SSH();
    FileService fileService = FileService();
    await ssh.connectToLG();
    String content = kml;
    final document = XmlDocument.parse(kml);
    final coords = document.findAllElements('coordinates');
    long = coords.isNotEmpty ? double.parse(coords.first.text.trim().split(',')[0]) : long;
    lat = coords.isNotEmpty ? double.parse(coords.first.text.trim().split(',')[1]) : lat;
    print("coordinates: long: $long, lat: $lat");
    String fileName = 'location.kml';

    await clearKml();

    String flyTo = '''flytoview=<LookAt><longitude>$long</longitude><latitude>$lat</latitude><altitude>$alt</altitude><tilt>0</tilt><altitudeMode>relativeToGround</altitudeMode><gx:altitudeMode>relativeToSeaFloor</gx:altitudeMode></LookAt>''';

    try {
      final kmlFile = await fileService.createFile(fileName, content);
      await ssh.upload(kmlFile, fileName);
      await Future.delayed(const Duration(seconds: 1));
      await ssh.client!.run('echo "http://lg1:81/location.kml" > /var/www/html/kmls.txt');
      await ssh.client!.run("echo '$flyTo' > /tmp/query.txt");
    } catch (e) {
      print('ERROR ON SENDING KML FILE: $e');
      throw e; // Re-throw to propagate the error
    }
  }

  // Future<void> sendKml(String kml, {double long = 0, double lat = 0, double alt = 8000}) async{
  //   SSH ssh = SSH();
  //   FileService fileService = FileService();
  //   await ssh.connectToLG();
  //   String content = kml;
  //   final document = XmlDocument.parse(kml);
  //   final coords = document.findAllElements('coordinates');
  //   long = coords.isNotEmpty ? double.parse(coords.first.text.trim().split(',')[0]) : long;
  //   lat = coords.isNotEmpty ? double.parse(coords.first.text.trim().split(',')[1]) : lat;
  //   String fileName = 'location.kml';

  //   await clearKml();

  //   String flyTo = '''flytoview=<LookAt><longitude>$long</longitude><latitude>$lat</latitude><altitude>$alt</altitude><tilt>0</tilt><altitudeMode>relativeToGround</altitudeMode><gx:altitudeMode>relativeToSeaFloor</gx:altitudeMode></LookAt>''';

  //   try {
  //     final kmlFile = await fileService.createFile(fileName, content);
  //     await ssh.upload(kmlFile, fileName);
  //     await Future.delayed(const Duration(seconds: 1));
  //     await ssh.client!.run('echo "http://lg1:81/location.kml" > /var/www/html/kmls.txt');
  //     await ssh.client!.run("echo '$flyTo' > /tmp/query.txt");
  //   } catch (e) {
  //     print('ERROR ON SENDING KML FILE: $e');
  //   }
  // }

  Future<void> sendPrompt(KMLEntity kml) async{
    SSH ssh = SSH();
    FileService fileService = FileService();
    await ssh.connectToLG();
    String content = kml.promptBody;
    String fileName = 'prompt.kml';

    await clearKml();

    String flyTo = '''flytoview=<LookAt><longitude>0</longitude><latitude>0</latitude><altitude>8000</altitude><tilt>0</tilt><altitudeMode>relativeToGround</altitudeMode><gx:altitudeMode>relativeToSeaFloor</gx:altitudeMode></LookAt>''';

    final kmlFile = await fileService.createFile(fileName, content);
    await ssh.upload(kmlFile, fileName);
    await Future.delayed(const Duration(seconds: 1));
    await ssh.client!.run('echo "http://lg1:81/prompt.kml" > /var/www/html/kmls.txt');
    await ssh.client!.run("echo '$flyTo' > /tmp/query.txt");
  }


  Future<void> sendKMLToSlave(int screen, String content) async {
    SSH ssh = SSH();
    await ssh.connectToLG();
    try {
      await ssh.client!.execute("echo '$content' > /var/www/html/kml/slave_$screen.kml");
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }

  Future<void> clearKml({bool keepLogos = false}) async {
    SSH ssh = SSH();
    await ssh.connectToLG();

    String query =
        'echo "exittour=true" > /tmp/query.txt && > /var/www/html/kmls.txt';

    for (var i = 2; i <= screenAmount; i++) {
      String blankKml = KMLEntity.generateBlank('slave_$i');
      query += " && echo '$blankKml' > /var/www/html/kml/slave_$i.kml";
    }

    if (keepLogos) {
      final kml = KMLEntity(
        name: 'LG-Logo',
        content: '<name>Logos</name>',
        screenOverlay: ScreenOverlayEntity.logos().tag,
      );

      query +=
          " && echo '${kml.body}' > /var/www/html/kml/slave_$logoScreen.kml";
    }

    await ssh.client!.execute(query);
  }

  Future<void> cleanKML(int screen) async {
    SSH ssh = SSH();
    await ssh.connectToLG();
    final kml = KMLEntity.generateBlank('slave_$screen');

    try {
      await ssh.client!.execute("echo '$kml' > /var/www/html/kml/slave_$screen.kml");
    } catch (e) {
      print(e);
    }
  }

}


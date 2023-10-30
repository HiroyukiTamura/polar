import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:polar/polar.dart';
import 'package:polar_example/model/polar_offline_recording.dart';
import 'package:polar_example/recording_type.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const MyApp());
}

/// Example app
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const identifier = 'C61A4F28';

  final polar = Polar();
  final logs = ['Service started'];

  PolarExerciseEntry? exerciseEntry;

  @override
  void initState() {
    super.initState();

    // polar
    //     .searchForDevice()
    //     .listen((e) => log('Found device in scan: ${e.deviceId}'));
    polar.batteryLevel.listen((e) => log('Battery: ${e.level}'));
    polar.deviceConnecting.listen((_) => log('Device connecting'));
    polar.deviceConnected.listen((_) => log('Device connected'));
    polar.deviceDisconnected.listen((_) => log('Device disconnected'));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Polar example app'),
          actions: [
            PopupMenuButton(
              itemBuilder: (context) => RecordingAction.values
                  .map((e) => PopupMenuItem(value: e, child: Text(e.name)))
                  .toList(),
              onSelected: handleRecordingAction,
              child: const IconButton(
                icon: Icon(Icons.fiber_manual_record),
                disabledColor: Colors.white,
                onPressed: null,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.stop),
              onPressed: () {
                log('Disconnecting from device: $identifier');
                polar.disconnectFromDevice(identifier);
              },
            ),
            IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: () {
                log('Connecting to device: $identifier');
                polar.connectToDevice(identifier);
                streamWhenReady();
              },
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(10),
          shrinkWrap: true,
          children: logs.reversed.map(Text.new).toList(),
        ),
      ),
    );
  }

  void streamWhenReady() async {
    final futureOffline = polar.sdkFeatureReady.firstWhere(
      (e) => e.identifier == identifier && e.feature == PolarSdkFeature.offlineRecording,
    );
    final futureOnline = polar.sdkFeatureReady.firstWhere(
      (e) => e.identifier == identifier && e.feature == PolarSdkFeature.onlineStreaming,
    );
    await Future.wait([futureOffline, futureOnline]);

    final availabletypes = await polar.getAvailableOnlineStreamDataTypes(identifier);

    debugPrint('available types: $availabletypes');

    if (availabletypes.contains(PolarDataType.ppi)) {
      try {
        await polar.stopOfflineRecording(identifier, type: RecordingType.ppi.name);
        await Future.delayed(const Duration(seconds: 3));
      } catch (e) {
        print(e);
      }

      try {
        final string = await polar.getLastPpiOfflineRecordingData(identifier);
        final json = jsonDecode(string!);
        final recordingData = PolarOfflineRecording.fromJson(json);
        print(recordingData);
      } catch (e) {
        print(e);
      }

      await polar.startOfflineRecording(
        identifier,
        type: RecordingType.acc.toString(),
      );
      await Future.delayed(const Duration(minutes: 1));

      await polar.stopOfflineRecording(
        identifier,
        type: RecordingType.acc.toString(),
      );

      await Future.delayed(const Duration(seconds: 5));

      try {
        final string = await polar.getLastPpiOfflineRecordingData(identifier);
        final json = jsonDecode(string!);
        final recordingData = PolarOfflineRecording.fromJson(json);
        print(recordingData);
      } catch (e) {
        print(e);
      }

      debugPrint('good work');
    }
  }

  void log(String log) {
    // ignore: avoid_print
    print(log);
    setState(() {
      logs.add(log);
    });
  }

  Future<void> handleRecordingAction(RecordingAction action) async {
    switch (action) {
      case RecordingAction.start:
        log('Starting recording');
        await polar.startRecording(
          identifier,
          exerciseId: const Uuid().v4(),
          interval: RecordingInterval.interval_1s,
          sampleType: SampleType.rr,
        );
        log('Started recording');
        break;
      case RecordingAction.stop:
        log('Stopping recording');
        await polar.stopRecording(identifier);
        log('Stopped recording');
        break;
      case RecordingAction.status:
        log('Getting recording status');
        final status = await polar.requestRecordingStatus(identifier);
        log('Recording status: $status');
        break;
      case RecordingAction.list:
        log('Listing recordings');
        final entries = await polar.listExercises(identifier);
        log('Recordings: $entries');
        // H10 can only store one recording at a time
        exerciseEntry = entries.first;
        break;
      case RecordingAction.fetch:
        log('Fetching recording');
        if (exerciseEntry == null) {
          log('Exercises not yet listed');
          await handleRecordingAction(RecordingAction.list);
        }
        final entry = await polar.fetchExercise(identifier, exerciseEntry!);
        log('Fetched recording: $entry');
        break;
      case RecordingAction.remove:
        log('Removing recording');
        if (exerciseEntry == null) {
          log('No exercise to remove. Try calling list first.');
          return;
        }
        await polar.removeExercise(identifier, exerciseEntry!);
        log('Removed recording');
        break;
    }
  }
}

enum RecordingAction {
  start,
  stop,
  status,
  list,
  fetch,
  remove,
}

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polar/polar.dart';

final polar = Polar();

void testSearch(String identifier) {
  test('search', () async {
    await polar.searchForDevice().any((e) => e.deviceId == identifier);
    // Will fail by timeout if device is not found
  });
}

void testConnection(String identifier) {
  test('connection', () async {
    await polar.connectToDevice(identifier);

    final connecting = await polar.deviceConnectingStream.first;
    expect(connecting.deviceId, identifier);

    final connected = await polar.deviceConnectedStream.first;
    expect(connected.deviceId, identifier);

    await polar.disconnectFromDevice(identifier);

    final disconnected = await polar.deviceDisconnectedStream.first;
    expect(disconnected.deviceId, identifier);
  });
}

void testBasicData(String identifier) {
  group('basic data', () async {
    setUp(() async {
      await polar.connectToDevice(identifier);
    });

    tearDown(() async {
      await polar.disconnectFromDevice(identifier);
    });

    test('blePowerState', () async {
      final blePowerState = await polar.blePowerStateStream.first;
      expect(blePowerState, true);
    });

    test('streamingFeaturesReady', () async {
      final streamingFeatures = await polar.streamingFeaturesReadyStream.first;
      expect(
        setEquals(streamingFeatures.features.toSet(), {
          DeviceStreamingFeature.ecg,
          DeviceStreamingFeature.acc,
        }),
        true,
      );
    });

    test('sdkModeFeatureAvailable', () async {
      final sdkModeFeatureIdentifier =
          await polar.sdkModeFeatureAvailableStream.first;
      expect(sdkModeFeatureIdentifier, identifier);
    });

    test('hrFeatureReady', () async {
      final hrFeatureIdentifier = await polar.hrFeatureReadyStream.first;
      expect(hrFeatureIdentifier, identifier);
    });

    test('disInformation', () async {
      final disInformation = await polar.disInformationStream.first;
      expect(disInformation.identifier, identifier);
    });

    test('batteryLevel', () async {
      final batteryLevel = await polar.batteryLevelStream.first;
      expect(batteryLevel, greaterThan(0));
    });

    test('heartRate', () async {
      // TODO: Will probably fail
      final heartRate = await polar.heartRateStream.first;
      // .map((e) => e.data.hr)
      // .firstWhere((e) => e > 0);
      expect(heartRate, greaterThan(0));
    });

    test('ftpFeatureReady', () {
      final ftpFeatureIdentifier = polar.ftpFeatureReadyStream.first;
      expect(ftpFeatureIdentifier, identifier);
    });
  });
}

void testStreaming(
  String identifier, {
  required List<DeviceStreamingFeature> features,
}) {
  group('streaming', () {
    setUpAll(() async {
      await polar.connectToDevice(identifier);
      await polar.streamingFeaturesReadyStream.first;
    });

    tearDownAll(() async {
      await polar.disconnectFromDevice(identifier);
    });

    if (features.contains(DeviceStreamingFeature.ecg)) {
      test('ecg', () async {
        final ecgData = await polar.startEcgStreaming(identifier).first;
        expect(ecgData.samples.length, greaterThan(0));
      });
    }

    if (features.contains(DeviceStreamingFeature.acc)) {
      test('acc', () async {
        final accData = await polar.startAccStreaming(identifier).first;
        expect(accData.samples.length, greaterThan(0));
      });
    }

    if (features.contains(DeviceStreamingFeature.ppg)) {
      test('ppg', () async {
        final ppgData = await polar.startOhrStreaming(identifier).first;
        expect(ppgData.samples.length, greaterThan(0));
      });
    }

    if (features.contains(DeviceStreamingFeature.ppi)) {
      test('ppi', () async {
        final ppiData = await polar.startOhrPPIStreaming(identifier).first;
        expect(ppiData.samples.length, greaterThan(0));
      });
    }
  });
}

void testRecording(String identifier) {
  group('recording', () {
    setUpAll(() async {
      await polar.connectToDevice(identifier);
      await polar.ftpFeatureReadyStream.first;
    });

    tearDownAll(() async {
      await polar.disconnectFromDevice(identifier);
    });
  });
}
import 'package:freezed_annotation/freezed_annotation.dart';

part 'polar_offline_recording.freezed.dart';
part 'polar_offline_recording.g.dart';

@freezed
class PolarOfflineRecording with _$PolarOfflineRecording {
  const factory PolarOfflineRecording({
    required String type,
    required OfflineData data,
  }) = _PolarOfflineRecording;

  factory PolarOfflineRecording.fromJson(Map<String, dynamic> json) =>
      _$PolarOfflineRecordingFromJson(json);
}

@freezed
class OfflineData with _$OfflineData {
  const factory OfflineData({
    required DataSampleWrapper data,
    required StartTime startTime,
  }) = _OfflineData;

  factory OfflineData.fromJson(Map<String, dynamic> json) => _$OfflineDataFromJson(json);
}

@freezed
class DataSampleWrapper with _$DataSampleWrapper {
  const factory DataSampleWrapper({
    required List<Sample> samples,
  }) = _DataSampleWrapper;

  factory DataSampleWrapper.fromJson(Map<String, dynamic> json) =>
      _$DataSampleWrapperFromJson(json);
}

@freezed
class Sample with _$Sample {
  const factory Sample({
    required bool blockerBit,
    required int errorEstimate,
    required int hr,
    required int ppi,
    required bool skinContactStatus,
    required bool skinContactSupported,
  }) = _Sample;

  factory Sample.fromJson(Map<String, dynamic> json) => _$SampleFromJson(json);
}

@freezed
class StartTime with _$StartTime {
  const factory StartTime({
    required int year,
    required int month,
    required int dayOfMonth,
    required int hourOfDay,
    required int minute,
    required int second,
  }) = _StartTime;

  factory StartTime.fromJson(Map<String, dynamic> json) => _$StartTimeFromJson(json);
}

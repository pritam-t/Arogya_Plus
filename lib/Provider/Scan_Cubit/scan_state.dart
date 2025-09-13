// scan_state.dart
import 'dart:io';

enum ScanStatus { initial, loading, success, failure }

class ScanState {
  final ScanStatus status;
  final File? imageFile;
  final String extractedText;
  final String? error;

  final String? drugName;
  final String? drugUsage;
  final String? drugDosage;
  final String? drugWarnings;

  final String? aiSummary;


  const ScanState({
    this.status = ScanStatus.initial,
    this.imageFile,
    this.extractedText = '',
    this.error,
    this.drugName,
    this.drugUsage,
    this.drugDosage,
    this.drugWarnings,
    this.aiSummary,
  });

  ScanState copyWith({
    ScanStatus? status,
    File? imageFile,
    String? extractedText,
    String? error,
    String? drugName,
    String? drugUsage,
    String? drugDosage,
    String? drugWarnings,
    String? aiSummary,
  }) {
    return ScanState(
      status: status ?? this.status,
      imageFile: imageFile ?? this.imageFile,
      extractedText: extractedText ?? this.extractedText,
      error: error ?? this.error,
      drugName: drugName ?? this.drugName,
      drugUsage: drugUsage ?? this.drugUsage,
      drugDosage: drugDosage ?? this.drugDosage,
      drugWarnings: drugWarnings ?? this.drugWarnings,
      aiSummary: aiSummary ?? this.aiSummary,
    );
  }
}

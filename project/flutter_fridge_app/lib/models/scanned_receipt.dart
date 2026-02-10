/// Domain model for a scanned receipt stored locally.
class ScannedReceipt {
  final String id;

  /// Absolute path to the captured image on disk.
  final String imagePath;

  /// The full OCR text (after redaction and user edits).
  final String ocrText;

  final DateTime scannedAt;

  const ScannedReceipt({
    required this.id,
    required this.imagePath,
    required this.ocrText,
    required this.scannedAt,
  });

  Map<String, Object?> toDb() => {
    "id": id,
    "imagePath": imagePath,
    "ocrText": ocrText,
    "scannedAt": scannedAt.toIso8601String(),
  };

  factory ScannedReceipt.fromDb(Map<String, Object?> row) => ScannedReceipt(
    id: row["id"] as String,
    imagePath: row["imagePath"] as String,
    ocrText: row["ocrText"] as String,
    scannedAt: DateTime.parse(row["scannedAt"] as String),
  );
}

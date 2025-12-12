enum DocumentStatus { waiting, uploading, uploaded, verified, rejected, error }

extension DocumentStatusExtension on DocumentStatus {
  String toJson() {
    return toString().split('.')[1]; // Mengambil nama enum setelah titik
  }

  static DocumentStatus fromJson(String status) {
    return DocumentStatus.values.firstWhere(
      (e) => e.toString().split('.')[1] == status,
      orElse: () => DocumentStatus.waiting, // Default ke waiting jika tidak ditemukan
    );
  }
}

class DocumentItemModel {
  final int id;
  final String label;
  String filename;
  DocumentStatus status;

  DocumentItemModel(this.id, this.label, this.filename, this.status);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'filename': filename,
      'status': status.toJson(),
    };
  }

  factory DocumentItemModel.fromJson(Map<String, dynamic> json) {
    return DocumentItemModel(
      json['id'] as int,
      json['label'] as String,
      json['filename'] as String,
      DocumentStatusExtension.fromJson(json['status'] as String),
    );
  }
}
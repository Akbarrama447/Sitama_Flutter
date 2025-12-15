import 'jadwal_sidang_model.dart';

class StatusPendaftaranResponse {
  final String status;
  final String message;
  final StatusPendaftaranData? data;

  StatusPendaftaranResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory StatusPendaftaranResponse.fromJson(Map<String, dynamic> json) {
    return StatusPendaftaranResponse(
      status: json['status'] as String,
      message: json['message'] as String,
      data: json['data'] != null 
          ? StatusPendaftaranData.fromJson(json['data'] as Map<String, dynamic>) 
          : null,
    );
  }
}

class StatusPendaftaranData {
  final TugasAkhir tugasAkhir;
  final PendaftaranSidangInfo pendaftaranSidang;

  StatusPendaftaranData({
    required this.tugasAkhir,
    required this.pendaftaranSidang,
  });

  factory StatusPendaftaranData.fromJson(Map<String, dynamic> json) {
    return StatusPendaftaranData(
      tugasAkhir: TugasAkhir.fromJson(json['tugas_akhir'] as Map<String, dynamic>),
      pendaftaranSidang: PendaftaranSidangInfo.fromJson(json['pendaftaran_sidang'] as Map<String, dynamic>),
    );
  }
}

class TugasAkhir {
  final int id;
  final String judul;
  final String status;
  final bool syaratSidangLengkap;

  TugasAkhir({
    required this.id,
    required this.judul,
    required this.status,
    required this.syaratSidangLengkap,
  });

  factory TugasAkhir.fromJson(Map<String, dynamic> json) {
    return TugasAkhir(
      id: json['id'] as int? ?? 0,
      judul: json['judul'] as String? ?? '',
      status: json['status'] as String? ?? '',
      syaratSidangLengkap: json['syarat_sidang_lengkap'] as bool? ?? false,
    );
  }
}

class PendaftaranSidangInfo {
  final int id;
  final String status;
  final JadwalSidang jadwalSidang;
  final String tanggalDaftar;

  PendaftaranSidangInfo({
    required this.id,
    required this.status,
    required this.jadwalSidang,
    required this.tanggalDaftar,
  });

  factory PendaftaranSidangInfo.fromJson(Map<String, dynamic> json) {
    return PendaftaranSidangInfo(
      id: json['id'] as int? ?? 0,
      status: json['status'] as String? ?? '',
      jadwalSidang: json['jadwal_sidang'] != null 
          ? JadwalSidang.fromJson(json['jadwal_sidang'] as Map<String, dynamic>) 
          : JadwalSidang(id: 0, tanggal: '', sesi: Sesi(id: 0, jamMulai: '', jamSelesai: ''), ruangan: Ruangan(id: 0, namaRuangan: '')),
      tanggalDaftar: json['tanggal_daftar'] as String? ?? '',
    );
  }
}
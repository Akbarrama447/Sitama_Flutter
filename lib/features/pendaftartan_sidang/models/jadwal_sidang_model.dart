// Model untuk jadwal sidang
class JadwalSidang {
  final int id;
  final String tanggal;
  final Sesi sesi;
  final Ruangan ruangan;

  JadwalSidang({
    required this.id,
    required this.tanggal,
    required this.sesi,
    required this.ruangan,
  });

  factory JadwalSidang.fromJson(Map<String, dynamic> json) {
    return JadwalSidang(
      id: json['id'] as int? ?? 0,
      tanggal: json['tanggal'] as String? ?? '',
      sesi: json['sesi'] != null ? Sesi.fromJson(json['sesi'] as Map<String, dynamic>) : Sesi(id: 0, jamMulai: '', jamSelesai: ''),
      ruangan: json['ruangan'] != null ? Ruangan.fromJson(json['ruangan'] as Map<String, dynamic>) : Ruangan(id: 0, namaRuangan: ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tanggal': tanggal,
      'sesi': sesi.toJson(),
      'ruangan': ruangan.toJson(),
    };
  }

  @override
  String toString() {
    return '$tanggal ${sesi.jamMulai}-${sesi.jamSelesai} ${ruangan.namaRuangan}';
  }
}

class Sesi {
  final int id;
  final String jamMulai;
  final String jamSelesai;

  Sesi({
    required this.id,
    required this.jamMulai, // Ini sebenarnya mengacu pada waktu_mulai dari DB
    required this.jamSelesai, // Ini sebenarnya mengacu pada waktu_selesai dari DB
  });

  factory Sesi.fromJson(Map<String, dynamic> json) {
    return Sesi(
      id: json['id'] as int? ?? 0,
      jamMulai: json['waktu_mulai'] as String? ?? '',  // Mapping dari DB field waktu_mulai
      jamSelesai: json['waktu_selesai'] as String? ?? '', // Mapping dari DB field waktu_selesai
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'waktu_mulai': jamMulai,      // Serialize ke DB field waktu_mulai
      'waktu_selesai': jamSelesai,  // Serialize ke DB field waktu_selesai
    };
  }
}

class Ruangan {
  final int id;
  final String namaRuangan;

  Ruangan({
    required this.id,
    required this.namaRuangan,
  });

  factory Ruangan.fromJson(Map<String, dynamic> json) {
    return Ruangan(
      id: json['id'] as int? ?? 0,
      namaRuangan: json['nama_ruangan'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_ruangan': namaRuangan,
    };
  }
}

// Model untuk response pendaftaran sidang
class PendaftaranResponse {
  final String status;
  final String message;
  final PendaftaranData? data;

  PendaftaranResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory PendaftaranResponse.fromJson(Map<String, dynamic> json) {
    return PendaftaranResponse(
      status: json['status'] as String? ?? '',
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? PendaftaranData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class PendaftaranData {
  final int sidangId;
  final int tugasAkhirId;
  final String judulTugasAkhir;
  final JadwalSidangPendaftaran jadwalSidang;
  final String tanggalDaftar;

  PendaftaranData({
    required this.sidangId,
    required this.tugasAkhirId,
    required this.judulTugasAkhir,
    required this.jadwalSidang,
    required this.tanggalDaftar,
  });

  factory PendaftaranData.fromJson(Map<String, dynamic> json) {
    return PendaftaranData(
      sidangId: json['sidang_id'] as int,
      tugasAkhirId: json['tugas_akhir_id'] as int,
      judulTugasAkhir: json['judul_tugas_akhir'] as String,
      jadwalSidang: JadwalSidangPendaftaran.fromJson(json['jadwal_sidang'] as Map<String, dynamic>),
      tanggalDaftar: json['tanggal_daftar'] as String,
    );
  }
}

class JadwalSidangPendaftaran {
  final int id;
  final String tanggal;
  final Sesi sesi;
  final Ruangan ruangan;

  JadwalSidangPendaftaran({
    required this.id,
    required this.tanggal,
    required this.sesi,
    required this.ruangan,
  });

  factory JadwalSidangPendaftaran.fromJson(Map<String, dynamic> json) {
    return JadwalSidangPendaftaran(
      id: json['id'] as int,
      tanggal: json['tanggal'] as String,
      sesi: Sesi.fromJson(json['sesi'] as Map<String, dynamic>),
      ruangan: Ruangan.fromJson(json['ruangan'] as Map<String, dynamic>),
    );
  }
}
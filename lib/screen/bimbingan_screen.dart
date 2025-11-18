import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Pastikan import file halaman aslimu jika sudah ada.
// import 'viewBimbingan_screen.dart'; 

class BimbinganScreen extends StatefulWidget {
  const BimbinganScreen({super.key});

  @override
  State<BimbinganScreen> createState() => _BimbinganScreenState();
}

class _BimbinganScreenState extends State<BimbinganScreen> {
  int _selectedIndex = 2;
  String _selectedFilter = 'Semua Bimbingan';
  
  // Index untuk melacak dosen mana yang sedang tampil di slider
  int _currentDosenIndex = 0; 

  // --- DATA DUMMY DOSEN (SLIDER ATAS) ---
  final List<Map<String, dynamic>> listStatusDosen = [
    {
      "nama": "Suko Tyas P", 
      "progress": 5,
      "total": 8,
    },
    {
      "nama": "Budi Santoso", 
      "progress": 2,
      "total": 8,
    },
  ];

  // --- DATA DUMMY BIMBINGAN (LIST BAWAH) ---
  List<Map<String, dynamic>> bimbinganList = [
    {
      "tanggal": "Senin,\n1 Mar",
      "namaDosen": "Suko Tyas P", 
      "judul": "Revisi Bab I: Pendahuluan",
      "status": "editable", 
    },
    {
      "tanggal": "Rabu,\n5 Mar",
      "namaDosen": "Suko Tyas P",
      "judul": "Bimbingan Bab II",
      "status": "verified", 
    },
    {
      "tanggal": "Jumat,\n7 Mar",
      "namaDosen": "Suko Tyas P",
      "judul": "Bimbingan Bab III",
      "status": "rejected", 
    },
    {
      "tanggal": "Senin,\n10 Mar",
      "namaDosen": "Budi Santoso",
      "judul": "Pengajuan Judul Skripsi",
      "status": "verified",
    },
  ];

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF149BF6);

    // --- LOGIKA FILTER ---
    final currentDosenName = listStatusDosen[_currentDosenIndex]['nama'];
    
    final filteredList = bimbinganList.where((item) {
      final matchDosen = item['namaDosen'] == currentDosenName;
      if (_selectedFilter == 'Semua Bimbingan') {
        return matchDosen;
      } else {
        return matchDosen && item['judul'].toString().contains(_selectedFilter);
      }
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), 
      
      // --- APP BAR ---
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        toolbarHeight: 60,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
             Text(
              "Suko Tyas",
              style: GoogleFonts.instrumentSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2A4B62),
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // --- BODY ---
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER STATUS ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Status Bimbingan",
                    style: GoogleFonts.instrumentSans(
                      fontSize: 18, 
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  
                  // --- TOMBOL CETAK (PINDAH HALAMAN) ---
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(4),
                      onTap: () {
                        // Pindah ke Halaman Cetak
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CetakScreen()),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                          children: [
                            Text(
                              "Cetak persetujuan", 
                              style: GoogleFonts.instrumentSans(
                                fontSize: 11, 
                                color: const Color(0xFF2A4B62),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.print, size: 18, color: Color(0xFF2A4B62)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),

              // --- SLIDER KARTU (PAGEVIEW) ---
              SizedBox(
                height: 110,
                child: PageView.builder(
                  controller: PageController(viewportFraction: 0.92),
                  itemCount: listStatusDosen.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentDosenIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final dosen = listStatusDosen[index];
                    return Container(
                      margin: const EdgeInsets.only(right: 10), 
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  dosen['nama'],
                                  style: GoogleFonts.instrumentSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: dosen['progress'] / dosen['total'],
                                    minHeight: 8,
                                    backgroundColor: Colors.grey[200],
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                               Text(
                                "${dosen['progress']}/${dosen['total']}",
                                style: GoogleFonts.instrumentSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              InkWell(
                                onTap: () {
                                    debugPrint("Buka Lembar Kontrol");
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.note_alt_outlined, 
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // --- HEADER PEMBIMBINGAN ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Pembimbingan",
                    style: GoogleFonts.instrumentSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  // --- TOMBOL TAMBAH (PINDAH HALAMAN) ---
                  ElevatedButton.icon(
                    onPressed: () async {
                      // Pindah ke Halaman ViewBimbinganScreen (Tambah)
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ViewBimbinganScreen()),
                      );
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text("Tambah"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),

              // --- DROPDOWN FILTER ---
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedFilter,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: const [
                      DropdownMenuItem(
                        value: 'Semua Bimbingan',
                        child: Text('Semua Bimbingan'),
                      ),
                      DropdownMenuItem(value: 'Bab I', child: Text('Bimbingan Bab I')),
                      DropdownMenuItem(value: 'Bab II', child: Text('Bimbingan Bab II')),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _selectedFilter = val!;
                      });
                    },
                  ),
                ),
              ),
              
              const SizedBox(height: 16),

              // --- LIST PEMBIMBINGAN ---
              filteredList.isEmpty 
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      "Belum ada riwayat bimbingan\nuntuk dosen ini.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.instrumentSans(color: Colors.grey),
                    ),
                  ),
                )
              : ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final item = filteredList[index];
                    
                    IconData statusIcon;
                    Color statusColor;
                    bool isEditable = false; 

                    switch (item["status"]) {
                      case "verified":
                        statusIcon = Icons.check_circle;
                        statusColor = Colors.green;
                        break;
                      case "editable":
                        statusIcon = Icons.edit; 
                        statusColor = Colors.orange;
                        isEditable = true;
                        break;
                      default:
                        statusIcon = Icons.cancel;
                        statusColor = Colors.red;
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 50,
                            child: Text(
                              item["tanggal"],
                              textAlign: TextAlign.center,
                              style: GoogleFonts.instrumentSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                                height: 1.2
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item["namaDosen"],
                                  style: GoogleFonts.instrumentSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item["judul"],
                                  style: GoogleFonts.instrumentSans(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(statusIcon, color: statusColor),
                            onPressed: () {
                              if (isEditable) {
                                debugPrint("Edit: ${item['judul']}");
                              } else {
                                debugPrint("Status: ${item['status']}");
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                )
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.note_alt), label: 'Info Sidang'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Bimbingan'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

// --- HALAMAN DUMMY UNTUK "TAMBAH" ---
class ViewBimbinganScreen extends StatelessWidget {
  const ViewBimbinganScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Form Tambah Bimbingan")),
      body: const Center(
        child: Text("Ini Halaman Tambah Bimbingan"),
      ),
    );
  }
}

// --- HALAMAN DUMMY UNTUK "CETAK" ---
class CetakScreen extends StatelessWidget {
  const CetakScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cetak Persetujuan")),
      body: const Center(
        child: Text("Ini Halaman Cetak / Preview Dokumen"),
      ),
    );
  }
}
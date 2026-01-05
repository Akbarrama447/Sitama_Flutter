import 'package:flutter/material.dart';
import '../constants/sidang_colors.dart';
import '../../../widgets/modern_back_button.dart';

class RevisiPage extends StatefulWidget {
  const RevisiPage({super.key});

  @override
  State<RevisiPage> createState() => _RevisiPageState();
}

class _RevisiPageState extends State<RevisiPage> {
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _fileController = TextEditingController();


  void _showUploadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text("Upload Revisi",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.cloud_upload_outlined, size: 60, color: Colors.blue),
              SizedBox(height: 15),
              Text("Pilih file PDF revisi Anda."),
              SizedBox(height: 5),
              Text("(Maks. 5 MB)",
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child:
                    const Text("Batal", style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Mengupload revisi...'),
                    duration: Duration(milliseconds: 500)));
                setState(() => _fileController.text = "revisi_final_v2.pdf");
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text("Pilih File",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                
                const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                Expanded(
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 250,
                        child: Container(
                          decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Color(0xFFE3F2FD), Colors.white])),
                        ),
                      ),
                      SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 20.0),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 5,
                                      offset: const Offset(0, 2))
                                ]),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      width: double.infinity,
                                      height: 4,
                                      color: SidangColors.cardTopBorderBlue),
                                  const Padding(
                                      padding: EdgeInsets.fromLTRB(20, 20, 20, 15),
                                      child: Text('Upload Revisi',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF37474F)))),
                                  const Divider(
                                      height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                                  Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildLabel("Judul"),
                                        const SizedBox(height: 8),
                                        _buildTextField(
                                            controller: _judulController,
                                            hintText: "Judul baru"),
                                        const SizedBox(height: 20),
                                        _buildLabel("Revisian"),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Expanded(
                                                child: _buildTextField(
                                                    controller: _fileController,
                                                    hintText: "revisian.pdf",
                                                    enabled: false)),
                                            const SizedBox(width: 10),
                                            Material(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              child: InkWell(
                                                onTap: () =>
                                                    _showUploadDialog(context),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                child: Container(
                                                    height: 45,
                                                    width: 45,
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: SidangColors.borderColor),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                4)),
                                                    child: const Icon(
                                                        Icons.description_outlined,
                                                        color: Colors.grey)),
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  const Divider(
                                      height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                                  Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 25.0),
                                    child: Center(
                                      child: SizedBox(
                                        width: 150,
                                        height: 40,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            if (_fileController.text.isEmpty) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                      content: Text(
                                                          "Harap upload file revisi dulu!")));
                                              return;
                                            }
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                                    content: Text(
                                                        "Revisi Berhasil Dikirim!")));
                                            Navigator.pop(context);
                                          },
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: SidangColors.buttonBlue,
                                              foregroundColor: Colors.white,
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(6))),
                                          child: const Text('Upload',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ModernBackButton(),
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(label,
        style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF455A64),
            fontWeight: FontWeight.w500));
  }

  Widget _buildTextField(
      {required TextEditingController controller,
      required String hintText,
      bool enabled = true}) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: SidangColors.borderColor)),
      child: TextField(
          controller: controller,
          enabled: enabled,
          style: const TextStyle(fontSize: 13, color: Colors.black87),
          decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 12))),
    );
  }
}
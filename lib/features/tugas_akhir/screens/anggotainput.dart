class AnggotaInputRow extends StatefulWidget {
  final TextEditingController controller;
  final List<Map<String, dynamic>> daftarMahasiswa;

  const AnggotaInputRow({
    super.key,
    required this.controller,
    required this.daftarMahasiswa,
  });

  @override
  State<AnggotaInputRow> createState() => _AnggotaInputRowState();
}

class _AnggotaInputRowState extends State<AnggotaInputRow> {
  // LayerLink ini kuncinya supaya dropdown nempel pas di bawah input
  final LayerLink _layerLink = LayerLink();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CompositedTransformTarget( // 1. Target posisi (Input)
          link: _layerLink,
          child: RawAutocomplete<Map<String, dynamic>>(
            textEditingController: widget.controller,
            // JANGAN pasang focusNode di sini, biarkan default
            
            optionsBuilder: (TextEditingValue val) {
              if (val.text.isEmpty) return const Iterable.empty();
              return widget.daftarMahasiswa.where((m) {
                final String name = m['name']?.toString().toLowerCase() ?? '';
                final String nim = m['nim']?.toString().toLowerCase() ?? '';
                final String search = val.text.toLowerCase();
                return name.contains(search) || nim.contains(search);
              });
            },
            
            displayStringForOption: (opt) => opt['name'].toString(),
            
            fieldViewBuilder: (ctx, ctrl, focusNode, submit) {
              return TextFormField(
                controller: ctrl,
                focusNode: focusNode, // Pakai focusNode bawaan builder
                decoration: InputDecoration(
                  labelText: 'Cari Nama/NIM Teman',
                  hintText: 'Ketik nama...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onFieldSubmitted: (value) => submit(),
              );
            },

            optionsViewBuilder: (ctx, onSelect, options) {
              return CompositedTransformFollower( // 2. Pengikut posisi (Dropdown)
                link: _layerLink,
                showWhenUnlinked: false,
                targetAnchor: Alignment.bottomLeft, // Muncul di bawah kiri target
                
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4.0,
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                    child: SizedBox(
                      width: constraints.maxWidth, // Lebar samain dengan input
                      height: 200, // Batasi tinggi biar bisa discroll
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (ctx, i) {
                          final opt = options.elementAt(i);
                          return ListTile(
                            title: Text(opt['name'].toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(opt['nim'].toString()),
                            onTap: () => onSelect(opt),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
import 'package:flutter/material.dart';

class ModernBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? size;
  final double? iconSize;
  final EdgeInsets? padding;
  final bool useSafeArea;

  const ModernBackButton({
    Key? key,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size,
    this.iconSize,
    this.padding,
    this.useSafeArea = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Warna biru utama SITAMA
    const Color blueMain = Color.fromARGB(255, 116, 165, 250);

    return Positioned(
      top: useSafeArea ? 60 : 30,  // Increased from 50/20 to 60/30 to give more space
      left: 16,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed ?? () => Navigator.of(context).pop(),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: size ?? 40,
            height: size ?? 40,
            padding: padding ?? const EdgeInsets.all(8),
            decoration: BoxDecoration(
              // Default background jadi biru transparan jika tidak diisi
              color: backgroundColor ?? blueMain.withOpacity(0.2),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: blueMain.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              size: iconSize ?? 20,
              // Default icon jadi biru pekat
              color: iconColor ?? blueMain,
            ),
          ),
        ),
      ),
    );
  }
}

class ModernBackButtonWithAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? titleColor;
  final List<Widget>? actions;
  final bool centerTitle;

  const ModernBackButtonWithAppBar({
    Key? key,
    required this.title,
    this.onBackPressed,
    this.backgroundColor,
    this.iconColor,
    this.titleColor,
    this.actions,
    this.centerTitle = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Warna biru utama SITAMA
    const Color blueMain = Color.fromARGB(255, 116, 165, 250);

    return AppBar(
      // Background AppBar jadi Biru
      backgroundColor: backgroundColor ?? blueMain,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new,
          size: 20,
          // Icon panah jadi Putih agar kontras dengan background biru
          color: iconColor ?? Colors.white,
        ),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
      ),
      title: Text(
        title,
        style: TextStyle(
          // Teks Judul jadi Putih
          color: titleColor ?? Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: centerTitle,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
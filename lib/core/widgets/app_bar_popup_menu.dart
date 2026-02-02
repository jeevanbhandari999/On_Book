import 'package:flutter/material.dart';

class AppPopupMenuItem {
  final String value;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const AppPopupMenuItem({
    required this.value,
    required this.label,
    required this.icon,
    required this.onTap,
  });
}

class AppPopupMenu extends StatefulWidget {
  final List<AppPopupMenuItem> items;
  final IconData icon;
  final Color iconColor;
  final double iconSize;

  const AppPopupMenu({
    super.key,
    required this.items,
    this.icon = Icons.more_vert,
    this.iconColor = Colors.black,
    this.iconSize = 24,
  });

  @override
  State<AppPopupMenu> createState() => _AppPopupMenuState();
}

class _AppPopupMenuState extends State<AppPopupMenu> {
  final GlobalKey _iconKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: _iconKey,
      icon: Icon(widget.icon, color: widget.iconColor, size: widget.iconSize),
      onPressed: () => _showPopup(context),
    );
  }

  void _showPopup(BuildContext context) {
    final RenderBox button =
        _iconKey.currentContext!.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final position = RelativeRect.fromLTRB(
      button.localToGlobal(Offset.zero).dx,
      button.localToGlobal(Offset.zero).dy + button.size.height,
      overlay.size.width -
          (button.localToGlobal(Offset.zero).dx + button.size.width),
      0,
    );

    showMenu(
      context: context,
      position: position,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      items: widget.items.map(_buildMenuItem).toList(),
    );
  }

  PopupMenuItem _buildMenuItem(AppPopupMenuItem item) {
    return PopupMenuItem(
      value: item.value,
      onTap: item.onTap,
      child: Row(
        children: [
          Icon(item.icon, size: 20, color: Colors.black),
          const SizedBox(width: 12),
          Text(item.label),
        ],
      ),
    );
  }
}

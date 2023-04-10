import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class ActionIcon extends StatefulWidget {
  final VoidCallback editAction;
  final VoidCallback deleteAction;
  const ActionIcon(
      {Key? key, required this.editAction, required this.deleteAction})
      : super(key: key);

  @override
  State<ActionIcon> createState() => _ActionIconState();
}

class _ActionIconState extends State<ActionIcon> {
  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2(
        customButton: const Icon(
          Icons.more_vert_outlined,
          size: 35,
          // color: Colors.red,
        ),
        // customItemsHeights: [
        //   ...List<double>.filled(MenuItems.firstItems.length, 48),
        //   8,
        //   ...List<double>.filled(MenuItems.secondItems.length, 48),
        // ],
        items: [
          ...MenuItems.firstItems.map(
            (item) => DropdownMenuItem<MenuItem>(
              value: item,
              child: MenuItems.buildItem(item),
            ),
          ),
        ],
        onChanged: (value) {
          MenuItem a = value as MenuItem;
          if (a.text == 'Borrar') {
            widget.deleteAction();
            return;
          }
          widget.editAction();
          // MenuItems.onChanged(context, value as MenuItem);
        },
        itemHeight: 48,
        itemPadding: const EdgeInsets.only(left: 16, right: 16),
        dropdownWidth: 160,
        dropdownPadding: const EdgeInsets.symmetric(vertical: 6),
        dropdownDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Colors.white,
        ),
        dropdownElevation: 8,
        offset: const Offset(0, 8),
      ),
    );
  }
}

class MenuItem {
  final String text;
  final IconData icon;

  const MenuItem({
    required this.text,
    required this.icon,
  });
}

class MenuItems {
  static const List<MenuItem> firstItems = [edit, delete];

  static const edit = MenuItem(text: 'Editar', icon: Icons.edit);
  static const delete = MenuItem(text: 'Borrar', icon: Icons.delete);

  static Widget buildItem(MenuItem item) {
    return Row(
      children: [
        Icon(item.icon, color: Colors.black),
        const SizedBox(
          width: 10,
        ),
        Text(
          item.text,
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import 'package:my_final_project/generated/l10n.dart';

class AddPageAppBar extends StatefulWidget implements PreferredSizeWidget {
  final bool status;
  final bool addSectionMode;

  const AddPageAppBar({
    super.key,
    required this.status,
    required this.addSectionMode,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  State<AddPageAppBar> createState() => _AddPageAppBarState();
}

class _AddPageAppBarState extends State<AddPageAppBar> {
  String titleText() {
    if (widget.addSectionMode) {
      return S.of(context).add_section;
    } else if (widget.status) {
      return S.of(context).edit_page;
    } else {
      return S.of(context).create_page;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        titleText(),
      ),
      automaticallyImplyLeading: false,
    );
  }
}

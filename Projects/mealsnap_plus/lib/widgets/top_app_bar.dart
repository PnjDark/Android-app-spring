import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../core/app_theme.dart';

class MealSnapTopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showMenu;
  final bool showSettings;
  final ImageProvider? profileImage;

  const MealSnapTopAppBar({
    super.key,
    this.title = 'MealSnap+',
    this.showMenu = true,
    this.showSettings = true,
    this.profileImage,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.backgroundColor,
      elevation: 0,
      centerTitle: false,
      leading: showMenu
          ? IconButton(
              icon: const Icon(Symbols.menu, color: AppTheme.primaryColor),
              onPressed: () {},
            )
          : null,
      title: Row(
        children: [
          if (!showMenu) const Icon(Symbols.restaurant, color: AppTheme.primaryColor),
          if (!showMenu) const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppTheme.primaryColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
      actions: [
        if (showSettings)
          IconButton(
            icon: const Icon(Symbols.settings, color: AppTheme.primaryColor),
            onPressed: () {},
          ),
        if (profileImage != null)
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2), width: 2),
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundImage: profileImage,
                backgroundColor: AppTheme.surfaceContainerLow,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

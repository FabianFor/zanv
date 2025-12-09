import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../l10n/app_localizations.dart';
import '../core/utils/theme_helper.dart';

class SortDropdown extends StatelessWidget {
  final String currentField;
  final bool ascending;
  final List<SortOption> options;
  final Function(String field, bool ascending) onSort;

  const SortDropdown({
    Key? key,
    required this.currentField,
    required this.ascending,
    required this.options,
    required this.onSort,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = ThemeHelper(context);

    return PopupMenuButton<String>(
      icon: Icon(
        Icons.sort,
        color: theme.iconColor,
        size: 24.sp,
      ),
      tooltip: l10n.sortBy,
      onSelected: (value) {
        if (value == currentField) {
          // Cambiar dirección si es el mismo campo
          onSort(value, !ascending);
        } else {
          // Nuevo campo, ascendente por defecto
          onSort(value, true);
        }
      },
      itemBuilder: (context) => options.map((option) {
        final isSelected = currentField == option.field;
        
        return PopupMenuItem<String>(
          value: option.field,
          child: Row(
            children: [
              Icon(
                option.icon,
                color: isSelected ? theme.primary : theme.iconColor,
                size: 20.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  option.getLabel(l10n),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: isSelected ? theme.primary : theme.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  ascending ? Icons.arrow_upward : Icons.arrow_downward,
                  color: theme.primary,
                  size: 18.sp,
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class SortOption {
  final String field;
  final IconData icon;
  final String Function(AppLocalizations) getLabel;

  SortOption({
    required this.field,
    required this.icon,
    required this.getLabel,
  });
}

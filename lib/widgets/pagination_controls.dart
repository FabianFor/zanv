import 'package:flutter/material.dart';

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;
  final bool isLoading;

  const PaginationControls({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Botón Anterior
          IconButton(
            onPressed: currentPage > 0 && !isLoading
                ? () => onPageChanged(currentPage - 1)
                : null,
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Página anterior',
          ),
          
          const SizedBox(width: 8),
          
          // Números de página
          _buildPageNumbers(context),
          
          const SizedBox(width: 8),
          
          // Botón Siguiente
          IconButton(
            onPressed: currentPage < totalPages - 1 && !isLoading
                ? () => onPageChanged(currentPage + 1)
                : null,
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Página siguiente',
          ),
        ],
      ),
    );
  }

  Widget _buildPageNumbers(BuildContext context) {
    final List<Widget> pageWidgets = [];
    
    // Calcular qué páginas mostrar
    int startPage = (currentPage - 2).clamp(0, totalPages - 1);
    int endPage = (currentPage + 2).clamp(0, totalPages - 1);
    
    // Ajustar para siempre mostrar 5 páginas si es posible
    if (endPage - startPage < 4) {
      if (startPage == 0) {
        endPage = (startPage + 4).clamp(0, totalPages - 1);
      } else if (endPage == totalPages - 1) {
        startPage = (endPage - 4).clamp(0, totalPages - 1);
      }
    }
    
    // Primera página si no está en el rango
    if (startPage > 0) {
      pageWidgets.add(_buildPageButton(context, 0));
      if (startPage > 1) {
        pageWidgets.add(const Text(' ... ', style: TextStyle(fontSize: 16)));
      }
    }
    
    // Páginas del rango
    for (int i = startPage; i <= endPage; i++) {
      pageWidgets.add(_buildPageButton(context, i));
    }
    
    // Última página si no está en el rango
    if (endPage < totalPages - 1) {
      if (endPage < totalPages - 2) {
        pageWidgets.add(const Text(' ... ', style: TextStyle(fontSize: 16)));
      }
      pageWidgets.add(_buildPageButton(context, totalPages - 1));
    }
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: pageWidgets,
    );
  }

  Widget _buildPageButton(BuildContext context, int page) {
    final bool isCurrent = page == currentPage;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: isLoading ? null : () => onPageChanged(page),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          decoration: BoxDecoration(
            color: isCurrent
                ? Theme.of(context).primaryColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isCurrent
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade300,
            ),
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '${page + 1}',
            style: TextStyle(
              color: isCurrent ? Colors.white : Colors.grey.shade700,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

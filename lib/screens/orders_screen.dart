import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../models/order.dart';  // ✅ AGREGAR ESTA LÍNEA
import '../providers/order_provider.dart';
import '../providers/settings_provider.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}


class _OrdersScreenState extends State<OrdersScreen> {
  String _searchQuery = '';
  String _selectedStatus = 'all';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final orderProvider = context.watch<OrderProvider>();
    final settingsProvider = context.watch<SettingsProvider>();

    List<Order> filteredOrders = orderProvider.orders;

    if (_searchQuery.isNotEmpty) {
      filteredOrders = orderProvider.searchOrders(_searchQuery);
    }

    if (_selectedStatus != 'all') {
      filteredOrders = filteredOrders
          .where((o) => o.status == _selectedStatus)
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.orders, style: TextStyle(fontSize: 18.sp)),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedStatus = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'all',
                child: Text(_getAllOrdersText(l10n)),
              ),
              PopupMenuItem(
                value: 'pending',
                child: Text(_getPendingOrdersText(l10n)),
              ),
              PopupMenuItem(
                value: 'completed',
                child: Text(_getCompletedOrdersText(l10n)),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            color: Colors.white,
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: _getSearchOrdersText(l10n),
                hintStyle: TextStyle(fontSize: 14.sp),
                prefixIcon: Icon(Icons.search, size: 20.sp),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, size: 20.sp),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
              style: TextStyle(fontSize: 14.sp),
            ),
          ),

          if (_selectedStatus != 'all')
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              color: Colors.blue[50],
              child: Row(
                children: [
                  Chip(
                    label: Text(_getStatusName(_selectedStatus, l10n)),
                    deleteIcon: Icon(Icons.close, size: 18.sp),
                    onDeleted: () {
                      setState(() {
                        _selectedStatus = 'all';
                      });
                    },
                  ),
                ],
              ),
            ),

          Expanded(
            child: filteredOrders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 80.sp,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          l10n.noOrders,
                          style: TextStyle(fontSize: 18.sp, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: InkWell(
                          onTap: () => _showOrderDetails(context, order, settingsProvider),
                          borderRadius: BorderRadius.circular(12.r),
                          child: Padding(
                            padding: EdgeInsets.all(16.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${_getOrderText(l10n)} #${order.orderNumber}',
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF2196F3),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12.w,
                                        vertical: 4.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: order.status == 'pending'
                                            ? Colors.orange.withOpacity(0.2)
                                            : Colors.green.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12.r),
                                      ),
                                      child: Text(
                                        _getStatusName(order.status, l10n),
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.bold,
                                          color: order.status == 'pending'
                                              ? Colors.orange[800]
                                              : Colors.green[800],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8.h),
                                Row(
                                  children: [
                                    Icon(Icons.person, size: 16.sp, color: Colors.grey[700]),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: Text(
                                        order.customerName,
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8.h),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt),
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      settingsProvider.formatPrice(order.total),
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF4CAF50),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

void _showOrderDetails(BuildContext context, Order order, SettingsProvider settingsProvider) {
  final l10n = AppLocalizations.of(context)!;
  final orderProvider = Provider.of<OrderProvider>(context, listen: false); // ✅ AGREGAR ESTA LÍNEA

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(height: 20.h),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_getOrderText(l10n)} #${order.orderNumber}',
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: order.status == 'pending'
                                ? Colors.orange.withOpacity(0.2)
                                : Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            _getStatusName(order.status, l10n),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: order.status == 'pending'
                                  ? Colors.orange[800]
                                  : Colors.green[800],
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Text(
                          order.customerName,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (order.customerPhone.isNotEmpty)
                          Text(
                            order.customerPhone,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        SizedBox(height: 8.h),
                        Text(
                          DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt),
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 24.h),
                        Text(
                          '${l10n.products}:',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        ...order.items.map((item) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 12.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item.productName} x${item.quantity}',
                                    style: TextStyle(fontSize: 14.sp),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Text(
                                  settingsProvider.formatPrice(item.total),
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        Divider(height: 32.h, thickness: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${l10n.total}:',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              settingsProvider.formatPrice(order.total),
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF4CAF50),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                if (order.status == 'pending')
                  ElevatedButton.icon(
                    onPressed: () async {
                      await orderProvider.updateOrderStatus(order.id, 'completed');
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_getOrderCompletedText(l10n)),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.check_circle),
                    label: Text(_getMarkCompletedText(l10n)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 50.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getAllOrdersText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es': return 'Todos los pedidos';
      case 'en': return 'All orders';
      case 'pt': return 'Todos os pedidos';
      case 'zh': return '所有订单';
      default: return 'All orders';
    }
  }

  String _getPendingOrdersText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es': return 'Pendientes';
      case 'en': return 'Pending';
      case 'pt': return 'Pendentes';
      case 'zh': return '待处理';
      default: return 'Pending';
    }
  }

  String _getCompletedOrdersText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es': return 'Completados';
      case 'en': return 'Completed';
      case 'pt': return 'Concluídos';
      case 'zh': return '已完成';
      default: return 'Completed';
    }
  }

  String _getSearchOrdersText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es': return 'Buscar pedidos...';
      case 'en': return 'Search orders...';
      case 'pt': return 'Buscar pedidos...';
      case 'zh': return '搜索订单...';
      default: return 'Search orders...';
    }
  }

  String _getOrderText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es': return 'Pedido';
      case 'en': return 'Order';
      case 'pt': return 'Pedido';
      case 'zh': return '订单';
      default: return 'Order';
    }
  }

  String _getStatusName(String status, AppLocalizations l10n) {
    switch (status) {
      case 'pending':
        return _getPendingOrdersText(l10n);
      case 'completed':
        return _getCompletedOrdersText(l10n);
      default:
        return status;
    }
  }

  String _getMarkCompletedText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es': return 'Marcar como completado';
      case 'en': return 'Mark as completed';
      case 'pt': return 'Marcar como concluído';
      case 'zh': return '标记为已完成';
      default: return 'Mark as completed';
    }
  }

  String _getOrderCompletedText(AppLocalizations l10n) {
    switch (l10n.localeName) {
      case 'es': return 'Pedido completado';
      case 'en': return 'Order completed';
      case 'pt': return 'Pedido concluído';
      case 'zh': return '订单已完成';
      default: return 'Order completed';
    }
  }
}

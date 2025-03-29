import 'package:forever_fusion/containers/additional_confirm.dart';
import 'package:forever_fusion/controllers/db_service.dart';
import 'package:forever_fusion/models/orders_model.dart';
import 'package:flutter/material.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  int totalQuantityCalculator(List<OrderProductModel> products) {
    return products.fold(0, (sum, item) => sum + item.quantity);
  }

  Widget statusIcon(String status) {
    Map<String, Map<String, dynamic>> statusStyles = {
      "PAID": {"text": "PAID", "bg": Colors.lightGreen, "textColor": Colors.white},
      "ON_THE_WAY": {"text": "ON THE WAY", "bg": Colors.yellow, "textColor": Colors.black},
      "DELIVERED": {"text": "DELIVERED", "bg": Colors.green.shade700, "textColor": Colors.white},
      "CANCELED": {"text": "CANCELED", "bg": Colors.red, "textColor": Colors.white},
    };

    return Container(
      padding: EdgeInsets.all(8),
      color: statusStyles[status]?["bg"] ?? Colors.grey,
      child: Text(
        statusStyles[status]?["text"] ?? "UNKNOWN",
        style: TextStyle(color: statusStyles[status]?["textColor"] ?? Colors.black),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Orders", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
      ),
      body: StreamBuilder(
        stream: DbService().readOrders(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print("Firestore Error: ${snapshot.error}");
            return Center(child: Text("Error loading orders"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No orders found"));
          }

          List<OrdersModel> orders = snapshot.data!.docs
              .map((doc) => OrdersModel.fromJson(doc.data() as Map<String, dynamic>, doc.id))
              .toList();

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              return ListTile(
                onTap: () {
                  print("Navigating to order: ${orders[index].id}");
                  Navigator.pushNamed(context, "/view_order", arguments: orders[index]);
                },
                title: Text("${totalQuantityCalculator(orders[index].products)} Items Worth ₹ ${orders[index].total}"),
                subtitle: Text("Ordered on ${DateTime.fromMillisecondsSinceEpoch(orders[index].created_at)}"),
                trailing: statusIcon(orders[index].status),
              );
            },
          );
        },
      ),
    );
  }
}

class ViewOrder extends StatefulWidget {
  const ViewOrder({super.key});

  @override
  State<ViewOrder> createState() => _ViewOrderState();
}

class _ViewOrderState extends State<ViewOrder> {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as OrdersModel?;

    if (args == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Order Summary")),
        body: Center(child: Text("Order details not found")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Order Summary")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _orderDetailsSection(args),
            _productsList(args.products),
            _orderSummary(args),
            if (args.status == "PAID" || args.status == "ON_THE_WAY")
              _modifyOrderButton(context, args),
          ],
        ),
      ),
    );
  }

  Widget _orderDetailsSection(OrdersModel order) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8),
      color: Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Order Id: ${order.id}"),
          Text("Order On: ${DateTime.fromMillisecondsSinceEpoch(order.created_at)}"),
          Text("Order by: ${order.name}"),
          Text("Phone no: ${order.phone}"),
          Text("Delivery Address: ${order.address}"),
        ],
      ),
    );
  }

  Widget _productsList(List<OrderProductModel> products) {
    return Column(
      children: products.map((e) => _productItem(e)).toList(),
    );
  }

  Widget _productItem(OrderProductModel product) {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              Image.network(product.image, height: 50, width: 50, fit: BoxFit.cover),
              SizedBox(width: 10),
              Expanded(child: Text(product.name)),
            ],
          ),
          Text("₹${product.single_price} x ${product.quantity} quantity", style: TextStyle(fontWeight: FontWeight.bold)),
          Text("₹${product.total_price}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        ],
      ),
    );
  }

  Widget _orderSummary(OrdersModel order) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Discount: ₹${order.discount}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          Text("Total: ₹${order.total}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          Text("Status: ${order.status}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        ],
      ),
    );
  }

  Widget _modifyOrderButton(BuildContext context, OrdersModel order) {
    return SizedBox(
      height: 60,
      width: MediaQuery.of(context).size.width * .9,
      child: ElevatedButton(
        child: Text("Modify Order"),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => ModifyOrder(order: order),
          );
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
      ),
    );
  }
}

class ModifyOrder extends StatelessWidget {
  final OrdersModel order;
  const ModifyOrder({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Modify this order"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Choose what you want to do"),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => AdditionalConfirm(
                  contentText: "After canceling, this cannot be changed. You need to order again.",
                  onYes: () async {
                    await DbService().updateOrderStatus(docId: order.id, data: {"status": "CANCELLED"});
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Order Updated")));
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  onNo: () => Navigator.pop(context),
                ),
              );
            },
            child: Text("Cancel Order"),
          ),
        ],
      ),
    );
  }
}

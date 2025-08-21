import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../helpers/dashboard_data_helper.dart';

class LowInventoryWidget extends StatelessWidget {
  final List<QueryDocumentSnapshot> products;

  const LowInventoryWidget({Key? key, required this.products})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = DashboardDataHelper.processDashboardData(products);
    final lowInventory = data['lowInventory'] as List<QueryDocumentSnapshot>;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Low Inventory Alert',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            lowInventory.isEmpty
                ? Text(
                    'No products are low in stock.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  )
                : SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: lowInventory.length,
                      itemBuilder: (context, idx) {
                        final doc = lowInventory[idx];
                        return ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: 100,
                            maxWidth: MediaQuery.of(context).size.width * 0.35,
                          ),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: Text(
                                    doc['Product_Name'] ?? 'Unknown',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  'Qty: ${doc['Stock_Quantity']}',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class RecentActivityWidget extends StatelessWidget {
  final List<QueryDocumentSnapshot> products;

  const RecentActivityWidget({Key? key, required this.products})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = DashboardDataHelper.processDashboardData(products);
    final recentFive = data['recentFive'] as List<QueryDocumentSnapshot>;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Inventory Activity',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: recentFive.length,
                itemBuilder: (context, idx) {
                  final doc = recentFive[idx];
                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: 120,
                      maxWidth: MediaQuery.of(context).size.width * 0.45,
                    ),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              doc['Product_Name'] ?? 'Unknown',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            'Received: ${doc['Date_Received']}',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Qty: ${doc['Stock_Quantity']}',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:finalproject/core/theme/app_colors.dart';
import 'package:finalproject/core/theme/app_radius.dart';
import 'package:finalproject/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/product.model.dart';
import 'widgets/product_list_item.dart';
import 'widgets/add_edit_product_dialog.dart';
import 'widgets/product_search_bar.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  String _searchQuery = '';
  String _categoryFilter = 'All';
  String _statusFilter = 'All';
  bool _showLowStockOnly = false;
  List<String> _categories = ['All'];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categoriesSnapshot = await FirebaseFirestore.instance
        .collection('categories')
        .orderBy('name')
        .get();

    setState(() {
      _categories = [
        'All',
        ...categoriesSnapshot.docs.map((doc) => doc['name'] as String),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Management'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.lightSurface,
        elevation: 2,
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.lightCardBackground,
              boxShadow: [
                BoxShadow(
                  color: AppColors.lightMainText.withOpacity(0.05),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Column(
              children: [
                ProductSearchBar(
                  onSearchChanged: (query) {
                    setState(() {
                      _searchQuery = query;
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _buildFilterDropdown(
                        'Category',
                        _categoryFilter,
                        _categories,
                        (value) {
                          setState(() {
                            _categoryFilter = value ?? 'All';
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _buildFilterDropdown(
                        'Status',
                        _statusFilter,
                        ['All', 'Active', 'Inactive', 'Discontinued'],
                        (value) {
                          setState(() {
                            _statusFilter = value ?? 'All';
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    FilterChip(
                      label: const Text('Low Stock Only'),
                      selected: _showLowStockOnly,
                      onSelected: (selected) {
                        setState(() {
                          _showLowStockOnly = selected;
                        });
                      },
                      selectedColor: AppColors.warning,
                      checkmarkColor: AppColors.error,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Product List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading products',
                          style: TextStyle(
                            color: Colors.red[600],
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          style: TextStyle(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No products found',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add your first product to get started',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                final products = snapshot.data!.docs
                    .map(
                      (doc) => ProductModel.fromMap(
                        doc.data() as Map<String, dynamic>,
                      ),
                    )
                    .where((product) => _filterProduct(product))
                    .toList();

                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No products match your filters',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or filters',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductListItem(
                      product: product,
                      onEdit: () => _showEditProductDialog(product),
                      onDelete: () => _showDeleteConfirmation(product),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddProductDialog(),
        label: const Text('Add Product'),
        icon: const Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildFilterDropdown(
    String label,
    String currentValue,
    List<String> options,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: currentValue,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          items: options.map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: onChanged,
          icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
        ),
      ],
    );
  }

  bool _filterProduct(ProductModel product) {
    // Search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      if (!product.productName.toLowerCase().contains(query) &&
          !product.category.toLowerCase().contains(query) &&
          !product.supplierName.toLowerCase().contains(query)) {
        return false;
      }
    }

    // Category filter
    if (_categoryFilter != 'All' && product.category != _categoryFilter) {
      return false;
    }

    // Status filter
    if (_statusFilter != 'All' && product.status != _statusFilter) {
      return false;
    }

    // Low stock filter
    if (_showLowStockOnly && product.stockQuantity > product.reorderLevel) {
      return false;
    }

    return true;
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddEditProductDialog(),
    );
  }

  void _showEditProductDialog(ProductModel product) {
    showDialog(
      context: context,
      builder: (context) => AddEditProductDialog(product: product),
    );
  }

  void _showDeleteConfirmation(ProductModel product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text(
          'Are you sure you want to delete "${product.productName}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteProduct(product);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProduct(ProductModel product) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(product.productId)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.productName} deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting product: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

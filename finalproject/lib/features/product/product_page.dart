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

  // Pagination state
  static const int _pageSize = 200;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> _loadedDocuments =
      <QueryDocumentSnapshot<Map<String, dynamic>>>[];
  final Set<String> _loadedIds = <String>{};
  final ScrollController _scrollController = ScrollController();
  bool _isFetching = false;
  bool _hasMore = true;
  QueryDocumentSnapshot<Map<String, dynamic>>? _lastDocument;
  String _orderByField = 'Product_Name';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchFirstPage();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasMore || _isFetching) return;
    if (!_scrollController.hasClients) return;
    final double threshold =
        _scrollController.position.maxScrollExtent * 0.85; // 85% down
    if (_scrollController.position.pixels >= threshold) {
      _fetchNextPage();
    }
  }

  Future<void> _fetchFirstPage() async {
    setState(() {
      _isFetching = true;
      _errorMessage = null;
      _loadedDocuments.clear();
      _loadedIds.clear();
      _hasMore = true;
      _lastDocument = null;
    });
    await _fetchInternal();
  }

  Future<void> _fetchNextPage() async {
    if (!_hasMore || _isFetching) return;
    await _fetchInternal();
  }

  Future<void> _fetchInternal() async {
    try {
      setState(() {
        _isFetching = true;
      });

      Query<Map<String, dynamic>> query = FirebaseFirestore.instance
          .collection('products')
          .orderBy(_orderByField)
          .limit(_pageSize);
      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }
      final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        for (final doc in snapshot.docs) {
          if (_loadedIds.add(doc.id)) {
            _loadedDocuments.add(doc);
          }
        }
        _lastDocument = snapshot.docs.last;
      }

      setState(() {
        _hasMore = snapshot.docs.length == _pageSize;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load products: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isFetching = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Management'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
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
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildFilterDropdown(
                        'Category',
                        _categoryFilter,
                        [
                          'All',
                          'Electronics',
                          'Clothing',
                          'Food',
                          'Books',
                          'Other',
                        ],
                        (value) {
                          setState(() {
                            _categoryFilter = value ?? 'All';
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
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
                    const SizedBox(width: 16),
                    FilterChip(
                      label: const Text('Low Stock Only'),
                      selected: _showLowStockOnly,
                      onSelected: (selected) {
                        setState(() {
                          _showLowStockOnly = selected;
                        });
                      },
                      selectedColor: Colors.red[100],
                      checkmarkColor: Colors.red[700],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Product List
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchFirstPage,
              child: _buildPaginatedList(),
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

  Future<void> _showAddProductDialog() async {
    await showDialog(
      context: context,
      builder: (context) => const AddEditProductDialog(),
    );
    if (mounted) await _fetchFirstPage();
  }

  Future<void> _showEditProductDialog(ProductModel product) async {
    await showDialog(
      context: context,
      builder: (context) => AddEditProductDialog(product: product),
    );
    if (mounted) await _fetchFirstPage();
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
        // Remove locally if present
        _loadedDocuments.removeWhere((doc) => doc.id == product.productId);
        _loadedIds.remove(product.productId);
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

  Widget _buildPaginatedList() {
    if (_errorMessage != null) {
      return ListView(
        controller: _scrollController,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
          TextButton(onPressed: _fetchFirstPage, child: const Text('Retry')),
        ],
      );
    }

    if (_loadedDocuments.isEmpty && _isFetching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadedDocuments.isEmpty) {
      return ListView(
        controller: _scrollController,
        children: [
          const SizedBox(height: 80),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No products found',
                  style: TextStyle(color: Colors.grey[600], fontSize: 18),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Convert to ProductModel and client-filter the current window
    final products = _loadedDocuments
        .map((doc) => ProductModel.fromMap(doc.data()))
        .where((p) => _filterProduct(p))
        .toList();

    if (products.isEmpty && !_hasMore && !_isFetching) {
      return ListView(
        controller: _scrollController,
        children: const [
          SizedBox(height: 80),
          Center(child: Text('No products match your filters')),
        ],
      );
    }

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.all(8.0),
      itemCount: products.length + 1,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        if (index == products.length) {
          if (_isFetching) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (!_hasMore) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(child: Text('No more products')),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: OutlinedButton(
                onPressed: _fetchNextPage,
                child: const Text('Load more'),
              ),
            ),
          );
        }

        final product = products[index];
        return ProductListItem(
          product: product,
          onEdit: () => _showEditProductDialog(product),
          onDelete: () => _showDeleteConfirmation(product),
        );
      },
    );
  }
}

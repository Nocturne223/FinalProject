import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/product.model.dart';

class AddEditProductDialog extends StatefulWidget {
  final ProductModel? product;

  const AddEditProductDialog({super.key, this.product});

  @override
  State<AddEditProductDialog> createState() => _AddEditProductDialogState();
}

class _AddEditProductDialogState extends State<AddEditProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  late TextEditingController _productNameController;
  late TextEditingController _categoryController;
  late TextEditingController _supplierNameController;
  late TextEditingController _warehouseLocationController;
  late TextEditingController _supplierIdController;
  late TextEditingController _stockQuantityController;
  late TextEditingController _reorderLevelController;
  late TextEditingController _reorderQuantityController;
  late TextEditingController _unitPriceController;
  late TextEditingController _salesVolumeController;
  late TextEditingController _inventoryTurnoverRateController;
  late TextEditingController _percentageController;

  late String _status;
  late DateTime _dateReceived;
  late DateTime _lastOrderDate;
  late DateTime _expirationDate;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final product = widget.product;

    _productNameController = TextEditingController(
      text: product?.productName ?? '',
    );
    _categoryController = TextEditingController(text: product?.category ?? '');
    _supplierNameController = TextEditingController(
      text: product?.supplierName ?? '',
    );
    _warehouseLocationController = TextEditingController(
      text: product?.warehouseLocation ?? '',
    );
    _supplierIdController = TextEditingController(
      text: product?.supplierId ?? '',
    );
    _stockQuantityController = TextEditingController(
      text: product?.stockQuantity.toString() ?? '',
    );
    _reorderLevelController = TextEditingController(
      text: product?.reorderLevel.toString() ?? '',
    );
    _reorderQuantityController = TextEditingController(
      text: product?.reorderQuantity.toString() ?? '',
    );
    _unitPriceController = TextEditingController(
      text: product?.unitPrice.toString() ?? '',
    );
    _salesVolumeController = TextEditingController(
      text: product?.salesVolume.toString() ?? '',
    );
    _inventoryTurnoverRateController = TextEditingController(
      text: product?.inventoryTurnoverRate.toString() ?? '',
    );
    _percentageController = TextEditingController(
      text: product?.percentage ?? '',
    );

    _status = product?.status ?? 'Active';
    _dateReceived = product?.dateReceived ?? DateTime.now();
    _lastOrderDate = product?.lastOrderDate ?? DateTime.now();
    _expirationDate =
        product?.expirationDate ??
        DateTime.now().add(const Duration(days: 365));
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _categoryController.dispose();
    _supplierNameController.dispose();
    _warehouseLocationController.dispose();
    _supplierIdController.dispose();
    _stockQuantityController.dispose();
    _reorderLevelController.dispose();
    _reorderQuantityController.dispose();
    _unitPriceController.dispose();
    _salesVolumeController.dispose();
    _inventoryTurnoverRateController.dispose();
    _percentageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isEditing ? Icons.edit : Icons.add,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isEditing ? 'Edit Product' : 'Add New Product',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Information Section
                      _buildSectionHeader('Basic Information'),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _productNameController,
                              label: 'Product Name',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Product name is required';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _categoryController,
                              label: 'Category',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Category is required';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _supplierNameController,
                              label: 'Supplier Name',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Supplier name is required';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _supplierIdController,
                              label: 'Supplier ID',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _warehouseLocationController,
                        label: 'Warehouse Location',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Warehouse location is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdownField(
                              label: 'Status',
                              value: _status,
                              items: [
                                'Active',
                                'Inactive',
                                'Discontinued',
                                'Backordered',
                                'Out of Stock',
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _status = value ?? 'Active';
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _percentageController,
                              label: 'Percentage',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Inventory Section
                      _buildSectionHeader('Inventory Details'),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _stockQuantityController,
                              label: 'Stock Quantity',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Stock quantity is required';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Must be a valid number';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _reorderLevelController,
                              label: 'Reorder Level',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Reorder level is required';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Must be a valid number';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _reorderQuantityController,
                              label: 'Reorder Quantity',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Reorder quantity is required';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Must be a valid number';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _unitPriceController,
                              label: 'Unit Price (\$)',
                              keyboardType: TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Unit price is required';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Must be a valid price';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Performance Section
                      _buildSectionHeader('Performance Metrics'),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _salesVolumeController,
                              label: 'Sales Volume',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _inventoryTurnoverRateController,
                              label: 'Inventory Turnover Rate',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Dates Section
                      _buildSectionHeader('Important Dates'),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateField(
                              label: 'Date Received',
                              value: _dateReceived,
                              onChanged: (date) {
                                setState(() {
                                  _dateReceived = date ?? DateTime.now();
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDateField(
                              label: 'Last Order Date',
                              value: _lastOrderDate,
                              onChanged: (date) {
                                setState(() {
                                  _lastOrderDate = date ?? DateTime.now();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildDateField(
                        label: 'Expiration Date',
                        value: _expirationDate,
                        onChanged: (date) {
                          setState(() {
                            _expirationDate =
                                date ??
                                DateTime.now().add(const Duration(days: 365));
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveProduct,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(isEditing ? 'Update' : 'Create'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          items: items.map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime value,
    required Function(DateTime?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: value,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (date != null) {
              onChanged(date);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${value.month}/${value.day}/${value.year}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                Icon(Icons.calendar_today, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final productData = {
        'Product_ID': widget.product?.productId ?? _uuid.v4(),
        'Product_Name': _productNameController.text.trim(),
        'Catagory': _categoryController.text.trim(),
        'Supplier_Name': _supplierNameController.text.trim(),
        'Warehouse_Location': _warehouseLocationController.text.trim(),
        'Status': _status,
        'Supplier_ID': _supplierIdController.text.trim(),
        'Date_Received': _dateReceived.toIso8601String(),
        'Last_Order_Date': _lastOrderDate.toIso8601String(),
        'Expiration_Date': _expirationDate.toIso8601String(),
        'Stock_Quantity': int.parse(_stockQuantityController.text),
        'Reorder_Level': int.parse(_reorderLevelController.text),
        'Reorder_Quantity': int.parse(_reorderQuantityController.text),
        'Unit_Price': double.parse(_unitPriceController.text),
        'Sales_Volume': int.tryParse(_salesVolumeController.text) ?? 0,
        'Inventory_Turnover_Rate':
            int.tryParse(_inventoryTurnoverRateController.text) ?? 0,
        'percentage': _percentageController.text.trim(),
      };

      final docId = productData['Product_ID'] as String;
      await FirebaseFirestore.instance
          .collection('products')
          .doc(docId)
          .set(productData);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.product != null
                  ? 'Product updated successfully!'
                  : 'Product created successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving product: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

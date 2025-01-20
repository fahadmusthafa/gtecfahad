import 'package:flutter/material.dart';
import 'package:lms/models/admin_model.dart';
import 'package:lms/screens/admin/batch_management/admin_allusers.dart';
import 'package:provider/provider.dart';
import 'package:lms/provider/authprovider.dart';

class AdminCreateBatchScreen extends StatefulWidget {
  final int courseId;

  const AdminCreateBatchScreen({Key? key, required this.courseId})
      : super(key: key);

  @override
  State<AdminCreateBatchScreen> createState() => _AdminCreateBatchScreenState();
}

class _AdminCreateBatchScreenState extends State<AdminCreateBatchScreen> {
  final TextEditingController _batchNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminAuthProvider>(context, listen: false)
          .AdminfetchBatchForCourseProvider(widget.courseId);
    });
  }

  void _showEditModuleDialog(BuildContext context, AdminCourseBatch module) {
    final TextEditingController editTitleController =
        TextEditingController(text: module.batchName);
    bool isUpdating = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.edit,
                      size: 24, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  const Text('Edit Batch',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      )),
                ],
              ),
              content: TextField(
                controller: editTitleController,
                decoration: InputDecoration(
                  hintText: 'Enter new batch name',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 16),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isUpdating
                      ? null
                      : () {
                          Navigator.of(context).pop();
                        },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isUpdating
                      ? null
                      : () async {
                          if (editTitleController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Batch name cannot be empty.'),
                              ),
                            );
                            return;
                          }

                          setState(() {
                            isUpdating = true;
                          });

                          try {
                            final provider = Provider.of<AdminAuthProvider>(
                                context,
                                listen: false);

                            await provider.AdminUpdatebatchprovider(
                              widget.courseId,
                              module.batchId,
                              editTitleController.text.trim(),
                            );

                            Navigator.of(context).pop();

                            await provider.AdminfetchBatchForCourseProvider(
                                widget.courseId);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Batch updated successfully!'),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Error updating batch: ${e.toString()}'),
                              ),
                            );
                          } finally {
                            setState(() {
                              isUpdating = false;
                            });
                          }
                        },
                  child: isUpdating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Batches'),
      ),
      body: Consumer<AdminAuthProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final batches = provider.courseBatches[widget.courseId] ?? [];
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (batches.isEmpty)
                    const Text('No batches available.')
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: batches.length,
                      itemBuilder: (context, index) {
                        final batch = batches[index];
                        return Card(
                          child: ListTile(
                            title: Text(batch.batchName),
                            subtitle: Text('Batch ID: ${batch.batchId}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () {
                                    _showEditModuleDialog(context, batch);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () async {
                                    final confirm = await _confirmDelete(
                                        context);
                                    if (confirm) {
                                      await _deleteBatch(
                                          provider, batch.batchId);
                                    }
                                  },
                                ),
                                 IconButton(
                                      icon: const Icon(Icons.arrow_forward,
                                          size: 16),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AdminAllUsersPage(
                                              courseId: widget.courseId,
                                              batchId: batch.batchId, 
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _batchNameController,
                    decoration: const InputDecoration(
                      labelText: 'Batch Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      await _createBatch(provider);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 12.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Create Batch'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _createBatch(AdminAuthProvider provider) async {
    final batchName = _batchNameController.text.trim();
    if (batchName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Batch name cannot be empty')),
      );
      return;
    }

    provider.isLoading = true;

    try {
      await provider.AdmincreateBatchprovider(batchName, widget.courseId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Batch created successfully!')),
      );

      _batchNameController.clear();
      await provider.AdminfetchBatchForCourseProvider(widget.courseId);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create batch: $error')),
      );
    } finally {
      provider.isLoading = false;
    }
  }

  Future<void> _deleteBatch(AdminAuthProvider provider, int batchId) async {
    provider.isLoading = true;

    try {
      await provider.AdmindeleteBatchprovider(widget.courseId, batchId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Batch deleted successfully!')),
      );

      await provider.AdminfetchBatchForCourseProvider(widget.courseId);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete batch: $error')),
      );
    } finally {
      provider.isLoading = false;
    }
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete Batch'),
              content:
                  const Text('Are you sure you want to delete this batch?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  void dispose() {
    _batchNameController.dispose();
    super.dispose();
  }
}

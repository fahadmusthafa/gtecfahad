import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lms/models/admin_model.dart';
import 'package:lms/screens/admin/course_management/admin_module_add.dart';
import 'package:provider/provider.dart';
import 'package:lms/provider/authprovider.dart';
import 'package:intl/intl.dart';

class AdminCourseBatchScreen extends StatefulWidget {
  final int courseId;

  const AdminCourseBatchScreen({Key? key, required this.courseId})
      : super(key: key);

  @override
  State<AdminCourseBatchScreen> createState() => _AdminCourseBatchScreenState();
}

class _AdminCourseBatchScreenState extends State<AdminCourseBatchScreen> {
  final TextEditingController _batchNameController = TextEditingController();
  String? _selectedMedium;
  DateTime? _startDate;
  DateTime? _endDate;
  bool isMediumExpanded = false;

  final List<String> _mediumOptions = [
    'Malayalam',
    'English',
    'Tamil',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminAuthProvider>(context, listen: false)
          .AdminfetchBatchForCourseProvider(widget.courseId);
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Widget _buildMediumDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.language, size: 24, color: Colors.blue),
              const SizedBox(width: 12),
              Text(
                'SELECT MEDIUM',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () {
              setState(() {
                isMediumExpanded = !isMediumExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12),
                color: Colors.blue.withOpacity(0.05),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedMedium ?? 'Select Medium',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: _selectedMedium != null
                            ? Colors.black87
                            : Colors.grey[600],
                      ),
                    ),
                  ),
                  Icon(
                    isMediumExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ),
          if (isMediumExpanded) ...[
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemCount: _mediumOptions.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: Colors.grey.withOpacity(0.2),
                ),
                itemBuilder: (context, index) {
                  final medium = _mediumOptions[index];
                  final isSelected = _selectedMedium == medium;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedMedium = medium;
                        isMediumExpanded = false;
                      });
                      Provider.of<AdminAuthProvider>(context, listen: false)
                          .AdminfetchBatchForCourseProvider(widget.courseId);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      color: isSelected ? Colors.blue.withOpacity(0.05) : null,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            medium,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected ? Colors.blue : Colors.black87,
                            ),
                          ),
                          if (isSelected)
                            Icon(Icons.check, color: Colors.blue, size: 20),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showEditBatchDialog(BuildContext context, AdminCourseBatch batch) {
    final TextEditingController editNameController =
        TextEditingController(text: batch.batchName);
    String? editMedium = batch.medium;
    DateTime? editStartDate = batch.startTime;
    DateTime? editEndDate = batch.endTime;
    bool isUpdating = false;
    bool isMediumExpanded = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Edit Batch',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              contentPadding: const EdgeInsets.all(24),
              content: SizedBox(
                width: 600,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: editNameController,
                        decoration: InputDecoration(
                          labelText: 'Batch Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.group),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.grey.withOpacity(0.2)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  isMediumExpanded = !isMediumExpanded;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.blue.withOpacity(0.05),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.language,
                                        color: Colors.blue, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        editMedium ?? 'Select Medium',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: editMedium != null
                                              ? Colors.black87
                                              : Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      isMediumExpanded
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      color: Colors.blue,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (isMediumExpanded)
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.grey.withOpacity(0.2)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  physics: const ClampingScrollPhysics(),
                                  itemCount: _mediumOptions.length,
                                  separatorBuilder: (context, index) => Divider(
                                    height: 1,
                                    color: Colors.grey.withOpacity(0.2),
                                  ),
                                  itemBuilder: (context, index) {
                                    final medium = _mediumOptions[index];
                                    final isSelected = editMedium == medium;
                                    return InkWell(
                                      onTap: () {
                                        setState(() {
                                          editMedium = medium;
                                          isMediumExpanded = false;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        color: isSelected
                                            ? Colors.blue.withOpacity(0.05)
                                            : null,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              medium,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                                color: isSelected
                                                    ? Colors.blue
                                                    : Colors.black87,
                                              ),
                                            ),
                                            if (isSelected)
                                              const Icon(Icons.check,
                                                  color: Colors.blue, size: 20),
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
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: 'Start Date',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.calendar_today),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              controller: TextEditingController(
                                text: editStartDate != null
                                    ? DateFormat('yyyy-MM-dd')
                                        .format(editStartDate!)
                                    : '',
                              ),
                              onTap: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: editStartDate ?? DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2030),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: ColorScheme.light(
                                          primary: Colors.blue,
                                          onPrimary: Colors.white,
                                          surface: Colors.white,
                                          onSurface: Colors.black,
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (picked != null) {
                                  setState(() {
                                    editStartDate = picked;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: 'End Date',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.calendar_today),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              controller: TextEditingController(
                                text: editEndDate != null
                                    ? DateFormat('yyyy-MM-dd')
                                        .format(editEndDate!)
                                    : '',
                              ),
                              onTap: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: editEndDate ?? DateTime.now(),
                                  firstDate: editStartDate ?? DateTime.now(),
                                  lastDate: DateTime(2030),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: ColorScheme.light(
                                          primary: Colors.blue,
                                          onPrimary: Colors.white,
                                          surface: Colors.white,
                                          onSurface: Colors.black,
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (picked != null) {
                                  setState(() {
                                    editEndDate = picked;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isUpdating ? null : () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
                ElevatedButton(
                  onPressed: isUpdating
                      ? null
                      : () async {
                          if (editNameController.text.trim().isEmpty) {
                            _showError(context, 'Please enter a batch name');
                            return;
                          }
                          if (editMedium == null) {
                            _showError(context, 'Please select a medium');
                            return;
                          }
                          if (editStartDate == null) {
                            _showError(context, 'Please select a start date');
                            return;
                          }

                          if (editEndDate == null) {
                            _showError(context, 'Please select an end date');
                            return;
                          }
                          if (editEndDate!.isBefore(editStartDate!)) {
                            _showError(context,
                                'End date cannot be before start date');
                            return;
                          }

                          setState(() => isUpdating = true);

                          try {
                            final provider = Provider.of<AdminAuthProvider>(
                                context,
                                listen: false);

                            await provider.AdminUpdatebatchprovider(
                              widget.courseId,
                              batch.batchId,
                              editNameController.text.trim(),
                              editMedium!,
                              editStartDate!,
                              editEndDate!,
                            );

                            Navigator.pop(context);
                            await provider.AdminfetchBatchForCourseProvider(
                                widget.courseId);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Batch updated successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            _showError(context,
                                'Failed to update batch: ${e.toString()}');
                          } finally {
                            setState(() => isUpdating = false);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
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
                      : const Text(
                          'Update',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCreateBatchDialog(BuildContext context) {
    _batchNameController.clear();
    _startDate = null;
    _endDate = null;
    bool isCreating = false;
    bool isMediumExpanded = false;
    String? selectedMedium;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Create New Batch',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              contentPadding: const EdgeInsets.all(24),
              content: SizedBox(
                width: 600,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _batchNameController,
                        decoration: InputDecoration(
                          labelText: 'Batch Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.group),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.grey.withOpacity(0.2)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  isMediumExpanded = !isMediumExpanded;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.blue.withOpacity(0.05),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.language,
                                        color: Colors.blue, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        selectedMedium ?? 'Select Medium',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: selectedMedium != null
                                              ? Colors.black87
                                              : Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      isMediumExpanded
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      color: Colors.blue,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (isMediumExpanded)
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.grey.withOpacity(0.2)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  physics: const ClampingScrollPhysics(),
                                  itemCount: _mediumOptions.length,
                                  separatorBuilder: (context, index) => Divider(
                                    height: 1,
                                    color: Colors.grey.withOpacity(0.2),
                                  ),
                                  itemBuilder: (context, index) {
                                    final medium = _mediumOptions[index];
                                    final isSelected = selectedMedium == medium;
                                    return InkWell(
                                      onTap: () {
                                        setState(() {
                                          selectedMedium = medium;
                                          isMediumExpanded = false;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        color: isSelected
                                            ? Colors.blue.withOpacity(0.05)
                                            : null,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              medium,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                                color: isSelected
                                                    ? Colors.blue
                                                    : Colors.black87,
                                              ),
                                            ),
                                            if (isSelected)
                                              const Icon(Icons.check,
                                                  color: Colors.blue, size: 20),
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
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: 'Start Date',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.calendar_today),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              controller: TextEditingController(
                                text: _startDate != null
                                    ? DateFormat('yyyy-MM-dd')
                                        .format(_startDate!)
                                    : '',
                              ),
                              onTap: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2030),
                                );
                                if (picked != null) {
                                  setState(() => _startDate = picked);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: 'End Date',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.calendar_today),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              controller: TextEditingController(
                                text: _endDate != null
                                    ? DateFormat('yyyy-MM-dd').format(_endDate!)
                                    : '',
                              ),
                              onTap: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2030),
                                );
                                if (picked != null) {
                                  setState(() => _endDate = picked);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isCreating ? null : () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
                ElevatedButton(
                  onPressed: isCreating
                      ? null
                      : () async {
                          if (_batchNameController.text.trim().isEmpty) {
                            _showError(context, 'Please enter a batch name');
                            return;
                          }
                          if (selectedMedium == null) {
                            _showError(context, 'Please select a medium');
                            return;
                          }
                          if (_startDate == null) {
                            _showError(context, 'Please select a start date');
                            return;
                          }
                          if (_endDate == null) {
                            _showError(context, 'Please select an end date');
                            return;
                          }
                          if (_endDate!.isBefore(_startDate!)) {
                            _showError(context,
                                'End date cannot be before start date');
                            return;
                          }

                          setState(() => isCreating = true);

                          try {
                            final provider = Provider.of<AdminAuthProvider>(
                                context,
                                listen: false);

                            await provider.AdminCreateBatchProvider(
                              _batchNameController.text.trim(),
                              widget.courseId,
                              selectedMedium!,
                              _startDate!,
                              _endDate!,
                            );

                            Navigator.pop(context);
                            await provider.AdminfetchBatchForCourseProvider(
                                widget.courseId);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Batch created successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            _showError(context,
                                'Failed to create batch: ${e.toString()}');
                          } finally {
                            setState(() => isCreating = false);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isCreating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Create',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title:
            const Text('Course Batches', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'BATCHES',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('Create Batch',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _selectedMedium != null ? Colors.blue : Colors.grey,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _selectedMedium != null
                      ? () => _showCreateBatchDialog(context)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildMediumDropdown(),
            const SizedBox(height: 24),
            Expanded(
              child: _buildBatchList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBatchList() {
    return Consumer<AdminAuthProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Return message if no medium is selected
        if (_selectedMedium == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.filter_list, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Please select a medium to view batches',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        final batches = provider.courseBatches[widget.courseId] ?? [];
        final filteredBatches =
            batches.where((batch) => batch.medium == _selectedMedium).toList();

        if (filteredBatches.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.school_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No batches available for ${_selectedMedium} medium',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                spreadRadius: 2,
                blurRadius: 15,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            itemCount: filteredBatches.length,
            itemBuilder: (context, index) {
              final batch = filteredBatches[index];
              return Container(
                margin: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: index == 0 ? 16 : 8,
                  bottom: index == filteredBatches.length - 1 ? 16 : 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.05),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminModuleAddScreen(
                          batchId: batch.batchId,
                          courseId: widget.courseId,
                          courseName: 'Course Name',
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.groups_rounded,
                              color: Colors.blue[700],
                              size: 32,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                batch.batchName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.language,
                                      size: 16, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text(
                                    batch.medium ?? 'No medium specified',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              if (batch.startTime != null &&
                                  batch.endTime != null)
                                Row(
                                  children: [
                                    Icon(Icons.date_range,
                                        size: 16, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${DateFormat('MMM d, y').format(batch.startTime!)} - ${DateFormat('MMM d, y').format(batch.endTime!)}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit_rounded,
                                  color: Colors.blue[700]),
                              onPressed: () =>
                                  _showEditBatchDialog(context, batch),
                              tooltip: 'Edit Batch',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_rounded,
                                  color: Colors.red),
                              onPressed: () async {
                                if (await _confirmDelete(context)) {
                                  await _deleteBatch(
                                    provider,
                                    batch.batchId,
                                  );
                                }
                              },
                              tooltip: 'Delete Batch',
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
        );
      },
    );
  }

  Future<void> _deleteBatch(AdminAuthProvider provider, int batchId) async {
    try {
      await provider.AdmindeleteBatchprovider(
        widget.courseId,
        batchId,
        _selectedMedium ?? 'All', // Provide a default value
        DateTime.now(), // Provide current date as default
        DateTime.now().add(const Duration(days: 365)), // Default end date
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Batch deleted successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      await provider.AdminfetchBatchForCourseProvider(widget.courseId);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete batch: $error'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
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

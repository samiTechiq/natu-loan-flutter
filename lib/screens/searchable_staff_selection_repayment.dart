import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:staff_loan/models/staff_model.dart';
import '../controllers/theme_controller.dart';

class SearchableStaffSelectionRepayment extends StatefulWidget {
  final List<Staff> staffList;
  final Staff? selectedStaff;

  const SearchableStaffSelectionRepayment({
    super.key,
    required this.staffList,
    this.selectedStaff,
  });

  @override
  State<SearchableStaffSelectionRepayment> createState() =>
      _SearchableStaffSelectionRepaymentState();
}

class _SearchableStaffSelectionRepaymentState
    extends State<SearchableStaffSelectionRepayment> {
  final TextEditingController _searchController = TextEditingController();
  List<Staff> _filteredStaffList = [];
  Staff? _selectedStaff;

  @override
  void initState() {
    super.initState();
    _filteredStaffList = widget.staffList;
    _selectedStaff = widget.selectedStaff;
    _searchController.addListener(_filterStaff);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterStaff);
    _searchController.dispose();
    super.dispose();
  }

  void _filterStaff() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredStaffList = widget.staffList;
      } else {
        _filteredStaffList =
            widget.staffList
                .where((staff) => staff.name.toLowerCase().contains(query))
                .toList();
      }
    });
  }

  void _selectStaff(Staff staff) {
    setState(() {
      _selectedStaff = staff;
    });
    // Auto-confirm selection after a short delay for visual feedback
    Future.delayed(const Duration(milliseconds: 300), () {
      _confirmSelection();
    });
  }

  void _confirmSelection() {
    Get.back(result: _selectedStaff);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Staff'),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _selectedStaff != null ? _confirmSelection : null,
            child: Text(
              'Done',
              style: TextStyle(
                color:
                    _selectedStaff != null
                        ? AppColors.primaryPurple
                        : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search staff...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
          ),

          // Results Count
          if (_searchController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text(
                    '${_filteredStaffList.length} result(s) found',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // Staff List
          Expanded(
            child:
                _filteredStaffList.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_search,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isEmpty
                                ? 'No staff members available'
                                : 'No staff members found',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                          if (_searchController.text.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Try adjusting your search terms',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey[500]),
                              ),
                            ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      itemCount: _filteredStaffList.length,
                      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 70),
                      itemBuilder: (context, index) {
                        final staff = _filteredStaffList[index];
                        final isSelected = _selectedStaff?.id == staff.id;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8.0),
                          elevation: isSelected ? 4 : 1,
                          child: InkWell(
                            onTap: () => _selectStaff(staff),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    isSelected
                                        ? Border.all(
                                          color: AppColors.primaryPurple,
                                          width: 2,
                                        )
                                        : null,
                                color:
                                    isSelected
                                        ? AppColors.primaryPurple.withValues(
                                          alpha: 0.05,
                                        )
                                        : null,
                              ),
                              child: Row(
                                children: [
                                  // Avatar
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor:
                                        isSelected
                                            ? AppColors.primaryPurple
                                            : Colors.grey[400],
                                    child: Text(
                                      staff.name.substring(0, 1).toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 16),

                                  // Staff Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          staff.name,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color:
                                                isSelected
                                                    ? AppColors.primaryPurple
                                                    : null,
                                          ),
                                        ),
                                        Text(
                                          'ID: ${staff.id}',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall?.copyWith(
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Selection Indicator
                                  if (isSelected)
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryPurple,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 16,
                                      ),
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
}

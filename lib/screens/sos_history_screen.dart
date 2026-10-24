// lib/screens/sos_history_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../app_theme.dart';

class SosHistoryScreen extends StatefulWidget {
  const SosHistoryScreen({super.key});

  @override
  State<SosHistoryScreen> createState() => _SosHistoryScreenState();
}

class _SosHistoryScreenState extends State<SosHistoryScreen> {
  String _selectedFilter = 'ALL';

  List<Map<String, String>> _historyItems = [];



  String _getHistoryKey() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return '';
    }

    return 'sos_history_${user.uid}';
  }



  @override
  void initState() {
    super.initState();
    _loadHistory();
  }


  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();

    final historyKey = _getHistoryKey();

    if (historyKey.isEmpty) {
      return;
    }

    final saved = prefs.getString(historyKey);

    if (saved == null) {
      if (!mounted) return;

      setState(() {
        _historyItems = [];
      });

      return;
    }

    final List<dynamic> decoded = jsonDecode(saved);

    if (!mounted) return;

    setState(() {
      _historyItems = decoded
          .map((item) => Map<String, String>.from(item))
          .toList();
    });
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();

    final historyKey = _getHistoryKey();

    if (historyKey.isEmpty) {
      return;
    }

    await prefs.setString(
      historyKey,
      jsonEncode(_historyItems),
    );
  }


  List<Map<String, String>> get _filteredItems {
    if (_selectedFilter == 'ALL') {
      return _historyItems;
    }

    return _historyItems
        .where((item) => item['status'] == _selectedFilter)
        .toList();
  }

  Future<void> _refreshHistory() async {
    await _loadHistory();
  }

  Future<void> _markAsResolved(Map<String, String> item) async {
    final index = _historyItems.indexWhere(
      (historyItem) => historyItem['id'] == item['id'],
    );

    if (index == -1) return;

    setState(() {
      _historyItems[index]['status'] = 'RESOLVED';
    });

    await _saveHistory();

    if (!mounted) return;

    Navigator.pop(context);
  }

  void _showItemDetails(Map<String, String> item) {
    final isResolved = item['status'] == 'RESOLVED';

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141927),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${item['title']} (${item['id']})',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textWhite,
                      ),
                    ),
                  ),
                  _buildStatusBadge(item['status']!),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white12),
              const SizedBox(height: 12),

              _buildDetailRow(
                Icons.access_time_rounded,
                'Timestamp',
                item['date']!,
              ),

              const SizedBox(height: 10),

              _buildDetailRow(
                Icons.location_on_outlined,
                'Coordinates',
                item['coordinates']!,
              ),

              const SizedBox(height: 10),

              _buildDetailRow(
                Icons.people_outline_rounded,
                'Notified',
                item['contactsNotified']!,
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isResolved
                      ? () => Navigator.pop(context)
                      : () => _markAsResolved(item),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isResolved
                        ? const Color(0xFF1E2638)
                        : AppColors.accentYellow,
                    foregroundColor: isResolved
                        ? AppColors.textPurple
                        : AppColors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    isResolved ? 'Close' : 'Mark as Resolved',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 12.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textPurple,
                  size: 28,
                ),
                onPressed: () => Navigator.pop(context),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.containerBg,
                    borderRadius: BorderRadius.circular(36),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.05),
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF141927),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.06),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'SOS',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.accentYellow,
                                  ),
                                ),
                                Text(
                                  'History',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.accentYellow,
                                  ),
                                ),
                              ],
                            ),
                            Image.asset(
                              'assets/images/pantherheartface.png',
                              height: 60,
                              width: 60,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      Row(
                        children: ['ALL', 'PENDING', 'RESOLVED']
                            .map((filter) {
                          final isSelected =
                              _selectedFilter == filter;

                          return Padding(
                            padding:
                                const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(
                                filter,
                                style: TextStyle(
                                  color: isSelected
                                      ? AppColors.background
                                      : AppColors.textPurple,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor:
                                  AppColors.accentYellow,
                              backgroundColor:
                                  const Color(0xFF141927),
                              side: BorderSide(
                                color:
                                    Colors.white.withOpacity(0.06),
                              ),
                              onSelected: (_) {
                                setState(() {
                                  _selectedFilter = filter;
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 12),

                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: _refreshHistory,
                          color: AppColors.accentYellow,
                          backgroundColor:
                              const Color(0xFF141927),
                          child: _filteredItems.isEmpty
                              ? _buildEmptyState()
                              : ListView.separated(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(
                                    parent:
                                        BouncingScrollPhysics(),
                                  ),
                                  itemCount:
                                      _filteredItems.length,
                                  separatorBuilder:
                                      (context, index) =>
                                          const SizedBox(
                                    height: 12,
                                  ),
                                  itemBuilder:
                                      (context, index) {
                                    final item =
                                        _filteredItems[index];

                                    return InkWell(
                                      onTap: () =>
                                          _showItemDetails(item),
                                      borderRadius:
                                          BorderRadius.circular(20),
                                      child: Container(
                                        padding:
                                            const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color:
                                              const Color(0xFF141927),
                                          borderRadius:
                                              BorderRadius.circular(
                                                  20),
                                          border: Border.all(
                                            color: Colors.white
                                                .withOpacity(0.04),
                                            width: 1,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  item['title']!,
                                                  style:
                                                      const TextStyle(
                                                    fontSize: 17,
                                                    fontWeight:
                                                        FontWeight
                                                            .bold,
                                                    color: AppColors
                                                        .textPurple,
                                                  ),
                                                ),
                                                _buildStatusBadge(
                                                  item['status']!,
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: 6),

                                            Text(
                                              item['date']!,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: AppColors
                                                    .textPurple
                                                    .withOpacity(0.7),
                                              ),
                                            ),

                                            const SizedBox(height: 2),

                                            Text(
                                              item['subtitle']!,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: AppColors
                                                    .textPurple
                                                    .withOpacity(0.7),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        'No more alerts to show.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPurple
                              .withOpacity(0.6),
                        ),
                      ),

                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final isResolved = status == 'RESOLVED';

    final bgColor = isResolved
        ? const Color(0xFF2E8B57).withOpacity(0.18)
        : const Color(0xFFB23B2A).withOpacity(0.18);

    final fgColor = isResolved
        ? const Color(0xFF4EAE7B)
        : const Color(0xFFE55D4A);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: fgColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isResolved
                ? Icons.check_circle_outline
                : Icons.hourglass_top_rounded,
            size: 14,
            color: fgColor,
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: fgColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.accentYellow,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textPurple
                      .withOpacity(0.6),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textWhite,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 48,
            color: AppColors.textPurple
                .withOpacity(0.4),
          ),
          const SizedBox(height: 12),
          Text(
            'No alerts found',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPurple
                  .withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
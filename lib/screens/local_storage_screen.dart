import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/time_tracker_provider.dart';

class LocalStorageScreen extends StatefulWidget {
  const LocalStorageScreen({Key? key}) : super(key: key);

  @override
  State<LocalStorageScreen> createState() => _LocalStorageScreenState();
}

class _LocalStorageScreenState extends State<LocalStorageScreen> {
  Map<String, String> _rawStorageSnapshot = {};
  bool _isLoadingStorage = true;

  @override
  void initState() {
    super.initState();
    _fetchStorageSnapshot();
  }

  Future<void> _fetchStorageSnapshot() async {
    final snapshot =
        await Provider.of<ProductivityRepository>(context, listen: false)
            .fetchRawStorageSnapshot();
    setState(() {
      _rawStorageSnapshot = snapshot;
      _isLoadingStorage = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        title: const Text('Local Storage Inspector',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoadingStorage = true);
              _fetchStorageSnapshot();
            },
          ),
        ],
      ),
      body: _isLoadingStorage
          ? const Center(child: CircularProgressIndicator())
          : Consumer<ProductivityRepository>(
              builder: (ctx, repository, _) {
                final hasPersistedData = repository.entries.isNotEmpty ||
                    repository.projects.isNotEmpty ||
                    repository.tasks.isNotEmpty;
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6366F1)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.storage,
                                      color: Color(0xFF6366F1), size: 20),
                                ),
                                const SizedBox(width: 12),
                                const Text('Storage Overview',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const Divider(height: 24),
                            _StorageRecordCountRow(
                              label: 'Time Entries',
                              value: '${repository.entries.length} records',
                              isEmpty: repository.entries.isEmpty,
                            ),
                            const SizedBox(height: 8),
                            _StorageRecordCountRow(
                              label: 'Projects',
                              value: '${repository.projects.length} records',
                              isEmpty: repository.projects.isEmpty,
                            ),
                            const SizedBox(height: 8),
                            _StorageRecordCountRow(
                              label: 'Tasks',
                              value: '${repository.tasks.length} records',
                              isEmpty: repository.tasks.isEmpty,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (!hasPersistedData)
                      Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6366F1).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.storage,
                                  size: 64, color: Color(0xFF6366F1)),
                            ),
                            const SizedBox(height: 16),
                            const Text('Storage is empty',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            const Text('No records have been persisted yet',
                                style: TextStyle(color: Color(0xFF6B7280))),
                          ],
                        ),
                      )
                    else ...[
                      _RawStorageKeyCard(
                        storageKey: 'time_entries',
                        icon: Icons.access_time,
                        color: const Color(0xFF6366F1),
                        rawJson: _rawStorageSnapshot['time_entries'] ?? '[]',
                      ),
                      const SizedBox(height: 12),
                      _RawStorageKeyCard(
                        storageKey: 'projects',
                        icon: Icons.folder,
                        color: const Color(0xFF10B981),
                        rawJson: _rawStorageSnapshot['projects'] ?? '[]',
                      ),
                      const SizedBox(height: 12),
                      _RawStorageKeyCard(
                        storageKey: 'tasks',
                        icon: Icons.task_alt,
                        color: const Color(0xFFF59E0B),
                        rawJson: _rawStorageSnapshot['tasks'] ?? '[]',
                      ),
                    ],
                  ],
                );
              },
            ),
    );
  }
}

class _StorageRecordCountRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isEmpty;

  const _StorageRecordCountRow({
    required this.label,
    required this.value,
    required this.isEmpty,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF6B7280))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isEmpty
                ? Colors.grey.shade200
                : const Color(0xFF6366F1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: isEmpty ? Colors.grey : const Color(0xFF6366F1),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class _RawStorageKeyCard extends StatefulWidget {
  final String storageKey;
  final IconData icon;
  final Color color;
  final String rawJson;

  const _RawStorageKeyCard({
    required this.storageKey,
    required this.icon,
    required this.color,
    required this.rawJson,
  });

  @override
  State<_RawStorageKeyCard> createState() => _RawStorageKeyCardState();
}

class _RawStorageKeyCardState extends State<_RawStorageKeyCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(widget.icon, color: widget.color, size: 20),
            ),
            title: Text(widget.storageKey,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('SharedPreferences key',
                style: TextStyle(fontSize: 11)),
            trailing: Icon(
                _isExpanded ? Icons.expand_less : Icons.expand_more,
                color: const Color(0xFF6B7280)),
            onTap: () => setState(() => _isExpanded = !_isExpanded),
          ),
          if (_isExpanded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF1F2937),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: Text(
                widget.rawJson,
                style: const TextStyle(
                  color: Color(0xFF10B981),
                  fontFamily: 'monospace',
                  fontSize: 11,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

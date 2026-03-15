// ─── History Page ─────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:qr_code_app/model/history.dart';
import 'package:qr_code_app/widgets/button.dart';
import 'package:qr_code_app/widgets/qrcode.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final _store = HistoryStore();

  IconData _typeIcon(String type) {
    switch (type) {
      case 'URL':     return Icons.link;
      case 'Text':    return Icons.text_fields;
      case 'Contact': return Icons.person;
      default:        return Icons.qr_code;
    }
  }

  Color _typeColor(String type, ColorScheme cs) {
    switch (type) {
      case 'URL':     return Colors.blue;
      case 'Text':    return Colors.green;
      case 'Contact': return cs.tertiary;
      default:        return cs.primary;
    }
  }

  void _viewQR(QRHistoryItem item) {
    final repaintKey = GlobalKey();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text(item.label,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            Text(item.type,
                style: TextStyle(color: Colors.grey.shade500)),
            const SizedBox(height: 20),
            QRDisplay(data: item.data, repaintKey: repaintKey),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => saveQrToGallery(context, repaintKey),
                icon: const Icon(Icons.download),
                label: const Text('Save to Gallery'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmClear() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Delete all QR code history? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true),
              child: const Text('Clear All')),
        ],
      ),
    );
    if (ok == true) _store.clear();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('History', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: cs.inversePrimary,
        actions: [
          AnimatedBuilder(
            animation: _store,
            builder: (_, __) => _store.items.isEmpty
                ? const SizedBox()
                : IconButton(
                    icon: const Icon(Icons.delete_sweep_outlined),
                    tooltip: 'Clear all',
                    onPressed: _confirmClear,
                  ),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _store,
        builder: (_, __) {
          final items = _store.items;
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history, size: 72, color: cs.outlineVariant),
                  const SizedBox(height: 12),
                  Text('No QR codes yet',
                      style: TextStyle(fontSize: 16, color: cs.outline)),
                  const SizedBox(height: 4),
                  Text('Generated codes will appear here',
                      style: TextStyle(color: cs.outlineVariant)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final item = items[i];
              final color = _typeColor(item.type, cs);
              return Dismissible(
                key: ValueKey('${item.createdAt}_$i'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: cs.errorContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.delete, color: cs.onErrorContainer),
                ),
                onDismissed: (_) => _store.remove(i),
                child: InkWell(
                  onTap: () => _viewQR(item),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: cs.surfaceVariant.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(_typeIcon(item.type), color: color, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15)),
                              const SizedBox(height: 2),
                              Text(item.createdAt,
                                  style: TextStyle(
                                      fontSize: 12, color: cs.outline)),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: cs.outline),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
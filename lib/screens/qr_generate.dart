


// ─── Home Page ───────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:qr_code_app/widgets/qrcode.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tabIndex = 0;

  final List<String> _labels = ['URL', 'Text', 'Contact'];
  final List<IconData> _icons = [Icons.link, Icons.text_fields, Icons.person];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('QR Code Generator',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: cs.inversePrimary,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          // Tab selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: cs.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: List.generate(_labels.length, (i) {
                  final selected = _tabIndex == i;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _tabIndex = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.all(4),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: selected ? cs.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(_icons[i],
                                size: 18,
                                color: selected
                                    ? cs.onPrimary
                                    : cs.onSurfaceVariant),
                            const SizedBox(width: 6),
                            Text(_labels[i],
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: selected
                                        ? cs.onPrimary
                                        : cs.onSurfaceVariant)),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Tab content
          Expanded(
            child: IndexedStack(
              index: _tabIndex,
              children: const [
                UrlTab(),
                TextTab(),
                ContactTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
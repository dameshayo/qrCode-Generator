import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(const QRGeneratorApp());

class QRGeneratorApp extends StatelessWidget {
  const QRGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Generator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}

// ─── Home Page ───────────────────────────────────────────────
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

// ─── Shared QR Display Widget ────────────────────────────────
class QRDisplay extends StatelessWidget {
  final String data;
  final GlobalKey repaintKey;

  const QRDisplay({super.key, required this.data, required this.repaintKey});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return RepaintBoundary(
      key: repaintKey,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: cs.shadow.withOpacity(0.15), blurRadius: 12)
          ],
        ),
        child: QrImageView(
          data: data,
          version: QrVersions.auto,
          size: 220,
          backgroundColor: Colors.white,
          eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.square, color: Colors.black),
          dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square, color: Colors.black),
        ),
      ),
    );
  }
}

// ─── Save Button Helper ───────────────────────────────────────
Future<void> saveQrToGallery(BuildContext ctx, GlobalKey key) async {
  try {
    // Request permission
    PermissionStatus status;
    if (Theme.of(ctx).platform == TargetPlatform.android) {
      status = await Permission.storage.request();
    } else {
      status = await Permission.photos.request();
    }

    if (!status.isGranted) {
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
            content: Text('Permission denied. Cannot save QR code.')));
      }
      return;
    }

    final boundary =
        key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;

    final img = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;

    final result = await ImageGallerySaverPlus.saveImage(
      byteData.buffer.asUint8List(),
      quality: 100,
      name: 'qr_code_${DateTime.now().millisecondsSinceEpoch}',
    );

    if (ctx.mounted) {
      final success = result['isSuccess'] == true;
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content:
            Text(success ? '✅ QR code saved to gallery!' : '❌ Failed to save.'),
        behavior: SnackBarBehavior.floating,
      ));
    }
  } catch (e) {
    if (ctx.mounted) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
          content: Text('Error: $e'), behavior: SnackBarBehavior.floating));
    }
  }
}

// ─── URL Tab ──────────────────────────────────────────────────
class UrlTab extends StatefulWidget {
  const UrlTab({super.key});

  @override
  State<UrlTab> createState() => _UrlTabState();
}

class _UrlTabState extends State<UrlTab> {
  final _ctrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _repaintKey = GlobalKey();
  String? _qrData;

  String _normalizeUrl(String url) {
    final trimmed = url.trim();
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      return 'https://$trimmed';
    }
    return trimmed;
  }

  void _generate() {
    if (_formKey.currentState!.validate()) {
      setState(() => _qrData = _normalizeUrl(_ctrl.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _ctrl,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: 'Website URL',
                hintText: 'e.g. https://flutter.dev',
                prefixIcon: Icon(Icons.link),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Please enter a URL';
                return null;
              },
            ),
            const SizedBox(height: 8),
            Text(
              '💡 URLs will open directly in the browser when scanned.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Theme.of(context).colorScheme.secondary),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _generate,
              icon: const Icon(Icons.qr_code),
              label: const Text('Generate QR Code'),
            ),
            if (_qrData != null) ...[
              const SizedBox(height: 28),
              Center(child: QRDisplay(data: _qrData!, repaintKey: _repaintKey)),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => saveQrToGallery(context, _repaintKey),
                icon: const Icon(Icons.download),
                label: const Text('Save to Gallery'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Text Tab ─────────────────────────────────────────────────
class TextTab extends StatefulWidget {
  const TextTab({super.key});

  @override
  State<TextTab> createState() => _TextTabState();
}

class _TextTabState extends State<TextTab> {
  final _ctrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _repaintKey = GlobalKey();
  String? _qrData;

  void _generate() {
    if (_formKey.currentState!.validate()) {
      setState(() => _qrData = _ctrl.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _ctrl,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Text',
                hintText: 'Enter any text...',
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 56),
                  child: Icon(Icons.text_fields),
                ),
                alignLabelWithHint: true,
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Please enter some text'
                  : null,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _generate,
              icon: const Icon(Icons.qr_code),
              label: const Text('Generate QR Code'),
            ),
            if (_qrData != null) ...[
              const SizedBox(height: 28),
              Center(child: QRDisplay(data: _qrData!, repaintKey: _repaintKey)),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => saveQrToGallery(context, _repaintKey),
                icon: const Icon(Icons.download),
                label: const Text('Save to Gallery'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Contact Tab ──────────────────────────────────────────────
class ContactTab extends StatefulWidget {
  const ContactTab({super.key});

  @override
  State<ContactTab> createState() => _ContactTabState();
}

class _ContactTabState extends State<ContactTab> {
  final _formKey = GlobalKey<FormState>();
  final _repaintKey = GlobalKey();

  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _org = TextEditingController();
  final _website = TextEditingController();

  String? _qrData;

  /// Builds a vCard 3.0 string — scanners recognize this as a contact.
  String _buildVCard() {
    final buf = StringBuffer();
    buf.writeln('BEGIN:VCARD');
    buf.writeln('VERSION:3.0');
    buf.writeln('N:${_lastName.text.trim()};${_firstName.text.trim()};;;');
    buf.writeln('FN:${_firstName.text.trim()} ${_lastName.text.trim()}'.trim());
    if (_org.text.isNotEmpty) buf.writeln('ORG:${_org.text.trim()}');
    if (_phone.text.isNotEmpty)
      buf.writeln('TEL;TYPE=CELL:${_phone.text.trim()}');
    if (_email.text.isNotEmpty) buf.writeln('EMAIL:${_email.text.trim()}');
    if (_website.text.isNotEmpty) {
      var url = _website.text.trim();
      if (!url.startsWith('http')) url = 'https://$url';
      buf.writeln('URL:$url');
    }
    buf.writeln('END:VCARD');
    return buf.toString();
  }

  void _generate() {
    if (_formKey.currentState!.validate()) {
      setState(() => _qrData = _buildVCard());
    }
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon,
      {TextInputType? keyboard, bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboard,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
        validator: required
            ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _field(_firstName, 'First Name *', Icons.badge, required: true),
            _field(_lastName, 'Last Name', Icons.badge_outlined),
            _field(_org, 'Organization', Icons.business),
            _field(_phone, 'Phone', Icons.phone, keyboard: TextInputType.phone),
            _field(_email, 'Email', Icons.email,
                keyboard: TextInputType.emailAddress),
            _field(_website, 'Website', Icons.language,
                keyboard: TextInputType.url),
            Text(
              '💡 Generates a vCard — scanners will prompt to add contact.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Theme.of(context).colorScheme.secondary),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _generate,
              icon: const Icon(Icons.qr_code),
              label: const Text('Generate QR Code'),
            ),
            if (_qrData != null) ...[
              const SizedBox(height: 28),
              Center(child: QRDisplay(data: _qrData!, repaintKey: _repaintKey)),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => saveQrToGallery(context, _repaintKey),
                icon: const Icon(Icons.download),
                label: const Text('Save to Gallery'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

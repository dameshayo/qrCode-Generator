

// ─── Shared QR Display Widget ────────────────────────────────
import 'package:flutter/material.dart';
import 'package:qr_code_app/widgets/button.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
            // ignore: deprecated_member_use
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
      // ignore: curly_braces_in_flow_control_structures
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


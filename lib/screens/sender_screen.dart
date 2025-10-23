import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import '../services/file_sharing_service.dart';
import '../services/robust_rsa_service_v2.dart';

class SenderScreen extends StatefulWidget {
  final RobustRsaKeyPair userKeyPair;

  const SenderScreen({super.key, required this.userKeyPair});

  @override
  State<SenderScreen> createState() => _SenderScreenState();
}

class _SenderScreenState extends State<SenderScreen> {
  final _recipientPublicKeyController = TextEditingController();
  String? _selectedFilePath;
  String? _selectedFileName;
  bool _isProcessing = false;
  FileShareData? _shareData;

  @override
  void dispose() {
    _recipientPublicKeyController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          _selectedFilePath = file.path;
          _selectedFileName = file.name;
          _shareData = null; // Clear previous share data
        });
      }
    } catch (e) {
      _showErrorDialog('Failed to pick file: $e');
    }
  }

  Future<void> _sendFile() async {
    if (_selectedFilePath == null) {
      _showErrorDialog('Please select a file first');
      return;
    }

    if (_recipientPublicKeyController.text.trim().isEmpty) {
      _showErrorDialog('Please enter recipient\'s public key');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final shareData = await FileSharingService.sendFile(
        filePath: _selectedFilePath!,
        recipientPublicKey: _recipientPublicKeyController.text.trim(),
        senderPrivateKey: widget.userKeyPair.privateKeyPem,
      );

      setState(() {
        _shareData = shareData;
        _isProcessing = false;
      });

      _showSuccessDialog();
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showErrorDialog('Failed to send file: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('File Sent Successfully!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('File: ${_shareData!.fileName}'),
            Text('Size: ${(_shareData!.fileSize / 1024).toStringAsFixed(2)} KB'),
            Text('IPFS CID: ${_shareData!.cid}'),
            const SizedBox(height: 16),
            const Text(
              'Share this data with the recipient:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: SelectableText(
                _shareData!.shareString,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 10),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _shareData!.shareString));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share data copied to clipboard')),
              );
            },
            child: const Text('Copy Share Data'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send File'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // File Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.attach_file,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Select File',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_selectedFilePath == null)
                      Container(
                        width: double.infinity,
                        height: 120,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: InkWell(
                          onTap: _pickFile,
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.cloud_upload, size: 48, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('Tap to select file'),
                            ],
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedFileName!,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    _selectedFilePath!,
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _selectedFilePath = null;
                                  _selectedFileName = null;
                                  _shareData = null;
                                });
                              },
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Recipient Public Key
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.key,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Recipient\'s Public Key',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _recipientPublicKeyController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Paste recipient\'s RSA public key here...',
                        border: OutlineInputBorder(),
                      ),
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Send Button
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _sendFile,
              icon: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              label: Text(_isProcessing ? 'Processing...' : 'Send File'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),

            if (_isProcessing) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      const Text('Encrypting and uploading file...'),
                      const SizedBox(height: 8),
                      Text(
                        'This may take a few moments depending on file size',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            if (_shareData != null) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            'File Sent Successfully',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('File: ${_shareData!.fileName}'),
                      Text('Size: ${(_shareData!.fileSize / 1024).toStringAsFixed(2)} KB'),
                      Text('IPFS CID: ${_shareData!.cid}'),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _shareData!.shareString));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Share data copied to clipboard')),
                          );
                        },
                        icon: const Icon(Icons.copy),
                        label: const Text('Copy Share Data'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

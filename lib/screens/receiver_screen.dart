import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/file_sharing_service.dart';
import '../services/robust_rsa_service_v2.dart';

class ReceiverScreen extends StatefulWidget {
  final RobustRsaKeyPair userKeyPair;

  const ReceiverScreen({super.key, required this.userKeyPair});

  @override
  State<ReceiverScreen> createState() => _ReceiverScreenState();
}

class _ReceiverScreenState extends State<ReceiverScreen> {
  final _shareDataController = TextEditingController();
  bool _isProcessing = false;
  ReceivedFile? _receivedFile;

  @override
  void dispose() {
    _shareDataController.dispose();
    super.dispose();
  }

  Future<void> _receiveFile() async {
    if (_shareDataController.text.trim().isEmpty) {
      _showErrorDialog('Please enter the share data');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Parse share data (in a real app, this would be structured data)
      final shareData = _parseShareData(_shareDataController.text.trim());
      
      final receivedFile = await FileSharingService.receiveFile(
        shareData: shareData,
        recipientPrivateKey: widget.userKeyPair.privateKeyPem,
      );

      setState(() {
        _receivedFile = receivedFile;
        _isProcessing = false;
      });

      _showSuccessDialog();
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showErrorDialog('Failed to receive file: $e');
    }
  }

  FileShareData _parseShareData(String shareData) {
    // This is a simplified parser for demo purposes
    // In a real app, you'd use proper data serialization (JSON, etc.)
    final lines = shareData.split('\n');
    
    String fileName = '';
    String cid = '';
    String encryptedAesKey = '';
    String iv = '';
    String hash = '';
    int fileSize = 0;
    int timestamp = DateTime.now().millisecondsSinceEpoch;

    for (final line in lines) {
      if (line.startsWith('📁 File:')) {
        fileName = line.substring(8).trim();
      } else if (line.startsWith('🔗 IPFS CID:')) {
        cid = line.substring(12).trim();
      } else if (line.startsWith('🔑 Encrypted AES Key:')) {
        encryptedAesKey = line.substring(21).trim();
      } else if (line.startsWith('📏 Original Size:')) {
        final sizeStr = line.substring(17).trim().replaceAll(' KB', '');
        fileSize = (double.parse(sizeStr) * 1024).round();
      } else if (line.startsWith('⏰ Shared:')) {
        timestamp = DateTime.parse(line.substring(9).trim()).millisecondsSinceEpoch;
      }
    }

    // Generate mock IV and hash if not provided (for demo)
    if (iv.isEmpty) iv = 'mock_iv_for_demo';
    if (hash.isEmpty) hash = 'mock_hash_for_demo';

    return FileShareData(
      fileName: fileName,
      cid: cid,
      encryptedAesKey: encryptedAesKey,
      fileSize: fileSize,
      encryptedSize: fileSize, // Mock value
      hash: hash,
      iv: iv,
      timestamp: timestamp,
    );
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
            Text('File Received Successfully!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('File: ${_receivedFile!.fileName}'),
            Text('Size: ${_receivedFile!.sizeFormatted}'),
            Text('Saved to: ${_receivedFile!.filePath}'),
            Text('Received at: ${_receivedFile!.receivedAt}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receive File'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instructions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'How to Receive Files',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '1. Ask the sender to share the file data with you\n'
                      '2. Paste the complete share data in the text field below\n'
                      '3. Click "Receive File" to decrypt and download',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Share Data Input
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.input,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Share Data',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _shareDataController,
                      maxLines: 10,
                      decoration: const InputDecoration(
                        hintText: 'Paste the complete share data here...\n\nExample:\n'
                        '📁 File: document.pdf\n'
                        '🔗 IPFS CID: QmXxxxxxxxxxxxxxxxxx\n'
                        '🔑 Encrypted AES Key: xxxxxxxxxxxxxx\n'
                        '📏 Original Size: 1024.50 KB\n'
                        '⏰ Shared: 2024-01-01 12:00:00.000',
                        border: OutlineInputBorder(),
                      ),
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Receive Button
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _receiveFile,
              icon: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download),
              label: Text(_isProcessing ? 'Processing...' : 'Receive File'),
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
                      const Text('Downloading and decrypting file...'),
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

            if (_receivedFile != null) ...[
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
                            'File Received Successfully',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('File: ${_receivedFile!.fileName}'),
                      Text('Size: ${_receivedFile!.sizeFormatted}'),
                      Text('Saved to: ${_receivedFile!.filePath}'),
                      Text('Received at: ${_receivedFile!.receivedAt}'),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Your Keys Info
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
                          'Your Public Key',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Share this public key with file senders so they can encrypt files for you:',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.userKeyPair.publicKeyPem.length > 100
                              ? '${widget.userKeyPair.publicKeyPem.substring(0, 100)}...'
                              : widget.userKeyPair.publicKeyPem,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: widget.userKeyPair.publicKeyPem),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Public key copied to clipboard'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.copy),
                            label: const Text('Copy Public Key'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            _showKeyDialog('Your Public Key', widget.userKeyPair.publicKeyPem);
                          },
                          icon: const Icon(Icons.visibility),
                          label: const Text('View Full'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showKeyDialog(String title, String key) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: SelectableText(
            key,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 10),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: key));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Key copied to clipboard')),
              );
            },
            child: const Text('Copy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

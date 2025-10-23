import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/file_sharing_service.dart';
import '../services/robust_rsa_service_v2.dart';
import 'sender_screen.dart';
import 'receiver_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  RobustRsaKeyPair? _userKeyPair;
  bool _isGeneratingKeys = false;

  @override
  void initState() {
    super.initState();
    _generateUserKeys();
  }

  Future<void> _generateUserKeys() async {
    setState(() {
      _isGeneratingKeys = true;
    });

    try {
      // Generate RSA key pair for the user
      final keyPair = FileSharingService.generateUserKeyPair();
      setState(() {
        _userKeyPair = keyPair;
        _isGeneratingKeys = false;
      });
    } catch (e) {
      setState(() {
        _isGeneratingKeys = false;
      });
      _showErrorDialog('Failed to generate keys: $e');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure File Share'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
      body: _isGeneratingKeys
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Generating security keys...'),
                ],
              ),
            )
          : _userKeyPair == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Failed to generate security keys',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _generateUserKeys,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Icon(
                                Icons.security,
                                size: 48,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'ROBUST Blockchain-based Secure File Sharing',
                                style: Theme.of(context).textTheme.headlineSmall,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'ROBUST: Real AES-256-GCM + RSA-2048 encryption with IPFS storage',
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // User Info
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.person,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                              Text(
                                'Your ROBUST RSA-2048 Security Keys',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Public Key:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _userKeyPair!.publicKeyPem.length > 100
                                      ? '${_userKeyPair!.publicKeyPem.substring(0, 100)}...'
                                      : _userKeyPair!.publicKeyPem,
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
                                          ClipboardData(text: _userKeyPair!.publicKeyPem),
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
                                      _showKeyDialog('Your Public Key', _userKeyPair!.publicKeyPem);
                                    },
                                    icon: const Icon(Icons.visibility),
                                    label: const Text('View'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SenderScreen(
                                      userKeyPair: _userKeyPair!,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.upload),
                              label: const Text('Send File'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReceiverScreen(
                                      userKeyPair: _userKeyPair!,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.download),
                              label: const Text('Receive File'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(16),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // How it works
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
                                    'How it works',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const _InfoStep(
                                step: '1',
                                title: 'File Encryption',
                                description: 'File is encrypted using AES-256 encryption',
                              ),
                              const _InfoStep(
                                step: '2',
                                title: 'IPFS Upload',
                                description: 'Encrypted file is uploaded to IPFS network',
                              ),
                              const _InfoStep(
                                step: '3',
                                title: 'Key Encryption',
                                description: 'AES key is encrypted using RSA with recipient\'s public key',
                              ),
                              const _InfoStep(
                                step: '4',
                                title: 'Secure Transfer',
                                description: 'Encrypted key and IPFS link are shared securely',
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

class _InfoStep extends StatelessWidget {
  final String step;
  final String title;
  final String description;

  const _InfoStep({
    required this.step,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

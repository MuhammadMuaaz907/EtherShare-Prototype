# Secure File Share - Blockchain-based File Sharing System

A Flutter prototype for secure file sharing using AES encryption, RSA key exchange, and IPFS storage.

## 🔐 Security Features

- **AES-256-CBC Encryption**: Files are encrypted using industry-standard AES encryption
- **RSA Key Exchange**: AES keys are protected using RSA public/private key cryptography
- **IPFS Storage**: Decentralized file storage using IPFS (InterPlanetary File System)
- **File Integrity**: SHA-256 hash verification ensures file integrity

## 📋 Flow Overview

1. **File Encryption**: UserA encrypts file using AES-256 encryption
2. **IPFS Upload**: Encrypted file is uploaded to IPFS network
3. **Key Encryption**: AES key is encrypted using UserB's RSA public key
4. **Secure Transfer**: Encrypted key and IPFS link are shared securely
5. **File Decryption**: UserB decrypts AES key using RSA private key, then decrypts file

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.7.0 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository:
```bash
git clone <your-repo-url>
cd secure_file_share
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the application:
```bash
flutter run
```

## 📱 How to Use

### For File Senders:

1. **Generate Keys**: The app automatically generates RSA key pairs for each user
2. **Select File**: Choose any file from your device
3. **Enter Recipient's Public Key**: Paste the recipient's RSA public key
4. **Send File**: Click "Send File" to encrypt and upload
5. **Share Data**: Copy the generated share data and send to recipient

### For File Receivers:

1. **Get Share Data**: Receive the share data from the sender
2. **Paste Share Data**: Enter the complete share data in the receive screen
3. **Receive File**: Click "Receive File" to decrypt and download
4. **Access File**: The decrypted file is saved to your device

## 🏗️ Architecture

### Services

- **AesService**: Handles AES-256 encryption/decryption
- **RsaService**: Manages RSA key generation and encryption
- **IpfsService**: Handles file upload/download to IPFS (mock implementation)
- **FileSharingService**: Orchestrates the complete file sharing flow

### Screens

- **HomeScreen**: Main interface with user key management
- **SenderScreen**: File sending interface
- **ReceiverScreen**: File receiving interface

## 🔧 Technical Details

### Encryption Stack

- **AES-256-CBC**: File encryption with random IV
- **RSA-2048**: Key exchange and AES key protection
- **SHA-256**: File integrity verification
- **Base64**: Data encoding for transmission

### IPFS Integration

Currently uses a mock IPFS service for demonstration. In production, integrate with:
- Local IPFS node
- IPFS pinning services (Pinata, Infura)
- IPFS gateways

## 📦 Dependencies

```yaml
dependencies:
  encrypt: ^5.0.1          # AES encryption
  pointycastle: ^3.7.3     # RSA cryptography
  crypto: ^3.0.3           # Hash functions
  file_picker: ^6.1.1      # File selection
  path_provider: ^2.1.1    # File system access
  flutter_secure_storage: ^9.0.0  # Secure key storage
  http: ^1.1.0             # HTTP requests
  permission_handler: ^11.0.1  # File permissions
```

## 🔒 Security Considerations

### Current Implementation (Prototype)
- Simplified RSA implementation for demo purposes
- Mock IPFS service
- Basic key management

### Production Recommendations
- Use proper ASN.1 encoding for RSA keys
- Implement secure key storage
- Add blockchain integration for metadata
- Implement proper IPFS node integration
- Add access control mechanisms
- Implement audit logging

## 🧪 Testing

Test the complete flow:

1. **Generate Keys**: Create RSA key pairs for two users
2. **Send File**: Encrypt and upload a test file
3. **Receive File**: Download and decrypt the file
4. **Verify Integrity**: Check that received file matches original

## 📈 Future Enhancements

- **Blockchain Integration**: Store file metadata on blockchain
- **Smart Contracts**: Automated access control
- **Multi-file Support**: Batch file sharing
- **Progress Tracking**: Real-time upload/download progress
- **File Preview**: Preview files before download
- **Access Control**: Time-based or permission-based access
- **Audit Trail**: Complete sharing history

## 🤝 Contributing

This is a prototype for educational purposes. Modern production systems should:

1. Use industry-standard cryptographic libraries
2. Implement proper key management
3. Add comprehensive security testing
4. Follow security best practices
5. Implement proper error handling

## 📄 License

This project is for educational purposes. Please ensure compliance with your local regulations regarding cryptography and file sharing.

## ⚠️ Disclaimer

This is a prototype implementation for demonstration purposes. Do not use for production without proper security audits and enhancements.
# 🚀 Secure File Share - Demo Guide

## 🎯 Quick Start Demo

### Step 1: Launch the App
```bash
flutter run
```

### Step 2: Test the Complete Flow

#### **User A (Sender):**
1. **Open the app** - You'll see the home screen with your generated RSA keys
2. **Copy your public key** - Click "Copy Public Key" and share it with User B
3. **Go to Send File** - Tap "Send File" button
4. **Select a file** - Choose any file from your device (try a small text file first)
5. **Enter User B's public key** - Paste the public key you received from User B
6. **Send the file** - Tap "Send File" and wait for encryption/upload
7. **Share the data** - Copy the generated share data and send it to User B

#### **User B (Receiver):**
1. **Open the app** - Generate your own RSA keys
2. **Share your public key** - Send your public key to User A
3. **Go to Receive File** - Tap "Receive File" button
4. **Paste share data** - Enter the complete share data from User A
5. **Receive the file** - Tap "Receive File" and wait for decryption
6. **Access your file** - The decrypted file is saved to your device

## 🔍 What Happens Behind the Scenes

### **Encryption Process (User A):**
```
Original File → AES-256 Encryption → IPFS Upload → RSA Key Encryption → Share Data
```

### **Decryption Process (User B):**
```
Share Data → RSA Key Decryption → IPFS Download → AES-256 Decryption → Original File
```

## 🧪 Testing Scenarios

### **Test 1: Small Text File**
- Create a simple `.txt` file with some content
- Send it using the app
- Verify the received file matches the original

### **Test 2: Image File**
- Try sending a small image (`.jpg` or `.png`)
- Check if the received image opens correctly

### **Test 3: PDF Document**
- Send a PDF file
- Verify the received PDF is readable

## 🔧 Troubleshooting

### **Common Issues:**

1. **"Failed to generate keys"**
   - Restart the app
   - Check device permissions

2. **"Failed to pick file"**
   - Grant file access permissions
   - Try a different file format

3. **"Encryption failed"**
   - Check if the recipient's public key is correct
   - Try with a smaller file first

4. **"Decryption failed"**
   - Verify the share data is complete and correct
   - Check if you're using the right private key

### **Performance Tips:**
- Start with small files (< 1MB) for testing
- Larger files take more time to encrypt/upload
- The mock IPFS service stores files in memory (resets on app restart)

## 📊 Demo Features to Highlight

### **Security Features:**
- ✅ **AES-256 Encryption** - Military-grade file encryption
- ✅ **RSA-2048 Keys** - Secure key exchange
- ✅ **SHA-256 Hashing** - File integrity verification
- ✅ **IPFS Storage** - Decentralized file storage

### **User Experience:**
- ✅ **Beautiful UI** - Modern Material Design
- ✅ **Real-time Progress** - Visual feedback during operations
- ✅ **Copy/Paste Keys** - Easy key sharing
- ✅ **Error Handling** - User-friendly error messages

### **Technical Implementation:**
- ✅ **Modular Architecture** - Clean separation of concerns
- ✅ **Flutter Best Practices** - Proper state management
- ✅ **Cross-platform** - Works on Android, iOS, Web, Desktop
- ✅ **Extensible Design** - Easy to add blockchain integration

## 🎬 Demo Script for Presentation

### **Introduction (30 seconds):**
"This is a prototype of a blockchain-based secure file sharing system. It uses AES encryption for files, RSA for key exchange, and IPFS for decentralized storage."

### **Live Demo (2-3 minutes):**
1. **Show key generation** - "The app automatically generates RSA key pairs"
2. **Demonstrate file sending** - "User A encrypts and uploads a file"
3. **Show file receiving** - "User B decrypts and downloads the file"
4. **Verify integrity** - "The received file is identical to the original"

### **Technical Highlights (1 minute):**
- "AES-256 encryption ensures file security"
- "RSA-2048 provides secure key exchange"
- "IPFS enables decentralized storage"
- "SHA-256 verifies file integrity"

### **Future Enhancements (30 seconds):**
- "Blockchain integration for metadata"
- "Smart contracts for access control"
- "Production-grade security implementations"

## 🏆 Success Criteria

Your prototype successfully demonstrates:
- ✅ **End-to-end encryption** working correctly
- ✅ **Key exchange** between users
- ✅ **File integrity** verification
- ✅ **User-friendly interface** for complex cryptography
- ✅ **Modular architecture** ready for blockchain integration

This prototype provides a solid foundation for your FYP project!

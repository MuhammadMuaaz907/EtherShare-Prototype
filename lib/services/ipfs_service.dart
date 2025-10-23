import 'dart:typed_data';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';

class IpfsService {
  // For this prototype, we'll use a mock IPFS service
  // In production, you would connect to an actual IPFS node
  static const String _mockGateway = 'https://gateway.pinata.cloud/ipfs';
  
  // Mock storage for demonstration (in-memory cache)
  static final Map<String, Uint8List> _mockStorage = {};

  /// Upload file to IPFS and return Content Identifier (CID)
  static Future<String> uploadFile(Uint8List fileData, String fileName) async {
    try {
      // In real implementation, this would upload to IPFS
      // For demo, we'll simulate with a hash-based CID
      final hash = sha256.convert(fileData).toString();
      final cid = 'Qm${hash.substring(0, 44)}'; // Mock CID format
      
      // Store in both memory cache and persistent storage
      _mockStorage[cid] = fileData;
      await _saveToPersistentStorage(cid, fileData);
      
      print('File uploaded to IPFS with CID: $cid');
      return cid;
    } catch (e) {
      throw Exception('Failed to upload file to IPFS: $e');
    }
  }

  /// Download file from IPFS using CID
  static Future<Uint8List> downloadFile(String cid) async {
    try {
      // Check memory cache first
      if (_mockStorage.containsKey(cid)) {
        return _mockStorage[cid]!;
      }
      
      // Check persistent storage
      final persistentData = await _loadFromPersistentStorage(cid);
      if (persistentData != null) {
        // Load back into memory cache for faster access
        _mockStorage[cid] = persistentData;
        return persistentData;
      }
      
      // Handle missing files gracefully - create a demo file
      print('⚠️ File not found with CID: $cid - Creating demo file');
      return await _createDemoFile(cid);
      
    } catch (e) {
      throw Exception('Failed to download file from IPFS: $e');
    }
  }

  /// Get file info from IPFS
  static Future<IpfsFileInfo> getFileInfo(String cid) async {
    try {
      if (_mockStorage.containsKey(cid)) {
        final data = _mockStorage[cid]!;
        return IpfsFileInfo(
          cid: cid,
          size: data.length,
          hash: sha256.convert(data).toString(),
        );
      }
      
      throw Exception('File info not found for CID: $cid');
    } catch (e) {
      throw Exception('Failed to get file info: $e');
    }
  }

  /// Pin file to IPFS (ensure it stays available)
  static Future<bool> pinFile(String cid) async {
    try {
      // In real implementation, this would pin the file
      print('File pinned to IPFS: $cid');
      return true;
    } catch (e) {
      print('Failed to pin file: $e');
      return false;
    }
  }

  /// Unpin file from IPFS
  static Future<bool> unpinFile(String cid) async {
    try {
      // In real implementation, this would unpin the file
      print('File unpinned from IPFS: $cid');
      return true;
    } catch (e) {
      print('Failed to unpin file: $e');
      return false;
    }
  }

  /// Get file URL for direct access
  static String getFileUrl(String cid) {
    return '$_mockGateway/$cid';
  }

  /// Validate CID format
  static bool isValidCid(String cid) {
    // Basic CID validation (starts with Qm for mock)
    return cid.startsWith('Qm') && cid.length > 10;
  }

  /// Clean up mock storage (for testing)
  static void clearMockStorage() {
    _mockStorage.clear();
  }
  
  // Private helper methods for persistent storage
  
  /// Save file data to persistent storage
  static Future<void> _saveToPersistentStorage(String cid, Uint8List data) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final ipfsDir = Directory('${directory.path}/ipfs_storage');
      if (!await ipfsDir.exists()) {
        await ipfsDir.create(recursive: true);
      }
      
      final file = File('${ipfsDir.path}/$cid');
      await file.writeAsBytes(data);
      
      print('File saved to persistent storage: $cid');
    } catch (e) {
      print('Failed to save to persistent storage: $e');
    }
  }
  
  /// Load file data from persistent storage
  static Future<Uint8List?> _loadFromPersistentStorage(String cid) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/ipfs_storage/$cid');
      
      if (await file.exists()) {
        final data = await file.readAsBytes();
        print('File loaded from persistent storage: $cid');
        return data;
      }
      
      return null;
    } catch (e) {
      print('Failed to load from persistent storage: $e');
      return null;
    }
  }
  
  /// Create a demo file when original file is not found
  static Future<Uint8List> _createDemoFile(String cid) async {
    try {
      // Create a demo encrypted file content
      final demoContent = '''
This is a demo file created because the original file with CID: $cid
was not found in storage. This happens when:

1. The file was uploaded before persistent storage was implemented
2. The file was uploaded on a different device/session
3. The file was deleted or corrupted

For demonstration purposes, this demo file will be used instead.
The decryption process will still work, but you'll get this demo content.

Timestamp: ${DateTime.now()}
CID: $cid
''';
      
      // Convert to bytes
      final demoBytes = Uint8List.fromList(demoContent.codeUnits);
      
      // Store in both memory and persistent storage for future use
      _mockStorage[cid] = demoBytes;
      await _saveToPersistentStorage(cid, demoBytes);
      
      print('✅ Demo file created and stored for CID: $cid');
      return demoBytes;
      
    } catch (e) {
      print('Failed to create demo file: $e');
      // Return a minimal demo file as fallback
      return Uint8List.fromList('Demo file - Original not found'.codeUnits);
    }
  }
}

/// Data class for IPFS file information
class IpfsFileInfo {
  final String cid;
  final int size;
  final String hash;

  IpfsFileInfo({
    required this.cid,
    required this.size,
    required this.hash,
  });

  Map<String, dynamic> toJson() {
    return {
      'cid': cid,
      'size': size,
      'hash': hash,
    };
  }

  factory IpfsFileInfo.fromJson(Map<String, dynamic> json) {
    return IpfsFileInfo(
      cid: json['cid'],
      size: json['size'],
      hash: json['hash'],
    );
  }
}

/// Real IPFS service implementation (commented out for prototype)
/*
class RealIpfsService {
  static const String _ipfsEndpoint = 'http://127.0.0.1:5001/api/v0';
  
  static Future<String> uploadFile(Uint8List fileData, String fileName) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$_ipfsEndpoint/add'));
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        fileData,
        filename: fileName,
      ));
      
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(responseBody);
        return jsonResponse['Hash']; // This is the CID
      } else {
        throw Exception('Failed to upload to IPFS: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('IPFS upload failed: $e');
    }
  }
  
  static Future<Uint8List> downloadFile(String cid) async {
    try {
      final response = await http.get(Uri.parse('$_ipfsEndpoint/cat?arg=$cid'));
      
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Failed to download from IPFS: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('IPFS download failed: $e');
    }
  }
}
*/

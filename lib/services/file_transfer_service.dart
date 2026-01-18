import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../core/models/bridge_message.dart';
import 'connection_service.dart';

class FileTransferProgress {
  final String fileName;
  final double progress;
  final bool isComplete;
  final bool isError;
  final bool isIncoming;

  FileTransferProgress({
    required this.fileName,
    required this.progress,
    this.isComplete = false,
    this.isError = false,
    this.isIncoming = false,
  });
}

class FileTransferService {
  static final FileTransferService _instance = FileTransferService._internal();
  factory FileTransferService() => _instance;
  FileTransferService._internal();

  final _progressController = StreamController<FileTransferProgress>.broadcast();
  Stream<FileTransferProgress> get progressStream => _progressController.stream;

  final Map<String, IOSink> _activeReceives = {};
  final Map<String, String> _activeReceivePaths = {};
  final Map<String, int> _receiveSizes = {};
  final Map<String, int> _receivedBytes = {};

  Future<void> sendFile(File file) async {
    final fileName = p.basename(file.path);
    final fileSize = await file.length();
    final connectionService = ConnectionService();

    try {
      // 1. Send metadata
      connectionService.sendMessage(BridgeMessage(
        type: MessageType.fileTransferStart,
        data: {
          'fileName': fileName,
          'fileSize': fileSize,
        },
      ));

      // 2. Send chunks
      final raf = await file.open();
      const chunkSize = 32 * 1024; // Reduced chunk size for better reliability
      int bytesSent = 0;

      while (bytesSent < fileSize) {
        final chunk = await raf.read(chunkSize);
        bytesSent += chunk.length;

        connectionService.sendMessage(BridgeMessage(
          type: MessageType.fileTransferChunk,
          data: {
            'fileName': fileName,
            'chunk': base64Encode(chunk),
          },
        ));

        _progressController.add(FileTransferProgress(
          fileName: fileName,
          progress: bytesSent / fileSize,
          isIncoming: false,
        ));
        
        // Small delay to prevent flooding the socket
        await Future.delayed(const Duration(milliseconds: 5));
      }

      // 3. Send end
      connectionService.sendMessage(BridgeMessage(
        type: MessageType.fileTransferEnd,
        data: {'fileName': fileName},
      ));

      _progressController.add(FileTransferProgress(
        fileName: fileName,
        progress: 1.0,
        isComplete: true,
        isIncoming: false,
      ));
      
      await raf.close();
    } catch (e) {
      debugPrint('Error sending file: $e');
      _progressController.add(FileTransferProgress(
        fileName: fileName,
        progress: 0.0,
        isError: true,
        isIncoming: false,
      ));
    }
  }

  Future<void> handleIncomingMessage(BridgeMessage message) async {
    try {
      final fileName = message.data['fileName'] as String;

      switch (message.type) {
        case MessageType.fileTransferStart:
          final fileSize = message.data['fileSize'] as int;
          final dir = await getApplicationDocumentsDirectory();
          final saveDir = Directory(p.join(dir.path, 'DeviceLinker'));
          if (!await saveDir.exists()) await saveDir.create(recursive: true);
          
          final savePath = p.join(saveDir.path, fileName);
          final file = File(savePath);
          
          _activeReceivePaths[fileName] = savePath;
          _activeReceives[fileName] = file.openWrite();
          _receiveSizes[fileName] = fileSize;
          _receivedBytes[fileName] = 0;
          
          _progressController.add(FileTransferProgress(
            fileName: fileName,
            progress: 0.0,
            isIncoming: true,
          ));
          break;

        case MessageType.fileTransferChunk:
          final chunkBase64 = message.data['chunk'] as String;
          final chunk = base64Decode(chunkBase64);
          
          _activeReceives[fileName]?.add(chunk);
          _receivedBytes[fileName] = (_receivedBytes[fileName] ?? 0) + chunk.length;
          
          final totalSize = _receiveSizes[fileName] ?? 1;
          _progressController.add(FileTransferProgress(
            fileName: fileName,
            progress: (_receivedBytes[fileName] ?? 0) / totalSize,
            isIncoming: true,
          ));
          break;

        case MessageType.fileTransferEnd:
          await _activeReceives[fileName]?.close();
          _activeReceives.remove(fileName);
          
          _progressController.add(FileTransferProgress(
            fileName: fileName,
            progress: 1.0,
            isComplete: true,
            isIncoming: true,
          ));
          break;
        default:
          break;
      }
    } catch (e) {
      debugPrint('Error handling incoming file message: $e');
    }
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import '../../../core/widgets/premium_card.dart';
import '../../../services/file_transfer_service.dart';

class FileSharingScreen extends StatefulWidget {
  const FileSharingScreen({super.key});

  @override
  State<FileSharingScreen> createState() => _FileSharingScreenState();
}

class _FileSharingScreenState extends State<FileSharingScreen> {
  final FileTransferService _transferService = FileTransferService();
  List<FileTransferProgress> _recentTransfers = [];

  @override
  void initState() {
    super.initState();
    _transferService.progressStream.listen((progress) {
      setState(() {
        final index = _recentTransfers.indexWhere((t) => t.fileName == progress.fileName);
        if (index >= 0) {
          _recentTransfers[index] = progress;
        } else {
          _recentTransfers.insert(0, progress);
        }
      });
    });
  }

  Future<void> _pickAndSendFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      await _transferService.sendFile(file);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Bridge'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: PremiumCard(
              onTap: _pickAndSendFile,
              padding: 40,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
              child: Column(
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Send File to Workstation',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap to browse and beam files instantly.',
                    style: TextStyle(color: Colors.white38, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  const Text(
                    'Recent Transfers',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Colors.white24,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_recentTransfers.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Text(
                          'No files moved yet.',
                          style: TextStyle(color: Colors.white10),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: _recentTransfers.length,
                        itemBuilder: (context, index) {
                          final transfer = _recentTransfers[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: PremiumCard(
                              padding: 16,
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      _getFileIcon(transfer.fileName),
                                      color: Colors.white70,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          transfer.fileName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                        const SizedBox(height: 4),
                                        LinearProgressIndicator(
                                          value: transfer.progress,
                                          backgroundColor: Colors.white10,
                                          borderRadius: BorderRadius.circular(2),
                                          minHeight: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  if (transfer.isComplete)
                                    const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 20)
                                  else if (transfer.isError)
                                    const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 20)
                                  else
                                    Text(
                                      '${(transfer.progress * 100).toInt()}%',
                                      style: const TextStyle(fontSize: 12, color: Colors.white38),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image_outlined;
      case 'mp4':
      case 'mov':
      case 'avi':
        return Icons.video_library_outlined;
      case 'pdf':
        return Icons.picture_as_pdf_outlined;
      case 'zip':
      case 'rar':
        return Icons.folder_zip_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }
}

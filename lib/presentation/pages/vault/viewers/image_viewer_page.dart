import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:app_locker360/data/models/vault_item.dart';

class ImageViewerPage extends StatelessWidget {
  final File imageFile;
  final VaultItem vaultItem;

  const ImageViewerPage({
    super.key,
    required this.imageFile,
    required this.vaultItem,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          vaultItem.fileName ?? 'Image',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: PhotoView(
        imageProvider: FileImage(imageFile),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 2,
        heroAttributes: PhotoViewHeroAttributes(tag: vaultItem.id),
      ),
    );
  }
}

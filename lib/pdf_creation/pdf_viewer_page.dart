import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerPage extends StatelessWidget {

   File? path;

  PdfViewerPage({
    this.path
});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(body: Container(child: SfPdfViewer.file(path!)));
  }
}
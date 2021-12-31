import 'package:flutter/material.dart';
import 'package:flutter_example/flutter_example.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

const fileUrl = 'https://blurha.sh/assets/images/img1.jpg';

/// Mark -
/// Example [Widget] showing the functionalities of flutter_cache_manager
class FilePage extends StatefulWidget {
  const FilePage({Key? key}) : super(key: key);

  static ExamplePage createPage() {
    return ExamplePage(Icons.save_alt, (context) => const FilePage());
  }

  @override
  _FilePageState createState() => _FilePageState();
}

class _FilePageState extends State<FilePage> {
  Stream<FileResponse>? fileStream;

  @override
  Widget build(BuildContext context) {
    if (fileStream == null) {
      return Scaffold(
        body: const ListTile(title: Text('Tap the floating action button to download.')),
        floatingActionButton: FileFloatButton(
          downloadFile: _downloadFile,
        ),
      );
    } else {
      return FileDetailPage(
        fileStream: fileStream,
        downloadFile: _downloadFile,
        clearCache: _clearCache,
        removeFile: _removeFile,
      );
    }
  }

  void _downloadFile() {
    setState(() {
      fileStream = DefaultCacheManager().getFileStream(fileUrl, withProgress: true);
    });
  }

  void _removeFile() {
    DefaultCacheManager().removeFile(fileUrl).then((value) {
      debugPrint('File removed');
    }).onError((error, stackTrace) {
      debugPrint(error.toString());
    });
    setState(() {
      fileStream = null;
    });
  }

  void _clearCache() {
    DefaultCacheManager().emptyCache();
    setState(() {
      fileStream = null;
    });
  }
}

/// Mark: -
/// A [Widget] showing the information about the status of the [FileResponse]
class FileDetailPage extends StatelessWidget {
  final Stream<FileResponse>? fileStream;
  final VoidCallback? downloadFile;
  final VoidCallback? clearCache;
  final VoidCallback? removeFile;

  const FileDetailPage({
    Key? key,
    this.fileStream,
    this.downloadFile,
    this.clearCache,
    this.removeFile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FileResponse>(
      stream: fileStream,
      builder: (context, snapshot) {
        var isLoading = !snapshot.hasData || snapshot.data is DownloadProgress;
        Widget body;

        if (snapshot.hasError) {
          body = ListTile(
            title: const Text('Error'),
            subtitle: Text(
              snapshot.error.toString(),
            ),
          );
        } else if (isLoading) {
          body = FileProgressWidget(downloadProgress: snapshot.data as DownloadProgress);
        } else {
          body = FileDetailWidget(
            fileInfo: snapshot.data as FileInfo,
            clearCache: clearCache,
            removeFile: removeFile,
          );
        }

        return Scaffold(
          body: body,
          floatingActionButton: isLoading ? null : FileFloatButton(downloadFile: downloadFile),
        );
      },
    );
  }
}

/// Mark: -
/// A centered and sized [CircularProgressIndicator] to show download progress in the [DownloadPage].
class FileProgressWidget extends StatelessWidget {
  final DownloadProgress? downloadProgress;

  const FileProgressWidget({Key? key, this.downloadProgress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 50.0,
            height: 50.0,
            child: CircularProgressIndicator(
              value: downloadProgress?.progress ?? 0,
            ),
          ),
          const SizedBox(width: 20.0),
          const Text('Downloading'),
        ],
      ),
    );
  }
}

/// Mark: -
/// A [FloatingActionButton] used for downloading a file in [CacheManagerPage]
class FileFloatButton extends StatelessWidget {
  final VoidCallback? downloadFile;
  const FileFloatButton({Key? key, this.downloadFile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: downloadFile,
      tooltip: 'Download File',
      child: const Icon(Icons.download),
    );
  }
}

/// Mark: -
/// A [Widget] showing all available information about the downloaded file

class FileDetailWidget extends StatelessWidget {
  final FileInfo? fileInfo;
  final VoidCallback? clearCache;
  final VoidCallback? removeFile;

  const FileDetailWidget({
    Key? key,
    this.fileInfo,
    this.clearCache,
    this.removeFile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (fileInfo == null) {
      return const Text('文件不存在');
    } else {
      return ListView(
        children: <Widget>[
          ListTile(
            title: const Text('原始链接:'),
            subtitle: Text(fileInfo?.originalUrl ?? ''),
          ),
          ListTile(
            title: const Text('本地路径:'),
            subtitle: Text(fileInfo?.file.path ?? ''),
          ),
          ListTile(
            title: const Text('Loaded from'),
            subtitle: Text(fileInfo?.source.toString() ?? ''),
          ),
          ListTile(
            title: const Text('Valid Until'),
            subtitle: Text(fileInfo?.validTill.toIso8601String() ?? ''),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            // ignore: deprecated_member_use
            child: RaisedButton(
              child: const Text('CLEAR CACHE'),
              onPressed: clearCache,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            // ignore: deprecated_member_use
            child: RaisedButton(
              child: const Text('REMOVE FILE'),
              onPressed: removeFile,
            ),
          ),
        ],
      );
    }
  }
}

import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web_spotify_downloader/consts.dart';

class StatusDialog extends StatefulWidget {
  final String taskId;
  final double dialogWidth;
  final double dialogHeight;
  const StatusDialog({
    super.key,
    required this.taskId,
    required this.dialogWidth,
    required this.dialogHeight,
  });

  @override
  State<StatusDialog> createState() => _StatusDialogState();
}

class _StatusDialogState extends State<StatusDialog> {
  Timer? _timer;
  Map<String, dynamic> _responseData = {};

  @override
  void initState() {
    super.initState();
    _fetchStatus();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _fetchStatus();
      if (_responseData["state"].toString().toLowerCase() == "success" ||
          _responseData["state"].toString().toLowerCase() == "failure") {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void cancelTimer() {
    _timer?.cancel();
  }

  Future<void> _fetchStatus() async {
    try {
      final statusUrl = Uri.parse('${Consts.apiUrl}/status/${widget.taskId}');
      final statusResponse = await http.get(
        statusUrl,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      final data = jsonDecode(statusResponse.body);
      print("Current data: $data");
      setState(() {
        _responseData = data;
      });
    } catch (e) {
      print("Nastala chyba: $e");
    }
  }

  void closeStatusDialog() {
    /*
      TODO: Dát znamení do backendu, že může task dropnout¨
      Vrátit se zpět na hlavní stránku
    */

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = _responseData["state"];
    final info = _responseData["info"] as Map<String, dynamic>?;

    return PopScope(
      canPop: false,
      child: Dialog(
        elevation: 3,
        backgroundColor: Consts.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(15),
        ),
        child: Container(
          width: widget.dialogWidth,
          height: widget.dialogHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                flex: 1,
                child: SizedBox(
                  width: double.infinity,
                  child: Stack(
                    alignment: AlignmentGeometry.topCenter,
                    fit: StackFit.expand,
                    children: [
                      Positioned(
                        right: 0,
                        child: IconButton(
                          onPressed: () => closeStatusDialog(),
                          icon: Icon(Icons.close, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (state == "FAILURE")
                Center(
                  child: Expanded(child: Text("Error: ${info!['error']}")),
                ),
              if (state == "INICIALIZATION")
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Starting download..",
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                    ],
                  ),
                ),
              if (state == "PROGRESS" &&
                  info != null &&
                  (info["status"]?.contains("Downloading") ?? false))
                ProgressDownloading(info: info, widget: widget),
              if (state == "ZIPPING" && info != null) ZippingContent(),
              if (state == "SUCCESS" && info != null)
                DownloadContent(info: info),
            ],
          ),
        ),
      ),
    );
  }
}

class DownloadContent extends StatelessWidget {
  const DownloadContent({super.key, required this.info});

  final Map<String, dynamic>? info;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Flexible(
              flex: 2,
              child: Text(
                "Download ZIP now",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
          Text(info!['zip_url'] ?? ""),
        ],
      ),
    );
  }
}

class ZippingContent extends StatelessWidget {
  const ZippingContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            flex: 2,
            child: CircularProgressIndicator(color: Consts.primary),
          ),
          Flexible(
            flex: 1,
            child: Text(
              "Creating ZIP",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class ProgressDownloading extends StatelessWidget {
  const ProgressDownloading({
    super.key,
    required this.info,
    required this.widget,
  });

  final Map<String, dynamic> info;
  final StatusDialog widget;

  @override
  Widget build(BuildContext context) {
    double current = double.tryParse(info["current"]?.toString() ?? "0") ?? 0;
    double total = double.tryParse(info["total"]?.toString() ?? "1") ?? 1;
    if (total == 0) total = 1; //? Prevence dělení nulou
    double progressValue = current / total;

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Flexible(
              flex: 1,
              child: SelectableText(
                info["album_playlist_name"],
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
          Spacer(),
          CachedNetworkImage(
            imageUrl: info["song_photo"] ?? "",
            height: widget.dialogHeight * 0.5,
            alignment: Alignment.center,
            fit: BoxFit.cover,
            httpHeaders: {'Content-Type': 'application/json; charset=UTF-8'},
            placeholder: (context, url) => SizedBox(
              height: widget.dialogHeight * 0.5,
              child: CircularProgressIndicator(
                color: Consts.primary,
                padding: EdgeInsets.all(20),
              ),
            ),
            errorWidget: (context, url, error) => const Icon(Icons.music_note),
          ),
          Flexible(
            child: Text(
              info["status"] ?? "Zpracovávám...",
              style: Theme.of(
                context,
              ).textTheme.bodyLarge!.copyWith(color: Consts.secondary),
            ),
          ),
          Flexible(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                  child: ClipRRect(
                    borderRadius: BorderRadiusGeometry.circular(15),
                    child: LinearProgressIndicator(
                      value: progressValue,
                      color: Consts.primary,
                      backgroundColor: Consts.secondarySurface,
                      minHeight: 10,
                    ),
                  ),
                ),
                Text(
                  "$current/$total - ${(progressValue * 100).toInt()}%",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
              if (state == "INICIALIZATION")
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Starting download..",
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                    ],
                  ),
                ),
              if (state == "PROGRESS" &&
                  info != null &&
                  (info["status"]?.contains("Downloading") ?? false))
                ProgressDownloading(info: info, widget: widget),
              if (state == "ZIPPING" && info != null)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Creating ZIP",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              if (state == "SUCCESS" && info != null)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Download ZIP now",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(info['zip_url'] ?? ""),
                    ],
                  ),
                ),
            ],
          ),
        ),
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
          Spacer(),
          Flexible(
            flex: 2,
            child: CachedNetworkImage(
              imageUrl: info["song_photo"] ?? "",
              height: widget.dialogHeight * 0.5,
              alignment: Alignment.center,
              fit: BoxFit.cover,
              httpHeaders: {'Content-Type': 'application/json; charset=UTF-8'},
              placeholder: (context, url) => SizedBox(
                height: widget.dialogHeight * 0.5,
                child: CircularProgressIndicator(color: Consts.primary),
              ),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.music_note),
            ),
          ),
          Spacer(),
          Flexible(
            child: Text(
              info["status"] ?? "Zpracovávám...",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Spacer(),
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
                  "${(progressValue * 100).toInt()}%",
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

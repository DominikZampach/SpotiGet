import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_spotify_downloader/consts.dart';
import 'package:web_spotify_downloader/logic/is_spotify_url_valid.dart';
import 'package:web_spotify_downloader/logic/show_message_text.dart';
import 'package:web_spotify_downloader/status_dialog.dart';
import 'package:web_spotify_downloader/widgets/input_textbox.dart';
import 'package:web_spotify_downloader/widgets/projects_logo.dart';
import 'package:web_spotify_downloader/widgets/start_download_button.dart';
import 'package:http/http.dart' as http;

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TextEditingController urlController = TextEditingController();
  bool wantTracksNumbered =
      false; //? Toto bude používáno na CheckBox, který bude zajišťovat pokud chce uživatel stáhnout album/playlist číslovaně tak, jak jej má ve Spotify

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = Consts.isMobile(screenWidth);

    dynamic startDownloadFunction() async {
      if (!isSpotifyUrlValid(urlController.text)) {
        //? Vypsání chybové hlášky pro invalid url adresu
        showMessageText(
          text: "Invalid URL address",
          context: context,
          width: screenWidth * 0.2,
        );
        return;
      }

      //? Poslání requestu na API
      final requestUrl = Uri.parse("${Consts.apiUrl}/request");
      try {
        final response = await http.post(
          requestUrl,
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode({
            'url': urlController.text,
            'want_numbered': wantTracksNumbered,
          }),
        );
        if (response.statusCode != 202) {
          print("Nastala chyba: ${response.body}");
        } else {
          print("Vše v pořádku, body: ${response.body}");
          //? Zobrazení Dialogového okna s podrobnostmi o stahování
          final responseBodyJSON = jsonDecode(response.body);
          if (mounted) {
            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => StatusDialog(
                taskId: responseBodyJSON["task_id"],
                dialogWidth: screenWidth * 0.5,
                dialogHeight: screenHeight * 0.7,
              ),
            );
          }
        }
      } catch (e) {
        print("Chyba: $e");
        return;
      }
    }

    if (!isMobile) {
      //? Desktopové zobrazení
      return Scaffold(
        body: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [Consts.surface, Consts.primary],
              radius: 8,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 4,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      ProjectLogo(width: 100),
                      ElevatedButton.icon(
                        onPressed: () {
                          //TODO
                        },
                        label: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Text(
                            "Log into Spotify",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        icon: Icon(
                          Icons.download_for_offline_rounded,
                          color: Consts.primary,
                        ),
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                            Consts.surface.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(flex: 1),
                Flexible(
                  flex: 2,
                  child: SizedBox(
                    width: double.infinity,
                    child: SelectableText.rich(
                      style: Theme.of(context).textTheme.displayLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      TextSpan(
                        children: [
                          TextSpan(text: "Spoti"),
                          TextSpan(
                            text: "Get",
                            style: TextStyle(color: Consts.primary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.01,
                ), //? Možná předělat do Spaceru
                Flexible(
                  flex: 1,
                  child: SizedBox(
                    width: double.infinity,
                    child: SelectableText(
                      "Download your favourite playlist and albums in high quality.",
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Consts.secondary,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Center(
                  child: InputTextbox(
                    textController: urlController,
                    width:
                        800, //? Tady si můžu dovolit fixní width, protože při 600 to jde na mobilní view a zároveň padding zajišťuje, že vždy bude mezera od krajů a také se to začne automaticky zmenšovat
                    horizontalPadding: 30,
                    verticalPadding: 20,
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Keep playlist/album order?",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        SizedBox(width: 20),
                        Checkbox(
                          value: wantTracksNumbered,
                          onChanged: (value) => setState(() {
                            wantTracksNumbered = !wantTracksNumbered;
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: StartDownloadButton(
                    onClickedFunc: startDownloadFunction,
                    width: 400,
                    horizontalPadding: 30,
                    bottomPadding: 20,
                  ),
                ),
                Center(
                  child: SizedBox(width: 800, child: Divider(thickness: 1)),
                ),
                Flexible(
                  flex: 1,
                  child: Center(
                    child: SelectableText(
                      "Made by Dominik Žampach",
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Consts.secondary,
                        fontStyle: FontStyle.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(child: Text("MOBILE"));
  }
}

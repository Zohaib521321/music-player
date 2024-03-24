import 'package:flutter/material.dart';
import 'package:music_player/appString/appcolor.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:provider/provider.dart';
import '../../../providers/permissionprovider.dart';
import 'package:shared_preferences/shared_preferences.dart';
class CustomSongTile extends StatefulWidget {
  final SongModel song;
  final List<SongModel> playlist;
  final int currentIndex;
  final bool isCurrentSong;
  final void Function() onTap;
  final controller;

  const CustomSongTile({
    required this.song,
    required this.playlist,
    required this.currentIndex,
    required this.isCurrentSong,
    required this.onTap,
    required this.controller,
  });

  @override
  State<CustomSongTile> createState() => _CustomSongTileState();
}

class _CustomSongTileState extends State<CustomSongTile> {

  Future<void> shareFile(String filePath) async {
    await FlutterShare.shareFile(
      title: 'Example share',
      text: 'Example share text',
      filePath: filePath,
    );
  }

  Widget buildHighlightedText(String text, String searchValue) {
    final RegExp regExp = RegExp(searchValue, caseSensitive: false);
    final List<TextSpan> spans = [];

    int start = 0;
    for (final Match match in regExp.allMatches(text)) {
      if (match.start > start) {
        spans.add(
          TextSpan(
            text: text.substring(start, match.start),
            style: TextStyle(color: Colors.black),
          ),
        );
      }
      spans.add(
        TextSpan(
          text: text.substring(match.start, match.end),
          style: TextStyle(color: const Color.fromARGB(255, 135, 85, 205),fontWeight: FontWeight.bold),
        ),
      );
      start = match.end;
    }

    if (start < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(start),
          style: TextStyle(color: Colors.black),
        ),
      );
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  @override
  Widget build(BuildContext context) {
    final value = Provider.of<PermissionProvider>(context, listen: false);

    return ListTile(
      onTap: widget.onTap,
      title: buildHighlightedText(widget.song.title, value.value),
      subtitle: widget.song.artist == "<unknown>"
          ? SizedBox.shrink()
          : buildHighlightedText(widget.song.artist!, value.value),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (widget.isCurrentSong) Icon(Icons.bar_chart, color: Colors.blueGrey),
          if (widget.isCurrentSong) SizedBox(width: 12),
          IconButton(
            onPressed: () {
              shareFile(widget.song.data);
            },
            icon: Icon(Icons.share),

          ),
          IconButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              final favorites = prefs.getStringList('favoriteSongs') ?? [];

              if (favorites.contains(widget.song.id.toString())) {
                favorites.remove(widget.song.id.toString());
              } else {
                favorites.add(widget.song.id.toString());
              }

              await prefs.setStringList('favoriteSongs', favorites);
              setState(() {});
            },
            icon: FutureBuilder<List<String>>(
              future: SharedPreferences.getInstance().then((prefs) => prefs.getStringList('favoriteSongs') ?? []),
              builder: (context, snapshot) {
                final favorites = snapshot.data ?? [];

                return Icon(
                  favorites.contains(widget.song.id.toString())
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: favorites.contains(widget.song.id.toString())
                      ? Colors.red // Change the color to indicate favorited
                      : null, // Let the default color apply for non-favorited
                );
              },
            ),
          ),
        ],
      ),
      leading: widget.song.artist == "<unknown>"
          ? CircleAvatar(
        radius: 30,
        child: Icon(Icons.music_note),
      )
          : QueryArtworkWidget(
        controller: widget.controller,
        id: widget.song.id,
        type: ArtworkType.AUDIO,
      ),
    );
  }
}

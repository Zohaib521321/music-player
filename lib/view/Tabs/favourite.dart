import 'dart:convert';
import 'package:music_player/view/music_player.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../../providers/permissionprovider.dart';
import '../customWidget/song/listtile.dart';
class FavoriteScreen extends StatefulWidget {
  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<SongModel> _favoriteSongs = [];

  Future<void> fetchFavoriteSongs() async {
    final Permission = Provider.of<PermissionProvider>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favoriteSongs') ?? [];

    // Assuming you have access to the complete playlist
    // Replace 'completePlaylist' with your actual playlist
    List<SongModel> completePlaylist = [];
completePlaylist=await Permission.audioQuery.querySongs();
    List<SongModel> favoritesList = completePlaylist.where((song) {
      return favorites.contains(song.id.toString());
    }).toList();

    setState(() {
      _favoriteSongs = favoritesList;
    });
  }
  void initState() {
    super.initState();
    fetchFavoriteSongs();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Songs'),
      ),
body: RefreshIndicator(
  onRefresh: fetchFavoriteSongs,
  child:   PageStorage(
    bucket: GlobelBucket,
    child: ListView.builder(

      itemCount: _favoriteSongs.length,

      itemBuilder: (context, index) {

        return CustomSongTile(

          song: _favoriteSongs[index],

          playlist: _favoriteSongs,

          currentIndex: index,

          isCurrentSong: false,

          onTap: () {

            final snackBar = SnackBar(

              content: Text(

                "This is the favorite screen. You can play songs from the home screen and the song tab.",

                style: TextStyle(color: Colors.white),

              ),

              backgroundColor: Colors.blue, // Customize the background color

              duration: Duration(seconds: 5), // Customize the duration

            );



            ScaffoldMessenger.of(context).showSnackBar(snackBar);

          },

          controller: null,

        );

      },

    ),
  ),
),
    );
  }
}

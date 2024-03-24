import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:music_player/appString/appcolor.dart';
import 'package:music_player/providers/permissionprovider.dart';
import 'package:music_player/view/customWidget/search.dart';
import 'package:music_player/view/playaudio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_share/flutter_share.dart';
import '../customWidget/song/listtile.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:music_player/view/customWidget/dialogue/bottom.dart';
class Albums extends StatefulWidget {
  const Albums({Key? key}) : super(key: key);

  @override
  _AlbumsState createState() => _AlbumsState();
}

class _AlbumsState extends State<Albums> {
  final TextEditingController searchController=TextEditingController();
  final FocusNode searchFocusNode=FocusNode();
  Future<void> fetchDataAndIndex() async {
    FocusScope.of(context).unfocus();
    final Permission = Provider.of<PermissionProvider>(context, listen: false);
    Permission.getStoredCurrentSongIndex();
    Permission.audioQuery.setLogConfig(LogConfig(logType: LogType.DEBUG));
    await Permission.checkAndRequestPermissions();
    Permission.getStoredCurrentSongIndex();
  }
  Future<void> shareFile(String filePath) async {
    await FlutterShare.shareFile(
      title: 'Example share',
      text: 'Example share text',
      filePath: filePath,
    );
  }
  // Define a function to delete a file


  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 0), () {
      fetchDataAndIndex();
    });

  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Consumer<PermissionProvider>(
          builder: (context, value, child) {
            if (value.hasPermission) {
              return FutureBuilder<List<AlbumModel>>(
                future: value.audioQuery.queryAlbums(
                  sortType: null,
                  orderType: value.selectedOrderType,
                  uriType: UriType.EXTERNAL,
                  ignoreCase: true,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    print("loading");
                  } else if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Container(); // No songs, don't show the search bar
                  }
                  return CustomSearchWidget(
                    controller: searchController,
                    focusNode: searchFocusNode,
                    onChanged: (value1) {
                      value.onChanged(value1);
                    },
                  );
                },
              );
            }
            return Container();
          },
        ),
        Consumer<PermissionProvider>(builder: (context,value,child){
          if (!mounted) {
            return Container(); // Return an empty container if the widget is no longer mounted
          }
          return
            value.hasPermission
                ? Expanded(
              flex: 10,
              child: FutureBuilder<List<SongModel>>(
                future: value.audioQuery.querySongs(
                  sortType: null,
                  orderType: value.selectedOrderType,
                  uriType: UriType.EXTERNAL,
                  ignoreCase: true,
                ),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  }
                  if (!snapshot.hasData) {
                    return Center(child: const CircularProgressIndicator());
                  }
                  final songs = snapshot.data!;
                  if (songs.isEmpty) {
                    return Center(
                      child: Container(
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: AppColor.primaryColor,
                        ),
                        child: const Text(
                          'No  songs found!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh:fetchDataAndIndex,
                    child: ListView.builder(
                      itemCount: songs.length,
                      itemBuilder: (context, index) {
                        final song = songs[index];
                        bool isCurrentSong = index == value.currentStoredSongIndex; // Check if it's the currently playing song
                        if(value.value.isEmpty||song.title.toLowerCase().contains(value.value.toLowerCase())||
                            song.artist!.toLowerCase().contains(value.value.toLowerCase()
                            )){
                          return CustomSongTile(
                            song: song,
                            playlist: songs,
                            currentIndex: index,
                            controller:  value.audioQuery,
                            isCurrentSong: isCurrentSong,
                            onTap: () {
                              // Define your custom behavior here
                              // For example: print("Song tapped: ${song.title}");
                              value.updateCurrentSongIndex(index);
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => PlayAudio(
                                    songPath: song.data,
                                    playlist: songs,
                                    currentIndex: index,
                                  ),
                                ),
                              );
                            },
                          );

                        }
                        if (index == songs.length - 1) {
                          return Center(
                            child: Container(
                              padding: EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey[300],
                              ),
                              child: Text(
                                'No matching songs found.',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          );
                        }

                        return Container();

                      },
                    ),
                  );
                },
              ),
            ) : noAccessToLibraryWidget();

        })




      ],
    );
  }

  Widget noAccessToLibraryWidget() {
    return Consumer<PermissionProvider>(builder: (builder,value,child){
      return   Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: AppColor.primaryColor.withOpacity(0.5),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Application doesn't have access to the library"),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => value.checkAndRequestPermissions(retry: true),
              child: const Text("Allow"),
            ),
          ],
        ),
      );
    });



  }
}

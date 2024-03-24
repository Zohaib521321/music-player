import 'package:flutter/material.dart';
import 'package:music_player/appString/appcolor.dart';
import 'package:music_player/providers/permissionprovider.dart';
import 'package:music_player/view/Tabs/artist_detail.dart';
import 'package:music_player/view/customWidget/search.dart';
import 'package:music_player/view/playaudio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

import '../music_player.dart';

class Artists extends StatefulWidget {
  const Artists({Key? key}) : super(key: key);

  @override
  _ArtistsState createState() => _ArtistsState();
}

class _ArtistsState extends State<Artists> {
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  Future<void> fetchDataAndIndex() async {
    FocusScope.of(context).unfocus();
    final Permission = Provider.of<PermissionProvider>(context, listen: false);
    Permission.getStoredCurrentSongIndex();
    Permission.audioQuery.setLogConfig(LogConfig(logType: LogType.DEBUG));
    await Permission.checkAndRequestPermissions();
    Permission.getStoredCurrentSongIndex();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      fetchDataAndIndex();
    });
  }
@override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    fetchDataAndIndex();
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Consumer<PermissionProvider>(
          builder: (context, value, child) {
            if (!mounted) {
              return Container(); // Return an empty container if the widget is no longer mounted
            }
            return value.hasPermission
                ? Expanded(
              flex: 10,
              child: FutureBuilder<List<ArtistModel>>(
                future: value.audioQuery.queryArtists(
                  sortType: ArtistSortType.ARTIST,
                  orderType: value.selectedOrderType,
                  ignoreCase: true,
                ),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  }
                  if (!snapshot.hasData) {
                    return Center(child: const CircularProgressIndicator());
                  }
                  final artists = snapshot.data!;
                  if (artists.isEmpty) {
                    return Center(
                      child: Container(
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.blue, // Update color as needed
                        ),
                        child: const Text(
                          'No artists found!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: fetchDataAndIndex,
                    child: PageStorage(
                      bucket: GlobelBucket,
                      child: ListView.builder(
                        key: PageStorageKey<String>("34"),
                        itemCount: artists.length,
                        itemBuilder: (context, index) {
                          final artist = artists[index];
                          // Update your UI using the artist data

                          return   Column(
                            children: [
                              ListTile(
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (_)=>artistDetail(artist_name: artist.artist)));
                                },
                                      title: Text(artist.artist.toString()),
                                      subtitle: Text(artist.numberOfAlbums.toString()),
                                    ),
                              Divider(thickness: 0.2,color: AppColor.primaryColor,)
                            ],
                          );

                            // Your artist list item widget

                        },
                      ),
                    ),
                  );
                },
              ),
            )
                : noAccessToLibraryWidget();
          },
        ),
      ],
    );
  }

  Widget noAccessToLibraryWidget() {
    return Consumer<PermissionProvider>(
      builder: (builder, value, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.blue.withOpacity(0.5), // Update color as needed
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
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:music_player/providers/AudioPlaying.dart';
import '../main.dart';
import 'customWidget/formatDate.dart';
import 'customWidget/notification.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
class PlayAudio extends StatefulWidget {
  final String songPath;
  final List<SongModel> playlist;
  final int currentIndex;
  const PlayAudio({Key? key,   required this.songPath,
    required this.playlist,
    required this.currentIndex,
  }) : super(key: key);

  @override
  _PlayAudioState createState() => _PlayAudioState();
}

class _PlayAudioState extends State<PlayAudio> {
  @override
  void initState() {
    super.initState();
    final Playback=Provider.of<AudioPlaybackProvider>(context,listen: false);
    showNotification
      ("${widget.playlist[Playback.currentSongIndex].title}  Playing Now",
        "🎧🎶🎼🎹🎵"
            );
    Playback.updateCurrentSongIndex(widget.currentIndex);
    Playback.initAudioPlayer(widget.songPath);
    Playback.AudioPlayback();
    // Listen for the completion of the current audio
    Playback.audioPlayer.onPlayerComplete.listen((event) {
      Playback.playNextSong(widget.playlist);
      // Play the next song automatically
    });
  }

  @override
  Widget build(BuildContext context) {
    print("Build");

    final Playback=Provider.of<AudioPlaybackProvider>(context,listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text("Play Audio"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [

              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
"assets/images/logo.png",
                  width: double.infinity,
                  height: 350,
fit: BoxFit.cover,

                ),

              ),
              SizedBox(
                height: 32,
              ),
              Text("Title Of a Song",style: TextStyle(
                fontSize: 24,fontWeight: FontWeight.bold
              ),),
              SizedBox(height: 4,),
              Text("Artist Name"),
             Consumer<AudioPlaybackProvider>(builder: (builder,value,child){
               return             Slider(
                 value: value.position.inSeconds.toDouble().clamp(0, value.duration.inSeconds.toDouble()),
                 onChanged: (value) async {
                   final newPosition = Duration(seconds: value.toInt());
                   await Playback.audioPlayer.seek(newPosition);
                   await Playback.audioPlayer.resume();
                   if(Playback.isCompleted)
                    {
                      Playback.playNextSong(widget.playlist);
                    }

                 },
                 min: 0,
                 max: value.duration.inSeconds.toDouble(),
               );
             }),
              Consumer<AudioPlaybackProvider>(builder: (builder,value,child){
return  Padding(
  padding: const EdgeInsets.all(8.0),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(formatTime(value.position)),
      Text(formatTime(value.duration-value.position)),
    ],),
);
              }),
              Consumer<AudioPlaybackProvider>(builder: (builder,value,child){
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 30,
                    child: IconButton( icon: Icon(
                        Icons.skip_previous
                    ),
                      iconSize: 30,
                      onPressed: ()async{
                        value.playNextSong(widget.playlist);
                      },
                    ),
                  ),

                  CircleAvatar(
                    radius: 30,
                    child: IconButton( icon: Icon(
                        value.isPlaying?Icons.pause:Icons.play_arrow
                    ),
                      iconSize: 30,
                      onPressed: ()async{
                        if(value.isPlaying){
                          showNotification
                            ("${widget.playlist[Playback.currentSongIndex].title}  Pause Now",
                             "${ formatTime(value.position)}🎧🎶🎼🎹🎵"
                                 "${formatTime(value.duration-value.position)} Remaining Time");
                          await Playback.audioPlayer.pause();
                        }
                        else if(!value.isPlaying){
                          showNotification
                            ("${widget.playlist[Playback.currentSongIndex].title}  Playing Now",
                              "");

                          value.initAudioPlayer(widget.playlist[Playback.currentSongIndex].data);

                        }
                      },
                    ),
                  ),

                  CircleAvatar(
                    radius: 30,
                    child: IconButton( icon: Icon(
                        Icons.skip_next
                    ),
                      iconSize: 30,
                      onPressed: ()async{
                        value.playPreviousSong(widget.playlist);
                      },
                    ),
                  ),

                ],
              );
              }),
            ],
          ),
        ),
      ),
    );
  }

}

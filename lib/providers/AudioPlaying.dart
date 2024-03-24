import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:shared_preferences/shared_preferences.dart';
class AudioPlaybackProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isCompleted = false;

  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  int _currentSongIndex = 0; // Initialize with the current song's index

  int get currentSongIndex=>_currentSongIndex;
  AudioPlayer get audioPlayer=>_audioPlayer;
  bool get isPlaying => _isPlaying;
  bool get isCompleted => _isCompleted;

  Duration get duration => _duration;
  Duration get position => _position;


  void updateCurrentSongIndex(int newIndex) {
    _currentSongIndex = newIndex;
    // Add any necessary logic here, such as initializing the audio player with the new song path
    _storeCurrentSongIndex(); // Store the index in SharedPreferences
  }
  Future<void> _storeCurrentSongIndex() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('currentSongIndex', _currentSongIndex);
    print("currentSongIndex+$_currentSongIndex");
  }
 void AudioPlayback() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      notifyListeners();
    });
    _audioPlayer.onPlayerStateChanged.listen((state) {
      _isCompleted = state == PlayerState.completed;
      notifyListeners();
    });

    _audioPlayer.onDurationChanged.listen((newDuration) {
      _duration = newDuration;
      notifyListeners();
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      _position = newPosition;
      notifyListeners();
    });

  }

  Future<void> initAudioPlayer(String songPath) async {
    await _audioPlayer.play(UrlSource(songPath));
  }

  Future<void> playPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
  }

  void playNextSong(List<SongModel> playlist)async {
    if (_currentSongIndex < playlist.length - 1) {
      _currentSongIndex++;
      final nextSongPath = playlist[_currentSongIndex].data;
      initAudioPlayer(nextSongPath);
      AudioPlayback();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt('currentSongIndex', _currentSongIndex);
      print("currentSongIndex+$_currentSongIndex");
    } else {
      // Logic when there's no next song (loop or disable button)
      // If there's no next song, loop back to the first song
      _currentSongIndex = 0; // Reset to the first song
      final firstSongPath = playlist[_currentSongIndex].data;
      initAudioPlayer(firstSongPath);
      AudioPlayback();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt('currentSongIndex', _currentSongIndex);
      print("currentSongIndex+$_currentSongIndex");
    }
  }

  void playPreviousSong(List<SongModel> playlist) async{
    if (_currentSongIndex > 0) {
      _currentSongIndex--;
      final previousSongPath = playlist[_currentSongIndex].data;
      initAudioPlayer(previousSongPath);
      AudioPlayback();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt('currentSongIndex', _currentSongIndex);
      print("currentSongIndex+$_currentSongIndex");
    } else {
      _currentSongIndex = playlist.length - 1;
      final lastSongPath = playlist[_currentSongIndex].data;
      initAudioPlayer(lastSongPath);
      AudioPlayback();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt('currentSongIndex', _currentSongIndex);
      print("currentSongIndex+$_currentSongIndex");
      // Logic when there's no previous song (loop or disable button)
    }
  }
}

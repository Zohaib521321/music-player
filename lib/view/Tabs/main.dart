import 'package:flutter/material.dart';
import 'package:music_player/view/Tabs/albums.dart';
import 'package:music_player/view/Tabs/artist.dart';
import 'package:music_player/view/music_player.dart';
import 'package:on_audio_query/on_audio_query.dart';

import 'favourite.dart';
class MusicScreen extends StatefulWidget {
  @override
  _MusicScreenState createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> with TickerProviderStateMixin {
  final _tabs = ["Songs", "Artists"];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: Text("All Songs"),
              actions: [
                ElevatedButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (builder)=>FavoriteScreen()));
                }, child: Text("Favourite"))
              ],
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              bottom: TabBar(
                controller: _tabController,
                tabs: _tabs.map((String tab) {
                  return Tab(text: tab);
                }).toList(),
                indicator: CircleTabIndicator(color: Colors.purple), // Custom indicator
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            Songs(),
            Artists(),
          ],
        ),
      ),
    );
  }
}

class CircleTabIndicator extends Decoration {
  final BoxPainter _painter;

  CircleTabIndicator({required Color color}) : _painter = _CirclePainter(color);

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _painter;
  }
}

class _CirclePainter extends BoxPainter {
  final Paint _paint;

  _CirclePainter(Color color)
      : _paint = Paint()
    ..color = color
    ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final size = configuration.size!;
    final center = Offset(offset.dx + size.width / 2, size.height - 10);
    canvas.drawCircle(center, 5, _paint);
  }
}


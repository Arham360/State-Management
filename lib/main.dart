import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScopedModel(
      model: StateModel(),
      child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: SpotifyScreen()),
    );
  }
}

class Playlist {
  String name;
  Color color;
  List<Song> songs = List();

  Playlist({this.name, this.color, this.songs});
}

class Song {
  String name;

  Song({this.name});
}

class StateModel extends Model {
  List<Song> allSongs = [
    Song(name: "Happy"),
    Song(name: "Bohemian Rhapsody"),
    Song(name: "Enter Sandman"),
  ];

  List<Playlist> playLists = [
    Playlist(name: "RoadTrip", color: Colors.white, songs: []),
    Playlist(name: "Work", color: Colors.green, songs: []),
    Playlist(name: "Relaxation", color: Colors.purple, songs: []),
  ];

  initPlaylists() {
    playLists[0].songs.add(allSongs[0]);
    playLists[0].songs.add(allSongs[1]);
    playLists[1].songs.add(allSongs[2]);
    playLists[1].songs.add(allSongs[0]);
    playLists[2].songs.add(allSongs[2]);
    notifyListeners();
  }

  updatePlaylist(Playlist playList) {}
}

class SpotifyScreen extends StatefulWidget {
  @override
  _SpotifyScreenState createState() => _SpotifyScreenState();
}

class _SpotifyScreenState extends State<SpotifyScreen> {
  @override
  void initState() {
    super.initState();
    populatePlayLists();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(title: Text("Playlists")),
      body: ScopedModelDescendant<StateModel>(
        builder: (context, child, model) => ListView.builder(
          itemCount: model.playLists.length,
          padding: EdgeInsets.all(18),
          itemBuilder: (BuildContext ctxt, int index) => Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: Colors.black,
                        style: BorderStyle.solid,
                        width: 2))),
            child: ListTile(
              onTap: () => _onPlayListTapped(index, context),
              title: Text(model.playLists[index].name),
              leading: Container(
                width: 20,
                color: model.playLists[index].color,
              ),
            ),
          ),
        ),
      ),
    );
  }

  _onPlayListTapped(int index, BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => PlayListDetailScreen(index)));
  }

  void populatePlayLists() {
    var model = ScopedModel.of<StateModel>(context);
    model.initPlaylists();
  }
}

class PlayListDetailScreen extends StatelessWidget {
  int i;

  PlayListDetailScreen(this.i);

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<StateModel>(
        builder: (context, child, model) => Scaffold(
              appBar: AppBar(
                title: Text(model.playLists[i].name),
                actions: <Widget>[
                  IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () => _addButtonTapped(context))
                ],
              ),
              body: Container(
                  color: model.playLists[i].color,
                  child: ListView.builder(
                    itemCount: model.playLists[i].songs.length,
                    padding: EdgeInsets.all(18),
                    itemBuilder: (BuildContext ctxt, int index) => Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: Colors.black,
                                  style: BorderStyle.solid,
                                  width: 2))),
                      child: ListTile(
                        onTap: () => null,
                        title: Text(model.playLists[i].songs[index].name),
                      ),
                    ),
                  )),
            ));
  }

  _addButtonTapped(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => EditPlaylistScreen(i)));
  }
}

class EditPlaylistScreen extends StatefulWidget {
  int index;

  EditPlaylistScreen(this.index);

  @override
  _EditPlaylistScreenState createState() => _EditPlaylistScreenState();
}

class _EditPlaylistScreenState extends State<EditPlaylistScreen> {
  Playlist playlist;

  @override
  void initState() {
    super.initState();

    playlist = ScopedModel.of<StateModel>(context).playLists[widget.index];
  }

  @override
  Widget build(BuildContext context) {
//    Set songsSet = ScopedModel.of<StateModel>(context).allSongs.toSet();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Select Songs"),
        actions: <Widget>[
          MaterialButton(
            onPressed: _doneButtonTapped(ScopedModel.of<StateModel>(context)),
            child: Text(
              "Done",
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
      body: ScopedModelDescendant<StateModel>(
        builder: (context, child, model) => ListView.builder(
          itemCount: model.allSongs.length,
          padding: EdgeInsets.all(18),
          itemBuilder: (BuildContext ctxt, int index) => Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: Colors.black,
                        style: BorderStyle.solid,
                        width: 2))),
            child: ListTile(
                onTap: () => _onSongTapped(model.allSongs[index]),
                title: Text(model.allSongs[index].name),
                trailing: Container(
                  width: 50,
                  child: (playlist.songs.contains(model.allSongs[index]))
                      ? Icon(Icons.done)
                      : Container(),
                )),
          ),
        ),
      ),
    );
  }

  _onSongTapped(Song song) {
    print("tapping");
    setState(() {
      if (playlist.songs.contains(song)) {
        playlist.songs.remove(song);
      } else {
        playlist.songs.add(song);
      }
    });
  }

  _doneButtonTapped(StateModel model) {
    model.playLists.firstWhere((val) => val == playlist).songs = playlist.songs;
    print(model.playLists.firstWhere((val) => val == playlist).songs);
  }
}

enum Mood { happy, sad, energetic, calm, any }

class Track {
  final String id;
  final String title;
  final String artist;
  final String path;
  final Mood mood;

  const Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.path,
    this.mood = Mood.any,
  });

  @override
  String toString() => '$artist - $title';
}

final List<Track> demoPlaylist = const [
  Track(
    id: '1',
    title: 'Clouds',
    artist: 'Ambient Project',
    path: 'assets/audio/sample1.mp3',
    mood: Mood.calm,
  ),
  Track(
    id: '2',
    title: 'Sunrise Jazz',
    artist: 'Morning Band',
    path: 'assets/audio/sample2.mp3',
    mood: Mood.happy,
  ),
  Track(
    id: '3',
    title: 'Beats',
    artist: 'Rhythm Team',
    path: 'assets/audio/sample3.mp3',
    mood: Mood.energetic,
  ),
];

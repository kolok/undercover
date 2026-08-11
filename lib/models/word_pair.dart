/// Une paire de mots proches : le mot des civils et celui des undercover.
class WordPair {
  const WordPair(this.civilian, this.undercover);

  final String civilian;
  final String undercover;

  @override
  String toString() => '$civilian / $undercover';
}

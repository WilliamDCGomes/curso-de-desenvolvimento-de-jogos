
class scenespeed{
  static final scenespeed _scenespeed = scenespeed._internal();
  factory scenespeed() {
    return _scenespeed;
  }
  scenespeed._internal();

  double speedvelocity = 10.0;

  IncreeseSpeend() {
    speedvelocity += 10.0;
    print("Velocidade atual: " + speedvelocity.toString());
  }
}
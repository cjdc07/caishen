class AccountColor {
  final int alpha;
  final int red;
  final int green;
  final int blue;

  AccountColor({
    this.alpha,
    this.red,
    this.green,
    this.blue,
  });

  static AccountColor parse(Map<String, dynamic> data) {
    return AccountColor(
      alpha: data['alpha'],
      red: data['red'],
      green: data['green'],
      blue: data['blue'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'alpha': alpha,
      'red': red,
      'green': green,
      'blue': blue,
    };
  }

  @override
  String toString() {
    return "{ alpha: $alpha, red: $red, green: $green, blue: $blue }";
  }
}

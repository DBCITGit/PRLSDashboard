class Globals {
  static var index = 0;
  static printInteger() {
    print(index);
  }

  static changeInteger(int a) {
    index = a;
    printInteger(); // this can be replaced with any static method
  }

  static int getInteger() {
    print(index);
    return index;
  }
}

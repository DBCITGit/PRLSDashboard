bool checkHttpCode(int code) {
  try {
    return code == 200;
  } catch (e) {
    return false;
  }
}

part of workspace;

int Function() rndColorCode() {
  return () => (Random().nextDouble() * 0xFFFFFF).toInt();
}

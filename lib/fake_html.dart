class Blob {
  Blob(List<dynamic> blobParts, [String? type, String? endings]);
}

class Url {
  static String createObjectUrlFromBlob(Blob blob) => '';
  static void revokeObjectUrl(String url) {}
}

class AnchorElement {
  String? href;
  String? download;
  Style style = Style();
  void click() {}
  void remove() {}
  void setAttribute(String name, String value) {}
  AnchorElement({this.href});
}

class Style {
  String display = '';
  String setProperty(String property, String value) => '';
}

class Document {
  Body? body = Body();
}

class Body {
  List<dynamic> children = [];
  void append(dynamic element) {}
}

final document = Document();

class FormData {
  void appendBlob(String name, Blob blob, [String? filename]) {}
}

class HttpRequest {
  int? status;
  dynamic response;
  Stream<dynamic> get onLoad => Stream.empty();
  void open(String method, String url,
      {bool? async, String? user, String? password}) {}
  void send([dynamic data]) {}
  String responseType = '';
}

class ImageElement {
  String? src;
  Style style = Style();
  void setAttribute(String name, String value) {}
  ImageElement({this.src});
}

class Navigator {
  String userAgent = '';
}

class Screen {
  int width = 0;
}

class Location {
  String href = '';
}

class WindowBase {
  final Location location = Location();
  void close() {}
}

class Window {
  final Navigator navigator = Navigator();
  final Screen screen = Screen();
  WindowBase? open(String url, String target, [String? features]) =>
      WindowBase();
}

final Window window = Window();

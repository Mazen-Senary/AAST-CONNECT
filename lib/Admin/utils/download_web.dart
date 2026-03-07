import 'dart:html' as html;

Future<void> downloadWeb(String url) async {
  final anchor = html.AnchorElement(href: url)
    ..setAttribute("download", "training_proof.jpg")
    ..click();
}

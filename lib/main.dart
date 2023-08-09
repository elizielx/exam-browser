import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const ExamBrowserApp());
}

class ExamBrowserApp extends StatelessWidget {
  const ExamBrowserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exam Browser',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: const HomePage(title: 'Exam Browser'),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _urlController = TextEditingController();

  void despose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white),
        ),
        actions: const [AppPopupMenuButton()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _urlController,
              decoration: const InputDecoration(labelText: 'Enter URL'),
            ),
            const SizedBox(
              height: 16.0,
            ),
            ElevatedButton(
                onPressed: () {
                  final enteredUrl = _urlController.text;
                  if (enteredUrl.isNotEmpty) {
                    Uri? uri = Uri.tryParse(enteredUrl);
                    if (uri != null &&
                        (uri.scheme == 'http' || uri.scheme == 'https')) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BrowserScreen(
                                    url: enteredUrl,
                                  )));
                    }
                  }
                },
                child: const Text('Open URL'))
          ],
        ),
      ),
    );
  }
}

class BrowserScreen extends StatelessWidget {
  final String url;

  const BrowserScreen({required this.url, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
        ),
      )
      ..loadRequest(Uri.parse(url));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Browser',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        automaticallyImplyLeading: false,
        actions: const [AppPopupMenuButton()],
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}

class AppPopupMenuButton extends StatelessWidget {
  const AppPopupMenuButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'exit') {
          if (Platform.isAndroid) {
            SystemNavigator.pop();
          } else if (Platform.isIOS) {
            exit(0);
          }
        }
      },
      color: Colors.white,
      itemBuilder: (BuildContext context) =>
          [const PopupMenuItem(value: 'exit', child: Text('Exit App'))],
    );
  }
}

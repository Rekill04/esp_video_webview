import 'package:esp_video_translator/widgets/status_bar.dart';
import 'package:esp_video_translator/widgets/video_player.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

const String _kStreamUrl = 'http://192.168.4.1:81/stream';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Esp32StreamApp());
}

class Esp32StreamApp extends StatelessWidget {
  const Esp32StreamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ESP32 Stream',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        useMaterial3: true,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  WebViewController? _controller;

  bool _showWebView = false;
  bool _showAppBar = true;
  int _progress = 0;
  String _status = 'Готово';

  double _speed = 0;
  double _steering = 0;

  bool _autoCenterSteering = false;

  static const double _kVideoBlockHeight = 280;
  static const double _kSideControlWidth = 64;
  @override
  void didChangeDependencies() {
    _showAppBar = MediaQuery.of(context).orientation == .portrait;
    setState(() {});
    super.didChangeDependencies();
  }

  Future<void> _openStream() async {
    setState(() {
      _status = 'Открываю поток…';
      _progress = 0;
      _showWebView = true;
    });

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            setState(() {
              _status = 'Загрузка…';
              _progress = 0;
            });
          },
          onProgress: (p) {
            setState(() {
              _progress = p.clamp(0, 100);
            });
          },
          onPageFinished: (_) {
            setState(() {
              _status = 'Поток открыт.';
              _progress = 100;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _status =
                  'Ошибка WebView: ${error.errorCode} ${error.description}';
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(_kStreamUrl));

    setState(() {
      _controller = controller;
    });
  }

  Future<void> _reload() async {
    final c = _controller;
    if (c == null) return;
    setState(() {
      _status = 'Перезагружаю…';
      _progress = 0;
    });
    await c.reload();
  }

  void _close() {
    setState(() {
      _showWebView = false;
      _controller = null;
      _progress = 0;
      _status = 'Закрыто.';
    });
  }

  Widget _verticalSlider({
    required String title,
    required IconData icon,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String valueText,
    required ValueChanged<double> onChanged,
    VoidCallback? onChangeEnd,
    Widget? headerTrailing,
  }) {
    return SizedBox(
      width: _kSideControlWidth,
      height: _kVideoBlockHeight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          if (headerTrailing != null) ...[
            const SizedBox(height: 6),
            headerTrailing,
          ],
          const SizedBox(height: 8),
          SizedBox(
            width: _kSideControlWidth,
            height: _kVideoBlockHeight - (headerTrailing == null ? 86 : 122),
            child: Center(
              child: RotatedBox(
                quarterTurns: -1,
                child: SizedBox(
                  width:
                      _kVideoBlockHeight - (headerTrailing == null ? 86 : 122),
                  child: Slider(
                    value: value,
                    min: min,
                    max: max,
                    divisions: divisions,
                    label: valueText,
                    onChanged: onChanged,
                    onChangeEnd: (_) => onChangeEnd?.call(),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            valueText,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canReload = _showWebView && _controller != null;

    return Scaffold(
      appBar: _showAppBar
          ? AppBar(
              title: const Text('ESP32 Stream'),
              actions: [
                IconButton(
                  onPressed: canReload ? _reload : null,
                  icon: const Icon(Icons.refresh),
                ),
                IconButton(
                  onPressed: _showWebView ? _close : null,
                  icon: const Icon(Icons.close),
                ),
              ],
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Поток ESP32',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  const Text('URL:'),
                  const SelectableText(_kStreamUrl),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      FilledButton.icon(
                        onPressed: _openStream,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Открыть'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _showWebView ? _close : null,
                        icon: const Icon(Icons.stop),
                        label: const Text('Закрыть'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          StatusBar(text: _status, progress: _showWebView ? _progress : null),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                crossAxisAlignment: .center,
                children: [
                  const Text("Автосброс поворота в 0"),
                  const Spacer(),
                  Transform.scale(
                    scale: 0.85,
                    child: Switch(
                      value: _autoCenterSteering,
                      onChanged: (v) {
                        setState(() {
                          _autoCenterSteering = v;
                          if (_autoCenterSteering) {
                            _steering = 0;
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          Card(
            elevation: 0,
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: SizedBox(
                height: _kVideoBlockHeight,
                child: Row(
                  children: [
                    _verticalSlider(
                      title: 'Скорость',
                      icon: Icons.speed,
                      value: _speed,
                      min: -100,
                      max: 100,
                      divisions: 100,
                      valueText: '${_speed.round()}%',
                      onChanged: (v) {
                        setState(() => _speed = v);
                      },
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: VideoPlayer(
                          showWebView: _showWebView,
                          controller: _controller,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _verticalSlider(
                      title: 'Поворот',
                      icon: Icons.swap_horiz,
                      value: _steering,
                      min: -100,
                      max: 100,
                      divisions: 200,
                      valueText: _steering.round().toString(),
                      onChanged: (v) {
                        setState(() => _steering = v);
                      },
                      onChangeEnd: () {
                        if (!_autoCenterSteering) return;
                        setState(() => _steering = 0);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

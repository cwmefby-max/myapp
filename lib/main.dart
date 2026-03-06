import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mqtt_client/mqtt_client.dart'; // Impor yang ditambahkan
import 'mqtt_service.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => MQTTService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter MQTT Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late MQTTService mqttService;
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Mengakses MQTTService dari Provider
    mqttService = Provider.of<MQTTService>(context, listen: false);
    // Memulai koneksi ke broker
    mqttService.connect();
  }

  @override
  void dispose() {
    // Memutuskan koneksi saat widget dihancurkan
    mqttService.disconnect();
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      mqttService.publish(_messageController.text);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter MQTT IoT Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Menampilkan status koneksi
            Consumer<MQTTService>(
              builder: (context, service, child) {
                final connectionState = service.client.connectionStatus?.state ?? MqttConnectionState.disconnected;
                String statusText;
                Color statusColor;

                switch (connectionState) {
                  case MqttConnectionState.connected:
                    statusText = 'Terhubung';
                    statusColor = Colors.green;
                    break;
                  case MqttConnectionState.connecting:
                    statusText = 'Menghubungkan...';
                    statusColor = Colors.orange;
                    break;
                  default:
                    statusText = 'Terputus';
                    statusColor = Colors.red;
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Status Broker: ', style: Theme.of(context).textTheme.titleLarge),
                    Text(
                      statusText,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: statusColor, fontWeight: FontWeight.bold),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            
            // Menampilkan data yang diterima
            Text(
              'Data Diterima:',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  // ValueListenableBuilder akan otomatis rebuild saat data berubah
                  child: ValueListenableBuilder<String>(
                    valueListenable: context.watch<MQTTService>().data,
                    builder: (context, value, child) {
                     return Text(
                        value.isEmpty ? "Menunggu data..." : value,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
              ),
            ),
            const Spacer(),
            
            // Input untuk mengirim pesan
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: 'Kirim Pesan ke Perangkat IoT',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.send),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _sendMessage,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Kirim Perintah'),
            ),
          ],
        ),
      ),
    );
  }
}

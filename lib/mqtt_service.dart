
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:developer' as developer;

class MQTTService with ChangeNotifier {
  final ValueNotifier<String> data = ValueNotifier<String>("");
  late MqttServerClient client;

  // Konfigurasi broker MQTT
  // Ganti dengan alamat broker Anda.
  // Untuk pengujian, kita bisa menggunakan broker publik seperti test.mosquitto.org
  final String _broker = 'test.mosquitto.org';
  final int _port = 1883;
  final String _clientIdentifier = 'flutter_client'; // Harus unik

  // Topik untuk subscribe dan publish
  // Ganti dengan topik yang sesuai dengan perangkat IoT Anda
  final String _topic = 'flutter/test'; 

  Future<void> connect() async {
    client = MqttServerClient(_broker, '');
    client.port = _port;
    client.clientIdentifier = _clientIdentifier;
    client.keepAlivePeriod = 20;
    client.onDisconnected = onDisconnected;
    client.onConnected = onConnected;
    client.onSubscribed = onSubscribed;

    final connMess = MqttConnectMessage()
        .withClientIdentifier(_clientIdentifier)
        .startClean() // Sesi bersih, tidak menyimpan state
        .withWillQos(MqttQos.atLeastOnce);
    developer.log('CONTOH: Menghubungkan ke broker MQTT...');
    client.connectionMessage = connMess;

    try {
      await client.connect();
    } catch (e) {
      developer.log('EXCEPTION: Gagal terhubung ke broker - $e');
      disconnect();
    }

    // Cek status koneksi
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      developer.log('CONTOH: Terhubung ke broker MQTT');
      // Berlangganan topik setelah terhubung
      client.subscribe(_topic, MqttQos.atMostOnce);
      
      // Mendengarkan pembaruan dari broker
      client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
        final recMess = c![0].payload as MqttPublishMessage;
        final pt =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

        // Simpan data yang diterima dan beri tahu listener
        data.value = pt;
        notifyListeners();
        developer.log('DITERIMA: Pesan diterima dari topik: <${c[0].topic}>, pesan: <$pt>');
      });
    } else {
      developer.log(
          'ERROR: Koneksi ke broker gagal - status: ${client.connectionStatus}');
      disconnect();
    }
  }

  void publish(String message) {
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);
      client.publishMessage(_topic, MqttQos.atMostOnce, builder.payload!);
      developer.log('TERKIRIM: Pesan "$message" ke topik "$_topic"');
    } else {
      developer.log('ERROR: Tidak dapat publish, klien tidak terhubung.');
    }
  }
  
  void onSubscribed(String topic) {
    developer.log('BERLANGGANAN: Berhasil berlangganan ke topik: $topic');
  }

  void onDisconnected() {
    developer.log('TERPUTUS: Koneksi ke broker terputus');
  }

  void onConnected() {
    developer.log('TERHUBUNG: Koneksi ke broker berhasil');
  }

  void disconnect() {
    client.disconnect();
  }
}

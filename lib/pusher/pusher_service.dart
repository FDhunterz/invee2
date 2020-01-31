import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pusher_websocket_flutter/pusher.dart';
import 'package:flutter/services.dart';
import 'package:invee2/routes/env.dart';
import 'package:invee2/notification/notification_service.dart';

class PusherService {
  Event eventPenjualanOnline, eventPenjualanOffline;
  String lastConnectionState;
  Channel penjualanChannelOn, penjualanChannelOff, penjualanChannel;
  NotificationService notificationService;
  PusherService({@required this.notificationService});

  StreamController<String> eventDataPenjualanOnline =
      StreamController<String>();
  StreamController<String> eventDataPenjualanOffline =
      StreamController<String>();
  Sink get _inEventData => eventDataPenjualanOnline.sink;
  Sink get _inEventDataOff => eventDataPenjualanOffline.sink;
  Stream get eventStream => eventDataPenjualanOnline.stream;
  Stream get eventStreamOff => eventDataPenjualanOffline.stream;

  Future<void> initPusher() async {
    try {
      await Pusher.init(key, PusherOptions(cluster: cluster));
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  void connectPusher() {
    Pusher.connect(
        onConnectionStateChange: (ConnectionStateChange connectionState) async {
      lastConnectionState = connectionState.currentState;
    }, onError: (ConnectionError e) {
      print("Error: ${e.message}");
    });
  }

  Future<void> subscribePusher() async {
    // penjualanChannelOff = await Pusher.subscribe('penjualan-channel');
    // penjualanChannelOn = await Pusher.subscribe('penjualan-channel');
    penjualanChannel = await Pusher.subscribe('penjualan-channel');
  }

  void unSubscribePusher(String channelName) {
    Pusher.unsubscribe(channelName);
  }

  bindEvent() {
    penjualanChannel.bind('penjualan-payment-on', (last) {
      eventPenjualanOnline = last;

      eventDataPenjualanOnline.add(last.data);

      dynamic dataJson = jsonDecode(last.data);
      print(dataJson);

      notificationService.showBigTextNotification(
        // title: 'Segera melakukan proses packing',
        title: 'Layanan Penjualan Online',
        description:
            'Customer ${dataJson['message']['customer']} dengan NO. NOTA ${dataJson['message']['nota']} sudah menyelesaikan proses pembayaran. Segera menyiapkan barang dan memproses NOTA tersebut.',
        payload: dataJson['message']['type'],
      );
    });

    penjualanChannel.bind('penjualan-payment-off', (last) {
      eventPenjualanOffline = last;
      eventDataPenjualanOffline.add(last.data);

      dynamic dataJson = jsonDecode(last.data);
      print(dataJson);

      notificationService.showBigTextNotification(
        // title: 'Segera melakukan proses packing',
        title: 'Layanan Penjualan Offline',
        description:
            'Customer ${dataJson['message']['customer']} dengan NO. NOTA ${dataJson['message']['nota']} sudah menyelesaikan proses pembayaran. Segera menyiapkan barang dan memproses NOTA tersebut.',
        payload: dataJson['message']['type'],
      );
    });
  }

  void unbindEvent() {
    penjualanChannel.unbind('penjualan-payment-on');
    penjualanChannel.unbind('penjualan-payment-off');
    // penjualanChannelOn.unbind('penjualan-payment-on');
    // penjualanChannelOn.unbind('penjualan-payment-off');
    // _eventData.close();
  }

  Future<void> firePusher() async {
    await initPusher();
    connectPusher();
    await subscribePusher();
    bindEvent();
  }
}

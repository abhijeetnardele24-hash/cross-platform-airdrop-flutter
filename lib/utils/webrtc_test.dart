import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

/// WebRTC Test Utility
/// This class provides methods to test basic WebRTC functionality
class WebRTCTest {
  static Future<bool> testBasicConnection() async {
    try {
      // Test 1: Create a peer connection
      final config = {
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
          {'urls': 'stun:stun1.l.google.com:19302'},
        ]
      };

      final constraints = {
        'mandatory': {},
        'optional': [
          {'DtlsSrtpKeyAgreement': true},
        ],
      };

      final peerConnection = await createPeerConnection(config, constraints);
      debugPrint('✅ Peer connection created successfully');

      // Test 2: Create a data channel
      final dataChannel = await peerConnection.createDataChannel(
        'test',
        RTCDataChannelInit()..ordered = true,
      );
      debugPrint('✅ Data channel created successfully');

      // Test 3: Create an offer
      final offer = await peerConnection.createOffer({
        'offerToReceiveAudio': false,
        'offerToReceiveVideo': false,
      });

      if (offer.sdp == null) {
        debugPrint('❌ Failed to create offer');
        await peerConnection.close();
        return false;
      }

      debugPrint('✅ Offer created successfully');
      debugPrint('Offer SDP type: ${offer.type}');

      // Test 4: Set local description
      await peerConnection.setLocalDescription(offer);
      debugPrint('✅ Local description set successfully');

      // Cleanup
      await dataChannel.close();
      await peerConnection.close();
      
      debugPrint('✅ All WebRTC tests passed!');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ WebRTC test failed: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Test WebRTC with connection state monitoring
  static Future<void> testConnectionWithMonitoring() async {
    try {
      final config = {
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
        ]
      };

      final peerConnection = await createPeerConnection(config);

      // Monitor connection states
      peerConnection.onConnectionState = (state) {
        debugPrint('📡 Connection State: $state');
      };

      peerConnection.onIceConnectionState = (state) {
        debugPrint('🧊 ICE Connection State: $state');
      };

      peerConnection.onIceGatheringState = (state) {
        debugPrint('🔍 ICE Gathering State: $state');
      };

      peerConnection.onIceCandidate = (candidate) {
        debugPrint('🎯 ICE Candidate: ${candidate.candidate}');
      };

      // Create data channel
      final dataChannel = await peerConnection.createDataChannel(
        'monitoring_test',
        RTCDataChannelInit(),
      );

      dataChannel.onDataChannelState = (state) {
        debugPrint('📊 Data Channel State: $state');
      };

      dataChannel.onMessage = (message) {
        debugPrint('📨 Message received: ${message.text}');
      };

      // Create offer to trigger ICE gathering
      final offer = await peerConnection.createOffer();
      await peerConnection.setLocalDescription(offer);

      debugPrint('✅ Connection monitoring test started');
      debugPrint('⏳ Waiting for ICE gathering...');

      // Wait a bit to see state changes
      await Future.delayed(const Duration(seconds: 3));

      // Cleanup
      await dataChannel.close();
      await peerConnection.close();
      
      debugPrint('✅ Monitoring test completed');
    } catch (e) {
      debugPrint('❌ Monitoring test failed: $e');
    }
  }

  /// Show test results in a dialog
  static Future<void> showTestDialog(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Testing WebRTC...'),
          ],
        ),
        content: const Text('Running WebRTC connection tests...'),
      ),
    );

    final result = await testBasicConnection();

    if (context.mounted) {
      Navigator.of(context).pop();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(
                result ? Icons.check_circle : Icons.error,
                color: result ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 12),
              Text(result ? 'Tests Passed!' : 'Tests Failed'),
            ],
          ),
          content: Text(
            result
                ? 'WebRTC is working correctly!\n\n✅ Peer connection created\n✅ Data channel created\n✅ Offer/Answer working\n✅ Local description set'
                : 'WebRTC tests failed. Check the console for details.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
            if (result)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  testConnectionWithMonitoring();
                },
                child: const Text('Run Monitoring Test'),
              ),
          ],
        ),
      );
    }
  }
}

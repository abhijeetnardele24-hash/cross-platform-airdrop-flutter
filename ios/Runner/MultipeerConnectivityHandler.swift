import Flutter
import MultipeerConnectivity
import UIKit

/// iOS Multipeer Connectivity handler for peer-to-peer file transfers
/// This class manages the MCSession, MCNearbyServiceAdvertiser, and MCNearbyServiceBrowser
class MultipeerConnectivityHandler: NSObject {
    private var session: MCSession?
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?
    private var peerID: MCPeerID?
    private var serviceName: String = "airdrop-flutter"
    private weak var channel: FlutterMethodChannel?
    
    init(channel: FlutterMethodChannel) {
        self.channel = channel
        super.init()
    }
    
    // MARK: - Public Methods
    
    /// Start advertising for nearby peers
    func startAdvertising(serviceName: String, displayName: String) {
        self.serviceName = serviceName
        
        // Create peer ID
        peerID = MCPeerID(displayName: displayName)
        
        // Create session
        guard let peerID = peerID else { return }
        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        session?.delegate = self
        
        // Start advertising
        advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceName)
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
        
        print("📢 iOS: Started advertising as \(displayName)")
    }
    
    /// Start browsing for nearby peers
    func startBrowsing(serviceName: String) {
        self.serviceName = serviceName
        
        // Create peer ID if not exists
        if peerID == nil {
            peerID = MCPeerID(displayName: UIDevice.current.name)
        }
        
        // Create session
        guard let peerID = peerID else { return }
        if session == nil {
            session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
            session?.delegate = self
        }
        
        // Start browsing
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceName)
        browser?.delegate = self
        browser?.startBrowsingForPeers()
        
        print("🔍 iOS: Started browsing for peers")
    }
    
    /// Send data to connected peers
    func sendData(_ data: Data) {
        guard let session = session else {
            print("❌ iOS: No active session")
            return
        }
        
        guard !session.connectedPeers.isEmpty else {
            print("❌ iOS: No connected peers")
            return
        }
        
        do {
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
            print("✅ iOS: Sent \(data.count) bytes to \(session.connectedPeers.count) peer(s)")
        } catch {
            print("❌ iOS: Error sending data: \(error.localizedDescription)")
        }
    }
    
    /// Stop all sessions
    func stopSession() {
        advertiser?.stopAdvertisingPeer()
        browser?.stopBrowsingForPeers()
        session?.disconnect()
        
        advertiser = nil
        browser = nil
        session = nil
        
        print("🔌 iOS: Stopped all sessions")
    }
}

// MARK: - MCSessionDelegate

extension MultipeerConnectivityHandler: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async { [weak self] in
            switch state {
            case .connected:
                print("✅ iOS: Connected to peer: \(peerID.displayName)")
                self?.channel?.invokeMethod("onPeerConnected", arguments: [
                    "peerId": peerID.displayName
                ])
                
            case .connecting:
                print("🔄 iOS: Connecting to peer: \(peerID.displayName)")
                
            case .notConnected:
                print("🔌 iOS: Disconnected from peer: \(peerID.displayName)")
                self?.channel?.invokeMethod("onPeerDisconnected", arguments: [:])
                
            @unknown default:
                print("⚠️ iOS: Unknown state for peer: \(peerID.displayName)")
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async { [weak self] in
            print("📦 iOS: Received \(data.count) bytes from \(peerID.displayName)")
            
            // Convert Data to FlutterStandardTypedData
            let flutterData = FlutterStandardTypedData(bytes: data)
            
            self?.channel?.invokeMethod("onDataReceived", arguments: [
                "data": flutterData
            ])
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        // Not implemented for now
        print("📡 iOS: Received stream from \(peerID.displayName)")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("📥 iOS: Started receiving resource: \(resourceName)")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        if let error = error {
            print("❌ iOS: Error receiving resource: \(error.localizedDescription)")
        } else {
            print("✅ iOS: Finished receiving resource: \(resourceName)")
        }
    }
}

// MARK: - MCNearbyServiceAdvertiserDelegate

extension MultipeerConnectivityHandler: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("📨 iOS: Received invitation from \(peerID.displayName)")
        
        // Auto-accept invitation
        invitationHandler(true, session)
        
        DispatchQueue.main.async { [weak self] in
            self?.channel?.invokeMethod("onPeerFound", arguments: [
                "peerName": peerID.displayName
            ])
        }
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("❌ iOS: Failed to start advertising: \(error.localizedDescription)")
    }
}

// MARK: - MCNearbyServiceBrowserDelegate

extension MultipeerConnectivityHandler: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("🔍 iOS: Found peer: \(peerID.displayName)")
        
        // Auto-invite peer
        guard let session = session else { return }
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 30)
        
        DispatchQueue.main.async { [weak self] in
            self?.channel?.invokeMethod("onPeerFound", arguments: [
                "peerName": peerID.displayName
            ])
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("📵 iOS: Lost peer: \(peerID.displayName)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print("❌ iOS: Failed to start browsing: \(error.localizedDescription)")
    }
}

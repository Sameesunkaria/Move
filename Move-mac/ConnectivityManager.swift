//
//  ConnectivityManager.swift
//  Move-mac
//
//  Created by Samar Sunkaria on 5/28/19.
//  Copyright © 2019 samar. All rights reserved.
//

import Foundation
import MultipeerConnectivity

#if os(iOS) || os(tvOS)
import UIKit
#endif

protocol ConnectivityManagerDelegate: class {
    func connectivityManager(_ manager: ConnectivityManager, peer peerID: MCPeerID, didChange state: MCSessionState)
    func connectivityManager(_ manager: ConnectivityManager, didReceive data: Data, from peer: MCPeerID)
}

class ConnectivityManager: NSObject {

    let session: MCSession
    let assistant: MCAdvertiserAssistant
    let serviceType = "move"

    weak var delegate: ConnectivityManagerDelegate?

    override init() {
        #if os(iOS) || os(tvOS)
        let name = UIDevice.current.name
        #elseif os(macOS)
        let name = Host.current().localizedName!
        #endif

        let peerID = MCPeerID(displayName: name)
        self.session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        self.assistant = MCAdvertiserAssistant(serviceType: serviceType, discoveryInfo: nil, session: session)

        super.init()

        self.session.delegate = self
        self.assistant.delegate = self
    }

    func startAdvertising() {
        assistant.start()
    }

    func stopAdvertising() {
        assistant.stop()
    }

    deinit {
        stopAdvertising()
        session.disconnect()
    }
}

extension ConnectivityManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("peer didChange")
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("didReceive fromPeer")
        print(String(bytes: data, encoding: .utf8) ?? "Can't parse data")
        delegate?.connectivityManager(self, didReceive: data, from: peerID)
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("didReceive withName fromPeer")
    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("didStartReceivingResourceWithName fromPeer")
    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        print("didFinishReceivingResourceWithName fromPeer")
    }
}

extension ConnectivityManager: MCAdvertiserAssistantDelegate {

}

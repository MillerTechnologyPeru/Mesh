//
//  LoRaMessage.swift
//  Mesh
//
//  Created by Alsey Coleman Miller on 3/15/19.
//

import Foundation

/// LoRa Mesh Message
public struct LoRaMeshMessage: Equatable, Hashable, LoRaMessage {    
    
    public static let messageType: LoRaMessageType = .meshMessage
    
    /// Source LoRa Device
    public let device: UUID
    
    /// Mesh Message / Packet
    public let message: Mesh.Message
}

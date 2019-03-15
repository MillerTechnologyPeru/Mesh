//
//  LoRa.swift
//  Mesh
//
//  Created by Alsey Coleman Miller on 3/15/19.
//

import Foundation

/// LoRa Message Type
public enum LoRaMessageType: UInt8 {
    
    case advertisement
    case message
}

/// LoRa Advertisment
public struct LoRaAdvertisement {
    
    public static let mesageType: LoRaMessageType = .advertisement
    
    /// Source LoRa Device
    public let device: UUID
}

/// LoRa Mesh Message
public struct LoRaMessage {
    
    public static let mesageType: LoRaMessageType = .message
    
    /// Source LoRa Device
    public let device: UUID
    
    /// Mesh Message / Packet
    public let message: Mesh.Message
}

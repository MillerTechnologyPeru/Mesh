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
    
    /// Mesh Message / Packet
    public let message: Mesh.Message
    
    public init(message: Mesh.Message) {
        
        self.message = message
    }
}

public extension LoRaMeshMessage {
    
    public init?(data: Data) {
        
        var data = DataIterator(data: data)
        
        guard let messageType = data.consume({ LoRaMessageType(rawValue: $0) }),
            messageType == type(of: self).messageType,
            let message = data.suffix({ Mesh.Message(data: $0) })
            else { return nil }
        
        self.message = message
    }
    
    public var data: Data {
        
        return Data(self)
    }
}

// MARK: - DataConvertible

extension LoRaMeshMessage: DataConvertible {
    
    static func += <T: DataContainer> (data: inout T, value: LoRaMeshMessage) {
        
        data += type(of: value).messageType.rawValue
        data += value.message
    }
    
    var dataLength: Int {
        
        return 1 + UUID.length + message.dataLength
    }
}

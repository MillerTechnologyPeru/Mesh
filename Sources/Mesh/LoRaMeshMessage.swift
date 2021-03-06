//
//  LoRaMessage.swift
//  Mesh
//
//  Created by Alsey Coleman Miller on 3/15/19.
//

import Foundation

/// LoRa Mesh Message
public struct LoRaMeshMessage: Equatable, Hashable, LoRaMessageProtocol {    
    
    public static var messageType: LoRaMessageType { return .meshMessage }
    
    /// Mesh Message / Packet
    public let message: Message
    
    public init(message: Message) {
        
        self.message = message
    }
}

public extension LoRaMeshMessage {
    
    init?(data: Data) {
        
        var data = DataIterator(data: data)
        
        guard let messageType = data.consume({ LoRaMessageType(rawValue: $0) }),
            messageType == type(of: self).messageType,
            let message = data.suffix({ Message(data: $0) })
            else { return nil }
        
        self.message = message
    }
    
    var data: Data {
        
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

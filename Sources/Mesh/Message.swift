//
//  Message.swift
//  Mesh
//
//  Created by Alsey Coleman Miller on 3/15/19.
//

import Foundation

/// Mesh Message
public struct Message: Equatable, Hashable {
    
    public static var version: Version { return .v1 }
    
    /**
     Unique identifier of the message.
     */
    public let identifier: UUID
    
    /**
     The address of the sending node.
     */
    public let source: UUID
    
    /**
     The address of the destination node.
     */
    public let destination: UUID
    
    /**
     Hop limit (time to live)
     
     To avoid looping in the network, every packet is sent with some TTL value set, which tells the network how many routers (hops) this packet can cross. At each hop, its value is decremented by one and when the value reaches zero, the packet is discarded.
     */
    public var hopLimit: UInt8
    
    /**
     Payload Type UUID
     */
    public let payloadType: PayloadType
    
    /**
     The payload to send.
     */
    public let payload: Data
    
    public init(identifier: UUID = UUID(),
                source: UUID,
                destination: UUID,
                hopLimit: UInt8 = .max,
                payloadType: PayloadType,
                payload: Data) {
        
        self.identifier = identifier
        self.source = source
        self.destination = destination
        self.hopLimit = hopLimit
        self.payloadType = payloadType
        self.payload = payload
    }
}

public extension Message {
    
    init <T: MessagePayload> (identifier: UUID = UUID(),
                                     source: UUID,
                                     destination: UUID,
                                     hopLimit: UInt8 = .max,
                                     payload: T) {
        
        self.identifier = identifier
        self.source = source
        self.destination = destination
        self.hopLimit = hopLimit
        self.payloadType = T.payloadType
        self.payload = payload.data
    }
}

public extension Message {
    
    init?(data: Data) {
        
        var data = DataIterator(data: data)
        
        guard let version = data.consume({ Version(rawValue: $0) }),
            version == Message.version, // must match version
            let identifier = data.consume(UUID.length, { UUID(data: $0)?.littleEndian }),
            let source = data.consume(UUID.length, { UUID(data: $0)?.littleEndian }),
            let destination = data.consume(UUID.length, { UUID(data: $0)?.littleEndian }),
            let hopLimit = data.consume(UInt8.self),
            let payloadType = data.consume({ PayloadType(rawValue: $0) })
            else { return nil }
        
        self.identifier = identifier
        self.source = source
        self.destination = destination
        self.hopLimit = hopLimit
        self.payloadType = payloadType
        self.payload = data.suffix() ?? Data()
    }
    
    var data: Data {
        
        return Data(self)
    }
}

// MARK: - DataConvertible

extension Message: DataConvertible {
    
    static func += <T: DataContainer> (data: inout T, value: Message) {
        
        data += type(of: value).version.rawValue
        data += value.identifier.littleEndian
        data += value.source.littleEndian
        data += value.destination.littleEndian
        data += value.hopLimit
        data += value.payloadType.rawValue
        data += value.payload
    }
    
    var dataLength: Int {
        
        return 1 + (UUID.length * 3) + 2 + payload.count
    }
}

// MARK: - Supporting Types

public protocol MessagePayload {
    
    static var payloadType: PayloadType { get }
    
    init?(data: Data)
    
    var data: Data { get }
}

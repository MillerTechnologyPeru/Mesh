//
//  ControlMessage.swift
//  Mesh
//
//  Created by Alsey Coleman Miller on 3/15/19.
//

import Foundation

public enum ControlMessage {
    
    public static let payloadType: UUID = UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
    
    case echoRequest
    case echoReply
    case error(ControlMessageError)
    case peerRequest
    case peerResponse([UUID])
}

public enum ControlMessageType: UInt8 {
    
    case echoRequest    = 0
    case echoReply      = 1
    case error          = 2
    case peerRequest    = 3
    case peerResponse   = 4
}

public enum ControlMessageError: UInt8, Error {
    
    /// TTL == 0
    case hopLimit = 0
}

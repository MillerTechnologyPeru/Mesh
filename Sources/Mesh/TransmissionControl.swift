//
//  TransmissionControl.swift
//  Mesh
//
//  Created by Alsey Coleman Miller on 3/15/19.
//

import Foundation

/// Mesh Transmission Control Protocol
public enum TransmissionControl: MessagePayload {
    
    public static var payloadType: PayloadType { return .transmissionControl }
    
    case metadata(Metadata)
    case chunk(DataChunk)
    case acknowledgement(Acknowledgement)
}

public extension TransmissionControl {
    
    init?(data: Data) {
        
        fatalError()
    }
    
    var data: Data {
        
        fatalError()
    }
}

public extension TransmissionControl {
    
    enum MessageType: UInt8 {
        
        case metadata
        case chunk
        case acknowledgement
    }
}

public extension TransmissionControl {
    
    struct DataChunk {
        
        public let port: UInt16
        
        public let sequence: UInt32
        
        public let checksum: UInt32
        
        public let payload: Data
    }
}

public extension TransmissionControl {
    
    struct Metadata {
        
        public let identifier: UUID
        
        public let port: UInt16
        
        public let total: UInt32
        
        public let chunksCount: UInt32
        
        public let checksum: UInt32
    }
}

public extension TransmissionControl {
    
    struct Acknowledgement {
        
        public let port: UInt16
        
        public let sequence: UInt32
        
        public let checksum: UInt32
    }
}

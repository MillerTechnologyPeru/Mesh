//
//  TransmissionControl.swift
//  Mesh
//
//  Created by Alsey Coleman Miller on 3/15/19.
//

import Foundation

/// Mesh Transmission Control Protocol
public enum TransmissionControl {
    
    public static var payloadType: PayloadType { return .transmissionControl }
    
    case metadata(Metadata)
    case chunk(DataChunk)
    case acknowledgement(Acknowledgement)
}

public extension TransmissionControl {
    
    public enum MessageType: UInt8 {
        
        case metadata
        case chunk
        case acknowledgement
    }
}

public extension TransmissionControl {
    
    public struct DataChunk {
        
        public let sequence: UInt32
        
        public let checksum: UInt32
        
        public let payload: Data
    }
}

public extension TransmissionControl {
    
    public struct Metadata {
        
        public let identifier: UUID
        
        public let total: UInt32
        
        public let chunksCount: UInt32
        
        public let checksum: UInt32
    }
}

public extension TransmissionControl {
    
    public struct Acknowledgement {
        
        public let sequence: UInt32
        
        public let checksum: UInt32
    }
}

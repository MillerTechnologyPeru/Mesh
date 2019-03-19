//
//  UUID.swift
//  Mesh
//
//  Created by Alsey Coleman Miller on 3/15/19.
//

import Foundation

internal extension UUID {
    
    static var zero: UUID { return UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)) }
}

internal extension UUID {
    
    init(littleEndian uuid: UUID) {
        
        /// Foundation always stores in Big Endian format
        self = uuid.littleEndian // byte swap
    }
    
    var littleEndian: UUID {
        
        /// Foundation always stores in Big Endian format
        return UUID(uuid: (
            uuid.15,
            uuid.14,
            uuid.13,
            uuid.12,
            uuid.11,
            uuid.10,
            uuid.9,
            uuid.8,
            uuid.7,
            uuid.6,
            uuid.5,
            uuid.4,
            uuid.3,
            uuid.2,
            uuid.1,
            uuid.0
        ))
    }
}

// MARK: - DataConvertible

extension UUID: DataConvertible {
    
    static func += <T>(data: inout T, value: UUID) where T : DataContainer {
        
        data.append(contentsOf: [
            value.uuid.0,
            value.uuid.1,
            value.uuid.2,
            value.uuid.3,
            value.uuid.4,
            value.uuid.5,
            value.uuid.6,
            value.uuid.7,
            value.uuid.8,
            value.uuid.9,
            value.uuid.10,
            value.uuid.11,
            value.uuid.12,
            value.uuid.13,
            value.uuid.14,
            value.uuid.15
            ])
    }
    
    var dataLength: Int {
        return UUID.length
    }
}

// MARK: - DataIterable

extension UUID: DataIterable {
    
    static var length: Int { return 16 }
    
    init?(data: Data) {
        
        guard data.count == type(of: self).length
            else { return nil }
        
        let bytes: uuid_t = data.withUnsafeBytes { $0.pointee }
        self.init(uuid: bytes)
    }
}

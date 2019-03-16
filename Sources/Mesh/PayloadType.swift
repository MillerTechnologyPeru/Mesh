//
//  PayloadType.swift
//  Mesh
//
//  Created by Alsey Coleman Miller on 3/15/19.
//

/// Mesh PayloadType
public struct PayloadType: Equatable, Hashable, RawRepresentable {
    
    public let rawValue: UInt8
    
    public init(rawValue: UInt8) {
        
        self.rawValue = rawValue
    }
}

public extension PayloadType {
    
    /// Mesh Control Message Protocol
    static var controlMessage: PayloadType { return PayloadType(rawValue: 0) }
    
    /// Mesh Transmission Control Protocol
    static var transmissionControl: PayloadType { return PayloadType(rawValue: 1) }
}

// MARK: - CustomStringConvertible

extension PayloadType: CustomStringConvertible {
    
    public var description: String {
        
        return rawValue.description
    }
}

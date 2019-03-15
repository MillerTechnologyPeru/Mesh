//
//  Version.swift
//  Mesh
//
//  Created by Alsey Coleman Miller on 3/15/19.
//

/// Mesh protocol version
public struct Version: Equatable, Hashable, RawRepresentable {
    
    public let rawValue: UInt8
    
    public init(rawValue: UInt8) {
        
        self.rawValue = rawValue
    }
}

public extension Version {
    
    /// First version
    static var v1: Version { return Version(rawValue: 1) }
}

// MARK: - CustomStringConvertible

extension Version: CustomStringConvertible {
    
    public var description: String {
        
        return rawValue.description
    }
}

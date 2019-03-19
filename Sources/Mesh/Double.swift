//
//  Double.swift
//  Mesh
//
//  Created by Alsey Coleman Miller on 3/18/19.
//

internal extension Double {
    
    /// Initializes value from four bytes.
    init(bytes: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)) {
        
        self = unsafeBitCast(bytes, to: Double.self)
    }
    
    /// Converts to eight bytes.
    var bytes: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8) {
        
        return unsafeBitCast(self, to: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8).self)
    }
}

extension Double: ByteSwap {
    
    public var byteSwapped: Double {
        
        return Double(bytes: (bytes.7,
                              bytes.6,
                              bytes.5,
                              bytes.4,
                              bytes.3,
                              bytes.2,
                              bytes.1,
                              bytes.0))
    }
}

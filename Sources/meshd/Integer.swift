//
//  Integer.swift
//  Mesh
//
//  Created by Alsey Coleman Miller on 3/22/19.
//

import Foundation

internal extension Int64 {
    
    func toInt() -> Int? {
        
        // Can't convert to Int if the stored value is larger than the max value of Int
        guard self <= Int64(Int.max) else { return nil }
        
        return Int(self)
    }
}

internal extension Int {
    
    func toInt64() -> Int64 {
        
        return Int64(self)
    }
}

internal extension UInt16 {
    
    /// Initializes value from two bytes.
    init(bytes: (UInt8, UInt8)) {
        
        self = unsafeBitCast(bytes, to: UInt16.self)
    }
    
    /// Converts to two bytes.
    var bytes: (UInt8, UInt8) {
        
        return unsafeBitCast(self, to: (UInt8, UInt8).self)
    }
}

internal extension UInt32 {
    
    /// Initializes value from four bytes.
    init(bytes: (UInt8, UInt8, UInt8, UInt8)) {
        
        self = unsafeBitCast(bytes, to: UInt32.self)
    }
    
    /// Converts to four bytes.
    var bytes: (UInt8, UInt8, UInt8, UInt8) {
        
        return unsafeBitCast(self, to: (UInt8, UInt8, UInt8, UInt8).self)
    }
}

internal extension UInt64 {
    
    /// Initializes value from four bytes.
    init(bytes: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)) {
        
        self = unsafeBitCast(bytes, to: UInt64.self)
    }
    
    /// Converts to eight bytes.
    var bytes: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8) {
        
        return unsafeBitCast(self, to: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8).self)
    }
}

protocol CommandLineData {
    
    init?(commandLine string: String)
    
    init?(bigEndian: [UInt8])
}

protocol CommandLineInteger: CommandLineData {
    
    init?(_ text: String, radix: Int)
}

extension CommandLineData {
    
    init?(commandLine string: String) {
        
        if let value = Self.from(hexadecimal: string, requiresPrefix: false) {
            
            self = value
            
        } else {
            
            return nil
        }
    }
}

extension CommandLineInteger {
    
    init?(commandLine string: String) {
        
        if let value = Self.from(hexadecimal: string, requiresPrefix: false) {
            
            self = value
            
        } else if let value = Self.init(string, radix: 10) {
            
            self = value
            
        } else {
            
            return nil
        }
    }
}

private extension CommandLineData {
    
    static func from(hexadecimal string: String, requiresPrefix: Bool) -> Self? {
        
        let hexString: String
        
        if string.containsHexadecimalPrefix() {
            
            hexString = string.removeHexadecimalPrefix()
            
        } else {
            
            guard requiresPrefix == false
                else { return nil }
            
            hexString = string
        }
        
        let characters = hexString
        
        let byteCount = characters.count / 2
        var bytes = [UInt8]()
        bytes.reserveCapacity(byteCount)
        
        var index = characters.startIndex
        
        while index < characters.endIndex {
            
            let nextLetterIndex = characters.index(index, offsetBy: 1)
            
            guard nextLetterIndex < characters.endIndex
                else { return nil }
            
            // 2 letter hex string
            let substring = String(characters[index ... nextLetterIndex])
            
            guard let byte = UInt8(substring, radix: 16)
                else { return nil }
            
            bytes.append(byte)
            
            index = characters.index(index, offsetBy: 2)
        }
        
        assert(bytes.count == byteCount)
        
        return Self.init(bigEndian: bytes)
    }
}


// MARK: - Protocol Conformance

extension UInt8: CommandLineInteger {
    
    init?(bigEndian bytes: [UInt8]) {
        
        guard bytes.count == 1
            else { return nil }
        
        self = bytes[0]
    }
}

extension UInt16: CommandLineInteger {
    
    init?(bigEndian bytes: [UInt8]) {
        
        guard bytes.count == 2
            else { return nil }
        
        self.init(bigEndian: UInt16(bytes: (bytes[0], bytes[1])))
    }
}

extension UInt32: CommandLineInteger {
    
    init?(bigEndian bytes: [UInt8]) {
        
        guard bytes.count == 4
            else { return nil }
        
        self.init(bigEndian: UInt32(bytes: (bytes[0], bytes[1], bytes[2], bytes[3])))
    }
}

extension UInt64: CommandLineInteger {
    
    init?(bigEndian bytes: [UInt8]) {
        
        guard bytes.count == 8
            else { return nil }
        
        self.init(bigEndian: UInt64(bytes: (bytes[0], bytes[1], bytes[2], bytes[3], bytes[4], bytes[5], bytes[6], bytes[7])))
    }
}

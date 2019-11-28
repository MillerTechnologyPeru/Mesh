//
//  Data.swift
//  Mesh
//
//  Created by Alsey Coleman Miller on 3/15/19.
//

import Foundation

internal extension Data {
    
    func subdataNoCopy(in range: Range<Int>) -> Data {
        
        // stored in heap, can reuse buffer
        if count > Data.inlineBufferSize {
            
            return withUnsafeBytes { (buffer: UnsafeRawBufferPointer) in
                Data(bytesNoCopy: UnsafeMutableRawPointer(mutating: buffer.baseAddress!.advanced(by: range.lowerBound)),
                     count: range.count,
                     deallocator: .none)
            }
            
        } else {
            
            // stored in stack, must copy
            return subdata(in: range)
        }
    }
    
    func suffixNoCopy(from index: Int) -> Data {
        return subdataNoCopy(in: index ..< count)
    }
    
    func suffixCheckingBounds(from start: Int) -> Data {
        
        if count > start {
            return Data(suffix(from: start))
        } else {
            return Data()
        }
    }
}

private extension Data {
    
    /// Size of the inline buffer for `Foundation.Data` used in Swift 5.
    ///
    /// Used to determine wheather data is stored on stack or in heap.
    static var inlineBufferSize: Int {
        
        // Keep up to date
        // https://github.com/apple/swift-corelibs-foundation/blob/master/Foundation/Data.swift#L621
        #if arch(x86_64) || arch(arm64) || arch(arm64_32) || arch(s390x) || arch(powerpc64) || arch(powerpc64le)
        typealias Buffer = (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
            UInt8, UInt8, UInt8, UInt8, UInt8, UInt8) //len  //enum
        #elseif arch(i386) || arch(arm)
        typealias Buffer = (UInt8, UInt8, UInt8, UInt8,
            UInt8, UInt8)
        #endif
        
        return MemoryLayout<Buffer>.size
    }
}

/// Can be converted into data.
internal protocol DataConvertible {
    
    /// Append data representation into buffer.
    static func += <T: DataContainer> (data: inout T, value: Self)
    
    /// Length of value when encoded into data.
    var dataLength: Int { get }
}

internal extension Data {
    
    /// Initialize data with contents of value.
    @inline(__always)
    init <T: DataConvertible> (_ value: T) {
        self.init(capacity: value.dataLength)
        self += value
        assert(self.count == value.dataLength, "\(T.self) invalid data length")
    }
}

// MARK: - UnsafeDataConvertible

/// Internal Data casting protocol
internal protocol UnsafeDataConvertible: DataConvertible { }

extension UnsafeDataConvertible {
    
    var dataLength: Int {
        return MemoryLayout<Self>.size
    }
    
    /// Append data representation into buffer.
    static func += <T: DataContainer> (data: inout T, value: Self) {
        #if swift(>=4.2)
        withUnsafePointer(to: value) {
        $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<Self>.size) {
        data.append($0, count: MemoryLayout<Self>.size)
        }
        }
        #else
        var value = value
        withUnsafePointer(to: &value) {
            $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<Self>.size) {
                data.append($0, count: MemoryLayout<Self>.size)
            }
        }
        #endif
    }
}

extension UInt16: UnsafeDataConvertible { }
extension UInt32: UnsafeDataConvertible { }
extension UInt64: UnsafeDataConvertible { }
extension Double: UnsafeDataConvertible { }

// MARK: - DataIterator

internal struct DataIterator {
    
    public let data: Data
    
    public init(data: Data) {
        self.data = data
    }
    
    public private(set) var index: Int = 0
    
    public mutating func reset() {
        
        index = 0
    }
    
    public mutating func consume<T>(_ count: Int, _ block: (Data) -> T?) -> T? {
        
        guard index + count <= data.count
            else { return nil } // out of bytes
        
        let subdata = data.subdataNoCopy(in: index ..< index + count)
        
        index += count
        
        return block(subdata)
    }
    
    public mutating func consume <T: DataIterable> (_ type: T.Type) -> T? {
        
        return consume(T.length) { T.init(data: $0) }
    }
    
    public mutating func consume <T: DataIterable, Result> (_ block: (T) -> Result) -> Result? {
        
        guard let value = self.consume(T.length, { T.init(data: $0) })
            else { return nil }
        
        return block(value)
    }
    
     public mutating func consume() -> UInt8? {
     
        // optimization
        
        guard index + 1 <= data.count
            else { return nil } // out of bytes
        
        let byte = data[index]
        
        index += 1
        
        return byte
     }
    
    public mutating func suffix() -> Data? {
        
        guard index + 1 <= data.count // at least one byte left
            else { return nil } // end of data
        
        let suffix = data.suffix(from: index)
        
        assert(suffix.count == data.count - index)
        
        return suffix
    }
    
    public mutating func suffix <T> (_ block: (Data) -> T?) -> T? {
        
        guard index + 1 <= data.count // at least one byte left
            else { return nil } // end of data
        
        let suffix = data.suffixNoCopy(from: index)
        
        assert(suffix.count == data.count - index)
        
        return block(suffix)
    }
}

internal protocol DataIterable {
    
    /// Number of bytes
    static var length: Int { get }
    
    /// Initialize from data.
    init?(data: Data)
}

internal protocol UnsafeDataIterable: DataIterable { }

extension UnsafeDataIterable {
    
    static var length: Int { return MemoryLayout<Self>.size }
    
    init?(data: Data) {
        
        guard data.count == Self.length
            else { return nil }
        
        self = data.withUnsafeBytes { $0.pointee }
    }
}

extension UInt8: UnsafeDataIterable { }
extension UInt16: UnsafeDataIterable { }
extension UInt32: UnsafeDataIterable { }
extension UInt64: UnsafeDataIterable { }
extension Double: UnsafeDataIterable { }

// MARK: - DataContainer

/// Data container type.
internal protocol DataContainer: RandomAccessCollection where Self.Index == Int {
    
    subscript(index: Int) -> UInt8 { get }
    
    subscript(range: Range<Int>) -> Slice<Self> { get }
    
    mutating func append(_ newElement: UInt8)
    
    mutating func append(_ pointer: UnsafePointer<UInt8>, count: Int)
    
    mutating func append <C: Collection> (contentsOf bytes: C) where C.Element == UInt8
    
    #if swift(>=4.2)
    static func += (lhs: inout Self, rhs: UInt8)
    static func += <C: Collection> (lhs: inout Self, rhs: C) where C.Element == UInt8
    #endif
}

extension DataContainer {
    
    #if swift(>=4.2)
    #else
    static func += (lhs: inout Self, rhs: UInt8) {
        lhs.append(rhs)
    }
    
    static func += <C: Collection> (lhs: inout Self, rhs: C) where C.Element == UInt8 {
        lhs.append(contentsOf: rhs)
    }
    #endif
    
    mutating func append <T: DataConvertible> (_ value: T) {
        self += value
    }
}

extension Data: DataContainer {
    
    #if swift(>=4.2)
    static func += (lhs: inout Data, rhs: UInt8) {
        lhs.append(rhs)
    }
    #endif
}

// MARK: - Bluetooth

#if canImport(Bluetooth)
import Bluetooth
extension Bluetooth.BluetoothAddress: UnsafeDataConvertible { }
extension Bluetooth.LowEnergyAdvertisingData: DataContainer { }
#endif


//
//  Data.swift
//  Mesh
//
//  Created by Alsey Coleman Miller on 3/15/19.
//

import Foundation

internal extension Data {
    
    #if swift(>=4.2)
    func subdataNoCopy(in range: Range<Int>) -> Data {
    
        let pointer = withUnsafeBytes { UnsafeMutableRawPointer(mutating: $0).advanced(by: range.lowerBound) }
        return Data(bytesNoCopy: pointer, count: range.count, deallocator: .none)
    }
    #else
    func subdataNoCopy(in range: CountableRange<Int>) -> Data {
        
        let pointer = withUnsafeBytes { UnsafeMutableRawPointer(mutating: $0).advanced(by: range.lowerBound) }
        return Data(bytesNoCopy: pointer, count: range.count, deallocator: .none)
    }
    
    /// Returns a new copy of the data in a specified range.
    func subdata(in range: CountableRange<Int>) -> Data {
        return Data(self[range])
    }
    #endif
    
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

/// Can be converted into data.
internal protocol DataConvertible {
    
    /// Append data representation into buffer.
    static func += <T: DataContainer> (data: inout T, value: Self)
    
    /// Length of value when encoded into data.
    var dataLength: Int { get }
}

extension Data {
    
    /// Initialize data with contents of value.
    @inline(__always)
    init <T: DataConvertible> (_ value: T) {
        self.init(capacity: value.dataLength)
        self += value
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
        
        guard index + count < data.count
            else { return nil } // out of bytes
        
        let subdata = data.subdataNoCopy(in: index ..< index + count)
        
        index += count
        
        return block(subdata)
    }
    
    public mutating func consumeByte() -> UInt8? {
        
        guard index + 1 < data.count
            else { return nil } // out of bytes
        
        let byte = data[index]
        
        index += 1
        
        return byte
    }
    
    public mutating func consumeByte<T>(_ block: (UInt8) -> T) -> T? {
        
        guard let byte = consumeByte()
            else { return nil }
        
        return block(byte)
    }
    
    public mutating func suffix() -> Data? {
        
        guard index + 1 < data.count // at least one byte left
            else { return nil } // end of data
        
        let suffix = data.suffix(from: index)
        
        assert(suffix.count == data.count - index)
        
        return suffix
    }
}

// MARK: - Bluetooth

#if canImport(Bluetooth)
import Bluetooth
extension Bluetooth.BluetoothAddress: UnsafeDataConvertible { }
extension Bluetooth.LowEnergyAdvertisingData: DataContainer { }
#endif


//
//  CommandLineBool.swift
//  Mesh
//
//  Created by Alsey Coleman Miller on 3/22/19.
//

/// Boolean for use with command line arguments.
public enum CommandLineBool: String {
    
    case `true` = "true"
    case `false` = "false"
}

public extension CommandLineBool {
    
    public init(_ boolValue: Bool) {
        
        if boolValue {
            self = .true
        } else {
            self = .false
        }
    }
    
    public var boolValue: Bool {
        switch self {
        case .true: return true
        case .false: return false
        }
    }
}

extension CommandLineBool: ExpressibleByBooleanLiteral {
    
    public init(booleanLiteral boolValue: Bool) {
        
        self.init(boolValue)
    }
}

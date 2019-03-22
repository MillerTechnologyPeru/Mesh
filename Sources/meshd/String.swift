//
//  String.swift
//  Mesh
//
//  Created by Alsey Coleman Miller on 3/17/19.
//

import Bluetooth

extension String {
    
    static var hexadecimalPrefix: String { return "0x" }
    
    func containsHexadecimalPrefix() -> Bool {
        
        return contains(String.hexadecimalPrefix)
    }
    
    func removeHexadecimalPrefix() -> String {
        
        guard contains(String.hexadecimalPrefix)
            else { return self }
        
        let suffixIndex = self.index(self.startIndex, offsetBy: 2)
        
        return String(self[suffixIndex ..< self.endIndex])
    }
}

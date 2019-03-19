//
//  ContentDelivery.swift
//  Mesh
//
//  Created by Alsey Coleman Miller on 3/16/19.
//

import Foundation

public enum ContentDelivery {
    
    case peersRequest(UUID)
    case peersResponse(Set<UUID>)
    
    
}

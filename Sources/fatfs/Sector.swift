//
//  File.swift
//  
//
//  Created by Sebastian Ritter on 23.03.22.
//

protocol Sector {
    
    /// Each ``Sector`` a factory implementation to create new instance from raw byte array.
    /// - Parameter rawContent: ``rawContent`` is a byte array
    /// - Returns: new instance
    static func canHandle (_ rawContent : [UInt8]) -> Sector?
}

extension Sector {
    static func getInstance (_ rawContent : [UInt8]?) -> Sector? {
        guard let _ = rawContent else {
            return EmptySector()
        }
        
        let impl : [Sector] = [
            Fat32Bootsector()
        ]
        for instance in impl {
            if let result = type(of: instance).canHandle(rawContent!) {
                return result
            }
        }
        return EmptySector ()
    }
}

struct Fat32Bootsector : Sector {
    
    static func canHandle(_ rawContent: [UInt8]) -> Sector? {
        guard rawContent.count == 512 else {
            return nil
        }
        let result : Fat32Bootsector = .init()
        return result
    }
    
    
}


struct EmptySector : Sector {
    
    private var content : [UInt8] = []
    
    static func canHandle(_ rawContent: [UInt8]) -> Sector? {
        let result : EmptySector = .init()
        return result
    }
}

//
//  StaticSectorFactory.swift
//  
//
//  Created by Sebastian Ritter on 24.03.22.
//

import Foundation

/// A factory implementation for ``Sector``.
///
/// The ``StaticSectorFactory`` has no knowledge over the concrete ``Sector`` implementations. These need to register at StaticSectorFactory and than the getInstance function returns a sector as build result. The concret building is encapsulate in the Sector implementation over the canHandle function.
/// In result the StaticSectorFactory need no internal knowledge over Sector implementation and a new Sector implementation need no change in StaticSectorFactory
struct StaticSectorFactory {
    
    private static var impl : [Sector] = []
    
    private static func firstIndex (_ sector : Sector) -> Int? {
        return impl.firstIndex(where: {type (of:$0) == type (of:sector)})
    }
    
    public static func register (_ sector : Sector, at wishAt: Int) -> Int{
        let _ = deregister(sector)
        var offset = wishAt
        if offset < 0 {
            offset = impl.count
        }
        else if offset > impl.count {
            offset = impl.count
        }
        impl.insert(sector, at: offset)
        return firstIndex(sector)!
    }
    public static func deregister (_ sector : Sector) -> Bool{
        if let index =  firstIndex(sector){
            impl.remove(at: index)
            return true
        }
        return false
    }

    /// Create a instance over check canHandle method of registered ``Sector`` implementation.
    ///
    /// - Parameter rawContent : Data of Sector
    /// - Returns : instance or nil
    public static func getInstance (_ rawContent : Data? = Data()) -> Sector? {
        guard let _ = rawContent else {
            return getInstance(Data())
        }
        
        for instance in impl {
            if let result = type(of: instance).canHandle(rawContent!) {
                return result
            }
        }
        return nil
    }
}



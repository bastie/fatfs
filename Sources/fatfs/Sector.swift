//
//  File.swift
//  
//
//  Created by Sebastian Ritter on 23.03.22.
//

import Foundation

protocol Sector {
    
    var content : Data {get set}
    
    /// Each ``Sector`` a factory implementation to create new instance from raw byte array.
    /// - Parameter rawContent: ``rawContent`` is a byte array
    /// - Returns: new instance
    static func canHandle (_ rawContent : Data) -> Sector?
}

extension Sector {
    static func getInstance (_ rawContent : Data?) -> Sector? {
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
    var content : Data
    var countOfSector : UInt32
    var lbaBegin : UInt32
    
    fileprivate init () {
        content = Data()
        countOfSector = 0
        lbaBegin = 0
    }
    
    static func canHandle(_ rawContent: Data) -> Sector? {
        guard rawContent.count == 512 else {
            return nil
        }
        
        var offset = 446 // skip 446 bytes
        var partitions : [Data] = []
        partitions.append(rawContent.subdata(in: offset..<offset+16))
        offset+=16
        partitions.append(rawContent.subdata(in: offset..<offset+16))
        offset+=16
        partitions.append(rawContent.subdata(in: offset..<offset+16))
        offset+=16
        partitions.append(rawContent.subdata(in: offset..<offset+16))
        offset+=16

        let MBRSanityCheck = NumberHelper.asUInt16(data: rawContent.subdata(in: offset..<offset+2))

        guard 43605 == MBRSanityCheck else { // same as 55AA
            // - TODO: TODO throw error
            return nil
        }
        
        #if DEBUG
            printData(partitions[0])
        #endif
        
        // - TODO: next switch is bad
        switch partitions[0][4] {
        case 11 : // 0B
            fallthrough
        case 12 : // 0C
            break // ALL OK
        default:
            guard false else {
                print("unsupported FAT information")
                return nil
            }
        }
        
        let lbaBeginArray = [
            partitions[0][8],
            partitions[0][9],
            partitions[0][10],
            partitions[0][11]
        ]
        let lbaBegin = NumberHelper.asUInt32(data: lbaBeginArray)

        let countOfSectorsArray = [
            partitions[0][12],
            partitions[0][13],
            partitions[0][14],
            partitions[0][15]
        ]
        let countOfSectors = NumberHelper.asUInt32(data: countOfSectorsArray)

        var result : Fat32Bootsector = .init()
        result.content = rawContent
        result.lbaBegin = lbaBegin
        result.countOfSector = countOfSectors
        return result
    }
    
    
}


struct EmptySector : Sector {
    
    internal var content : Data = Data()
    
    static func canHandle(_ rawContent: Data) -> Sector? {
        let result : EmptySector = .init()
        return result
    }
}
struct SectorFactory : Sector{
    var content: Data
    
    static func canHandle(_ rawContent: Data) -> Sector? {
        return nil
    }
    
    
}


#if DEBUG
extension Sector {
    static func printData (_ value : Data?) {
        if let data = value {
            let size = data.count
            var i = size
            for _ in data {
                if i == 0{
                    break
                }
                let x =  String(format:"%02X", UInt(data[size-i]))
                print ("\(x) ", terminator: "")
                if i % 17 == 0 {
                    print ("")
                }
                i -= 1
            }
        }
        print ("")
    }

}
#endif

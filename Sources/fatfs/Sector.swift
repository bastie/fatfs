//
//  Sector.swift
//  
//
//  Created by Sebastian Ritter on 23.03.22.
//

import Foundation
///
/// Blub
///


/// A sector of data for raw file access with can use
protocol Sector {
    
    var content : Data {get set}
    
    /// Each ``Sector`` has this factory implementation to create new instance from raw byte array but create only for accepted data a instance.
    ///
    /// Do use the ``StaticSectorFactory`` instead of this function.
    ///
    /// - Parameter rawContent: ``rawContent`` is a byte array
    /// - Returns: new instance
    static func canHandle (_ rawContent : Data) -> Sector?
}

///
/// A Fat32Bootsector implementation
struct Fat32Bootsector : Sector {
    var content : Data
    var countOfSector : UInt32
    var lbaBegin : UInt32
    
    internal init () {
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
                #if debug
                print("This is not a FAT32 boot sector")
                #endif 
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

/// A empty sector implementation
struct EmptySector : Sector {
    
    internal var content : Data = Data()
    
    static func canHandle(_ rawContent: Data) -> Sector? {
        guard rawContent.count == 0 else {
            return nil
        }
        let result : EmptySector = .init()
        return result
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



import Foundation

public struct FAT32 {
    
    public enum VERBOSE_CHAR : Character{
        case DOT = "."
        case QUOTE = "\""
        case SLASH = "/"
        case BACKSLASH = "\\"
        case SQUARE_BRACKET_OPEN = "["
        case SQUARE_BRACKET_CLOSE = "]"
        case COLON = ":"
        case SEMICOLON = ";"
        case PIPE = "|"
        case EQUAL = "="
        case COMMA = ","
    }
    
    public enum REVERVED_DEVICE {
        case CON, AUX, COM1, COM2, COM3, COM4, LPT1, LPT2, LPT3, PRN, NUL
    }

    
    @available(macOS 10.15.4, *)
    public func read(path : String?) {
        if let image = path {
            if let handle : FileHandle = try? .init(forReadingFrom: URL(fileURLWithPath: image)) {
                
                print ("\(handle)")

                let bootcode = try? handle.read(upToCount: 446)
                let partitions = [
                    try? handle.read(upToCount: 16),
                    try? handle.read(upToCount: 16),
                    try? handle.read(upToCount: 16),
                    try? handle.read(upToCount: 16)
                ]
                let MBRSanityCheck = try? handle.readAsUInt16(littleEndian: true)
                guard 43605 == MBRSanityCheck else { // same as 55AA
                    // - TODO: TODO throw error
                    return
                }
                
                printData(partitions[0])
                
                switch partitions[0]![4] {
                case 11 : // 0B
                    fallthrough
                case 12 : // 0C
                    print ("seems like FAT32")
                default:
                    guard false else {
                        print("unsupported FAT information")
                        return
                    }
                }
                
                let lbaBeginArray = [
                    partitions[0]![8],
                    partitions[0]![9],
                    partitions[0]![10],
                    partitions[0]![11]
                ]
                let lbaBegin = NumberHelper.asUInt32(data: lbaBeginArray)
                print("LBA Begin: \(lbaBegin)")

                let countOfSectorsArray = [
                    partitions[0]![12],
                    partitions[0]![13],
                    partitions[0]![14],
                    partitions[0]![15]
                ]
                let countOfSectors = NumberHelper.asUInt32(data: countOfSectorsArray)
                print ("Sector count: \(countOfSectors)")
                
                // OK - I read 1 sector and the lbaBegin get information from absolute sector offset I need to look at - and yes a sector ist 512 bytes long
                let offsetToRead = Int(512 * lbaBegin)
                var skip = offsetToRead-512 // 512 bytes (Bootblock) we read before
                
                let _ = try? handle.read(upToCount: skip)
                let next = try? handle.read(upToCount: 512)
                
                printData(next)
                
    /*            print ("1: \(String(format:"%02X", UInt8 (MBRSanityCheck![0])))")
                print ("2: \(String(format:"%02X", UInt8 (MBRSanityCheck![1])))")
    */
                
    /*            let available = handle.availableData // kill the RAM
                print (available.count)

                let size = 512
                var i = size
                for _ in available {
                    if i == 0{
                        break
                    }
                    let x =  String(format:"%02X", UInt(available[size-i]))
                    print ("\(x) ", terminator: "")
                    if i % 16 == 0 {
                        print ("")
                    }
                    i -= 1
                }
                
     */
            }
            else {
                print ("shit")
            }
        }
    }

    public private(set) var text = "Hello, World!"

    public init() {
    }
}


@available(macOS 10.15.4, *)
extension FileHandle {
    
    /// Read next 2 bytes as UInt16
    /// - Parameters little endian order of bytes if ``true`` or big endian order of bytes if ``false``
    func readAsUInt16 (littleEndian : Bool = true) throws -> UInt16 {
        let asUInt8Array = try self.read(upToCount: 2)
        let asUInt16 = NumberHelper.asUInt16(data: asUInt8Array!)
        return asUInt16
    }
}


struct NumberHelper {
    
    public static func asUInt16 (data bytes : Data, _ littleEndian : Bool = true) -> UInt16 {
        return littleEndian ?
        UInt16(littleEndian: bytes.withUnsafeBytes { $0.pointee }) :
        UInt16(bigEndian: bytes.withUnsafeBytes { $0.pointee })
    }
        
    public static func asUInt16 (data bytes : [UInt8]) -> UInt16 {
        return bytes.withUnsafeBytes { $0.load(as: UInt16.self) }
    }
    public static func asUInt32 (data bytes : [UInt8]) -> UInt32 {
        return bytes.withUnsafeBytes { $0.load(as: UInt32.self) }
    }
}

extension FAT32 {

    func printData (_ value : Data?) {
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



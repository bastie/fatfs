

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
                let nextSector = try? handle.read(upToCount: 512)
                
                let sector_1 = SectorFactory.getInstance(nextSector)

                // OK - I read 1 sector and the lbaBegin get information from absolute sector offset I need to look at - and yes a sector ist 512 bytes long
                switch sector_1 {
                case let sector as Fat32Bootsector :
                    print ("Fat32Bootsector detected")
                    print ("  Sector count: \(sector.countOfSector)")
                    print ("  LBA begin:    \(sector.lbaBegin)")
                    

                    let offsetToRead = Int(512 * sector.lbaBegin)
                    let skip = offsetToRead-512 // 512 bytes (Bootblock) we read before
                    
                    let _ = try? handle.read(upToCount: skip)
                    let next = try? handle.read(upToCount: 512)
                    
                    printData(next)
                default :
                    print ("Unknown sector type")

                }
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



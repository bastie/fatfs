//
//  Program entry point
//  
//
//  Created by Sebastian Ritter on 21.03.22.
//

import fatfs
import Foundation


print ("\(CommandLine.arguments[0]) v0.1")

let maybeImageName = CommandLine.arguments.count < 2 ? "./Tests/Resources/beNergerFat/beNerger.img.dd" : CommandLine.arguments[1]


if #available(macOS 10.15.4, *) {
    let FAT : fatfs.FAT32 = .init()

    FAT.read(path: maybeImageName)
} else {
    // Fallback on earlier versions
    print("Unsupported OS")
    exit(1)
}



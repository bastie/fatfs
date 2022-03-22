//
//  File.swift
//  
//
//  Created by Administrator on 21.03.22.
//

import fatfs
import Darwin

print ("Hello DD")

if #available(macOS 10.15.4, *) {
    let FAT : fatfs.FAT32 = .init()

    FAT.read()
} else {
    // Fallback on earlier versions
    print("Unsupported OS")
    exit(1)
}



//
//  Pixel.swift
//  Project
//
//  Created by Admin on 08.12.2017.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit

public struct Pixel {
    
    public init(ravVal : UInt32){
        value = ravVal
    }
    public var value: UInt32
    
    //red
    public var R: UInt8 {
        get { return UInt8(value & 0xFF); }
        set { value = UInt32(newValue) | (value & 0xFFFFFF00) }
    }
    
    //green
    public var G: UInt8 {
        get { return UInt8((value >> 8) & 0xFF) }
        set { value = (UInt32(newValue) << 8) | (value & 0xFFFF00FF) }
    }
    
    //blue
    public var B: UInt8 {
        get { return UInt8((value >> 16) & 0xFF) }
        set { value = (UInt32(newValue) << 16) | (value & 0xFF00FFFF) }
    }
    
    //alpha
    public var A: UInt8 {
        get { return UInt8((value >> 24) & 0xFF) }
        set { value = (UInt32(newValue) << 24) | (value & 0x00FFFFFF) }
    }
    public var Rf: Double {
        get { return Double(self.R) / 255.0 }
        set { self.R = UInt8(newValue * 255.0) }
    }
    
    public var Gf: Double {
        get { return Double(self.G) / 255.0 }
        set { self.G = UInt8(newValue * 255.0) }
    }
    
    public var Bf: Double {
        get { return Double(self.B) / 255.0 }
        set { self.B = UInt8(newValue * 255.0) }
    }
    
    public var Af: Double {
        get { return Double(self.A) / 255.0 }
        set { self.A = UInt8(newValue * 255.0) }
    }
}



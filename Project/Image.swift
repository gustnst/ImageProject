//
//  Image.swift
//  Project
//
//  Created by Admin on 08.12.2017.
//  Copyright © 2017 Admin. All rights reserved.
//

var WinSize=16
var f1 = [[-1,-1,1,1],[-1,-1,1,1],[-1,-1,1,1],[-1,-1,1,1]]
var f2 = [[1,1,1,1],[1,1,1,1],[-1,-1,-1,-1],[-1,-1,-1,-1]]
var f3 = [[-1,-1,1,1],[-1,-1,1,1],[1,1,-1,-1],[1,1,-1,-1]]
var f4 = [[-1,1,1,-1],[-1,1,1,-1],[-1,1,1,-1],[-1,1,1,-1]]
var f5 = [[-1,-1,-1,-1],[1,1,1,1],[1,1,1,1],[-1,-1,-1,-1]]
var f6 = [[-1,1,1,-1],[-1,1,1,-1],[1,-1,-1,1],[1,-1,-1,1]]
var f7 = [[1,1,-1,-1],[-1,-1,1,1],[-1,-1,1,1],[1,1,-1,-1]]
var f8 = [[1,-1,-1,1],[-1,1,1,-1],[-1,1,1,-1],[1,-1,-1,1]]
var f9 = [[1,-1,1,-1],[1,-1,1,-1],[1,-1,1,-1],[1,-1,1,-1]]
var f10 = [[-1,-1,-1,-1],[1,1,1,1],[-1,-1,-1,-1],[1,1,1,1]]
var f11 = [[1,-1,1,-1],[1,-1,1,-1],[-1,1,-1,1],[-1,1,-1,1]]
var f12 = [[1,1,-1,-1],[-1,-1,1,1],[1,1,-1,-1],[-1,-1,1,1]]
var f13 = [[-1,1,-1,1],[1,-1,1,-1],[1,-1,1,-1],[-1,1,-1,1]]
var f14 = [[1,-1,-1,1],[-1,1,1,-1],[-1,1,1,-1],[-1,-1,1,1]]
var f15 = [[-1,1,-1,1],[1,-1,1,-1],[-1,1,-1,1],[1,-1,1,-1]]

import Foundation
import UIKit

class Image{
    public var pixels: UnsafeMutableBufferPointer<Pixel>
    public var width: Int
    public var height: Int
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
    let bitsPerComponent = 8
    let bytesPerRow : Int
    
    public init(width: Int, height: Int){
        self.height = height
        self.width = width
        bytesPerRow = 4 * width
        let imageData = UnsafeMutablePointer<Pixel>.allocate(capacity: width * height)
        pixels = UnsafeMutableBufferPointer<Pixel>(start: imageData, count: width * height)
    }
    
    public init?(image: UIImage) {
        guard let cgImage = image.cgImage else {
            return nil
        }
        width = Int(image.size.width)
        height = Int(image.size.height)
        bytesPerRow = width * 4
        
        let imageData = UnsafeMutablePointer<Pixel>.allocate(capacity: width * height)
        
        guard let imageContext = CGContext(data: imageData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
            return nil
        }
        
        imageContext.draw(cgImage, in: CGRect(origin: .zero, size: image.size))
        
        pixels = UnsafeMutableBufferPointer<Pixel>(start: imageData, count: width * height)
    }
    
    public func getPixel(x: Int, y: Int)-> Pixel{
        return pixels[x+y*width]
    }
    public func setPixel(value: Pixel, x: Int, y: Int){
        pixels[x+y*width]=value
    }
    
    public func toUIImage() -> UIImage? {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Big.rawValue
        let bytesPerRow = width * 4
        
        bitmapInfo |= CGImageAlphaInfo.premultipliedLast.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
        
        guard let imageContext = CGContext(data: pixels.baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo, releaseCallback: nil, releaseInfo: nil) else {
            return nil
        }
        guard let cgImage = imageContext.makeImage() else {
            return nil
        }
        
        let image = UIImage(cgImage: cgImage)
        return image
    }
    
    public func grayScale(p: Pixel)->Pixel{
        var pixel = p
        let result = (pixel.Rf + pixel.Gf + pixel.Bf) / 3.0
        pixel.Rf = result
        pixel.Gf = result
        pixel.Bf = result
        
        return pixel
    }
    public func transformPixels(transformFunc: (Pixel)->Pixel)->Image{
        let newImage = Image(width: self.width, height: self.height)
        for y in 0..<height{
            for x in 0..<width{
                let p1 = getPixel(x: x, y: y)
                let p2 = transformFunc(p1)
                newImage.setPixel(value: p2, x: x, y: y)
            }
        }
        return newImage
    }
    
    public func norm(image: Image)->[[Double]]{
      //  print(image.width,image.height)
        let img = image.transformPixels(transformFunc: grayScale)
        var matrix = Array(repeating: Array(repeating: 0.0,count: img.height), count: img.width)
        for y in 0..<img.height{
            for x in 0..<img.width{
            matrix[x][y]=Double(img.getPixel(x: x, y: y).value)
               // print(matrix[x][y])
            }
        }
        let minPix = matrix.map({$0.min()!}).min()!
        for y in 0..<img.height{
            for x in 0..<img.width{
                matrix[x][y] =  matrix[x][y] - minPix
            }
        }
        let maxPix = matrix.map({$0.max()!}).max()!
        for y in 0..<img.height{
            for x in 0..<img.width{
                matrix[x][y] =  matrix[x][y]/maxPix
                 matrix[x][y] = round(100*matrix[x][y])/100
                //print(matrix[x][y])
            }
        }

        return matrix
    }
    
    public func qTransformation(matrix: [[Double]],windowSize: Int)->[[Double]]{
        let q = 4
        let h = windowSize/q
        let w = windowSize/q
        var result = Array(repeating: Array(repeating: 0.0,count: 4), count: 4)
        var sum : Double
        for i in 0..<q{
            for j in 0..<q{
                sum=0
                for y in i*w..<(i+1)*w{
                    for x in j*h..<(j+1)*h{
                        sum = sum + matrix[y][x]
                    }
                }
                result[i][j]=sum
                //print(result[i][j])
            }
        }
        //print("q")
        return result
    }
    public func createVectors(matrix: [[Double]], winSize: Int)->[Double]{
        var result = Array(repeating: 0.0,count: 15)
        let qResult = qTransformation(matrix: matrix, windowSize: winSize)
        result[0]=MulMatrixs(array: qResult, f: f1)
        result[1]=MulMatrixs(array: qResult, f: f2)
        result[2]=MulMatrixs(array: qResult, f: f3)
        result[3]=MulMatrixs(array: qResult, f: f4)
        result[4]=MulMatrixs(array: qResult, f: f5)
        result[5]=MulMatrixs(array: qResult, f: f6)
        result[6]=MulMatrixs(array: qResult, f: f7)
        result[7]=MulMatrixs(array: qResult, f: f8)
        result[8]=MulMatrixs(array: qResult, f: f9)
        result[9]=MulMatrixs(array: qResult, f: f10)
        result[10]=MulMatrixs(array: qResult, f: f11)
        result[11]=MulMatrixs(array: qResult, f: f12)
        result[12]=MulMatrixs(array: qResult, f: f13)
        result[13]=MulMatrixs(array: qResult, f: f14)
        result[14]=MulMatrixs(array: qResult, f: f15)
        print (result)
        return result
    }
    
    public func MulMatrixs(array: [[Double]],f: [[Int]])->Double{
        var result = Array(repeating: Array(repeating: 0.0,count: 4), count: 4)
        for i in 0..<4{
            for j in 0..<4{
                result[i][j] = array[i][j] * Double(f[j][i])
            }
        }
        
        return SumMatrix(array: result)
    }
    
    public func SumMatrix(array: [[Double]])->Double{
        var sum = 0.0
        for i in 0..<4{
            for j in 0..<4{
                sum=sum + array[i][j]
            }
        }
        return sum
    }
    public func standardDeviation(arr : [Double]) -> Double
    {
        let length = 15.0//Double(arr.count)
        let avg = arr.reduce(0, {$0 + $1}) / length
        let sumOfSquaredAvgDiff = arr.map { pow($0 - avg, 2.0)}.reduce(0, {$0 + $1})
        return sqrt(sumOfSquaredAvgDiff / length)
    }
    
    public func getKeyPoints(image: Image, windowSize : Int)->Image{
        let height = image.height
        let width = image.width
        let img = image
        let matrix = norm(image: image)
        print (matrix)
        var res = [KeyPoint]()
        var deviations = [Double]()
        var points = [KeyPoint]()
        var i = 0
        var k = 0
        var j = 0
        var u = Array(repeating: 0.0,count: 15)
        var windowMatrix = Array(repeating: Array(repeating: 0.0,count: WinSize), count: WinSize)
        while(i<(height-windowSize+1)){
            j = 0
            while(j<(width-windowSize+1)){
                windowMatrix = makeWindow(NormMatrix: matrix, xFrom: j, xTo: j+windowSize-1, yFrom: i, yTo: i+windowSize-1)
                //print(j,j+windowSize-1,i,i+windowSize-1)
                //u=createVectors(i: i,j: j,heigh: i+windowSize-1,widt: j+windowSize-1,mat: matrix)
                u = createVectors(matrix: windowMatrix, winSize: windowSize)
               // print(u)
                points.append(KeyPoint(x: j,y: i,windowSize: windowSize,u: u))
                deviations.append(standardDeviation(arr: u))
                
                k=k+1
                j = j + 6//step
            }
            i = i+6
        }
        
        let maxDev = deviations.max()
        for i in 0..<deviations.count{
           //print(deviations[i],maxDev)
            if(deviations[i]>maxDev!*0.6){
                res.append(points[i])
            }
        }
        //print(k)
        var red = Pixel(ravVal: 0x00000000)
        red.R = 255
        red.A = 255
        for i in 0..<res.count{
          //  print(res[i].x,res[i].y)
            //  print(res[i].x)
          img.setPixel(value: red,x: res[i].x+(res[i].windowSize/2) - 1,y: res[i].y + (res[i].windowSize/2) - 1)
            img.setPixel(value: red,x: res[i].x+res[i].windowSize/2,y: res[i].y + (res[i].windowSize/2) - 1)
            img.setPixel(value: red,x: res[i].x+(res[i].windowSize/2) - 1,y: res[i].y + windowSize/2)
            img.setPixel(value: red,x: res[i].x+res[i].windowSize/2,y: res[i].y + windowSize/2)
        }
        return img
    }
    
    public func makeWindow(NormMatrix: [[Double]], xFrom: Int,xTo: Int, yFrom:Int,yTo:Int)->[[Double]]{
        var windowMatrix = Array(repeating: Array(repeating: 0.0,count: WinSize), count: WinSize)
        var k=0
        var l:Int
        for i in xFrom..<xTo{
            l=0
            for j in yFrom..<yTo{
                
                windowMatrix[k][l]=NormMatrix[i][j]
                l=l+1
            }
            k=k+1
        }
        print(windowMatrix)
        return windowMatrix
    }
}

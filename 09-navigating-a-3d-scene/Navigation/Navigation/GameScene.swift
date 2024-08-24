///// Copyright (c) 2023 Kodeco Inc.
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
import MetalKit

struct GameScene {
    
    var camera = ArcballCamera()
    
    lazy var house: Model = {
       let house = Model(name: "lowpoly-house.usdz")
        house.setTexture(name: "barn-color", type: BaseColor)
        return house
    }()
    
    lazy var ground: Model = {
        let ground = Model(name: "ground", primitiveType: .plane)
        ground.setTexture(name: "barn-ground", type: BaseColor)
        ground.tiling = 16
        ground.transform.scale = 40
        ground.transform.rotation.z = Float(90).degreesToRadians
        return ground
    }()
    
    lazy var models: [Model] = [ground, house]
    
    init() {
        camera.position = [0, 1.4, -4.0]
        camera.distance = length(camera.position)
        camera.target = [0, 1.2, 0]
    }
    
    mutating func update(deltaTime: Float) {
//        ground.rotation.y = sin(deltaTime)
//        house.rotation.y = sin(deltaTime)
//        camera.rotation.y = sin(deltaTime)
        camera.update(deltaTime: deltaTime)
        
        // 测试按键是否有响应，与渲染无关
//        if InputComtroller.shared.keysPressed.contains(.keyH) {
//            print("H Key pressed")
//        }
    }
    
    mutating func update(size: CGSize) {
        camera.update(size: size)
    }
    
}


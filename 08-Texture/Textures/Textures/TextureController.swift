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
/*
 一个模型通常具有多个引用相同纹理的submeshed ，为了不想重复加载此纹理，需要创建一个中央纹理控制器来保存纹理。
 */

enum TextureController {
    // 使用字典存储已经加载过的纹理
    static var textures: [String: MTLTexture] = [:]
    
    static func loadTexture(texture: MDLTexture, name: String) -> MTLTexture? {
        if let texture = textures[name] {
            return texture
        }
        
        let textureloader = MTKTextureLoader(device: Renderer.device)
        // 更改纹理的原点 位于左下角。如果不设置这个，纹理将无法正确包着房子
        let textureLoaderOptions: [MTKTextureLoader.Option: Any] = [.origin : MTKTextureLoader.Origin.bottomLeft]
        let texture = try? textureloader.newTexture(texture: texture, options: textureLoaderOptions)
        print("loaded texture from USD file")
        textures[name] = texture
        return texture
    }
    
    static func loadTexture(name: String) -> MTLTexture? {
        // 1
        if let texture = textures[name] {
            return texture
        }
        // 2 从 Asset catalog 中加载纹理
        let textureLoader = MTKTextureLoader(device: Renderer.device)
        let texture: MTLTexture?
        texture = try? textureLoader.newTexture(
            name: name,
            scaleFactor: 1.0, // 因为纹理只有 1x 所以这里使用1.0
            bundle: Bundle.main,
            options: nil)
        // 3 缓存纹理
        if texture != nil {
            print("loaded texture: \(name)")
            textures[name] = texture
        }
        return texture
    }
}



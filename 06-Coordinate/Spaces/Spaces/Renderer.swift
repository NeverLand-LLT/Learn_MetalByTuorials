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

import MetalKit

// swiftlint:disable implicitly_unwrapped_optional

class Renderer: NSObject {
    static var device: MTLDevice!
    static var commandQueue: MTLCommandQueue!
    static var library: MTLLibrary!
    var pipelineState: MTLRenderPipelineState!
    
    var uniforms = Uniforms()
    
    
    lazy var model: Model = {
        Model(device: Renderer.device, name: "train.usdz")
    }()
    
    var timer: Float = 0
    
    init(metalView: MTKView) {
        guard
            let device = MTLCreateSystemDefaultDevice(),
            let commandQueue = device.makeCommandQueue() else {
            fatalError("GPU not available")
        }
        Self.device = device
        Self.commandQueue = commandQueue
        metalView.device = device
        
        // create the shader function library
        let library = device.makeDefaultLibrary()
        Self.library = library
        let vertexFunction = library?.makeFunction(name: "vertex_main")
        let fragmentFunction =
        library?.makeFunction(name: "fragment_main")
        
        // create the pipeline state object
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat =
        metalView.colorPixelFormat
        pipelineDescriptor.vertexDescriptor =
        MTLVertexDescriptor.defaultLayout
        do {
            pipelineState =
            try device.makeRenderPipelineState(
                descriptor: pipelineDescriptor)
        } catch {
            fatalError(error.localizedDescription)
        }
        super.init()
        metalView.clearColor = MTLClearColor(
            red: 1.0,
            green: 1.0,
            blue: 0.9,
            alpha: 1.0)
        metalView.delegate = self
        
//        // 在 init(metalView:) 底部添加代码。 配置 uniform
//        let translation = float4x4(translation: [0.5, -0.4, 0])
//        let rotation = float4x4(rotation: [0, 0, Float(45).degreesToRadians])
//        uniforms.modelMatrix = translation * rotation
            
        
        // Tips： 场景中所有对象都应沿着与摄像机相反的方向移动。所以调用 inverse 。当相机向右移动时， 整个世界 向左移动了0.8个单元
        uniforms.viewMatrix = float4x4(translation: [0.8,0,0]).inverse
        
    }
}

extension Renderer: MTKViewDelegate {
    // 因为外面SWiftUI 视图框架，设置了固定高度，没有设置固定宽度，所以APP启动时，会走这里。
    // 如果外面设置了固定宽高。 这个代理不会走。从而导致 没有走设置投影视角初始化
    func mtkView(
        _ view: MTKView,
        drawableSizeWillChange size: CGSize
    ) {
        // 使用 视野为45°，近平面位0.1 远平面为100
        let aspect = Float(view.bounds.width) / Float(view.bounds.height)
        let projectionMatrix = float4x4(
            projectionFov: Float(45).degreesToRadians,
            near: 0.1,
            far: 100,
//            far: 1000, // 当 translation z轴改为 98 + 相机back -3 超过 100 far就看不到了
            aspect: aspect)
        uniforms.projectionMatrix = projectionMatrix
    }
    
    // 当视图大小发生变化
    func draw(in view: MTKView) {
        guard
            let commandBuffer = Self.commandQueue.makeCommandBuffer(),
            let descriptor = view.currentRenderPassDescriptor,
            let renderEncoder =
                commandBuffer.makeRenderCommandEncoder(
                    descriptor: descriptor) else {
            return
        }
        
        renderEncoder.setRenderPipelineState(pipelineState)
//        renderEncoder.setTriangleFillMode(.lines) // 如果要实现实心火车，注释掉这句
        
        renderEncoder.setVertexBytes(&uniforms,
                                     length: MemoryLayout<Uniforms>.stride,
                                     index: 11)
        
        
        
        timer += 0.005
        uniforms.viewMatrix = float4x4.identity
        uniforms.viewMatrix = float4x4(translation: [0, 0, -3]).inverse
//        let translationMatrix = float4x4(translation: [0, -0.6, 0])
//        let translationMatrix = float4x4(translation: [0, -0.6, 98])
//        let rotationMatrix = float4x4(rotationY: sin(timer))
//        uniforms.modelMatrix = translationMatrix * rotationMatrix
        
        model.position.y = -0.6
        model.rotation.y = sin(timer)
        uniforms.modelMatrix = model.transform.modelMatrix
        
        model.render(encoder: renderEncoder)
        
        renderEncoder.endEncoding()
        guard let drawable = view.currentDrawable else {
            return
        }
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

// swiftlint:enable implicitly_unwrapped_optional

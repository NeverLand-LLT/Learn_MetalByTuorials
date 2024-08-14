//
//  Renderer.swift
//  03-Pipeline
//
//  Created by Liangyz on 2024/7/27.
//

import MetalKit

class Renderer: NSObject {
    // 在大多数APP中 使用一个 Device commandQueue  library  就可以
    static var device: MTLDevice!
    static var commandQueue: MTLCommandQueue!
    static var library: MTLLibrary!
    var mesh: MTKMesh!
    
    var vertexBuffer: MTLBuffer!
    var pipelineState: MTLRenderPipelineState!
    
    
    init(metalView: MTKView) {
        // 初始化：
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue() else {
            fatalError("GPU not available")
        }
        Self.device = device
        Self.commandQueue = commandQueue
        metalView.device = device
        
        // 创建Mesh
        let allocator = MTKMeshBufferAllocator(device: device)
        let size: Float = 0.8
        // 创建一个立方体ModelMesh
        let mdlMesh = MDLMesh(boxWithExtent: [size, size, size], segments: [1,1,1], inwardNormals: false, geometryType: .triangles, allocator: allocator)
        do {
            mesh = try MTKMesh(mesh: mdlMesh, device: device)
        } catch  {
            print(error.localizedDescription)
        }
        vertexBuffer = mesh.vertexBuffers[0].buffer
        
        // 创建着色器函数
        let library = device.makeDefaultLibrary()
        Self.library = library
        let vertexFunction = library?.makeFunction(name: "vertex_main")
        let fragmentFunction = library?.makeFunction(name: "fragment_main")
        
        // 创建管道状态对象
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
        pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mdlMesh.vertexDescriptor)
        
        do {
            pipelineState =  try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch  {
            fatalError(error.localizedDescription)
        }
        
        super.init()
        metalView.clearColor = MTLClearColor(red: 1.0, green: 1.0, blue: 0.8, alpha: 1.0)
        metalView.delegate = self
    
    }
}

extension Renderer: MTKViewDelegate {
    /*
     每一帧调用， 这里是编写渲染GPU代码的地方
     */
    func draw(in view: MTKView) {
        print("draw")
        guard let commandBuffer = Self.commandQueue.makeCommandBuffer(),
              let descriptor = view.currentRenderPassDescriptor,
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            return
        }
        
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        
        for submesh in mesh.submeshes {
            renderEncoder.drawIndexedPrimitives(type: .triangle,
                                                indexCount: submesh.indexCount,
                                                indexType: submesh.indexType,
                                                indexBuffer: submesh.indexBuffer.buffer,
                                                indexBufferOffset: submesh.indexBuffer.offset)
        }
        
        // 将GPU命令添加到 命令编码器后，即刻结束其编码
        renderEncoder.endEncoding()
        
        // 将视图的可绘制纹理 present 给GPU
        guard let drawable = view.currentDrawable else {
            return
        }
        commandBuffer.present(drawable)
        
        // 提交命令缓冲区，将编码的名利发送给GPU执行
        commandBuffer.commit()
        
    }
    
    /*
     - 每次窗口大小改变时调用。 这里可以更新渲染纹理大小和相机投影 (testure sizes and camera projection)
     */
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
}

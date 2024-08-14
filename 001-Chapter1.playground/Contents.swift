
// 可以在 assistant editor 查看实时视图
import PlaygroundSupport
import MetalKit


// 创建设备来检查是否有合适的 GPU
guard let device = MTLCreateSystemDefaultDevice() else {
    fatalError("GPU is not supported")
}

// 设置视图
let frame = CGRect(x: 0, y: 0, width: 600, height: 600)
let view = MTKView(frame: frame, device: device)

// 奶油色
view.clearColor = MTLClearColor(red: 0, green: 0.4, blue: 0.21, alpha: 1.0)


// 加载3D图元

// (1) 创建一个 mesh data Buffer
let allocator = MTKMeshBufferAllocator(device: device)

// (2) 使用Model I/O 创建一个 具有指定大小的球体，并返回一个 MDLMesh(其中包含数据缓冲区中的所有顶点信息)
let mdlMesh = MDLMesh(
    sphereWithExtent: [0.2, 0.75, 0.2],
    segments: [100, 100],
    inwardNormals: false,
    geometryType: .triangles,
    allocator: allocator)
// (3) 为了使Metal 能改使用 mesh , 将 Model I/O mesh 转为 Metal mesh
let mesh = try MTKMesh(mesh: mdlMesh, device: device)


// 创建一个命令队列
guard let commandQueue = device.makeCommandQueue() else {
    fatalError("Could not create a command queue")
}

/*
 这里包含两个着色器函数，一个名为 vertex_main 的顶点函数 和 一个名为 fragment_main 片段函数。
 - 顶点函数通常操作顶点位置
 - 片段函数 指定像素颜色的地方
 */
let shader = """
    #include <metal_stdlib>
    using namespace metal;
    
    struct VertexIn {
    float4 position [[attribute(0)]];
    };
    
    
    vertex float4 vertex_main(const VertexIn vertex_in [[stage_in]])
    {
    return vertex_in.position;
    }
    
    
    
    fragment float4 fragment_main() {
    return float4(1, 0, 0, 1);
    }
    """

// 指定 包含这两个函数的Metal Library, 并获取着色器
let library = try device.makeLibrary(source: shader, options: nil)
let vertexFunction = library.makeFunction(name: "vertex_main")
let fragmentFunction = library.makeFunction(name: "fragment_main")


// 创建 管道状态描述符, 来描述 pipeline State
let pipelineDescriptor = MTLRenderPipelineDescriptor()
pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm // 指定4个8位无符号整数
pipelineDescriptor.vertexFunction = vertexFunction
pipelineDescriptor.fragmentFunction = fragmentFunction

// 使用vertex descriptor 向GPU描述顶点如何在内存中布局(怎么读取顶点数据)
// Model I/O 在加载球体Mesh时会自动创建一个顶点描述符，所以可以直接使用该描述符
pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mesh.vertexDescriptor)
// 创建一个 pipelineState
let pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)


/**
 1. 创建一个命令缓冲区
 2. 得到当前 views render pass 的 descriptor,
 3. 从命令缓冲区中，创建一个 encoder ,(encoder 保存发送到GPU所需的所有信息，以便绘制顶点。)
 
 
 */
guard let commandBuffer = commandQueue.makeCommandBuffer(),
      let renderPassDescriptor = view.currentRenderPassDescriptor,
      let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
    fatalError()
}

renderEncoder.setRenderPipelineState(pipelineState)

// 偏移量(offset)是缓冲区中顶点信息开始的位置。索引(index)是GPU顶点着色器函数如何定位改缓冲区的方式
renderEncoder.setVertexBuffer(mesh.vertexBuffers[0].buffer, offset: 0, index: 0)

// 从Model I/O 中得到 mesh的 子网格
guard let submesh = mesh.submeshes.first else {
    fatalError()
}

// 绘制

// 指示GPU渲染由三角形组成的顶点缓冲区，其中顶点根据 子网络索引信息按正确的顺序放置。
// 这段代码并不执行 真正的渲染，直到GPU接受到所有与命令缓冲区的命令后才会发生渲染
renderEncoder.drawIndexedPrimitives(type: .triangle,
                                    indexCount: submesh.indexCount, 
                                    indexType: submesh.indexType,
                                    indexBuffer: submesh.indexBuffer.buffer,
                                    indexBufferOffset: 0)


// 指定 要完成向渲染命令编码器 发送 最后确定帧。
// 1. 告诉渲染编码器，不再有绘制并结束 render pass
renderEncoder.endEncoding()
// 2. 从MTKView获取可绘制对象，MTK由Core Animation CAMetalLayer支持，该层由MEtal可以读取和介写入的可绘制纹理。
guard let drawable = view.currentDrawable else {
    fatalError()
}

// 3. 要求命令缓冲区 present MTKVCiew的 可绘制对象并提交给GPU
commandBuffer.present(drawable)
commandBuffer.commit()

// 添加这行代码，能在Assisatant 可以看到奶油色背景上的虹桥
PlaygroundPage.current.liveView = view

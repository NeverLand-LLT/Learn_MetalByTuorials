import PlaygroundSupport
import MetalKit

guard let device = MTLCreateSystemDefaultDevice() else {
    fatalError("GPU is not supported")
}

let frame = CGRect(x: 0, y: 0, width: 600, height: 600)
let view = MTKView(frame: frame, device: device)
view.clearColor = MTLClearColor(red: 1,
                                green: 1, blue: 0.8, alpha: 1)

let allocator = MTKMeshBufferAllocator(device: device)

// 生成球体
//let mdlMesh = MDLMesh(
//  sphereWithExtent: [0.75, 0.75, 0.75],
//  segments: [100, 100],
//  inwardNormals: false,
//  geometryType: .triangles,
//  allocator: allocator)

// 生成三角锥
//let mdlMesh = MDLMesh(
//coneWithExtent: [1, 1, 1],
//segments: [10, 10],
//inwardNormals: false,
//cap: true,
//geometryType: .triangles,
//allocator: allocator)

//导入火车模型
guard let assetURL = Bundle.main.url(
    forResource: "train",
    withExtension: "usdz") else {
    fatalError()
}
let asset = MDLAsset(
    url: assetURL,
    vertexDescriptor: meshDescriptor,
    bufferAllocator: allocator)
let mdlMesh =
asset.childObjects(of: MDLMesh.self).first as! MDLMesh

// 1 创建一个顶点描述符，用于配置对象需要了解的所有属性
let vertexDescriptor = MTLVertexDescriptor()
// 2 告诉描述符 xyz 位置数据应以 float3 的形式加载，这是一个由三个 Float 值组成的 simd 数据类型。MTLVertexDescriptor 具有一个包含 31 个属性的数组，您可以在其中配置数据格式。
vertexDescriptor.attributes[0].format = .float3
// 3 偏移量指定此特定数据将在缓冲区中的起始位置。
vertexDescriptor.attributes[0].offset = 0
// 4
/*
 当您通过渲染编码器将顶点数据发送到 GPU 时，您需要在 MTLBuffer 中发送该数据，并通过索引标识缓冲区。有 31 个缓冲区可用，Metal 在缓冲区参数表中跟踪它们。
 您在此处使用缓冲区 0，以便顶点着色器函数能够将缓冲区 0 中的传入顶点数据与此顶点布局匹配。
 */
vertexDescriptor.attributes[0].bufferIndex = 0

// 1
vertexDescriptor.layouts[0].stride =
MemoryLayout<SIMD3<Float>>.stride
// 2
let meshDescriptor =
MTKModelIOVertexDescriptorFromMetal(vertexDescriptor)
// 3
(meshDescriptor.attributes[0] as! MDLVertexAttribute).name =
MDLVertexAttributePosition



let mesh = try MTKMesh(mesh: mdlMesh, device: device)

guard let commandQueue = device.makeCommandQueue() else {
    fatalError("Could not create a command queue")
}

let shader = """
#include <metal_stdlib>
using namespace metal;

struct VertexIn {
  float4 position [[attribute(0)]];
};

vertex float4 vertex_main(const VertexIn vertex_in [[stage_in]]) {
float4 position = vertex_in.position;
        position.y -= 1.0; // 调整火车模型
  return position;
}

fragment float4 fragment_main() {
  return float4(1, 0, 0, 1);
}
"""

let library = try device.makeLibrary(source: shader, options: nil)
let vertexFunction = library.makeFunction(name: "vertex_main")
let fragmentFunction = library.makeFunction(name: "fragment_main")

let pipelineDescriptor = MTLRenderPipelineDescriptor()
pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
pipelineDescriptor.vertexFunction = vertexFunction
pipelineDescriptor.fragmentFunction = fragmentFunction

pipelineDescriptor.vertexDescriptor =
MTKMetalVertexDescriptorFromModelIO(mesh.vertexDescriptor)

let pipelineState =
try device.makeRenderPipelineState(descriptor: pipelineDescriptor)

guard let commandBuffer = commandQueue.makeCommandBuffer(),
      let renderPassDescriptor = view.currentRenderPassDescriptor,
      let renderEncoder = commandBuffer.makeRenderCommandEncoder(
        descriptor:  renderPassDescriptor)
else { fatalError() }

renderEncoder.setRenderPipelineState(pipelineState)

renderEncoder.setVertexBuffer(
    mesh.vertexBuffers[0].buffer, offset: 0, index: 0)

// 指定 渲染三角形的填充模式
renderEncoder.setTriangleFillMode(.lines)

// 只是绘制一个mesh
//guard let submesh = mesh.submeshes.first else {
//    fatalError()
//}
//renderEncoder.drawIndexedPrimitives(
//    type: .triangle,
//    indexCount: submesh.indexCount,
//    indexType: submesh.indexType,
//    indexBuffer: submesh.indexBuffer.buffer,
//    indexBufferOffset: 0)

for submesh in mesh.submeshes {
    renderEncoder.drawIndexedPrimitives(
        type: .triangle,
        indexCount: submesh.indexCount,
        indexType: submesh.indexType,
        indexBuffer: submesh.indexBuffer.buffer,
        indexBufferOffset: submesh.indexBuffer.offset
    )
}

renderEncoder.endEncoding()
guard let drawable = view.currentDrawable else {
    fatalError()
}
commandBuffer.present(drawable)
commandBuffer.commit()

PlaygroundPage.current.liveView = view

// MARK: - 导出3D模型

//// begin export code
//// 1
//let asset = MDLAsset()
//asset.add(mdlMesh)
//// 2
//let fileExtension = "usda"
//guard MDLAsset.canExportFileExtension(fileExtension) else {
//fatalError("Can't export a .\(fileExtension) format")
//}
//// 3
//do {
//let url = playgroundSharedDataDirectory
//.appendingPathComponent("primitive.\(fileExtension)")
//try asset.export(to: url)
//} catch {
//fatalError("Error \(error.localizedDescription)")
//}
//// end export code

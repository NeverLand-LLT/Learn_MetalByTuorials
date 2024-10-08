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

#include <metal_stdlib>
using namespace metal;

// float3 为 13
//vertex
//float4 vertex_main(
//                   constant packed_float3 *vertices [[buffer(0)]],
//                   constant float &timer [[buffer(11)]],
//                   uint vertexID [[vertex_id]]
//                   ) {
//                       float4 position = float4(vertices[vertexID], 1.0);
//                       position.y += timer;
//                       return position;
//                   }


//vertex
//float4 vertex_main(
//                   constant packed_float3 *vertices [[buffer(0)]],
//                   constant ushort *indices [[buffer(1)]],
//                   constant float &timer [[buffer(11)]],
//                   uint vertexID [[vertex_id]]
//                   ) {
//                       ushort index = indices[vertexID];
//                       float4 position = float4(vertices[index], 1.0);
//
//                       position.y += timer;
//                       return position;
//                   }


//vertex
//float4 vertex_main(
//                   float4 position [[attribute(0)]] [[stage_in]],
//                   constant float &timer [[buffer(11)]],
//                   uint vertexID [[vertex_id]]
//                   ) {
//                       position.y += timer;
//                       return position;
//                   }


struct VertexIn {
    float4 position [[attribute(0)]];
    float4 color    [[attribute(1)]];
};

//vertex
//float4 vertex_main(
//                   VertexIn in [[stage_in]],
//                   constant float &timer [[buffer(11)]]
//                   ) {
//                       in.position.y += timer;
//                       return in.position;
//                   }
//
//fragment float4 fragment_main() {
//    return float4(0, 0, 1, 1);
//}


//// 渲染 三角形
//struct VertexOut {
//    float4 position [[position]];
//    float4 color;
//};
//
//vertex
//VertexOut vertex_main(VertexIn in [[stage_in]], 
//                      constant float &timer [[buffer(11)]] ) {
//    in.position.y += timer;
//    VertexOut out {
//        .position = in.position,
//        .color = in.color
//    };
//    return out;
//}
//
//fragment 
//float4 fragment_main(VertexOut in [[stage_in]]) {
//    return in.color;
//}


// 渲染 点
struct VertexOut {
    float4 position [[position]];
    float4 color;
    float pointSize [[point_size]];
};

vertex
VertexOut vertex_main(VertexIn in [[stage_in]],
                      constant float &timer [[buffer(11)]] ) {
//    in.position.y += timer;
    VertexOut out {
        .position = in.position,
        .color = in.color,
        .pointSize = 30
    };
    return out;
}

fragment
float4 fragment_main(VertexOut in [[stage_in]]) {
    return in.color;
}

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
#import "Common.h"

struct VertexOut {
  float4 position [[position]];
};

//fragment float4 fragment_main(VertexOut in [[stage_in]])
//{
//    float color;
//    in.position.x < 200 ? color = 0 : color = 1;
//    return float4(color, color, color, 1.0);
////  return float4(0.2, 0.5, 1.0, 1);
//}

fragment float4 fragment_main(
                              constant Params &params [[buffer(12)]],
                              VertexOut in [[stage_in]])
{
    
// MARK: - Step
//    float color;
////    in.position.x < params.width * 0.5 ? color = 0 : color = 1;
//    color = step(params.width * 0.5, in.position.x);
//    return float4(color, color, color, 1.0);
    
//    // 黑白棋盘
//    uint checks = 8;
//    // 1 UV坐标 归一化，中心点为0.5 , 0.5 左上角为0.0, 0.0
//    float2 uv = in.position.xy / params.width;
//    // 2 fract(x) 返回x的小数部分。将UV的值 * 棋盘数量的一半 ，得到一个 0 ~ 1的值，然后减去0.5， 让一般小于 0
//    uv = fract(uv * checks * 0.5) - 0.5;
//    // 3 xy 乘法结果小于0 则为白色， 大于0 为黑色
//    float3 color = step(uv.x * uv.y, 0.0);
    //  return float4(color, 1.0);
    
    
// MARK: - Length
    
//    float center = 0.5;
//    float radius = 0.2;
//    float2 uv = in.position.xy / params.width - center;
//    float3 color = step(length(uv), radius);
//     return float4(color, 1.0);

// MARK: - smoothStep
    
//    
//    float color = smoothstep(0, params.width, in.position.x);
//    return float4(color, color, color, 1);
    
    // MARK: - mix
    // mix(x, y, a) 等同于 x + (y - x) * a
//    float3 red = float3(1.0 , 0.0, 0.0);
//    float3 blue = float3(0.0, 0.0, 1.0);
//    float3 color = mix(red, blue, 0.6);
//    return float4(color, 1.0);
    
    // mix 与 smoothstep
//    float3 red = float3(1.0 , 0.0, 0.0);
//    float3 blue = float3(0.0, 0.0, 1.0);
//    float result = smoothstep(0, params.width, in.position.x);
//    float3 color = mix(red, blue, result);
//    return float4(color, 1.0);
    
    // MARK: - Normalize
//    return in.position;
    
    float3 color = normalize(in.position.xyz);
    return float4(color, 1.0);
}
                            

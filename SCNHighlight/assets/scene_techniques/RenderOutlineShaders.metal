//
//  RenderOutlineShades.metal
//  scape-ar-project
//
//  Created by Alberto Taiuti on 16/05/2019.
//  Copyright © 2019 Alberto Taiuti. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include <SceneKit/scn_metal>

struct custom_node_t3 {
  float4x4 modelTransform;
  float4x4 modelViewTransform;
  float4x4 normalTransform;
  float4x4 modelViewProjectionTransform;
};

struct custom_vertex_t
{
  float4 position [[attribute(SCNVertexSemanticPosition)]];
  float4 normal [[attribute(SCNVertexSemanticNormal)]];
};

struct out_vertex_t
{
  float4 position [[position]];
  float2 uv;
};


vertex out_vertex_t mask_vertex(custom_vertex_t in [[stage_in]],
                                constant custom_node_t3& scn_node [[buffer(0)]])
{
  out_vertex_t out;
  out.position = scn_node.modelViewProjectionTransform * float4(in.position.xyz, 1.0);
  return out;
};

fragment half4 mask_fragment(out_vertex_t in [[stage_in]])
{
  return half4(1.0);
};


constexpr sampler s = sampler(coord::normalized,
                              r_address::clamp_to_edge,
                              t_address::clamp_to_edge,
                              filter::linear);

vertex out_vertex_t combine_vertex(custom_vertex_t in [[stage_in]])
{
  out_vertex_t out;
  out.position = in.position;
  out.uv = float2( (in.position.x + 1.0) * 0.5, 1.0 - (in.position.y + 1.0) * 0.5 );
  return out;
};


fragment half4 combine_fragment(out_vertex_t vert [[stage_in]],
                                texture2d<float, access::sample> colorSampler [[texture(0)]],
                                texture2d<float, access::sample> maskSampler [[texture(1)]])
{
  
  float4 FragmentColor = colorSampler.sample( s, vert.uv);
  float4 maskColor = maskSampler.sample(s, vert.uv);
  
  if ( maskColor.g >= 1.0 ) {
    return half4(FragmentColor);
  }
  
  float3 glowColor = float3(1.0, 1.0, 0.0);
  
  float alpha = maskColor.r;
  if (alpha > 0.0) {
    alpha = 1;
  }
  float3 out = FragmentColor.rgb * ( 1.0 - alpha ) + alpha * glowColor;
  return half4( float4(out.rgb, 1.0) );
  
}

///// Blur //////

vertex out_vertex_t blur_vertex(custom_vertex_t in [[stage_in]])
{
  out_vertex_t out;
  out.position = in.position;
  out.uv = float2( (in.position.x + 1.0) * 0.5, 1.0 - (in.position.y + 1.0) * 0.5 );
  return out;
};

// http://rastergrid.com/blog/2010/09/efficient-gaussian-blur-with-linear-sampling/
constant float offset[] = { 0.0, 1.0, 2.0, 3.0, 4.0 };
constant float weight[] = { 0.2270270270, 0.1945945946, 0.1216216216, 0.0540540541, 0.0162162162 };
constant float bufferSize = 512.0;

fragment half4 blur_fragment_h(out_vertex_t vert [[stage_in]],
                               texture2d<float, access::sample> maskSampler [[texture(0)]])
{
  
  float4 FragmentColor = maskSampler.sample( s, vert.uv);
  float FragmentR = FragmentColor.r * weight[0];
  
  
  for (int i=1; i<5; i++) {
    FragmentR += maskSampler.sample( s, ( vert.uv + float2(offset[i], 0.0)/bufferSize ) ).r * weight[i];
    FragmentR += maskSampler.sample( s, ( vert.uv - float2(offset[i], 0.0)/bufferSize ) ).r * weight[i];
  }
  return half4(FragmentR, FragmentColor.g, FragmentColor.b, 1.0);
}

fragment half4 blur_fragment_v(out_vertex_t vert [[stage_in]],
                               texture2d<float, access::sample> maskSampler [[texture(0)]])
{
  
  float4 FragmentColor = maskSampler.sample( s, vert.uv);
  float FragmentR = FragmentColor.r * weight[0];
  
  for (int i=1; i<5; i++) {
    FragmentR += maskSampler.sample( s, ( vert.uv + float2(0.0, offset[i])/bufferSize ) ).r * weight[i];
    FragmentR += maskSampler.sample( s, ( vert.uv - float2(0.0, offset[i])/bufferSize ) ).r * weight[i];
  }
  
  return half4(FragmentR, FragmentColor.g, FragmentColor.b, 1.0);
  
};

shader_type spatial;

#include "res://addons/zylann.voxel/shaders/transvoxel.gdshaderinc"
#include "res://addons/zylann.voxel/shaders/virtual_texturing.gdshaderinc"
#include "res://addons/zylann.voxel/shaders/triplanar.gdshaderinc"
#include "res://addons/zylann.voxel/shaders/lod_fade.gdshaderinc"

uniform sampler2D u_texture_top : source_color;
uniform sampler2D top_normal_map;

uniform float layer_depth = 32.0;
uniform int num_depth_textures = 0;
uniform sampler2D[8] depth_textures;
uniform sampler2D[8] depth_normal_maps;
uniform float normal_strength = 1.0;

varying vec3 v_world_pos;
varying vec3 v_vertex_pos_model;


void vertex() {
  VERTEX = get_transvoxel_position(VERTEX, CUSTOM0);
  v_vertex_pos_model = VERTEX;

  v_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
  // float nm_factor = clamp(0.5 + 0.5 * (4.0 * sin(TIME * 2.0)), 0.0, 1.0);
  // NORMAL = mix(NORMAL, get_voxel_normal_view(NORMAL, VIEW_MATRIX * MODEL_MATRIX), nm_factor);
  NORMAL = get_voxel_normal_view(v_vertex_pos_model, NORMAL, VIEW_MATRIX * MODEL_MATRIX);

  vec3 normal = (INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
  vec3 wpos = v_world_pos * 0.2;

  float topness_midlevel = 0.5;
  float topness_smoothness = 0.04;
  float topness_min = topness_midlevel - topness_smoothness;
  float topness_max = topness_midlevel + topness_smoothness;
  float topness = smoothstep(topness_min, topness_max, normal.y);

  float triplanar_sharpness = 8.0;
  vec3 blending = get_triplanar_blend(normal, triplanar_sharpness);

  vec3 detail_normal = vec3(0.0);

  int depth_layer = int(clamp(floor(-v_world_pos.y / layer_depth), 0.0, float(num_depth_textures - 1)));
  if (v_world_pos.y > -1.0) {
    vec3 top_col = texture_triplanar(u_texture_top, wpos, blending).rgb;
    vec3 side_col = texture_triplanar(depth_textures[depth_layer], wpos, blending).rgb;

    float r = top_col.r;
    ALBEDO = mix(side_col, top_col, topness);
    
    vec3 top_normal = texture_triplanar(top_normal_map, wpos, blending).rgb * 2.0 - 1.0;
    vec3 side_normal = texture_triplanar(depth_normal_maps[depth_layer], wpos, blending).rgb * 2.0 - 1.0;
    detail_normal = mix(side_normal, top_normal, topness);
  } else {
    ALBEDO = texture_triplanar(depth_textures[depth_layer], wpos, blending).rgb;
    detail_normal = texture_triplanar(depth_normal_maps[depth_layer], wpos, blending).rgb * 2.0 - 1.0;
  }

  // Transform detail normal from triplanar tangent space to world space
  vec3 world_normal = normalize(normal);
  vec3 tangent, bitangent;
	
	detail_normal.xy *= normal_strength;
	detail_normal.z = sqrt(1.0 - clamp(dot(detail_normal.xy, detail_normal.xy), 0.0, 1.0));

  // Create tangent space basis from world normal
  if (abs(world_normal.y) < 0.999) {
    tangent = normalize(cross(world_normal, vec3(0.0, 1.0, 0.0)));
  } else {
    tangent = normalize(cross(world_normal, vec3(1.0, 0.0, 0.0)));
  }
  bitangent = cross(world_normal, tangent);
  
  // Transform detail normal to world space
  vec3 world_detail_normal = normalize(
    detail_normal.x * tangent + 
    detail_normal.y * bitangent + 
    detail_normal.z * world_normal
  );
  
  // Blend with surface normal and transform back to view space
  vec3 final_world_normal = normalize(mix(world_normal, world_detail_normal, 0.5));
  NORMAL = (VIEW_MATRIX * vec4(final_world_normal, 0.0)).xyz;


  // Discard has to be last to workaround https://github.com/godotengine/godot/issues/34966
  if (get_lod_fade_discard(SCREEN_UV)) {
    discard;
  }
}

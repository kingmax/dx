#include "../LightingModes/Common.fxh"

// Resources
cbuffer CBufferPerFrame
{
	float4 AmbientColor : AMBIENT <
		string UIName = "Amibent Color";
		string UIWidget = "Color";
	> = {1.0f, 1.0f, 1.0f, 1.0f};
	
	float4 EnvColor : COLOR <
		string UIName = "Environment Color";
		string UIWidget = "Color";
	> = {1.0f, 1.0f, 1.0f, 1.0f};
	
	float3 CameraPosition : CAMERAPOSITION < string UIWidget = "None"; >;
}

cbuffer CBufferPerObject
{
	float4x4 WorldViewProjection : WORLDVIEWPROJECTION < string UIWidget = "None"; >;
	float4x4 World : WORLD < string UIWidget = "None"; >;
	float ReflectionAmount <
		string UIName = "Reflection Amount";
		string UIWidget = "slider";
		float UIMin = 0.0f;
		float UIMax = 1.0f;
		float UIStep = 0.05f;
	> = {0.5f};
};

Texture2D ColorTexture <
	string ResourceName = "default_color.dds";
	string UIName = "Color Texture";
	string ResourceType = "2D";
>;

TextureCube EnvironmentMap <
	string UIName = "Environment Map";
	string ResourceType = "3D";
>;

SamplerState TrilinearSampler { Filter = MIN_MAG_MIP_LINEAR; };

RasterizerState DisableCulling { CullMode = NONE; };

// Data Structures
struct VS_INPUT
{
	float4 ObjectPosition : POSITION;
	float3 Normal : NORMAL;
	float2 TextureCoordinate : TEXCOORD;
};

struct VS_OUTPUT
{
	float4 Position : SV_Position;
	float2 TextureCoordinate : TEXCOORD0;
	float3 ReflectionVector : TEXCOORD1;
};

// Vertex Shader
VS_OUTPUT vertex_shader(VS_INPUT IN)
{
	VS_OUTPUT OUT = (VS_OUTPUT)0;
	
	OUT.Position = mul(IN.ObjectPosition, WorldViewProjection);
	OUT.TextureCoordinate = get_corrected_texture_coordinate(IN.TextureCoordinate);
	
	float3 worldPosition = mul(IN.ObjectPosition, World).xyz;
	float3 incident = normalize(worldPosition - CameraPosition);
	float3 normal = normalize(mul(float4(IN.Normal, 0), World).xyz);
	
	// Reflection Vector for CubeMap: R = I - 2 * N * (I dot N)
	// Here, I is the incident vector and N is the surface normal.
	OUT.ReflectionVector = reflect(incident, normal);
	
	return OUT;
}

// Pixel Shader
float4 pixel_shader(VS_OUTPUT IN) : SV_Target
{
	float4 OUT = (float4)0;
	
	float4 color = ColorTexture.Sample(TrilinearSampler, IN.TextureCoordinate);
	float3 ambient = get_vector_color_contribution(AmbientColor, color.rgb);
	float3 environment = EnvironmentMap.Sample(TrilinearSampler, IN.ReflectionVector).rgb;
	float3 reflection = get_vector_color_contribution(EnvColor, environment);
	
	// Linear Interpolation = x * (1 - s) + (y * s), s range is [0.0, 1.0]
	// ColorFinal = ambient * (1 – ReflectionAmount) + (reflection * ReflectionAmount)
	OUT.rgb = lerp(ambient, reflection, ReflectionAmount);
	
	return OUT;
}

// Techniques
technique10 main10
{
	pass p0
	{
		SetVertexShader(CompileShader(vs_4_0, vertex_shader()));
		SetGeometryShader(NULL);
		SetPixelShader(CompileShader(ps_4_0, pixel_shader()));
		SetRasterizerState(DisableCulling);
	}
}

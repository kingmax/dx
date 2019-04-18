#include "Common.fxh"

// Resources
cbuffer CBufferPerFrame
{
	float4 AmbientColor : AMBIENT <
		string UIName = "Ambient Color";
		string UIWidget = "Color";
	> = {0.07f, 0.07f, 0.07f, 0.07f};
	
	float4 LightColor : COLOR <
		string Object = "LightColor0";
		string UIName = "Light Color";
		string UIWidget = "Color";
	> = {1.0f, 1.0f, 1.0f, 1.0f};
	
	float3 LightDirection : DIRECTION <
		string Object = "DirectionalLight0";
		string UIName = "Light Direction";
		string Space = "World";
	> = {0.0f, 0.0f, -1.0f};
	
	float3 CameraPosition : CAMERAPOSITION <string UIWidget = "None";>;
};

cbuffer CBufferPerObject
{
	float4x4 WorldViewProjection : WORLDVIEWPROJECTION <string UIWidget="None";>;
	
	float4x4 World : WORLD <string UIWidget="None";>;
	
	float4 SpecularColor : SPECULAR <
		string UIName = "Specular Color";
		string UIWidget = "Color";
	> = {1.0f, 1.0f, 1.0f, 1.0f};
	
	float SpecularPower : SPECULARPOWER <
		string UIName = "Specular Power";
		string UIWidget = "slider";
		float UIMin = 1.0f;
		float UIMax = 255.0f;
		float UIStep = 1.0f;
	> = {25.0f};
};

Texture2D ColorTexture <
	string ResourceName = "default_color.dds";
	string UIName = "Color Texture";
	string UIType = "2D";
>;

SamplerState ColorSampler
{
	Filter = MIN_MAG_MIP_LINEAR;
	AddressU = WRAP;
	AddressV = WRAP;
};

RasterizerState DisableCulling
{
	CullMode = NONE;
};

// Data Structures
struct VS_INPUT
{
	float4 ObjectPosition : POSITION;
	float2 TextureCoordinate : TEXCOORD;
	float3 Normal : NORMAL;
};

struct VS_OUTPUT
{
	float4 Position : SV_Position;
	float3 Normal : NORMAL;
	float2 TextureCoordinate : TEXCOORD0;
	float3 LightDirection : TEXCOORD1;
	float3 ViewDirection : TEXCOORD2;
};

// Vertex Shader
VS_OUTPUT vertex_shader(VS_INPUT IN)
{
	VS_OUTPUT OUT = (VS_OUTPUT)0;
	OUT.Position = mul(IN.ObjectPosition, WorldViewProjection);
	OUT.Normal = normalize(mul(float4(IN.Normal, 0), World).xyz);
	OUT.TextureCoordinate = get_corrected_texture_coordinate(IN.TextureCoordinate);
	OUT.LightDirection = normalize(-LightDirection);
	float3 worldPosition = mul(IN.ObjectPosition, World).xyz;
	OUT.ViewDirection = normalize(CameraPosition - worldPosition);
	return OUT;
}

// Pixel Shader
float4 pixel_shader(VS_OUTPUT IN) : SV_Target
{
	float4 OUT = (float4)0;
	
	float3 normal = normalize(IN.Normal);
	float3 lightDir = normalize(IN.LightDirection);
	float3 viewDir = normalize(IN.ViewDirection);
	float N_dot_L = dot(normal, lightDir);
	
	float4 color = ColorTexture.Sample(ColorSampler, IN.TextureCoordinate);
	float3 ambient = AmbientColor.rgb * AmbientColor.a * color.rgb;
	
	float3 diffuse = (float3)0;
	float3 specular = (float3)0;
	
	if(N_dot_L > 0)
	{
		diffuse = LightColor.rgb * LightColor.a * N_dot_L * color.rgb;
		
		/*
			Phong Lighting Model::
			SpecularPhong = (R dot V)^s
			R is the reflection vector:
			R = 2 * (N dot L) * N - L
			V is the view direction
			s specifies the size of the highlight
		*/
		float3 reflectionDir = normalize(2 * N_dot_L * normal - lightDir);
		float R_dot_V = dot(reflectionDir, viewDir);
		float S = pow(saturate(R_dot_V), SpecularPower); // saturate ref: http://developer.download.nvidia.com/cg/saturate.html
		specular = SpecularColor.rgb * SpecularColor.a * min(S, color.w);
	}
	
	OUT.rgb = ambient + diffuse + specular;
	OUT.a = 1.0f; //color.a;
	
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
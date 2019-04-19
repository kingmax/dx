#include "Common.fxh"

cbuffer CBufferPerFrame
{
	float4 AmbientColor : AMBIENT <
		string UIName = "Ambient Color";
		string UIWidget = "COLOR";
	> = {0.1f, 0.1f, 0.1f, 0.1f};
	
	float4 LightColor : COLOR <
		string UIName = "SpotLight Color";
		string UIWidget = "Color";
		string Object = "LightColor0";
	> = {1.0f, 1.0f, 1.0f, 1.0f};
	
	float3 LightPosition : POSITION <
		string UIName = "SpotLight Position";
		string Object = "SpotLightPosition0";
		string Space = "World";
	> = {0, 0, 0};
	
	float3 LightLookAt : DIRECTION <
		string UIName = "SpotLight Direction";
		string Object = "SpotLightDirection0";
		string Space = "World";
	> = {0, 0, -1.0f};
	
	float LightRadius <
		string UIName = "SpotLight Radius";
		string UIWidget = "slider";
		float UIMin = 0.0f;
		float UIMax = 100.0f;
		float UIStep = 1.0f;
	> = {10.0f};
	
	float SpotLightInnerAngle <
		string UIName = "SpotLight Inner Angle";
		string UIWidget = "slider";
		float UIMin = 0.5f;
		float UIMax = 1.0f;
		float UIStep = 0.01f;
	> = {0.75f};
	
	float SpotLightOuterAngle <
		string UIName = "SpotLight Outer Angle";
		string UIWidget = "slider";
		float UIMax = 0.5f;
		float UIMin = 0.0f;
		float UIStep = 0.01f;
	> = {0.25f};
	
	float3 CameraPosition : CAMERAPOSITION < string UIWidget = "None"; >;
};

cbuffer CBufferPerObject
{
	float4x4 WorldViewProjection : WORLDVIEWPROJECTION < string UIWidget = "None"; >;
	float4x4 World : WORLD < string UIWidget = "None"; >;
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
	> = {25.f};
};

Texture2D ColorTexture <
	string UIName = "Color Texture";
	string ResourceName = "default_color.dds";
	string ResourceType = "2D";
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

struct VS_INPUT
{
	float4 ObjectPosition : POSITION;
	float3 Normal : NORMAL;
	float2 TextureCoordinate : TEXCOORD;
};

struct VS_OUTPUT
{
	float4 Position : SV_Position;
	float3 Normal : NORMAL;
	float2 TextureCoordinate : TEXCOORD0;
	float3 WorldPosition : TEXCOORD1;
	float Attenuation : TEXCOORD2;
	float3 LightLookAt : TEXCOORD3;
};

//
VS_OUTPUT vertex_shader(VS_INPUT IN)
{
	VS_OUTPUT OUT = (VS_OUTPUT)0;
	
	OUT.Position = mul(IN.ObjectPosition, WorldViewProjection);
	OUT.Normal = normalize(mul(float4(IN.Normal, 0), World).xyz);
	OUT.TextureCoordinate = get_corrected_texture_coordinate(IN.TextureCoordinate);
	OUT.WorldPosition = mul(IN.ObjectPosition, World).xyz;
	OUT.Attenuation = saturate(1.0f - length(LightPosition-OUT.WorldPosition) / LightRadius);
	OUT.LightLookAt = -LightLookAt;
	
	return OUT;
}

//
float4 pixel_shader(VS_OUTPUT IN) : SV_Target
{
	float4 OUT = (float4)0;
	float4 color = ColorTexture.Sample(ColorSampler, IN.TextureCoordinate);
	float3 ambient = get_vector_color_contribution(AmbientColor, color.rgb);
	float3 diffuse = (float3)0;
	float3 specular = (float3)0;
	
	float3 lightDir = normalize(LightPosition - IN.WorldPosition);
	float3 viewDir = normalize(CameraPosition - IN.WorldPosition);
	float3 normal = normalize(IN.Normal);
	float3 halfVec = normalize(lightDir + viewDir);
	float N_dot_L = dot(normal, lightDir);
	float N_dot_H = dot(normal, halfVec);
	float3 lightLookAt = normalize(IN.LightLookAt);
	
	float4 lightCoefficients = lit(N_dot_L, N_dot_H, SpecularPower);
	diffuse = get_vector_color_contribution(LightColor, lightCoefficients.y * color.rgb) * IN.Attenuation;
	specular = get_scalar_color_contribution(SpecularColor, min(lightCoefficients.z, color.w)) * IN.Attenuation;
	
	float spotFactor = 0.0f;
	float lightAngle = dot(lightLookAt, lightDir);
	if(lightAngle > 0.0f)
	{
		spotFactor = smoothstep(SpotLightOuterAngle, SpotLightInnerAngle, lightAngle);
	}
	
	OUT.rgb = ambient + (diffuse + specular)*spotFactor;
	OUT.a = 1.0f;
	
	return OUT;
}

//
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
#include "Common.fxh"

// Resouces
cbuffer CBufferPerFrame
{
	float4 AmbientColor : AMBIENT <
		string UIName = "Ambient Color";
		string UIWidget = "Color";
	> = {0.1f, 0.1f, 0.1f, 0.1f};
	
	float4 LightColor : COLOR <
		string UIName = "Light Color";
		string UIWidget = "Color";
		string Object = "LightColor0";
	> = {1.0f, 1.0f, 1.0f, 1.0f};
	
	float3 LightDirection : DIRECTION <
		string UIName = "Light Direction";
		string Object = "DirectionalLight0";
		string Space = "World";
	> = {0.0f, 0.0f, -1.0f};
	
	float3 CameraPosition : CAMERAPOSITION <
		string UIWidget = "None";
	>;
};

cbuffer CBufferPerObject
{
	float4x4 WorldViewProjection : WORLDVIEWPROJECTION <
		string UIWidget = "None";
	>;
	
	float4x4 World : WORLD <
		string UIWidget = "None";
	>;
	
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
	CullMode = None;
};

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
	float3 Normal : NORMAL;
	float2 TextureCoordinate : TEXCOORD0;
	float3 LightDirection : TEXCOORD1;
	float3 ViewDirection  : TEXCOORD2;
};

// Vertex shader
VS_OUTPUT vertex_shader(VS_INPUT IN)
{
	VS_OUTPUT OUT = (VS_OUTPUT)0;
	OUT.Position = mul(IN.ObjectPosition, WorldViewProjection);
	OUT.Normal = normalize(mul(float4(IN.Normal, 0), World).xyz);
	OUT.TextureCoordinate = get_corrected_texture_coordinate(IN.TextureCoordinate);
	OUT.LightDirection = normalize(-LightDirection);
	OUT.ViewDirection = normalize(CameraPosition - mul(IN.ObjectPosition, World).xyz);
	return OUT;
}

// Pixel shader using lit compute
float4 pixel_shader(VS_OUTPUT IN) : SV_Target
{
	float4 OUT = (float4)0;
	
	float4 color = ColorTexture.Sample(ColorSampler, IN.TextureCoordinate);
	float3 ambient = (float3)0;
	float3 diffuse = (float3)0;
	float3 specular = (float3)0;
	
	float3 normal = normalize(IN.Normal);
	float3 light = normalize(IN.LightDirection);
	float N_dot_L = dot(normal, light);
	
	float3 view = normalize(IN.ViewDirection);
	float3 halfVec = normalize(light + view);
	float N_dot_H = dot(normal, halfVec);
	
	// 	using lit intrinsic
	/*
		The lit() intrinsic performs the same diffuse and
		specular calculations and returns coefficients for these terms in a float4. The x and w components of the
		returned vector are always 1. The diffuse coefficient is stored in the y component and specular in z
	*/
	float4 lightCoefficients = lit(N_dot_L, N_dot_H, SpecularPower);
	ambient = get_vector_color_contribution(AmbientColor, color.rgb);
	diffuse = get_vector_color_contribution(LightColor, color.rgb * lightCoefficients.y);
	specular = get_scalar_color_contribution(SpecularColor, min(lightCoefficients.z, color.w));
	
	//float3 ambient = AmbientColor.rgb * AmbientColor.a * color.rgb;
	/*
	if(N_dot_L > 0) // check if light face to the surface
	{
		diffuse = LightColor.rgb * LightColor.a * saturate(N_dotL) * color.rgb;
		specular = SpecularColor.rgb * SpecularColor.a * min(pow(saturate(N_dot_H), SpecularPower), color.w); //glow map in color.alpha
	}
	*/
	
	OUT.rgb = ambient + diffuse + specular;
	OUT.a = 1.0f;
	
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
#include "../LightingModes/Common.fxh"

/*
When displacing a vertex, you do so either inward or outward along its normal, with the
magnitude sampled from the displacement map. For outward displacement, you use the
following equation:

Position = Position0 + (Normal * Scale * DisplacementMagnitude)

Here, Scale is a shader constant that scales the magnitudes stored within the displacement
map. For inward displacement, the equation is rewritten as:

Position = Position0 + (Normal * Scale * DisplacementMagnitude - 1)
*/

cbuffer CBufferPerFrame
{
	float4 AmbientColor : AMBIENT <
		string UIName = "Ambient Light";
		string UIWidget = "Color";
	> = {1.0f, 1.0f, 1.0f, 1.0f};
	
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
	> = {25.0f};
	
	float DisplacementScale <
		string UIName = "Displacement Scale";
		string UIWidget = "slider";
		float UIMin = 0.0f;
		float UIMax = 2.0f;
		float UIStep = 0.01;
	> = {0.0f};
};

Texture2D ColorTexture <
	string ResourceName = "default_color.dds";
	string UIName = "Color Texture";
	string ResourceType = "2D";
>;

Texture2D NormalMap <
	string ResourceName = "default_bump_normal.dds";
	string UIName = "Normal Map";
	string ResourceType = "2D";
>;

Texture2D DisplacementMap <
	string UIName = "Displacement Map";
	string ResourceType = "2D";
>;

SamplerState TrilinearSampler
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
	float2 TextureCoordinate : TEXCOORD;
	float3 Normal : NORMAL;
	float3 Tangent : TANGENT;
};

struct VS_OUTPUT
{
	float4 Position : SV_Position;
	float3 Normal : NORMAL;
	float3 Tangent : TANGENT;
	float3 Binormal : BINORMAL;
	float2 TextureCoordinate : TEXCOORD0;
	float3 LightDirection : TEXCOORD1;
	float3 ViewDirection : TEXCOORD2;
};

VS_OUTPUT vertex_shader(VS_INPUT IN)
{
	VS_OUTPUT OUT = (VS_OUTPUT)0;
	
	OUT.TextureCoordinate = get_corrected_texture_coordinate(IN.TextureCoordinate);
	if(DisplacementScale > 0.0f)
	{
		float displacement = DisplacementMap.SampleLevel(TrilinearSampler, OUT.TextureCoordinate, 0);
		IN.ObjectPosition.xyz += IN.Normal * DisplacementScale * (displacement - 1);
	}
	
	OUT.Position = mul(IN.ObjectPosition, WorldViewProjection);
	OUT.Normal = normalize(mul(float4(IN.Normal, 0), World).xyz);
	OUT.Tangent = normalize(mul(float4(IN.Tangent, 0), World).xyz);
	OUT.Binormal = cross(OUT.Normal, OUT.Tangent);
	
	float3 worldPosition = mul(IN.ObjectPosition, World).xyz;
	float3 viewDirection = CameraPosition - worldPosition;
	OUT.ViewDirection = normalize(viewDirection);
	
	OUT.LightDirection = normalize(-LightDirection);
	//OUT.LightDirection = get_light_data(LightPosition, worldPosition, LightRadius); //normalize(-LightDirection);
	
	return OUT;
}

float4 pixel_shader(VS_OUTPUT IN) : SV_Target
{
	float4 OUT = (float4)0;
	
	// Map normal from [0..1] to [-1..1]
	float3 sampledNormal = 2 * NormalMap.Sample(TrilinearSampler, IN.TextureCoordinate).xyz - 1.0;
	float3x3 tbn = float3x3(IN.Tangent, IN.Binormal, IN.Normal);
	// Transform normal to world space
	sampledNormal = mul(sampledNormal, tbn);
	
	float3 viewDirection = normalize(IN.ViewDirection);
	float4 color = ColorTexture.Sample(TrilinearSampler, IN.TextureCoordinate);
	float3 ambient = get_vector_color_contribution(AmbientColor, color.rgb);
	
	LIGHT_CONTRIBUTION_DATA lightContributionData;
	lightContributionData.Color = color;
	lightContributionData.Normal = sampledNormal;
	lightContributionData.ViewDirection = viewDirection;
	lightContributionData.LightDirection = float4(IN.LightDirection, 1);
	lightContributionData.SpecularColor = SpecularColor;
	lightContributionData.SpecularPower = SpecularPower;
	lightContributionData.LightColor = LightColor;
	float3 light_contribution = get_light_contribution
	(lightContributionData);
	OUT.rgb = ambient + light_contribution;
	OUT.a = 1.0f;
	
	return OUT;
}

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

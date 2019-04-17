/*

% Description of my shader.
% Second line of description for my shader.

keywords: material classic

date: YYMMDD

*/

/* DX9
float4x4 WorldViewProj : WorldViewProjection;

float4 mainVS(float3 pos : POSITION) : POSITION{
	return mul(float4(pos.xyz, 1.0), WorldViewProj);
}

float4 mainPS() : COLOR {
	return float4(1.0, 1.0, 1.0, 1.0);
}

technique technique0 {
	pass p0 {
		CullMode = None;
		VertexShader = compile vs_3_0 mainVS();
		PixelShader = compile ps_3_0 mainPS();
	}
}
*/

// DX10
cbuffer CBufferPerObject
{
	//float4x4 WorldViewProjection : WORLDVIEWPROJECTION;
	float4x4 WVP : WORLDVIEWPROJECTION;
}

RasterizerState DisableCulling
{
	CullMode = NONE;
};

float4 vertex_shader(float3 pos : POSITION) : SV_Position
{
	return mul(float4(pos, 1), WVP);
}

float4 pixel_shader() : SV_Target
{
	return float4(1, 1, 0, 1);
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
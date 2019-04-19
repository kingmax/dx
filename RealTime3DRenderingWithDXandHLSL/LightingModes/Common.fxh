#ifndef _COMMON_FXH_
#define _COMMON_FXH_

/************* Constants *************/

#define FLIP_TEXTURE_Y 1


/************* Data Structures *************/

struct POINT_LIGHT
{
	float3 Position;
	float LightRadius;
	float4 Color;
};

struct LIGHT_CONTRIBUTION_DATA
{
	float4 Color;
	float3 Normal;
	float3 ViewDirection;
	float4 LightColor;
	float4 LightDirection;
	float4 SpecularColor;
	float SpecularPower;
};


/************* Utility Functions *************/

float2 get_corrected_texture_coordinate(float2 textureCoordinate)
{
	#if FLIP_TEXTURE_Y
		return float2(textureCoordinate.x, 1.0f - textureCoordinate.y);
	#else
		return textureCoordinate;
	#endif
}

float3 get_vector_color_contribution(float4 light, float3 color)
{
	// Color (.rgb) * Intensity (.a)
	return light.rgb * light.a * color;
}

float3 get_scalar_color_contribution(float4 light, float color)
{
	// Color (.rgb) * Intensity (.a)
	return light.rgb * light.a * color;
}

float4 get_light_data(float3 lightPosition, float3 worldPosition, float lightRadius)
{
	float4 lightData;
	float3 lightDirection = lightPosition - worldPosition;

	lightData.xyz = normalize(lightDirection);
	lightData.w = saturate(1.0f - length(lightDirection) / lightRadius); // Attenuation

	return lightData;
}

float3 get_light_contribution(LIGHT_CONTRIBUTION_DATA IN)
{
	float3 lightDirection = IN.LightDirection.xyz;
	float3 halfVector = normalize(lightDirection + IN.ViewDirection);
	float N_dot_L = dot(IN.Normal, lightDirection);
	float N_dot_H = dot(IN.Normal, halfVector);
	
	float4 lightCoefficients = lit(N_dot_L, N_dot_H, IN.SpecularPower);
	
	float3 diffuse = get_vector_color_contribution(IN.LightColor, lightCoefficients.y * IN.Color.rgb) * IN.LightDirection.w;
	float3 specular = get_vector_color_contribution(IN.SpecularColor, min(lightCoefficients.z, IN.Color.w)) * IN.LightDirection.w; // * IN.LightColor.w;
	
	return diffuse + specular;
}



#endif
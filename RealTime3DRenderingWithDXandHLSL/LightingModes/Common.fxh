#ifndef _COMMON_FXH_
#define _COMMON_FXH_

#define FLIP_TEXTURE_Y 1

float2 get_corrected_texture_coordinate(float2 textureCoordinate)
{
	#if FLIP_TEXTURE_Y
		return float2(textureCoordinate.x, 1.0f - textureCoordinate.y);
	#else
		return textureCoordinate;
	#endif
}

#endif
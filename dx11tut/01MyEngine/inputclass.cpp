#include "inputclass.h"

InputClass::InputClass()
{
}

InputClass::~InputClass()
{
}

void InputClass::Initialize()
{
	for (int i = 0; i < 256; i++)
	{
		m_keys[i] = false;
	}
}

void InputClass::KeyUp(unsigned int input)
{
	m_keys[input] = false;
}

void InputClass::KeyDown(unsigned int input)
{
	m_keys[input] = true;
}

bool InputClass::IsKeyDown(unsigned int input)
{
	return m_keys[input];
}


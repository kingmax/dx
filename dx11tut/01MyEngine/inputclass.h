#pragma once

class InputClass
{
public:
	InputClass();
	~InputClass();

	void Initialize();
	void KeyUp(unsigned int);
	void KeyDown(unsigned int);
	bool IsKeyDown(unsigned int);

private:
	bool m_keys[256];
};
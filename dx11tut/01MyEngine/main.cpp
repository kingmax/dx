#include "systemclass.h"

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPreInstance, PSTR psCmdLine, int iCmdShow)
{
	SystemClass* System;
	bool result;

	System = new SystemClass();
	if (!System)
	{
		return 0;
	}

	result = System->Initialize();
	if (result)
	{
		System->Run();
	}

	System->Shutdown();
	delete System;
	System = 0;

	return 0;
}
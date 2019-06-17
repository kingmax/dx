#include <memory>
#include "Game.h"
#include "GameException.h"

#if defined(DEBUG) || defined(_DEBUG)
#define _CRTDBG_MAP_ALLOC
#include <stdlib.h>
#include <crtdbg.h>
#endif

using namespace Library;

int WINAPI WinMain(HINSTANCE instance, HINSTANCE preInstance, LPSTR cmdLine, int showCmd)
{
#if defined(DEBUG) || defined(_DEBUG)
	_CrtSetDbgFlag(_CRTDBG_ALLOC_MEM_DF | _CRTDBG_LEAK_CHECK_DF);
#endif

	std::unique_ptr<Game> game(new Game(instance, L"RenderingClass", L"Real-Time 3D Rendering", showCmd));

	try
	{
		game->Run();
	}
	catch (const GameException& ex)
	{
		MessageBox(game->WindowHandle(), ex.whatw().c_str(), game->WindowTitle().c_str(), MB_ABORTRETRYIGNORE);
	}

	return 0;
}
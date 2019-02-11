// using COM in windows
// ref: https://docs.microsoft.com/zh-cn/windows/desktop/learnwin32/example--the-open-dialog-box

#include <Windows.h>
#include <ShObjIdl.h>

#include <atlbase.h>	// Contains the declaration of CComPtr (Smart Pointer)

int WINAPI wWinMain(HINSTANCE hInstance, HINSTANCE, PWSTR pCmdLine, int nCmdShow)
{
	HREFTYPE hr = CoInitializeEx(NULL, COINIT_APARTMENTTHREADED | COINIT_DISABLE_OLE1DDE);

	if (SUCCEEDED(hr))
	{
		//IFileOpenDialog *pFileOpen;

		CComPtr<IFileOpenDialog> pFileOpen;

		// Create the FileOpenDialog object.
		// hr = CoCreateInstance(CLSID_FileOpenDialog, NULL, CLSCTX_ALL, IID_IFileOpenDialog, reinterpret_cast<void**>(&pFileOpen));
		// hr = CoCreateInstance(__uuidof(FileOpenDialog), NULL, CLSCTX_ALL, __uuidof(pFileOpen), reinterpret_cast<void**>(&pFileOpen));	// using __uuidof

		hr = pFileOpen.CoCreateInstance(__uuidof(FileOpenDialog));	// using SmartPointer CComPtr

		if (SUCCEEDED(hr))
		{
			// Show the Open dialog box.
			hr = pFileOpen->Show(NULL);

			// Get the file name from the dialog box.
			if (SUCCEEDED(hr))
			{
				//IShellItem *pItem;
				CComPtr<IShellItem> pItem;
				hr = pFileOpen->GetResult(&pItem);
				if (SUCCEEDED(hr))
				{
					PWSTR pszFilePath;
					hr = pItem->GetDisplayName(SIGDN_FILESYSPATH, &pszFilePath);

					// Display the file name to the user.
					if (SUCCEEDED(hr))
					{
						MessageBox(NULL, pszFilePath, L"File Path", MB_OK);
						CoTaskMemFree(pszFilePath);
					}
					//pItem->Release();
				}
			}
			// pFileOpen->Release();
		}

		CoUninitialize();
	}

	return 0;
}

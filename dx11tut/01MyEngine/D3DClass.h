#pragma once

#pragma comment(lib, "dxgi.lib")
#pragma comment(lib, "d3d11.lib")
#pragma commnet(lib, "d3dx11.lib")
#pragma commnet(lib, "d3dx10.lib")

#include <dxgi.h>
#include <d3dcommon.h>
#include <d3d11.h>
// #include <d3dx10math.h>
// #include <DirectXMath.h>

/*
	https://github.com/Microsoft/DirectXTK/wiki
	https://github.com/Microsoft/DirectXTK/wiki/Adding-the-DirectX-Tool-Kit
	https://github.com/Microsoft/DirectXTK/wiki/Using-the-SimpleMath-library
	https://github.com/Microsoft/DirectXTK/wiki/SimpleMath
*/

#include <SimpleMath.h>	// install by nuget: Install-Package directxtk_desktop_2015 -Version 2019.2.7.1, https://www.nuget.org/packages/directxtk_desktop_2015
using namespace DirectX::SimpleMath; // https://github.com/Microsoft/DirectXTK/wiki/SimpleMath

class D3DClass
{
public:
	D3DClass();
	~D3DClass();

	bool Initialize(int, int, bool, HWND, bool, float, float);
	void Shutdown();

	void BeginScene(float, float, float, float);
	void EndScene();

	ID3D11Device* GetDevice();
	ID3D11DeviceContext* GetDeviceContext();

	void GetProjectionMatrix(Matrix&);
	void GetWorldMatrix(Matrix&);
	void GetOrthoMatrix(Matrix&);

	void GetVideoCardInfo(char*, int&);

private:
	bool m_vsync_enabled;
	int m_videoCardMemory;
	char m_videoCardDesc[128];
	IDXGISwapChain* m_swapChain;
	ID3D11Device* m_device;
	ID3D11DeviceContext* m_deviceContext;
	ID3D11RenderTargetView* m_renderTargetView;
	ID3D11Texture2D* m_depthStencilBuffer;
	ID3D11DepthStencilState* m_depthStencilState;
	ID3D11DepthStencilView* m_depthStencilView;
	ID3D11RasterizerState* m_rasterState;
	/*
	D3DXMATRIX m_projectionMatrix;
	D3DXMATRIX m_worldMatrix;
	D3DXMATRIX m_orthoMatrix;
	*/
	Matrix m_projectionMatrix;
	Matrix m_worldMatrix;
	Matrix m_orthoMatrix;

};


#include <iostream>
#include <Windows.h>

LRESULT CALLBACK WndProc(HWND hwnd, UINT msg, WPARAM wp, LPARAM lp)
{
	HDC hdc;
	PAINTSTRUCT ps;

	LPCSTR pathLabel = TEXT("Config Path: ");

	switch (msg)
	{
	case WM_DESTROY:
		PostQuitMessage(0);
		return 0;

	case WM_PAINT:
		hdc = BeginPaint(hwnd, &ps);
		TextOut(hdc, 10, 10, pathLabel, lstrlen(pathLabel));
		EndPaint(hwnd, &ps);
		return 0;
	}
	return DefWindowProc(hwnd, msg, wp, lp);
}

int WINAPI WinMain(
	HINSTANCE hInstance,
	HINSTANCE hPrevInstance,
	PSTR lpCmdLine,
	int nCmdShow)
{
	HWND hwnd;
	WNDCLASS winc;
	MSG msg;

	LPCSTR caption = TEXT("Computational ElectroMagnetics");

	winc.style = CS_HREDRAW | CS_VREDRAW;
	winc.lpfnWndProc = WndProc;
	winc.cbClsExtra = winc.cbWndExtra = 0;
	winc.hInstance = hInstance;
	winc.hIcon = LoadIcon(NULL, IDI_APPLICATION);
	winc.hCursor = LoadCursor(NULL, IDC_ARROW);
	winc.hbrBackground = (HBRUSH)GetStockObject(WHITE_BRUSH);
	winc.lpszMenuName = NULL;
	winc.lpszClassName = caption;

	if (!RegisterClass(&winc)) return 0;

	hwnd = CreateWindow(
		caption, caption, WS_OVERLAPPEDWINDOW | WS_VISIBLE,
		CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,
		NULL, NULL, hInstance, NULL);

	if (hwnd == NULL) return 0;

	while (GetMessage(&msg, NULL, 0, 0)) DispatchMessage(&msg);

	return msg.wParam;

	return 0;
}
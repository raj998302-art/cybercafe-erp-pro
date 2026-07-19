#include "runner.h"

#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include <memory>

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  HANDLE snap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  if (snap != INVALID_HANDLE_VALUE) {
    PROCESSENTRY32 pe;
    pe.dwSize = sizeof(PROCESSENTRY32);
    if (Process32First(snap, &pe)) {
      do {
        if (_wcsicmp(pe.szExeFile, L"cybercafe_erp.exe") == 0) {
          if (pe.th32ProcessID != GetCurrentProcessId()) {
            HWND hwnd = FindWindow(L"FLUTTER_RUNNER_WIN32_WINDOW",
                                   L"CyberCafe ERP Pro");
            if (hwnd) {
              SetForegroundWindow(hwnd);
            }
            CloseHandle(snap);
            return 0;
          }
        }
      } while (Process32Next(snap, &pe));
    }
    CloseHandle(snap);
  }

  ::AllocConsole();

  flutter::DartProject project(L"data");
  std::vector<std::string> arguments;
  project.set_dart_entrypoint_arguments(arguments);

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 800);
  if (!window.CreateAndShow(L"CyberCafe ERP Pro", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::FreeConsole();
  return EXIT_SUCCESS;
}

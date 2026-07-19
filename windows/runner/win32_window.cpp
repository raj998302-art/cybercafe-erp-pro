#include "win32_window.h"

#include <dwmapi.h>
#include <flutter_windows.h>

#include "resource.h"

namespace {

constexpr const wchar_t kWindowClassName[] = L"FLUTTER_RUNNER_WIN32_WINDOW";

HWND g_window_handle = nullptr;

int g_current_width = 0;
int g_current_height = 0;

LRESULT CALLBACK WndProc(HWND hwnd, UINT message, WPARAM wparam,
                          LPARAM lparam) {
  if (message == WM_NCCREATE) {
    auto cs = reinterpret_cast<CREATESTRUCT *>(lparam);
    SetWindowLongPtr(hwnd, GWLP_USERDATA,
                      reinterpret_cast<LONG_PTR>(cs->lpCreateParams));
    auto that = static_cast<Win32Window *>(cs->lpCreateParams);
    that->window_handle_ = hwnd;
  } else if (Win32Window *that = GetThisFromHandle(hwnd)) {
    return that->MessageHandler(hwnd, message, wparam, lparam);
  }
  return DefWindowProc(hwnd, message, wparam, lparam);
}

Win32Window *GetThisFromHandle(HWND window) noexcept {
  return reinterpret_cast<Win32Window *>(
      GetWindowLongPtr(window, GWLP_USERDATA));
}

}  // namespace

Win32Window::Win32Window() {}

Win32Window::~Win32Window() { Destroy(); }

bool Win32Window::CreateAndShow(const std::wstring &title, const Point &origin,
                                  const Size &size) {
  destroyed_ = false;
  HICON icon = LoadIcon(GetModuleHandle(nullptr), MAKEINTRESOURCE(IDC_APP_ICON));
  WNDCLASS window_class{};
  window_class.hCursor = LoadCursor(nullptr, IDC_ARROW);
  window_class.lpszClassName = kWindowClassName;
  window_class.style = CS_HREDRAW | CS_VREDRAW;
  window_class.cbClsExtra = 0;
  window_class.cbWndExtra = 0;
  window_class.hInstance = GetModuleHandle(nullptr);
  window_class.hIcon = icon;
  window_class.hbrBackground = 0;
  window_class.lpszMenuName = nullptr;
  window_class.lpfnWndProc = WndProc;
  RegisterClass(&window_class);

  POINT target_point;
  target_point.x = origin.x;
  target_point.y = origin.y;
  HMONITOR monitor = MonitorFromPoint(target_point, MONITOR_DEFAULTTONEAREST);
  UINT dpi = FlutterDesktopGetDpiForMonitor(monitor);
  double scale_factor = dpi / 96.0;
  int scaled_width = static_cast<int>(size.width * scale_factor);
  int scaled_height = static_cast<int>(size.height * scale_factor);

  HWND window = CreateWindow(
      kWindowClassName, title.c_str(),
      WS_OVERLAPPEDWINDOW, origin.x, origin.y, scaled_width,
      scaled_height, nullptr, nullptr, GetModuleHandle(nullptr), this);
  if (!window) return false;
  g_window_handle = window;
  OnCreate();
  ShowWindow(window, SW_SHOWNORMAL);
  UpdateWindow(window);
  return true;
}

void Win32Window::SetQuitOnClose(bool quit_on_close) {
  quit_on_close_ = quit_on_close;
}

bool Win32Window::OnCreate() { return true; }

void Win32Window::OnDestroy() {}

void Win32Window::Destroy() {
  if (destroyed_) return;
  destroyed_ = true;
  if (window_handle_) {
    DestroyWindow(window_handle_);
    window_handle_ = nullptr;
  }
  UnregisterClass(kWindowClassName, nullptr);
}

Win32Window::Size Win32Window::GetClientArea() {
  RECT rect;
  GetClientRect(window_handle_, &rect);
  return {rect.right - rect.left, rect.bottom - rect.top};
}

void Win32Window::SetChildContent(HWND content) {
  SetParent(content, window_handle_);
  RECT frame;
  GetClientRect(window_handle_, &frame);
  MoveWindow(content, frame.left, frame.top, frame.right - frame.left,
             frame.bottom - frame.top, true);
  child_content_ = content;
}

LRESULT Win32Window::MessageHandler(HWND hwnd, UINT message, WPARAM wparam,
                                      LPARAM lparam) noexcept {
  switch (message) {
    case WM_DESTROY: {
      window_handle_ = nullptr;
      OnDestroy();
      if (quit_on_close_) PostQuitMessage(0);
    } break;
    case WM_DPICHANGED: {
      auto newRectSize = reinterpret_cast<RECT *>(lparam);
      LONG newWidth = newRectSize->right - newRectSize->left;
      LONG newHeight = newRectSize->bottom - newRectSize->top;
      SetWindowPos(hwnd, nullptr, newRectSize->left, newRectSize->top,
                    newWidth, newHeight, SWP_NOZORDER | SWP_NOACTIVATE);
    } break;
    case WM_SIZE: {
      RECT rect;
      GetClientRect(hwnd, &rect);
      if (child_content_) {
        MoveWindow(child_content_, rect.left, rect.top,
                    rect.right - rect.left, rect.bottom - rect.top, TRUE);
      }
    } break;
    case WM_ACTIVATE:
      if (child_content_) SetFocus(child_content_);
      break;
  }
  return DefWindowProc(hwnd, message, wparam, lparam);
}

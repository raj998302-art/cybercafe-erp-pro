#ifndef WIN32_WINDOW_H_
#define WIN32_WINDOW_H_

#include <windows.h>

#include <functional>
#include <memory>
#include <string>

class Win32Window {
 public:
  struct Point { unsigned int x; unsigned int y; };
  struct Size { unsigned int width; unsigned int height; };

  Win32Window();
  virtual ~Win32Window();

  bool CreateAndShow(const std::wstring &title, const Point &origin,
                      const Size &size);
  void SetQuitOnClose(bool quit_on_close);
  void Destroy();
  Size GetClientArea();
  void SetChildContent(HWND content);
  HWND GetHandle() { return window_handle_; }

 protected:
  virtual bool OnCreate();
  virtual void OnDestroy();
  virtual LRESULT MessageHandler(HWND window, UINT const message,
                                  WPARAM const wparam,
                                  LPARAM const lparam) noexcept;

 private:
  HWND window_handle_ = nullptr;
  HWND child_content_ = nullptr;
  bool quit_on_close_ = false;
  bool destroyed_ = false;
};

#endif  // WIN32_WINDOW_H_

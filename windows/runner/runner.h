#ifndef RUNNER_H_
#define RUNNER_H_

#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include <memory>
#include <string>

class FlutterWindow : public Win32Window {
 public:
  explicit FlutterWindow(const flutter::DartProject &project);
  ~FlutterWindow();

 protected:
  bool OnCreate() override;
  void OnDestroy() override;
  LRESULT MessageHandler(HWND window, UINT const message,
                         WPARAM const wparam, LPARAM const lparam) noexcept override;

 private:
  flutter::FlutterViewController *flutter_controller_ = nullptr;
  flutter::DartProject project_;
};

#endif  // RUNNER_H_

#include "utils.h"

#include <windows.h>

#include <shlobj.h>
#include <filesystem>

std::string GetExecutableDirectory() {
  wchar_t path[MAX_PATH];
  if (GetModuleFileName(nullptr, path, MAX_PATH) == 0) {
    return "";
  }
  std::filesystem::path p(path);
  return p.parent_path().string();
}

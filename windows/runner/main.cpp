#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);


  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  //set current frame center
  int scrWidth, scrHeight, xShaft, yShaft,mWidth,mHeight;

  scrWidth = GetSystemMetrics(SM_CXSCREEN);
  scrHeight = GetSystemMetrics(SM_CYSCREEN);

    //set current frame size 2/3 screen
  mWidth = scrWidth / 3 * 2;
  mHeight = scrHeight / 3 * 2;

    //center x y
  xShaft = (scrWidth - mWidth) / 2;
  yShaft = (scrHeight - mHeight) / 2;

  FlutterWindow window(project);
  Win32Window::Point origin(xShaft, yShaft);
  Win32Window::Size size(mWidth, mHeight);
  if (!window.CreateAndShow(L"", origin, size)) {
      return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}

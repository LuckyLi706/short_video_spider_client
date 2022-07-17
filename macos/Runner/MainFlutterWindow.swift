import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController.init()

    let screenFrame=NSScreen.screens[0].frame; //获取第一块屏幕的大小
    let scrWidth=screenFrame.size.width
    let scrHeight=screenFrame.size.height
    let windowWidth=scrWidth/3*2
    let windowHeight=scrHeight/3*2
    let pointX=(scrWidth-windowWidth)/2
    let pointY=(scrHeight-windowHeight)/2

    var windowFrame = self.frame
    windowFrame.size.height=windowHeight
    windowFrame.size.width=windowWidth
    windowFrame.origin.x=pointX
    windowFrame.origin.y=pointY
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}

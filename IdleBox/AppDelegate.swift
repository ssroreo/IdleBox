//
//  AppDelegate.swift
//  IdleBox
//
//  Created by chaichengxun on 2021/11/23.
//

import Cocoa
import FinderSync

@main
class AppDelegate: NSObject, NSApplicationDelegate {

//    @IBOutlet var window: NSWindow!
    var mainWC: NSWindowController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
//        if !FIFinderSyncController.isExtensionEnabled {
//            FIFinderSyncController.showExtensionManagementInterface()
//        }
//        NSApplication.shared.terminate(self)
        openPreferences()
    }
    
    func openPreferences() {
        if mainWC == nil {
            let sb = NSStoryboard(name: "SettingsTab", bundle: nil)
            mainWC = (sb.instantiateInitialController() as! NSWindowController)
            mainWC!.window?.delegate = self
        }
        NSApp.activate(ignoringOtherApps: true)
        mainWC?.showWindow(nil)
    }
}

extension AppDelegate: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        guard let window = notification.object as? NSWindow else { return }
        if window === mainWC?.window {
            mainWC = nil
        }
    }
}

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: self)
    }
}

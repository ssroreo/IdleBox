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

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if !FIFinderSyncController.isExtensionEnabled {
            FIFinderSyncController.showExtensionManagementInterface()
        }
        NSApplication.shared.terminate(self)
    }
}


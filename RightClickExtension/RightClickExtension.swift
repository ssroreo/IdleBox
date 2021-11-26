//
//  FinderSync.swift
//  RightClickExtension
//
//  Created by chaichengxun on 2021/11/23.
//

import Cocoa
import FinderSync

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: self)
    }
}

class FinderSync: FIFinderSync {

    override init() {
        super.init()
        NSLog("FinderSync() launched from %@", Bundle.main.bundlePath as NSString)
        FIFinderSyncController.default().directoryURLs = [URL(fileURLWithPath: "/")]
    }
    
    override func menu(for menuKind: FIMenuKind) -> NSMenu {
        let menu = NSMenu()
        let newFile = creatMenuItem(for: .newFile)
        let copyPath = creatMenuItem(for: .copyPath)
        let openTerminal = creatMenuItem(for: .openTerminal)
        let openTerminalTab = creatMenuItem(for: .openTerminalTab)
        let openTerminalInCurrentFolder = creatMenuItem(for: .openTerminalInCurrentFolder)
        
        let newFileSub = NSMenu()
        self.newFileMenus.forEach { (menuItem) in
            newFileSub.addItem(menuItem)
        }
        newFile.submenu = newFileSub
        menu.addItem(newFile)
        menu.addItem(copyPath)
        menu.addItem(openTerminal)
        menu.addItem(openTerminalTab)
        menu.addItem(openTerminalInCurrentFolder)
        return menu
    }
    
    enum MenuItemType {
        case newFile
        case copyPath
        case openTerminalTab
        case openTerminal
        case openTerminalInCurrentFolder
        case custom(title: String,selector: Selector)
    }
    
    func creatMenuItem(for menuType: MenuItemType) -> NSMenuItem {
        switch menuType {
        case .newFile:
            return NSMenuItem(title: "NewFile".localized, action: nil, keyEquivalent: "")
        case .copyPath:
            return NSMenuItem(title: "CopyPath".localized, action: #selector(copyPath(_:)), keyEquivalent: "")
        case .openTerminalTab:
            return NSMenuItem(title: "OpenTerminalOnTab".localized, action: #selector(openTerminalTab(_:)), keyEquivalent: "")
        case .openTerminal:
            return NSMenuItem(title: "OpenTerminal".localized, action: #selector(openTerminal(_:)), keyEquivalent: "")
        case .custom(let title, let selector):
            if title == MenuItemTitle.separator {
                let s = NSMenuItem(title: "————————", action: nil, keyEquivalent: "")
                s.isEnabled = false
                return s
            }else {
                return NSMenuItem(title: title, action: selector, keyEquivalent: "")
            }
        case .openTerminalInCurrentFolder:
            return NSMenuItem(title: "OpenTerminalInCurrentFolder".localized, action: #selector(openTerminalInCurrentFolder(_:)), keyEquivalent: "")
        }
    }
}

extension FinderSync {
    @IBAction func newFile(_ sender: NSMenuItem?) {
        guard let target = FIFinderSyncController.default().targetedURL() else {
            NSLog("Failed to obtain targeted URL: %@")
            return
        }
        var originalPath = target
        let originalFilename = "newfile".localized
        var filename="newfile".localized+"."+getFileType(menuItemTitle: sender?.title)
        let fileType="."+getFileType(menuItemTitle: sender?.title)
        var counter = 1
        
        while FileManager.default.fileExists(atPath: originalPath.appendingPathComponent(filename).path) {
            filename = "\(originalFilename)\(counter)\(fileType)"
            counter+=1
            originalPath = target
        }
        
        do {
            try "".write(to: target.appendingPathComponent(filename), atomically: true, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            NSLog("Failed to create file: %@", error.description as NSString)
        }
    }
    
    @IBAction func newOtherFile(_ sender: NSMenuItem?) {
        guard let target = FIFinderSyncController.default().targetedURL() else {
            NSLog("Failed to obtain targeted URL: %@")
            return
        }
        NSApp.activate(ignoringOtherApps: true)
        DispatchQueue.main.async {
            let savePanel = NSSavePanel()
            savePanel.title = "NewFile".localized
            savePanel.directoryURL = target
            savePanel.canCreateDirectories = true
            savePanel.showsTagField = false
            savePanel.nameFieldStringValue = "newfile".localized
            savePanel.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.modalPanelWindow)))
            if (savePanel.runModal() == NSApplication.ModalResponse.OK){
                do {
                    try "".write(to: target.appendingPathComponent(savePanel.nameFieldStringValue), atomically: true, encoding: String.Encoding.utf8)
                } catch let error as NSError {
                    NSLog("Failed to create file: %@", error.description as NSString)
                }
            }
        }
    }
    
    /// 将要打开的路径
    private var urlsToOpen: [URL] {
        get {
            guard let target = FIFinderSyncController.default().targetedURL() else {
                NSLog("target is nil – attempting to open from an unknown path?")
                return []
            }
            
            guard let items = FIFinderSyncController.default().selectedItemURLs() else {
                NSLog("items is nil – attempting to open from an unknown path?")
                return []
            }
            
            if items.count > 0 {
                return items
            } else {
                return [ target ]
            }
        }
    }
    
    @IBAction func openTerminal(_ sender: NSMenuItem?) {
        let urls = urlsToOpen
        DispatchQueue.main.async {
            let service = "New Terminal at Folder"
            _ = ServiceRunner.run(service: service, withFileURLs: urls)
        }
    }
    
    @IBAction func openTerminalTab(_ sender: NSMenuItem?) {
        let urls = urlsToOpen
        DispatchQueue.main.async {
            let service = "New Terminal Tab at Folder"
            _ = ServiceRunner.run(service: service, withFileURLs: urls)
        }
    }
    
    @IBAction func openTerminalInCurrentFolder(_ sender: NSMenuItem?) {
        guard let target = FIFinderSyncController.default().targetedURL() else {
            NSLog("target is nil – attempting to open from an unknown path?")
            return
        }
        let urls = [target]
        DispatchQueue.main.async {
            let service = "New Terminal Tab at Folder"
            _ = ServiceRunner.run(service: service, withFileURLs: urls)
        }
    }
    
    @IBAction func copyPath(_ sender: NSMenuItem?) {
        let items = FIFinderSyncController.default().selectedItemURLs()
        guard let paths = items else {
            return
        }
        var str: String = ""
        for obj in paths {
            str.append(obj.path)
            str.append("\n")
        }
        
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        let success = pasteboard.setString(str.trimmingCharacters(in: .whitespacesAndNewlines), forType: .string)
        if (!success) {
            NSLog("copy path failed")
        }
    }
}

class ServiceRunner {
    fileprivate static var pasteboard: NSPasteboard = {
        let bundleIdentifier = Bundle.main.bundleIdentifier!
        return NSPasteboard(name: NSPasteboard.Name(rawValue: "\(bundleIdentifier).pasteboard"))
    }()
    
    class func run(service: String, withFileURLs fileURLs: [URL]) -> Bool {
        if !Thread.isMainThread {
            fatalError("ServiceRunner.run() called from non-main thread!")
        }
        
        var pasteboardItems: [NSPasteboardItem] = []
        for url in fileURLs {
            let item = NSPasteboardItem()
            item.setString(url.path, forType: .compatString)
            pasteboardItems.append(item)
        }
        
        pasteboard.declareTypes([ .compatString ], owner: nil)
        pasteboard.writeObjects(pasteboardItems)
        
        if !NSPerformService(service, self.pasteboard) {
            NSLog("service execution failed, and we don’t know why!!")
            return false
        }
        
        return true
    }
    
}

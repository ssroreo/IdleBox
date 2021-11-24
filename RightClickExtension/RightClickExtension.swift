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

enum FileType {
    case TxtFile
    case DocFile
    case XlsFile
    case PptFile
}

class FinderSync: FIFinderSync {

    override init() {
        super.init()
        NSLog("FinderSync() launched from %@", Bundle.main.bundlePath as NSString)
        FIFinderSyncController.default().directoryURLs = [URL(fileURLWithPath: "/")]
    }
    
    override func menu(for menuKind: FIMenuKind) -> NSMenu {
        let menu = NSMenu(title: "")
        let menuitem = NSMenuItem(title: "IdleBox".localized, action: nil, keyEquivalent: "")
        let submenu = NSMenu(title: "")
        submenu.addItem(withTitle: "OpenTerminal".localized, action: #selector(openTerminalClicked(_:)), keyEquivalent: "")
        submenu.addItem(withTitle: "Copyselectedpaths".localized, action: #selector(copyPathToClipboard), keyEquivalent: "")
        submenu.addItem(withTitle: "Createtxtfile".localized, action: #selector(createEmptyTxtFileClicked(_:)), keyEquivalent: "")
        submenu.addItem(withTitle: "Createdocfile".localized, action: #selector(createEmptyDocFileClicked(_:)), keyEquivalent: "")
        submenu.addItem(withTitle: "Createexcelfile".localized, action: #selector(createEmptyExcelFileClicked(_:)), keyEquivalent: "")
        submenu.addItem(withTitle: "Createpptfile".localized, action: #selector(createEmptyPptFileClicked(_:)), keyEquivalent: "")
        submenu.addItem(withTitle: "CreateOtherfile".localized, action: #selector(createEmptyOtherFileClicked(_:)), keyEquivalent: "")
        menuitem.submenu = submenu
        menu.addItem(menuitem)
        return menu
    }

    @IBAction func copyPathToClipboard(_ sender: AnyObject?) {
        
        guard let target = FIFinderSyncController.default().selectedItemURLs() else {
            NSLog("Failed to obtain targeted URLs: %@")
            return
        }
        
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
        var result = ""
        
        for path in target {
            result.append(contentsOf: path.relativePath)
            result.append("\n")
        }
        result.removeLast()

        pasteboard.setString(result, forType: NSPasteboard.PasteboardType.string)
    }

    @IBAction func openTerminalClicked(_ sender: AnyObject?) {
        
        guard let target = FIFinderSyncController.default().targetedURL() else {
            NSLog("Failed to obtain targeted URL: %@")
            return
        }
        
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        task.arguments = ["-a", "terminal", "\(target)"]
        
        do {
            try task.run()
        } catch let error as NSError {
            NSLog("Failed to open Terminal.app: %@", error.description as NSString)
        }
    }

    @IBAction func createEmptyTxtFileClicked(_ sender: AnyObject?) {
        createFile(.TxtFile)
    }

    @IBAction func createEmptyDocFileClicked(_ sender: AnyObject?) {
        createFile(.DocFile)
    }
    
    @IBAction func createEmptyExcelFileClicked(_ sender: AnyObject?) {
        createFile(.XlsFile)
    }
    
    @IBAction func createEmptyPptFileClicked(_ sender: AnyObject?) {
        createFile(.PptFile)
    }
    
    @IBAction func createEmptyOtherFileClicked(_ sender: AnyObject?) {
        guard let target = FIFinderSyncController.default().targetedURL() else {
            NSLog("Failed to obtain targeted URL: %@")
            return
        }
        
        let savePanel = NSSavePanel()
        savePanel.canCreateDirectories = true
        savePanel.showsTagField = false
        savePanel.nameFieldStringValue = "newfile".localized
        savePanel.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.modalPanelWindow)))
        savePanel.begin { (result) in
            if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
                do {
                    try "".write(to: target.appendingPathComponent(savePanel.nameFieldStringValue), atomically: true, encoding: String.Encoding.utf8)
                } catch let error as NSError {
                    NSLog("Failed to create file: %@", error.description as NSString)
                }
            }
        }
    }
    
    func createFile(_ type:FileType) {
        guard let target = FIFinderSyncController.default().targetedURL() else {
            NSLog("Failed to obtain targeted URL: %@")
            return
        }
        
        var originalPath = target
        let originalFilename = "newfile".localized
        var filename="newfile".localized
        var fileType=""
        var counter = 1
        
        switch type {
        case .TxtFile:
            filename = "newfile.txt".localized
            fileType = ".txt"
            break;
        case .DocFile:
            filename = "newfile.docx".localized
            fileType = ".docx"
            break;
        case .XlsFile:
            filename = "newfile.xlsx".localized
            fileType = ".xlsx"
            break;
        case .PptFile:
            filename = "newfile.pptx".localized
            fileType = ".pptx"
            break;
        }
        
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
}


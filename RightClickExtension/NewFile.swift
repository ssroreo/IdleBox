//
//  NewFile.swift
//  RightClickExtension
//
//  Created by chaichengxun on 2021/11/25.
//

import Foundation

import Cocoa

protocol NewFile {
    var templateType: [String] {get}
    var newFileMenus: [NSMenuItem] {get}
    func getFileType(menuItemTitle: String?) -> String
}

extension FinderSync: NewFile {
    struct MenuItemTitle {
        static let separator = "---"
        
        static let textFile = "TextFile".localized
        static let richFile = "RichFile".localized
        
        static let keynoteFile = "KeynoteFile".localized
        static let pagesFile = "PagesFile".localized
        static let numbersFile = "NumbersFile".localized
        
        static let wordFile = "WordFile".localized
        static let excelFile = "ExcelFile".localized
        static let powerPointFile = "PowerPointFile".localized
        
        static let markdownFile = "MarkdownFile".localized
        static let HTMLFile = "HTMLFile".localized
        static let CSSFile = "CSSFile".localized
        static let JavaScriptFile = "JavaSciptFile".localized
        static let pythonFile = "PythonFile".localized
        static let other = "Others".localized
    }
    
    func getFileType(menuItemTitle: String?) -> String {
        guard let title = menuItemTitle else {
            return ""
        }
        switch title {
        case MenuItemTitle.textFile:
            return "txt"
        case MenuItemTitle.richFile:
            return "rtf"
        case MenuItemTitle.keynoteFile:
            return "key"
        case MenuItemTitle.pagesFile:
            return "pages"
        case MenuItemTitle.numbersFile:
            return "numbers"
        case MenuItemTitle.wordFile:
            return "docx"
        case MenuItemTitle.excelFile:
            return "xlsx"
        case MenuItemTitle.powerPointFile:
            return "pptx"
        case MenuItemTitle.markdownFile:
            return "md"
        case MenuItemTitle.HTMLFile:
            return "html"
        case MenuItemTitle.CSSFile:
            return "css"
        case MenuItemTitle.JavaScriptFile:
            return "js"
        case MenuItemTitle.pythonFile:
            return "py"
        default:
            return ""
        }
    }
    
    var templateType: [String] {
        return ["rtf", "html", "pages", "key", "numbers", "py", "rb", "sh", "xlsx"]
    }
    
    var newFileMenus: [NSMenuItem] {
        let appList = try! FileManager.default.contentsOfDirectory(atPath: "/Applications/")
        let appListStr = appList.joined().lowercased()
        
        var fileTypes = [MenuItemTitle.textFile,
                         MenuItemTitle.richFile,
                         MenuItemTitle.separator]
        
        var macOffer = [String]()
        if appListStr.contains("keynote") {
            macOffer.append(MenuItemTitle.keynoteFile)
        }
        if appListStr.contains("pages") {
            macOffer.append(MenuItemTitle.pagesFile)
        }
        if appListStr.contains("numbers") {
            macOffer.append(MenuItemTitle.numbersFile)
        }
        if macOffer.count > 0 {
            fileTypes += macOffer
            fileTypes.append(MenuItemTitle.separator)
        }
        
        var windowsOffer = [String]()
        if appListStr.contains("word") {
            windowsOffer.append(MenuItemTitle.wordFile)
        }
        if appListStr.contains("excel") {
            windowsOffer.append(MenuItemTitle.excelFile)
        }
        if appListStr.contains("powerpoint") {
            windowsOffer.append(MenuItemTitle.powerPointFile)
        }
        if windowsOffer.count > 0 {
            fileTypes += windowsOffer
            fileTypes.append(MenuItemTitle.separator)
        }
        
        fileTypes += [MenuItemTitle.markdownFile, MenuItemTitle.HTMLFile, MenuItemTitle.CSSFile, MenuItemTitle.JavaScriptFile, MenuItemTitle.pythonFile, MenuItemTitle.separator, MenuItemTitle.other]
        
        var result = [NSMenuItem]()
        fileTypes.forEach({ (title) in
            if getFileType(menuItemTitle: title).isEmpty {
                let item = creatMenuItem(for: .custom(title: title, selector: #selector(newOtherFile(_:))))
                result.append(item)
            } else {
                let item = creatMenuItem(for: .custom(title: title, selector: #selector(newFile(_:))))
                result.append(item)
            }
            
        })
        return result
    }
}

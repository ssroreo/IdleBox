//
//  NSPasteboard+Additions.swift
//  RightClickExtension
//
//  Created by chaichengxun on 2021/11/25.
//

import Cocoa

extension NSPasteboard.PasteboardType {
    public static var compatString: NSPasteboard.PasteboardType {
        if #available(macOS 10.13, OSXApplicationExtension 10.13, *) {
            return .string
        } else {
            return NSPasteboard.PasteboardType(rawValue: "NSStringPboardType")
        }
    }
    
    public static var compatFileURL: NSPasteboard.PasteboardType {
        if #available(macOS 10.13, OSXApplicationExtension 10.13, *) {
            return .fileURL
        } else {
            return NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")
        }
    }
    
    public static var compatFilename: NSPasteboard.PasteboardType {
        return NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")
    }
    
    public static var compatURL: NSPasteboard.PasteboardType {
        if #available(macOS 10.13, OSXApplicationExtension 10.13, *) {
            return .URL
        } else {
            return NSPasteboard.PasteboardType(rawValue: "NSURLPboardType")
        }
    }
    
    public static var compatMultipleTextSelection: NSPasteboard.PasteboardType {
        if #available(macOS 10.13, OSXApplicationExtension 10.13, *) {
            return .multipleTextSelection
        } else {
            return NSPasteboard.PasteboardType(rawValue: "NSMultipleTextSelectionPboardType")
        }
    }
}

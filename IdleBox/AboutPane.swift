//
//  AboutPane.swift
//  IdleBox
//
//  Created by chaichengxun on 2021/11/25.
//

import Cocoa

class AboutPane: NSViewController {

    @IBOutlet weak var versionLabel: NSTextField!
    @IBOutlet weak var copyrightLabel: NSTextField!
    
    var originalSize: CGSize!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        originalSize = self.view.frame.size
        
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        versionLabel.stringValue = "version \(version)"
        
        let copyright = Bundle.main.object(forInfoDictionaryKey: "NSHumanReadableCopyright") as! String
        copyrightLabel.stringValue = copyright
    }
    
}

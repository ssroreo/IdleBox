//
//  GeneralPane.swift
//  IdleBox
//
//  Created by chaichengxun on 2021/11/25.
//

import Cocoa
import FinderSync

class GeneralPane: NSViewController {

    @IBOutlet weak var statusLabel: NSTextField!
    
    var originalSize: CGSize!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        originalSize = self.view.frame.size
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateStatus),
            name: NSApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    @objc func updateStatus() {
        if FIFinderSyncController.isExtensionEnabled {
            statusLabel.stringValue = "AllowedInformative".localized
            statusLabel.textColor = NSColor.init(red: 0.196, green: 0.804, blue: 0.196, alpha: 1)
        } else {
            statusLabel.stringValue = "NotAllowedInformative".localized
            statusLabel.textColor = NSColor.red
        }
    }
        
    @IBAction func openPreferences(_ sender: Any) {
        FIFinderSyncController.showExtensionManagementInterface()
    }
    
}

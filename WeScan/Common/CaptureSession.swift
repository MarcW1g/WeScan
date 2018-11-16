//
//  CaptureSession.swift
//  WeScan
//
//  Created by Julian Schiavo on 23/9/2018.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import Foundation

/// A class containing global variables and settings for this capture session
final class CaptureSession {
    
    static let current = CaptureSession()
    
    /// Whether the user is past the scanning screen or not (needed to disable auto scan on other screens)
    var isEditing: Bool
    
    /// Whether auto scan is enabled or not
    var isAutoModeEnabled: Bool
    
    /// The orientation of the captured image
    var editImageOrientation: CGImagePropertyOrientation
    
    private init(isAutoModeEnabled: Bool = true, editImageOrientation: CGImagePropertyOrientation = .up) {
        self.isEditing = false
        self.isAutoModeEnabled = isAutoModeEnabled
        self.editImageOrientation = editImageOrientation
    }
    
}

//
//  IVMaskField
//
//  Created by Irakli Vashakidze on 13.02.2018.
//  Copyright © 2018 Irakli Vashakidze. All rights reserved.
//
import UIKit

protocol IVMaskFieldDelegate : class {
    func maskField(textChanged sender : IVMaskField,
                   newText: String?,
                   at position: UITextPosition?)
}

class IVMaskField : UITextField {
    
    private var prevText        : String?
    private var prevFormatted   : String?
    
    private var _originalText   : String?
    var originalText            : String? {
        return _originalText
    }
    
    weak var maskDelegate : IVMaskFieldDelegate?
    
    var format : String? {
        didSet {
            self.text = ""
        }
    }
    
    var escapeString: String = "" {
        didSet {
            self.text = ""
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configure()
    }
    
    init() {
        super.init(frame: CGRect.zero)
        self.configure()
    }
    
    func configure() {
        self.addTarget(self,
                       action: #selector(IVMaskField.reformat(sender:)),
                       for: UIControlEvents.editingChanged);
    }
    
    var initialText : String? {
        didSet {
            self.text = initialText
            self.reformat(sender: self)
        }
    }
    
    @objc private func reformat(sender: UITextField) {
        self.reformatInternal(textField: sender)
    }
    
    private func reformatInternal(textField: UITextField) {
        var targetPosition : UITextPosition?
        
        if textField.text == nil {
            return
        }
        
        if let fmt = self.format, fmt.count > 0 {
            
            let clears = textField.text?.count ?? 0 < self.prevText?.count ?? 0
            
            let range = textField.selectedTextRange ?? UITextRange()
            
            var targetCursorPosition = textField.offset(from: textField.beginningOfDocument, to: range.start)
            
            if textField.text?.count ?? 0 > fmt.count {
                var newStr = String()
                
                for i in 0..<(textField.text?.count ?? 0) {
                    if i != targetCursorPosition - 1 {
                        newStr.append(textField.text![i])
                    }
                }
                
                textField.text = newStr;
                return;
            }
            
            let noSpaces = self.stringByRemovingEscapeStrings(string: textField.text!,
                                                              andPreserveCursor: &targetCursorPosition)
            
            let withSpaces = clears ? self.reformatWhenDeletingCharacter(string: noSpaces, andPreserveCursor: &targetCursorPosition) :
                self.reformat(string: noSpaces, andPreserveCursor: &targetCursorPosition)
            
            self._originalText = noSpaces
            textField.text = withSpaces
            
            targetPosition = textField.position(from: textField.beginningOfDocument, offset: targetCursorPosition)
            textField.selectedTextRange = textField.textRange(from: targetPosition!, to: targetPosition!)
            
            
        } else {
            self._originalText = self.text;
        }
        
        self.maskDelegate?.maskField(textChanged: self,
                                     newText: self._originalText,
                                     at: targetPosition)
        
        self.prevText = self.text
        self.prevFormatted = self.originalText
    }
    
    private func stringByRemovingEscapeStrings(string: String, andPreserveCursor cursor: inout Int) -> String {
        let original: Int = cursor
        var result = String()
        for i in 0..<string.count {
            let c = string[i];
            if String(c) != self.escapeString {
                result.append(c)
            } else if i < original {
                cursor -= 1
            }
        }
        
        return result
    }
    
    private func reformat(string: String, andPreserveCursor cursor: inout Int) -> String {
        var result = String()
        
        if let fmt = self.format {
            
            let original = cursor
            let components = fmt.components(separatedBy: self.escapeString)
            
            var indices = [Int]()
            var position = 0
            
            for i in 0..<components.count {
                if i > 0 {
                    let str = components[i - 1]
                    position += str.count
                    indices.append(position - 1)
                }
            }
            
            for i in 0..<string.count {
                
                let c = string[i]
                result.append(c)
                
                if indices.contains(i) {
                    result.append(self.escapeString)
                    if i < original {
                        cursor += self.escapeString.count
                    }
                }
            }
        }
        
        return result
    }
    
    private func reformatWhenDeletingCharacter(string: String, andPreserveCursor cursor: inout Int) -> String {
        
        var result = String()
        
        if let fmt = self.format {
            
            let original: Int = cursor
            let components = fmt.components(separatedBy: self.escapeString)
            
            var indices = [Int]()
            var position = 0
            
            for i in 0..<components.count {
                if i > 0 {
                    let str = components[i]
                    position += str.count
                    indices.append(position)
                }
            }
            
            for i in 0..<string.count {
                if indices.contains(i) {
                    result.append(self.escapeString)
                    if i < original {
                        cursor += self.escapeString.count
                    }
                }
                
                let c = string[i]
                result.append(c)
            }
        }
        
        return result
    }
}

extension String {
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
}

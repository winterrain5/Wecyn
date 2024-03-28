//
//  ChatVC_InputBarAccessoryViewDelegate.swift
//  Wecyn
//
//  Created by Derrick on 2024/3/22.
//

import Foundation
// MARK: InputBarAccessoryViewDelegate

extension ChatViewController: InputBarAccessoryViewDelegate {
    // MARK: Internal
    
    @objc
    func inputBar(_: InputBarAccessoryView, didPressSendButtonWith _: String) {
        processInputBar(messageInputBar)
    }
    
    func processInputBar(_ inputBar: InputBarAccessoryView) {
        // Here we can parse for which substrings were autocompleted
        let attributedText = inputBar.inputTextView.attributedText!
        let range = NSRange(location: 0, length: attributedText.length)
        attributedText.enumerateAttribute(.autocompleted, in: range, options: []) { _, range, _ in
            
            let substring = attributedText.attributedSubstring(from: range)
            let context = substring.attribute(.autocompletedContext, at: 0, effectiveRange: nil)
            print("Autocompleted: `", substring, "` with context: ", context ?? "-")
        }
        
        let components = inputBar.inputTextView.components
        inputBar.inputTextView.text = String()
        inputBar.invalidatePlugins()
        // Send button activity animation
        inputBar.sendButton.startAnimating()
        inputBar.inputTextView.placeholder = "Sending..."
        // Resign first responder for iPad split view
//        inputBar.inputTextView.resignFirstResponder()
        inputBar.inputTextView.placeholder = "Aa"
        self.insertMessages(components)
        
    }
    
    // MARK: Private
    
    private func insertMessages(_ data: [Any]) {
        for component in data {
            if let str = component as? String {
                
                IMController.shared.sendTextMessage(text: str, to: dataProvider.receiverId, conversationType: .c2c) { info in
                    print(info)
                } onComplete: { info in
                    let message = IMMessage.build(messageInfo: info)
                    self.insertMessage(message)
                }

                
            }
            
        }
      
    }
    

   
}

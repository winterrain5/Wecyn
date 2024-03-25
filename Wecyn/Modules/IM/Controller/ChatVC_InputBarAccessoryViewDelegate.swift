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
        DispatchQueue.global(qos: .default).async {
            // fake send request task
//            sleep(1)
            DispatchQueue.main.async { [weak self] in
                inputBar.sendButton.stopAnimating()
                inputBar.inputTextView.placeholder = "Aa"
                self?.insertMessages(components)
                self?.messagesCollectionView.scrollToLastItem(animated: true)
            }
        }
    }
    
    // MARK: Private
    
    private func insertMessages(_ data: [Any]) {
        for component in data {
            if let str = component as? String {
             
                let info = MessageInfo()
                IMController.shared.sendTextMessage(text: str, to: replyuser.id.string, conversationType: .c2c) { msg in
                    print(msg)
                } onComplete: { [weak self] msg in
                    let message = IMMessage(text: str, user: IMController.shared.currentSender, messageId: UUID().uuidString, date: Date())
                    self?.insertMessage(message)
                }

            
            }
            
        }
      
    }
    
    // MARK: 发送消息
    
    func typing(doing: Bool) {
        IMController.shared.typingStatusUpdate(recvID: replyuser.id.string, msgTips: doing ? "yes" : "no")
    }

    func sendMessage(_ data:)
    
    func insertMessage(_ message: IMMessage) {
      messageList.append(message)
      // Reload last section to update header/footer labels and insert a new one
      messagesCollectionView.performBatchUpdates({
        messagesCollectionView.insertSections([messageList.count - 1])
        if messageList.count >= 2 {
          messagesCollectionView.reloadSections([messageList.count - 2])
        }
      }, completion: { [weak self] _ in
        if self?.isLastSectionVisible() == true {
          self?.messagesCollectionView.scrollToLastItem(animated: true)
        }
      })
    }
    
    func isLastSectionVisible() -> Bool {
      guard !messageList.isEmpty else { return false }

      let lastIndexPath = IndexPath(item: 0, section: messageList.count - 1)

      return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
}

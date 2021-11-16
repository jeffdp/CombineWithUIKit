//
//  ViewController.swift
//  CombineWithUIKit
//
//  Created by Jeffrey Porter on 11/14/21.
//

// Based on 'Combine Framework - A Practical Introduction with UIKit'
//   https://www.youtube.com/watch?v=RysM_XPNMTw&t=518s

import UIKit
import Combine

extension Notification.Name {
    static let message = Self.init("message")
}

struct Message {
    let content: String
    let author: String
}

class NotificationsViewController: UIViewController {
    @IBOutlet weak var allowMessagesSwitch: UISwitch!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    
    @Published var canSendMessage = true
    private var subscribers = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        $canSendMessage
            .receive(on: DispatchQueue.main)
            .assign(to: \.isEnabled, on: sendButton)
            .store(in: &subscribers)
        
        NotificationCenter.Publisher(center: .default, name: .message)
            .receive(on: DispatchQueue.main)
            .map { Notification -> String? in
                (Notification.object as? Message)?.content
            }
            .subscribe(Subscribers.Assign(object: messageLabel, keyPath: \.text))
    }

    @IBAction func didSwitch(_ sender: UISwitch) {
        canSendMessage = sender.isOn
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
        let message = Message(content: "Time: \(Date())", author: "JP")
        NotificationCenter.default.post(name: .message, object: message)
    }
}

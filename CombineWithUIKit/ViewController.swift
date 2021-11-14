//
//  ViewController.swift
//  CombineWithUIKit
//
//  Created by Jeffrey Porter on 11/14/21.
//

import UIKit
import Combine

extension Notification.Name {
    static let message = Self.init("message")
}

struct Message {
    let content: String
    let author: String
}

class ViewController: UIViewController {
    @IBOutlet weak var allowMessagesSwitch: UISwitch!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    
    @Published var canSendMessage = true
    private var switchSubscriber: AnyCancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupProcessing()
    }

    func setupProcessing() {
        switchSubscriber = $canSendMessage.receive(on: DispatchQueue.main)
            .assign(to: \.isEnabled, on: sendButton)
        
        let messagePublisher = NotificationCenter.Publisher(center: .default, name: .message)
            .map { Notification -> String? in
                (Notification.object as? Message)?.content
            }
        
        let messageSubscriber = Subscribers.Assign(object: messageLabel, keyPath: \.text)
        messagePublisher.subscribe(messageSubscriber)
    }
    
    @IBAction func didSwitch(_ sender: UISwitch) {
        canSendMessage = sender.isOn
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
        let message = Message(content: "Time: \(Date())", author: "JP")
        NotificationCenter.default.post(name: .message, object: message)
    }
}

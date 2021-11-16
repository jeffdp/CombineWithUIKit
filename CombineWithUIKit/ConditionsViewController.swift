//
//  ConditionsViewController.swift
//  CombineWithUIKit
//
//  Created by Jeffrey Porter on 11/14/21.
//

// Based on 'Getting started with Combine + UIKit in Swift'
//   https://www.youtube.com/watch?v=IAKco9XaPgg

import UIKit
import Combine

class ConditionsViewController: UIViewController {
    
    @IBOutlet weak var termsSwitch: UISwitch!
    @IBOutlet weak var conditionsSwitch: UISwitch!
    @IBOutlet weak var signedText: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    // Define publishers to connect to our UI
    @Published private var acceptedTerms = false
    @Published private var acceptedConditions = false
    @Published private var signed = ""
    
    var userName = "Jeff"
    
    var validSignature: AnyPublisher<Bool, Never> {
        $signed
            .throttle(for: 0.5, scheduler: DispatchQueue.main, latest: true)
            .removeDuplicates()
            .flatMap { [weak self] name in
                Future { promise in
                    // We're immediately calling this, but it could be called from
                    // an asynchronous API.
                    promise(.success(name == self?.userName))
                }
            }
            .eraseToAnyPublisher()
    }
        
    // Define a publisher that combines three publishers into one
    private var validToSubmit: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest3($acceptedTerms, $acceptedConditions, validSignature)
            .map { terms, conditions, signature in
                return terms && conditions && signature
            }
            .eraseToAnyPublisher()
    }
    
    private var subscribers = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        validToSubmit
            .receive(on: DispatchQueue.main)
            .assign(to: \.isEnabled, on: submitButton)
            .store(in: &subscribers)
    }

    @IBAction func acceptTerms(_ sender: UISwitch) {
        acceptedTerms = sender.isOn
    }
    
    @IBAction func acceptConditions(_ sender: UISwitch) {
        acceptedConditions = sender.isOn
    }
    
    @IBAction func nameChanged(_ sender: UITextField) {
        signed = sender.text ?? ""
    }
    
    @IBAction func submit(_ sender: UIButton) {
        print("Submitted!")
    }
}

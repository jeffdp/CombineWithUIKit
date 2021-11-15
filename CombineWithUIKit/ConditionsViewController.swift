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
    
    // Define a publisher that combines the above three publishers into one
    private var validToSubmit: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest3($acceptedTerms, $acceptedConditions, $signed)
            .map { terms, conditions, signed in
                return terms && conditions && !signed.isEmpty
            }
            .eraseToAnyPublisher()
    }
    
    private var observers = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        validToSubmit
            .receive(on: DispatchQueue.main)
            .assign(to: \.isEnabled, on: submitButton)
            .store(in: &observers)
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

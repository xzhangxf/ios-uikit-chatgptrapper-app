//
//  ChatViewController.swift
//  ChatGPTRapper
//
//  Created by Xufeng Zhang on 17/10/25.
//

import UIKit

class ChatViewController: UIViewController, UITextFieldDelegate {

    private let promptField: UITextField = {
        let field = UITextField()
            field.placeholder = "Ask the rap mentor…"
            field.borderStyle = .roundedRect
            field.returnKeyType = .send
            return field
        }()

        private let sendButton: UIButton = {
            let button = UIButton(type: .system)
            button.setTitle("Hit it!", for: .normal)
            return button
        }()

        private let responseView: UITextView = {
            let textView = UITextView()
            textView.isEditable = false
            textView.isSelectable = true
            textView.text = "Your rhymes will land here."
            textView.font = .preferredFont(forTextStyle: .body)
            textView.backgroundColor = .secondarySystemBackground
            textView.layer.cornerRadius = 12
            textView.layer.borderWidth = 1
            textView.layer.borderColor = UIColor.separator.cgColor
            textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
            return textView
        }()
    
        private let resetButton: UIButton = {
            let button = UIButton(type: .system)
            button.setTitle("Reset Session", for: .normal)
            button.heightAnchor.constraint(equalToConstant: 44).isActive = true
            return button
        }()
    
        private let stack: UIStackView = {
            let s = UIStackView()
            s.axis = .vertical
            s.spacing = 12
            s.translatesAutoresizingMaskIntoConstraints = false
            return s
        }()

        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .systemBackground
            
            let topRow = UIStackView(arrangedSubviews: [promptField, sendButton])
            topRow.axis = .horizontal
            topRow.spacing = 8
            topRow.translatesAutoresizingMaskIntoConstraints = false
            
            let stack = UIStackView(arrangedSubviews: [promptField, sendButton, responseView])
            stack.axis = .vertical
            stack.spacing = 16
            stack.translatesAutoresizingMaskIntoConstraints = false
            stack.addArrangedSubview(topRow)
            stack.addArrangedSubview(responseView)
            stack.addArrangedSubview(resetButton)

            view.addSubview(stack)

            NSLayoutConstraint.activate([
                stack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
                stack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
                stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
                responseView.heightAnchor.constraint(greaterThanOrEqualToConstant: 220)
            ])

            sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
            resetButton.addTarget(self, action: #selector(resetTapped), for: .touchUpInside)
            promptField.delegate = self
            do { service = try RapperChatService() }
            catch { responseView.text = "\(error.localizedDescription)" }

        }
        private var service: RapperChatService?

        @objc private func sendTapped() {
            responseView.text = "Loading..."
            let text = promptField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            guard !text.isEmpty else {
                responseView.text = "Please type something to rap about."
                    return
            }
                responseView.text = "Loading…"
                promptField.resignFirstResponder()

            Task { [weak self] in
                guard let self = self, let service = self.service else { return }
                    do {
                        let reply = try await service.respond(to: text)
                        self.responseView.text = reply
                    } catch {
                        self.responseView.text = " \(error.localizedDescription)"
                    }
            }
        }

        @objc private func resetTapped() {
            promptField.text = nil
            responseView.text = "Your rhymes will land here."
        }

        @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
                    sendTapped()
                    return true
        }
}

    
    



//
//  AEOTPTextField.swift
//  Motivaid
//
//  Created by Hrithik Gupta on 29/08/25.
//


import UIKit

public class AEOTPTextField: UITextField {
    // MARK: - PROPERTIES
    public var otpDefaultCharacter = ""
    public var otpBackgroundColor: UIColor = UIColor.white
    public var otpFilledBackgroundColor: UIColor = UIColor.white
    public var otpCornerRaduis: CGFloat = 10
    public var otpDefaultBorderColor: CGColor = UIColor(hex: "#D0E6FF").cgColor
    public var otpFilledBorderColor: UIColor = UIColor.gradientBorderColor()
    public var otpDefaultBorderWidth: CGFloat = 1
    public var otpFilledBorderWidth: CGFloat = 1.5
    public var otpTextColor: UIColor = .black
    public var otpFontSize: CGFloat = 14
    public var otpFont: UIFont = UIFont.systemFont(ofSize: 14)

    /// Delegate
    public weak var otpDelegate: AEOTPTextFieldDelegate?

    private var implementation = AEOTPTextFieldImplementation()
    private var isConfigured = false
    private var digitLabels = [UILabel]()
    private lazy var tapRecognizer: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer()
        recognizer.addTarget(self, action: #selector(becomeFirstResponder))
        return recognizer
    }()
    
    // MARK: - METHODS
    public func configure(with slotCount: Int = 6) {
        guard isConfigured == false else { return }
        isConfigured.toggle()
        configureTextField()
        
        let labelsStackView = createLabelsStackView(with: slotCount)
        addSubview(labelsStackView)
        addGestureRecognizer(tapRecognizer)
        NSLayoutConstraint.activate([
            labelsStackView.topAnchor.constraint(equalTo: topAnchor),
            labelsStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            labelsStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            labelsStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    public func clearOTP() {
        text = nil
        digitLabels.forEach { currentLabel in
            currentLabel.text = otpDefaultCharacter
            currentLabel.layer.borderWidth = otpDefaultBorderWidth
            currentLabel.layer.borderColor = otpDefaultBorderColor
            currentLabel.backgroundColor = otpBackgroundColor
        }
    }
    
    public func setText(_ text: String) {
        let characters = Array(text)
        for i in 0 ..< characters.count {
            if digitLabels.indices.contains(i) {
                digitLabels[i].text = String(characters[i])
            }
        }
    }
}

// MARK: - PRIVATE METHODS
private extension AEOTPTextField {
    func configureTextField() {
        tintColor = .clear
        textColor = .clear
        keyboardType = .numberPad
        textContentType = .oneTimeCode
        borderStyle = .none
        addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        addTarget(self, action: #selector(highlightActiveField), for: .editingDidBegin)
        delegate = implementation
        implementation.implementationDelegate = self
    }
    
    func createLabelsStackView(with count: Int) -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        for _ in 1 ... count {
            let label = createLabel()
            stackView.addArrangedSubview(label)
            digitLabels.append(label)
        }
        return stackView
    }
    
    func createLabel() -> UILabel {
        let label = UILabel()
        label.backgroundColor = otpBackgroundColor
        label.layer.cornerRadius = otpCornerRaduis
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = otpTextColor
        label.font = otpFont
        label.isUserInteractionEnabled = true
        label.layer.masksToBounds = true
        label.text = otpDefaultCharacter
        
        label.layer.borderWidth = otpDefaultBorderWidth
        label.layer.borderColor = otpDefaultBorderColor
        return label
    }
    
    @objc
    func textDidChange() {
        guard let text = self.text, text.count <= digitLabels.count else { return }

        for labelIndex in 0..<digitLabels.count {
            let currentLabel = digitLabels[labelIndex]

            if labelIndex < text.count {
                let index = text.index(text.startIndex, offsetBy: labelIndex)
                currentLabel.text = String(text[index])
                currentLabel.layer.borderWidth = otpFilledBorderWidth
                currentLabel.layer.borderColor = otpFilledBorderColor.cgColor
            }
            else if labelIndex == text.count {
                currentLabel.text = otpDefaultCharacter
                currentLabel.layer.borderWidth = otpFilledBorderWidth
                currentLabel.layer.borderColor = otpFilledBorderColor.cgColor
            }
            else {
                currentLabel.text = otpDefaultCharacter
                currentLabel.layer.borderWidth = otpDefaultBorderWidth
                currentLabel.layer.borderColor = otpDefaultBorderColor
            }
        }

        if text.count == digitLabels.count {
            otpDelegate?.didUserFinishEnter(the: text)
        }
    }
    
    @objc
    func highlightActiveField() {
        guard let firstLabel = digitLabels.first else { return }

        firstLabel.layer.borderWidth = otpFilledBorderWidth
        firstLabel.layer.borderColor = otpFilledBorderColor.cgColor
    }
}

// MARK: - AEOTPTextFieldImplementationProtocol
extension AEOTPTextField: AEOTPTextFieldImplementationProtocol {
    var digitalLabelsCount: Int {
        digitLabels.count
    }
}


public protocol AEOTPTextFieldDelegate: AnyObject {
    func didUserFinishEnter(the code: String)
}

protocol AEOTPTextFieldImplementationProtocol: AnyObject {
    var digitalLabelsCount: Int { get }
}

class AEOTPTextFieldImplementation: NSObject, UITextFieldDelegate {
    weak var implementationDelegate: AEOTPTextFieldImplementationProtocol?

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard let characterCount = textField.text?.count else { return false }
        return characterCount < implementationDelegate?.digitalLabelsCount ?? 0 || string == ""
    }
}

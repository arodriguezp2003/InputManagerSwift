//
//  InputManager.swift
//  textfield
//
//  Created by Alejandro  Rodriguez on 12/11/18.
//  Copyright © 2018 Alejandro  Rodriguez. All rights reserved.
//

//
//  InputManager.swift
//  textfield
//
//  Created by Alejandro  Rodriguez on 12/11/18.
//  Copyright © 2018 Alejandro  Rodriguez. All rights reserved.
//

import UIKit

protocol InputManagerProtocol {
    func setCurrentInput(_ currentInput: AnyObject)
}

public class InputManagerControl: InputManagerProtocol {
    
    
//    public init(from view: UIView, with controls: [AnyObject]) {
//        self.view = view
//        self._controls = controls
//    }
//
    
    public init(_ v: UIView?, with c: [AnyObject]? ) {
        self.view = v
        self._controls = c
        reloadControls()
    }
    private var _controls: [AnyObject]?
    private var currentInput: AnyObject?
    private var dkt = false
    
    var view: UIView? //SuperView
    
    public var dismissKeyboardTouchOutside: Bool {
        get { return dkt }
        set(value) {
            dkt = value
            reloadControls()
        }
    }
    
    
//    public func setControls(_ controls:[AnyObject]) {
//        _controls = controls
//        reloadControls()
//    }
//
    func reloadControls() {
        
        if _controls?.count == 0 {
            return
        }
        if dkt {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
            self.view?.addGestureRecognizer(tapGesture)
        }
        
        for (index, c) in _controls!.enumerated() {
            if let control = c as? UITextFieldWithToolbar {
                if index < _controls!.count - 1 {
                    control.delegateProtocol = self
                    control.nextControl = _controls![index + 1]
                } else {
                    control.delegateProtocol = self
                }
                
                
                
            }
        }
    }
    
    @objc private func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                var nextControl: AnyObject?
                if let ci =  self.currentInput as? UITextFieldWithToolbar {
                    nextControl = ci.nextControl
                    ci.nextControl = nil
                }
                
                _ = self.currentInput?.resignFirstResponder()
                
                if let ci =  self.currentInput as? UITextFieldWithToolbar {
                    ci.nextControl = nextControl
                }
                
            }
        }
    }
    
    //Protocolo
    func setCurrentInput(_ ci: AnyObject) {
        self.currentInput = ci
    }
}


public class UITextFieldWithToolbar: UITextField, UITextFieldDelegate {
    
    weak var nextControl: AnyObject?
    var doneButtonTitle = "Continuar"
    var doneButtonTintColor: UIColor = UIColor.blue
    
    var delegateProtocol: InputManagerProtocol?
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.drawToolbar()
        self.delegate = self

    }
    
    func drawToolbar() {
        let bar = UIToolbar()
        
        let flexibleButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: doneButtonTitle, style: .done, target: self, action: #selector(doneTapped))
        
        done.tintColor = doneButtonTintColor
        bar.items = [flexibleButton,done]
        bar.sizeToFit()
        
        self.inputAccessoryView = bar
    }
    
    @objc func doneTapped() {
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                self.resignFirstResponder()
                _ = self.nextControl?.becomeFirstResponder()
            }
        }
        
    }
    public func textFieldDidBeginEditing(_ textField: UITextField)  {
        print("Entro??")
        delegateProtocol?.setCurrentInput(textField)
        
        let heightSuperView = self.superview!.frame.height
        let myView = self.frame.origin
        let keyboard = CGFloat(372)
        
        let changeFrame = heightSuperView - keyboard - myView.y
        // si es > 0 No esta abajo del keyboard
        if changeFrame > 0 {
            return
        }
        var up  = CGFloat(0.0)
        
        if Double(self.superview?.frame.origin.y ?? 0) < 0 {
            let originY = self.superview!.frame.origin.y
            up = abs(keyboard -  myView.y - originY) - self.frame.height + 5
        } else {
            if changeFrame < 0 {
                up = abs(keyboard -  myView.y) - self.frame.height + 5
            }
        }
        
        UIView.animate(withDuration: 0.3) {
            self.superview?.frame.origin.y -= up
        }
    }
    
     public func  textFieldDidEndEditing(_ textField: UITextField)  {
        if self.nextControl != nil {
            return
        }
        
        let heightSuperView = self.superview!.frame.height
        let myView = self.frame.origin
        let keyboardHeight = CGFloat(372.0)
        
        let changeFrame = heightSuperView - keyboardHeight - myView.y
        
        
        if changeFrame < 0 {
            UIView.animate(withDuration: 0.15) {
                self.superview?.frame.origin.y = 0
            }
        }
    }
}




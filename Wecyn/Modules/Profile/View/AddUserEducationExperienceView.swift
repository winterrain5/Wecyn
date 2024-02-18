//
//  AddUserEducationExperienceView.swift
//  Wecyn
//
//  Created by Derrick on 2023/10/24.
//

import UIKit
import KMPlaceholderTextView
class AddUserEducationExperienceView: UIView,UITextFieldDelegate,UITextViewDelegate {

    @IBOutlet weak var currentSwitch: UISwitch!
    @IBOutlet weak var descTfHCons: NSLayoutConstraint!
    @IBOutlet weak var orgNameSelectButton: UIButton!
    @IBOutlet weak var descTf: KMPlaceholderTextView!
    @IBOutlet weak var degreeTf: UITextField!
    @IBOutlet weak var endButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var fieldTf: UITextField!
    @IBOutlet weak var orgTf: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        descTf.font = UIFont.systemFont(ofSize: 16)
        descTf.textColor = R.color.textColor33()
        descTf.returnKeyType = .done
        descTf.delegate = self
        
     
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.endEditing(true)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    

}

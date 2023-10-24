//
//  AddUserEducationExperienceView.swift
//  Wecyn
//
//  Created by Derrick on 2023/10/24.
//

import UIKit

class AddUserEducationExperienceView: UIView,UITextFieldDelegate {

   
    @IBOutlet weak var orgNameSelectButton: UIButton!
    @IBOutlet weak var descTf: UITextField!
    @IBOutlet weak var degreeTf: UITextField!
    @IBOutlet weak var endButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var fieldTf: UITextField!
    @IBOutlet weak var orgTf: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.endEditing(true)
    }

}

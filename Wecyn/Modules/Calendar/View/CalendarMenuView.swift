//
//  CalendarMenuView.swift
//  Wecyn
//
//  Created by Derrick on 2023/7/20.
//

import UIKit

class CalendarMenuView: UIView {
    var createEventView = UIView()
    var isOpen = false
    var backgroundView = UIImageView().blurred(withStyle: .extraLight)
    
    let calendarButton = UIButton()
    let calendarLabel = UILabel()
    
    let line = UIView()
    
    let arrowButton = UIButton()
    
    let shareButton = UIButton()
    let shareLabel = UILabel()
    
    init(originView:UIView) {
        super.init(frame: .zero)
        
        self.layer.zPosition = 1000
        
        func toggleOpen(_ complete: (()->())? = nil) {
            self.isOpen = false
            UIView.animate(withDuration: 0.25) {
                self.setNeedsLayout()
                self.layoutIfNeeded()
            } completion: { flat in
                if  let complete = complete {
                    complete()
                }
            }
            Haptico.selection()
        }
        
        
        originView.addSubview(backgroundView)
        backgroundView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight)
        backgroundView.alpha = 0
        backgroundView.layer.zPosition = 999
        backgroundView.isUserInteractionEnabled = true
        backgroundView.rx.tapGesture().when(.recognized).subscribe(onNext:{ _ in
            toggleOpen()
        }).disposed(by: rx.disposeBag)
        
        addSubview(createEventView)
        createEventView.backgroundColor = R.color.theamColor()!
        
      
        createEventView.addShadow(cornerRadius: 28)
        arrowButton.rx.tap.subscribe(onNext:{
            self.isOpen.toggle()
            UIView.animate(withDuration: 0.25) {
                self.setNeedsLayout()
                self.layoutIfNeeded()
            }
            Haptico.selection()
        }).disposed(by: rx.disposeBag)
        
        
        calendarButton.imageForNormal = R.image.calendarBadgePlus()
        calendarButton.imageForHighlighted = R.image.calendarBadgePlus()
        createEventView.addSubview(calendarButton)
        calendarButton.rx.tap.subscribe(onNext:{ [weak self] in
            guard let `self` = self else { return }
            if self.isOpen {
                toggleOpen{
                    let vc = CalendarAddNewEventController()
                    UIViewController.sk.getTopVC()?.navigationController?.pushViewController(vc)
                }
            } else {
                Haptico.selection()
                let vc = CalendarAddNewEventController()
                UIViewController.sk.getTopVC()?.navigationController?.pushViewController(vc)
            }
            
        }).disposed(by: rx.disposeBag)
        
        
        arrowButton.imageForNormal = R.image.chevronUp()
        arrowButton.imageForHighlighted = R.image.chevronUp()
        createEventView.addSubview(arrowButton)
       
        calendarLabel.text = "New Event"
        calendarLabel.textColor = .black
        calendarLabel.font = UIFont.sk.pingFangSemibold(16)
        calendarLabel.alpha = 0
        backgroundView.addSubview(calendarLabel)
        
        shareButton.imageForNormal = R.image.squareAndArrowUp()?.withTintColor(R.color.theamColor()!)
        shareButton.imageForHighlighted =  R.image.squareAndArrowUp()?.withTintColor(R.color.theamColor()!)
        shareButton.addShadow(cornerRadius: 20)
        shareButton.backgroundColor = .white
        shareButton.alpha = 0
        backgroundView.addSubview(shareButton)
        shareButton.rx.tap.subscribe(onNext:{
            toggleOpen{
                let vc = EventSetAssistantsController()
                UIViewController.sk.getTopVC()?.navigationController?.pushViewController(vc)
            }
        }).disposed(by: rx.disposeBag)
        
        shareLabel.text = "Share Calendar"
        shareLabel.textColor = .black
        shareLabel.font = UIFont.sk.pingFangSemibold(16)
        shareLabel.alpha = 0
        backgroundView.addSubview(shareLabel)
        
        
        
        createEventView.addSubview(line)
        line.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        line.cornerRadius = 1
    }
 
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
       
        let menuW:CGFloat = self.isOpen ? 56 : 112
        let menuY = kScreenHeight - kTabBarHeight - 12 - 56
        
        createEventView.frame = CGRect(x: 0, y: 0, width: menuW, height: 56)
        self.frame = CGRect(x: kScreenWidth - menuW - 16, y: menuY, width: menuW, height: 56)
        backgroundView.alpha = self.isOpen.int.cgFloat
        
        calendarLabel.alpha = self.isOpen.int.cgFloat
        calendarLabel.frame = CGRect(x: kScreenWidth - 166, y: 0, width: 0, height: 20)
        calendarLabel.center.y = self.center.y
        calendarLabel.sizeToFit()
        
        shareButton.alpha = self.isOpen.int.cgFloat
        shareButton.frame = CGRect(x: 0, y: menuY - 60, width: 40, height: 40)
        shareButton.center.x = self.center.x
        
        shareLabel.alpha = self.isOpen.int.cgFloat
        shareLabel.frame = CGRect(x: kScreenWidth - 117 - 66 - 12, y: 0, width: 0, height: 20)
        shareLabel.center.y = shareButton.center.y
        shareLabel.sizeToFit()
        
        if isOpen {
            calendarButton.frame = CGRect(x: 0, y: 0, width: 56, height: 56)
            line.alpha = 0
            arrowButton.alpha = 0
        } else {
            calendarButton.frame = CGRect(x: 17, y: 0, width: 22, height: 56)
            line.frame = CGRect(x: 0, y: 8, width: 2, height: 40)
            line.center.x = createEventView.center.x
            arrowButton.frame = CGRect(x: 73, y: 0, width: 22, height: 56)
            line.alpha = 1
            arrowButton.alpha = 1
        }
    }
    
    static func addMenu(originView:UIView) {
        let menu = CalendarMenuView(originView: originView)
        originView.addSubview(menu)
    }
}

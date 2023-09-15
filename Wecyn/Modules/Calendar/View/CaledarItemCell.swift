//
//  CaledarItemCell.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/15.
//

import UIKit

class CaledarItemCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var crossDayLabel: UILabel!
    @IBOutlet weak var creatorLabel: UILabel!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var repeatImgView: UIImageView!
    @IBOutlet weak var statusImgView: UIImageView!
    var searchingText = ""
    var model: EventListModel? {
        didSet {
            guard let model = model else { return }
            titleLabel.text = model.title
            if !searchingText.isEmpty {
                titleLabel.sk.setSpecificTextColor(searchingText, color: UIColor(hexString: "#21a93c")!)
            }
            
            
            switch model.status {
            case 0: // 未知
                statusImgView.image = R.image.personFillQuestionmark()
            case 1: // 同意
                statusImgView.image = R.image.personFillCheckmark()
            case 2: // 拒绝
                statusImgView.image = R.image.personFillXmark()
            default:
                statusImgView.image = R.image.personFillQuestionmark()
            }
            statusView.backgroundColor = UIColor(hexString: EventColor.allColor[model.color])
            repeatImgView.isHidden = model.is_repeat != 1
            creatorLabel.text = "creator: \(model.creator_name)"
            crossDayLabel.isHidden = !model.isCrossDay
            
            if model.isBySearch {
                self.startLabel.isHidden = true
                timeLabel.text = model.start_time + "\n" + model.end_time
                return
            }
            
            let startTime = model.start_time.split(separator: " ").last ?? ""
            let endTime = model.end_time.split(separator: " ").last ?? ""
            if model.isCrossDay {
                
                if model.isCrossDayStart {
                    timeLabel.text = String(startTime)
                    crossDayLabel.text = "Start"
                }
                
                if model.isCrossDayEnd {
                    timeLabel.text = String(endTime)
                    crossDayLabel.text = "End"
                }
                
                if model.isCrossDayMiddle {
                    timeLabel.text = "all day"
                    crossDayLabel.text = ""
                }
                
               
            } else {
                timeLabel.text = startTime + " - " + endTime
            }
            
            guard let startDate = model.start_date else { return }
            let distance =  Date().distance(to: startDate)
            let minitue = (distance.int % (60 * 60)) / (60)
            if distance <= 30 * 60 && distance > 0 {
                self.startLabel.isHidden = false
                self.startLabel.text = " \(minitue) mins to start "
            } else {
                self.startLabel.isHidden = true
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.startLabel.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

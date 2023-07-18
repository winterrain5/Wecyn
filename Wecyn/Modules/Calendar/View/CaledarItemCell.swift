//
//  CaledarItemCell.swift
//  Wecyn
//
//  Created by Derrick on 2023/6/15.
//

import UIKit

class CaledarItemCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var creatorLabel: UILabel!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var shadowView: UIView!
    
    var searchingText = ""
    var model: EventListModel? {
        didSet {
            guard let model = model else { return }
            titleLabel.text = model.title
            if !searchingText.isEmpty {
                titleLabel.sk.setSpecificTextColor(searchingText, color: UIColor(hexString: "#21a93c")!)
            }
            
            
            let starTime = model.start_time.date(withFormat: DateFormat.ddMMyyyyHHmm.rawValue)?.string(withFormat: "dd/MM/yyyy HH:mm") ?? ""
            let endTime = model.end_time.date(withFormat: DateFormat.ddMMyyyyHHmm.rawValue)?.string(withFormat: "dd/MM/yyyy HH:mm") ?? ""
            timeLabel.text = starTime + " - " + endTime
            
            switch model.status {
            case 0: // 未知
                statusView.backgroundColor = UIColor(hexString: "#ed8c00")
            case 1: // 同意
                statusView.backgroundColor = UIColor(hexString: "#21a93c")
            case 2: // 拒绝
                statusView.backgroundColor = UIColor(hexString: "#d82739")
            default:
                statusView.backgroundColor = UIColor(hexString: "#ed8c00")
            }
            
            creatorLabel.text = "create by: \(model.creator_name)"
//            locationLabel.text = "Location:\(model)"
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        shadowView.addShadow(cornerRadius: 10)
        statusView.sk.addCorner(conrners: [.topRight,.bottomRight], radius: 10)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

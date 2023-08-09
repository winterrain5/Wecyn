
import OUICore
import RxSwift

class NewFriendTableViewCell: UITableViewCell {
    var disposeBag = DisposeBag()

    let avatarView = AvatarView()

    let titleLabel: UILabel = {
        let v = UILabel()
        v.font = .f17
        v.textColor = .c0C1C33
        
        return v
    }()

    let subtitleLabel: UILabel = {
        let v = UILabel()
        v.font = .f14
        v.textColor = .c8E9AB0
        
        return v
    }()

    let agreeBtn: UIButton = {
        let v = UIButton(type: .system)
        v.titleLabel?.font = .f14
        v.layer.cornerRadius = 5
        v.contentEdgeInsets = UIEdgeInsets(top: .margin8, left: .margin8, bottom: .margin8, right: .margin8)
        
        return v
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(avatarView)
        avatarView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }

        let textStack: UIStackView = {
            let v = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
            v.axis = .vertical
            v.spacing = 4
            v.alignment = .leading
            return v
        }()

        contentView.addSubview(textStack)
        textStack.snp.makeConstraints { make in
            make.leading.equalTo(avatarView.snp.trailing).offset(8)
            make.centerY.equalTo(avatarView)
        }

        contentView.addSubview(agreeBtn)
        agreeBtn.snp.makeConstraints { make in
            make.leading.equalTo(textStack.snp.trailing)
            make.trailing.equalToSuperview().offset(-CGFloat.margin16)
            make.centerY.equalToSuperview()
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    func setApplyState(_ state: ApplyState) {
        switch state {
        case .uncertain:
            agreeBtn.setTitle("接受".innerLocalized(), for: .normal)
            agreeBtn.backgroundColor = .c0089FF
            agreeBtn.tintColor = .white
            agreeBtn.isEnabled = true
        case .agreed:
            agreeBtn.setTitle("已同意".innerLocalized(), for: .normal)
            agreeBtn.backgroundColor = .clear
            agreeBtn.tintColor = .c8E9AB0
            agreeBtn.isEnabled = false
        case .rejected:
            agreeBtn.setTitle("已拒绝".innerLocalized(), for: .normal)
            agreeBtn.backgroundColor = .clear
            agreeBtn.tintColor = .c8E9AB0
            agreeBtn.isEnabled = false
        }
    }

    enum ApplyState: Int {
        case rejected = -1
        case uncertain = 0
        case agreed = 1
        
        var title: String {
            switch self {
            case .rejected:
                return "已拒绝".innerLocalized()
            case .uncertain:
                return "接受".innerLocalized()
            case .agreed:
                return "已同意".innerLocalized()
            }
        }
    }
}

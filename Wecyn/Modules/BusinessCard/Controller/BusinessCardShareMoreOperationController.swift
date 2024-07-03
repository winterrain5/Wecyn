//
//  BusinessCardShareMoreOperationController.swift
//  Wecyn
//
//  Created by Derrick on 2024/7/2.
//

import UIKit
import ZLPhotoBrowser
struct BusinessCardShareOperation {
    var title:String
    var selStr:String
    var image:UIImage?
}

class BusinessCardShareMoreOperationController: BaseTableController {

    let model = UserDefaults.sk.get(of: UserInfoModel.self, for: UserInfoModel.className)
    var datas:[BusinessCardShareOperation] = [
        BusinessCardShareOperation(title: "Copy Link", selStr: "copyLink", image: UIImage.rectangle_on_rectangle),
        BusinessCardShareOperation(title: "Download QR Code Image", selStr: "downloadImage", image: UIImage.qrcode),
        BusinessCardShareOperation(title: "Send QR Code Image", selStr: "sendImage", image: UIImage.qrcode),
//        BusinessCardShareOperation(title: "Add to wallet", selStr: "addToWallet", image: UIImage.rectangle_stack_fill)kk
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let indictor = UIView().backgroundColor(R.color.iconColor()!)
        view.addSubview(indictor)
        indictor.frame = CGRect(x: 0, y: 20, width: 32, height: 4)
        indictor.center.x = self.view.center.x
        indictor.cornerRadius = 2

    }
    

    override func createListView() {
        super.createListView()
        
        tableView?.register(cellWithClass: UITableViewCell.self)
        tableView?.rowHeight = 50
    }
    
    override func listViewFrame() -> CGRect {
        CGRect(x: 0, y: 44, width: kScreenWidth, height: self.view.height)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        datas.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: UITableViewCell.self)
        let data = datas[indexPath.row]
        cell.imageView?.image = data.image?.withTintColor(R.color.iconColor()!, renderingMode: .alwaysOriginal)
        cell.textLabel?.text = data.title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let sel = Selector(datas[indexPath.row].selStr)
        if responds(to: sel) {
            perform(sel)
        }
        
    }
 
    
    @objc func copyLink() {
        Haptico.selection()
        let url = APIHost.share.WebpageUrl + "/card/\(model?.uuid ?? "")"
        UIPasteboard.general.string = url
        Toast.showSuccess("链接已拷贝".innerLocalized())
    }
    
    @objc func downloadImage() {
        Haptico.selection()
        guard let image = generateQRCodeImage() else { return }
       
        ZLPhotoManager.saveImageToAlbum(image: image) { flag, asset in
            if flag {
                Toast.showSuccess("二维码已保存".innerLocalized())
            }
        }
    }
    
    @objc func sendImage() {
        Haptico.selection()
        guard let image = generateQRCodeImage() else { return }
        let vc = VisualActivityViewController(image: image)
        vc.previewImageSideLength = 40
        UIViewController.sk.getTopVC()?.present(vc, animated: true)
    }
    
    func generateQRCodeImage() -> UIImage? {
        let url = APIHost.share.WebpageUrl + "/card/\(model?.uuid ?? "")"
        guard let image = UIImage.sk.QRImage(with: url, size: CGSize(width: 200, height: 200), logoSize: CGSize(width: 40, height: 40),logoImage: R.image.appicon()!,logoRoundCorner: 8) else {
            return nil
        }
        return image
    }

}

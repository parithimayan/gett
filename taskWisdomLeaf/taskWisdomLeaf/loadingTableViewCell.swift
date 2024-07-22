//
//  loadingTableViewCell.swift
//  taskWisdomLeaf
//
//  Created by ilamparithi mayan on 23/06/24.
//

import UIKit

class loadingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var viewUI: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var checkBoxImage: UIImageView!
    @IBOutlet weak var chkButton: UIButton!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var picImage: UIImageView!
    
    var chkBoxTapped: ((Bool) -> Void)?

    var check = false

    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewUI.layer.masksToBounds = true
        viewUI.clipsToBounds = true
        viewUI.layer.cornerRadius = 5
        
    }
    
    
    func config(photo: Pics) {//photodetails){
        self.picImage.image = nil
        let slno = Int(photo.id ?? "1") ?? 1
        
        // Set the title label with the photo's serial number and author.
        titleLbl.text = "\(slno+1) " + "\(photo.author ?? "None")"
        
        // Set the photo image if image data is available.
        if let data = photo.picImageData {
            picImage.image = data//UIImage(data: data)
        }
    }

    @IBAction func checkBoxTapping(_ sender: Any) {
        
        if check {
            check = false
        } else {
            check = true
        }
        // Call the closure to notify about the check state change.
        self.chkBoxTapped?(self.check)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

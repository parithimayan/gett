//
//  ViewController.swift
//  taskWisdomLeaf
//
//  Created by ilamparithi mayan on 23/06/24.
//

import UIKit
import Foundation

class MainViewController: UIViewController {

    @IBOutlet weak var picsTable: UITableView!
    
    
    // Activity indicator to show loading progress.
    var activityIndicator: UIActivityIndicatorView?
    // Lazy initialization of the view model.
    lazy var viewModel = {
       return MainViewModel()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("receive memory warning")
    }
    // Set up the table view, including its delegate, data source, and refresh control.
    func tablesetup() {
        picsTable.delegate = self
        picsTable.dataSource = self
        picsTable.refreshControl = UIRefreshControl()
        picsTable.refreshControl?.addTarget(self, action: #selector(refreshPhotos), for: .valueChanged)
        setupActivityIndicator()
    }
    // Initialize and configure the activity indicator.
    func setupActivityIndicator() {
            activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator?.color = .red
            guard let activityIndicator = activityIndicator else { return }
            
            activityIndicator.center = view.center
            activityIndicator.hidesWhenStopped = true
            picsTable.addSubview(activityIndicator)
        }
    // Show the activity indicator and hide it after 10 seconds.
        func showActivityIndicator() {
            activityIndicator?.startAnimating()
            DispatchQueue.main.asyncAfter(deadline: .now()+10, execute: {
                self.hideActivityIndicator()
            })
        }

        // Hide the activity indicator.
        func hideActivityIndicator() {
            self.activityIndicator?.stopAnimating()
        }

    // Refresh the photos by resetting the view model and fetching the first page of photos.
    
    @objc func refreshPhotos() {
        viewModel.currentPage = 1
        viewModel.getphotodatails.removeAll()
        viewModel.photoList.removeAll()
        self.picsTable.reloadData()
        self.viewModel.fetchphotos(page: self.viewModel.currentPage, completion: {
            self.updateData()
        })
    }
    
    // Update the data in the table view after a delay.
    func updateData() {
        DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
            
            self.picsTable.refreshControl?.endRefreshing()
            self.picsTable.reloadData()
            self.loadImages()
        })
        
    }
    // Load images asynchronously from URLs and update the view model with the images.
        
    func loadImages() {
        for i in 0..<self.viewModel.getphotodatails.count {
            guard let urlfromimage = self.viewModel.getphotodatails[i].download_url else {
                return
            }
            if let url = URL(string: urlfromimage) {
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: url),
                       let image = UIImage(data: data) {
                        DispatchQueue.main.async {
//                            self.getphotodatails[i].photoImageData = data
                            if self.viewModel.getphotodatails.indices.contains(i) {
                                let id = self.viewModel.getphotodatails[i].id ?? ""
                                let photo = Pics.init(id: id, author: self.viewModel.getphotodatails[i].author ?? "", photoImageData: image, check: false)
                                let found = self.viewModel.photoList.filter({ ($0.id ?? "").contains(id) })
                                if found.isEmpty {
                                    self.viewModel.photoList.append(photo)
                                }
                                if self.viewModel.getphotodatails.count == self.viewModel.photoList.count {
                                    self.viewModel.photoList = self.viewModel.photoList.sorted(by: { Int($0.id ?? "0") ?? 0 < Int($1.id ?? "0") ?? 0 })
                                    self.hideActivityIndicator()
                                    self.picsTable.reloadData()
                                }
                            }
                        }
                    }
                }
            }
        }
        self.hideActivityIndicator()
    }
    
}
// Return the number of rows in the section.

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.photoList.count
    }
    // Configure and return the cell for the given index path.
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = picsTable.dequeueReusableCell(withIdentifier: "tablecell", for: indexPath) as! loadingTableViewCell
        if self.viewModel.photoList.indices.contains(indexPath.row) {
            let photoindex = self.viewModel.photoList[indexPath.row]
            cell.config(photo: photoindex)
            cell.chkButton.tag = indexPath.row
            cell.chkButton.addTarget(self, action: #selector(checkboxTapped(_:)), for: .valueChanged)
            cell.descriptionLbl.text = indexPath.row % 2 == 0 ? "Apple iOS is the operating system for iPhone, iPad, and other Apple mobile devices." : "Based on Mac OS, the operating system which runs Apple's line of Mac desktop and laptop computers, Apple iOS is designed for easy, seamless networking among a range of Apple products."
            cell.descriptionLbl.numberOfLines = 0
            cell.descriptionLbl.lineBreakMode = .byWordWrapping
            cell.descriptionLbl.sizeToFit()
            cell.checkBoxImage.image = UIImage(named: (photoindex.check ?? false) ? "CheckBox" : "Uncheckbox")
            cell.checkBoxTapping = { status in
                self.viewModel.photoList[indexPath.row].check = status
                cell.checkBox.image = UIImage(named: status ? "CheckBox" : "Uncheckbox")
                self.photocollectiontable.reloadData()
                self.showAlert(status: status, title: cell.titleLabel.text!)
                
            }
//            if indexPath.row == photoList.count - 15 && !isLoading {
//                currentPage += 1
//                fetchphotos(page: currentPage)
//            }
        }
        return cell
    }
    
    // Handle the checkbox tap action and display the photo URL in an alert.
    
    @objc func checkboxTapped(_ sender: UISwitch) {
        let photo = viewModel.getphotodatails[sender.tag]
           let message = photo.url
           let alert = UIAlertController(title: "Photo URL", message: message, preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "OK", style: .default))
           present(alert, animated: true)
    }
    
    // Show an alert indicating the selection status of the photo.
    
    func showAlert(status: Bool, title: String) {
        let alertVC = UIAlertController(title: title, message: status ? "\(title) is Selected" : "\(title) is UnSelected", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alertVC, animated: true)
    }
    
}
// Return the automatic dimension for the row height.

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // Handle the event when a cell is about to be displayed.
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.photoList.count - 15 { // Last cell
            if viewModel.currentPage < viewModel.totalPages {
                viewModel.currentPage += 1
                viewModel.fetchphotos(page: viewModel.currentPage, completion: {
                    self.updateData()
                })
            }
        }
    }
        


}


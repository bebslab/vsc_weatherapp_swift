//
//  InfoTableViewController.swift
//  WeatherApp
//
//  Created by Hubert LABORDE on 22/08/2017.
//  Copyright © 2017 Hubert LABORDE. All rights reserved.
//

import UIKit

class InfoTableViewController: UITableViewController {
    //MARK: - Assets
    
    /* Labels */
    @IBOutlet weak var appTitleLabel: UILabel!
    @IBOutlet weak var appVersionLabel: UILabel!
    
    @IBOutlet weak var legendEntryLabel_1: UILabel!
    @IBOutlet weak var legendEntryLabel_2: UILabel!
    @IBOutlet weak var legendEntryLabel_3: UILabel!
    @IBOutlet weak var legendEntryLabel_4: UILabel!
    
    
    @IBOutlet weak var supportNoteLabel: UILabel!
    @IBOutlet weak var supportAddressLabel: UILabel!
    
    @IBOutlet weak var sourceNoteLabel: UILabel!
    @IBOutlet weak var sourceAddressLabel: UILabel!
    
    @IBOutlet weak var developerName_0: UILabel!
    
    @IBOutlet weak var iconsNoteLabel: UILabel!
    @IBOutlet weak var iconsAddressLabel: UILabel!
    
    
    //MARK: - Override Functions
    
    /* View */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        NotificationCenter.default.addObserver(self, selector: #selector(InfoTableViewController.preferredTextSizeChanged(_:)), name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
    }
    
    func setupUI() {
        navigationItem.title = NSLocalizedString("InfoTVC_NavigationItemTitle", comment: "").uppercased()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(InfoTableViewController.didTapDoneButton(_:)))
        tableView.delegate = self
        self.navigationController?.navigationBar.tintColor = UIColor(red: 89/255, green: 200/255, blue: 224/255, alpha: 1.0)
        tableView.backgroundColor = UIColor(red: 51/255, green: 56/255, blue: 92/255, alpha: 1.0)
        configureText()
        tableView.estimatedRowHeight = 61
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.layoutIfNeeded()
    }
    
    //MARK: - Tableview delegate
    /* TableView */
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 2 && indexPath.row == 0 {
            UIApplication.shared.open(URL(string: "http://www.laborde-hubert.com")!, options: [:], completionHandler: nil)
        }
        if indexPath.section == 2 && indexPath.row == 1 {
            UIApplication.shared.open(URL(string: "https://github.com/bebslab")!, options: [:], completionHandler: nil)
        }
        if indexPath.section == 4 && indexPath.row == 0 {
            UIApplication.shared.open(URL(string: "https://icons8.com")!, options: [:], completionHandler: nil)
        }
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1: return NSLocalizedString("InfoTVC_TableViewSectionHeader2", comment: "")
        case 2: return NSLocalizedString("InfoTVC_TableViewSectionHeader3", comment: "")
        case 3: return NSLocalizedString("InfoTVC_TableViewSectionHeader4", comment: "")
        case 4: return NSLocalizedString("InfoTVC_TableViewSectionHeader5", comment: "")
        default: return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 4: return NSLocalizedString("InfoTVC_TableViewSectionFooter5", comment: "")
        default: return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = UIColor.red
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor(red: 89/255, green: 200/255, blue: 224/255, alpha: 1.0)
    }
    
    /* Deinitializer */
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: - Handle NSNotification
    
    func preferredTextSizeChanged(_ notification: Notification) {
        configureText()
        tableView.reloadSections(IndexSet(integer: 0), with: UITableViewRowAnimation.none)
        tableView.reloadSections(IndexSet(integer: 1), with: UITableViewRowAnimation.none)
        tableView.reloadSections(IndexSet(integer: 2), with: UITableViewRowAnimation.none)
        tableView.reloadSections(IndexSet(integer: 3), with: UITableViewRowAnimation.none)
    }
    
    
    // MARK: - Interface Setup
    
    private func configureText() {
        appTitleLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        appTitleLabel.text! = NSLocalizedString("InfoTVC_AppTitle", comment: "")
        
        legendEntryLabel_1.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        legendEntryLabel_1.text! = NSLocalizedString("InfoTVC_Legend_Temperature", comment: "")
        legendEntryLabel_2.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        legendEntryLabel_2.text! = NSLocalizedString("InfoTVC_Legend_CloudCover", comment: "")
        legendEntryLabel_3.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        legendEntryLabel_3.text! = NSLocalizedString("InfoTVC_Legend_Humidity", comment: "")
        legendEntryLabel_4.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        legendEntryLabel_4.text! = NSLocalizedString("InfoTVC_Legend_WindSpeed", comment: "")
        
        
        appVersionLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        appVersionLabel.text! = NSLocalizedString("InfoTVC_AppVersion", comment: "")
        
        supportNoteLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        supportNoteLabel.text! = NSLocalizedString("InfoTVC_Support", comment: "")
        
        supportAddressLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        
        sourceNoteLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        sourceNoteLabel.text! = NSLocalizedString("InfoTVC_Source", comment: "")
        
        sourceAddressLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
        
        developerName_0.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        
        iconsNoteLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        iconsNoteLabel.text! = NSLocalizedString("InfoTVC_Icons", comment: "")
        
        iconsAddressLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.subheadline)
    }
    
    
    // MARK: - Button Interaction
    
    @objc private func didTapDoneButton(_ sender: UIBarButtonItem) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}

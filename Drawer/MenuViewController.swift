//
//  MenuViewController.swift
//  Drawer
//
//  Created by he on 2017/7/13.
//  Copyright © 2017年 hezongjiang. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    fileprivate lazy var tableView: UITableView = {
       
        let tableView = UITableView(frame: self.view.bounds)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.backgroundColor = .clear
        
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    fileprivate lazy var vi = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .yellow
        
        view.addSubview(tableView)
        
        vi.backgroundColor = .red
        vi.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        vi.center = view.center
        
        view.addSubview(vi)
    }

}

extension MenuViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .clear
        cell.textLabel?.text = "\(indexPath.row)"
        cell.textLabel?.textColor = .white
        return cell
    }
}

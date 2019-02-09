//
//  CityChooserView.swift
//  GlovoApp
//
//  Created by Gui on 06/02/2019.
//  Copyright © 2019 Gui. All rights reserved.
//

import Foundation
import SnapKit
import UIKit
import ReactiveKit


class CityChooserView: UIView {
    
    private let disposeBag = DisposeBag()
    var presenter: CityChooserPresenter?
    var viewContainer: UIView!
    var tableViewDataSource: UITableViewDataSource!
    var tableViewDelegate: UITableViewDelegate!
    private var tableView: UITableView!
    private var loadingView: UIActivityIndicatorView!
    
    init(presenter: CityChooserPresenter?, tableViewDataSource: UITableViewDataSource, tableViewDelegate: UITableViewDelegate) {
        super.init(frame: CGRect.zero)
        self.presenter = presenter
        self.tableViewDataSource = tableViewDataSource
        self.tableViewDelegate = tableViewDelegate
        
        setupContainerView()
        setupTableView()
        setupLoadingView()
        bindViewModel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupContainerView() {
        viewContainer = UIView()
        self.addSubview(viewContainer)
        viewContainer.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        viewContainer.backgroundColor = UIColor.white
        viewContainer.clipsToBounds = true
    }
    
    func setupTableView(){
        tableView = UITableView()
        
        tableView.register(CityTableCell.self, forCellReuseIdentifier: "MyCell")
        tableView.dataSource = self.tableViewDataSource
        tableView.delegate = self.tableViewDelegate
        viewContainer.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func setupLoadingView(){
        loadingView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        loadingView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        viewContainer.addSubview(loadingView)
        loadingView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        viewContainer.bringSubviewToFront(loadingView)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func bindViewModel(){
        presenter?.isLoadingTableView.bind(to: tableView.reactive.isHidden)
        presenter?.isLoadingTableView.observeNext { isLoading in
            if isLoading {
                self.loadingView.startAnimating()
            }else {
                self.loadingView.stopAnimating()
            }
        }.dispose(in: disposeBag)
    }

    func reloadData(){
        self.tableView.reloadData()
    }
}

class CityTableCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//
//  DetailViewController.swift
//  RxSwiftMVVMInOut
//
//  Created by 박준우 on 2/19/25.
//

import UIKit

final class DetailViewController: UIViewController {

    let label: UILabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .lightGray
        self.view.addSubview(self.label)
        self.label.backgroundColor = .green
        self.label.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(100)
        }
    }
}

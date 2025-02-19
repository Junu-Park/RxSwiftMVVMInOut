//
//  HomeworkViewController.swift
//  RxSwiftMVVMInOut
//
//  Created by 박준우 on 2/19/25.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

final class HomeworkViewController: UIViewController {
    
    private let sampleUsers: [Person] = MockData.personList
    
    private lazy var sampleUsersSubject = BehaviorSubject(value: sampleUsers)
    
    private let tableView = UITableView()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout())
    private let searchBar = UISearchBar()
    
    private var disposeBag = DisposeBag()
    
    private var selectedUsers: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        bind()
    }
     
    private func bind() {
        self.sampleUsersSubject
        // TODO: .bind(to) 말고 .bind(onNext) 활용해서 만드는 법
            .bind(to: self.tableView.rx.items(cellIdentifier: PersonTableViewCell.identifier, cellType: PersonTableViewCell.self)) { index, data, cell in
                cell.usernameLabel.text = data.name
                cell.detailButton.rx.tap
                    .bind(with: self) { owner, _ in
                        let vc = DetailViewController()
                        vc.label.text = data.name
                        vc.title = data.name
                        owner.navigationController?.pushViewController(vc, animated: true)
                    }
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: self.disposeBag)
        
        self.tableView.rx.modelSelected(Person.self)
            .withUnretained(self, resultSelector: { owner, value in
                owner.selectedUsers.insert(value.name, at: 0)
                return owner.selectedUsers
            })
            .bind(to: self.collectionView.rx.items(cellIdentifier: UserCollectionViewCell.identifier, cellType: UserCollectionViewCell.self)) {
                index, data, cell in
                cell.label.text = data
            }
            .disposed(by: self.disposeBag)
        
        self.searchBar.rx.searchButtonClicked
            .withLatestFrom(self.searchBar.rx.text.orEmpty)
            .withLatestFrom(Observable.just(self.sampleUsers), resultSelector: { text, dataList in
                return text.isEmpty ? dataList : dataList.filter { $0.name.lowercased().contains(text.lowercased()) }
            })
            .bind(with: self) { owner, value in
                owner.sampleUsersSubject.onNext(value)
            }
            .disposed(by: self.disposeBag)
        
        self.searchBar.rx.text.orEmpty
            .bind(with: self) { owner, value in
                if value.isEmpty {
                    owner.sampleUsersSubject.onNext(self.sampleUsers)
                }
            }
            .disposed(by: self.disposeBag)
    }
    
    private func configure() {
        view.backgroundColor = .white
        view.addSubview(tableView)
        view.addSubview(collectionView)
        view.addSubview(searchBar)
        
        navigationItem.titleView = searchBar
         
        collectionView.register(UserCollectionViewCell.self, forCellWithReuseIdentifier: UserCollectionViewCell.identifier)
        collectionView.backgroundColor = .lightGray
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(50)
        }
        
        tableView.register(PersonTableViewCell.self, forCellReuseIdentifier: PersonTableViewCell.identifier)
        tableView.backgroundColor = .systemGreen
        tableView.rowHeight = 100
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(50)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    private func layout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 80, height: 40)
        layout.scrollDirection = .horizontal
        return layout
    }

}
 

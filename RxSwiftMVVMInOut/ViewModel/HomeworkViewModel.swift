//
//  HomeworkViewModel.swift
//  RxSwiftMVVMInOut
//
//  Created by 박준우 on 2/19/25.
//

import Foundation

import RxCocoa
import RxSwift

final class HomeworkViewModel {
    struct Input {
        var drawTableViewCell: BehaviorSubject<String?>
        var enterSearchButton: ControlEvent<Void>
        var enterSearchTerm: ControlProperty<String?>
        var selectTableViewCell: ControlEvent<Person>
//        var tappedCellButton: ControlEvent<Void>
    }
    struct Output {
        var userList: Observable<[Person]>
        var nameList: Observable<[String]>
//        var tappedCellButton: ControlEvent<Void>
    }
    
    private var selectedUserNameList: [String] = []
    
    private var disposeBag = DisposeBag()
    
    
    init() {
        
    }
    
    func transform(input: Input) -> Output {
        let userList = input.drawTableViewCell
            .withLatestFrom(Observable.just(MockData.personList)) { text, list in
                
                guard let text else {
                    return list
                }
                
                return text.isEmpty ? list : list.filter { $0.name.lowercased().contains(text.lowercased()) }
            }
        
        input.enterSearchButton
            .withLatestFrom(input.enterSearchTerm.orEmpty.distinctUntilChanged())
            .bind(with: self) { owner, value in
                input.drawTableViewCell.onNext(value)
            }
            .disposed(by: self.disposeBag)
        
        input.enterSearchTerm.orEmpty
            .bind(onNext: { text in
                if text.isEmpty {
                    input.drawTableViewCell.onNext(text)
                }
            })
            .disposed(by: self.disposeBag)
        
        let nameList = input.selectTableViewCell
            .withUnretained(self, resultSelector: { owner, value in
                if let index = owner.selectedUserNameList.firstIndex(of: value.name) {
                    owner.selectedUserNameList.remove(at: index)
                }
                owner.selectedUserNameList.insert(value.name, at: 0)
                return owner.selectedUserNameList
            })
        
        return Output(userList: userList, nameList: nameList)
    }
}

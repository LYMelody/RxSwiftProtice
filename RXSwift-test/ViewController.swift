//
//  ViewController.swift
//  RXSwift-test
//
//  Created by 周辉平 on 2018/3/30.
//  Copyright © 2018年 fightOrganization. All rights reserved.
//

import UIKit

import RxCocoa
import SnapKit
import RxSwift

class ViewController: UIViewController {

//    /// 按钮
//    lazy var button: UIButton = {
//
//        let button = UIButton()
//        button.backgroundColor = UIColor.orange
//        button.setTitle("提交", for: .normal)
//        button.setTitleColor(UIColor.black, for: .normal)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
//        button.layer.cornerRadius = 22
//        button.layer.masksToBounds = true
//
//        button.rx.tap.bind {
//            [weak self] _ -> Void in
//            self?.button.setTitle("完成", for: .normal)
//        }
//        .diposed(by: DisposeBag)
//        return button
//    }()
    
    var disposeBag = DisposeBag()
    //var event = Event()
    
    
    lazy var firstFld: UITextField = {
        let fld = UITextField()
        fld.font = UIFont.systemFont(ofSize: 16)
        fld.placeholder = "enter a number"
        fld.layer.cornerRadius = 3
        fld.layer.borderWidth = 1
        fld.layer.borderColor = UIColor.orange.cgColor
        fld.keyboardType = .numberPad
        fld.text = "1"
        fld.textAlignment = NSTextAlignment.center
        return fld
    }()
    
    lazy var secondFld: UITextField = {
        let fld = UITextField()
        fld.font = UIFont.systemFont(ofSize: 16)
        fld.placeholder = "enter a number"
        fld.layer.cornerRadius = 3
        fld.layer.borderWidth = 1
        fld.layer.borderColor = UIColor.orange.cgColor
        fld.keyboardType = .numberPad
        fld.text = "2"
        fld.textAlignment = NSTextAlignment.center
        return fld
    }()
    
    lazy var result: UILabel = {
       let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 20)
        lab.textColor = UIColor.red
        lab.layer.cornerRadius = 3
        lab.layer.borderColor = UIColor.orange.cgColor
        lab.layer.borderWidth = 1
        lab.textAlignment = NSTextAlignment.center
        lab.text = "3"
        return lab
    }()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.title = "RxSwift-Test"
        self.navigationController?.navigationBar.barTintColor = UIColor.purple
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
        //self.view .addSubview(button)
    
//        button.snp.makeConstraints { (make) in
//            make.center.equalTo(self.view)
//            make.width.height.equalTo(100)
//        }
        
        func printStar(type: String) {
            print("\(type):  *************************")
        }
        
        
        //第一个输入
        
        self.view.addSubview(firstFld)
        self.view.addSubview(secondFld)
        self.view.addSubview(result)
        
        firstFld.snp.makeConstraints { (make) in
            make.top.equalTo(self.view).offset(100)
            make.left.equalTo(self.view).offset(60)
            make.right.equalTo(self.view).offset(-60)
            make.height.equalTo(40)
        }
        
        secondFld.snp.makeConstraints { (make) in
            make.top.equalTo(firstFld.snp.bottom).offset(20)
            make.left.right.height.equalTo(firstFld)
        }
        
        result.snp.makeConstraints { (make) in
            make.top.equalTo(secondFld.snp.bottom).offset(20)
            make.left.right.height.equalTo(secondFld)
        }
        
        /// 订阅观察者
        Observable.combineLatest(firstFld.rx.text.orEmpty, secondFld.rx.text.orEmpty) { (textValue1, textValue2) -> Int in
            return (Int(textValue1) ?? 0) + (Int(textValue2) ?? 0)
        }
        .map { $0.description }
        .bind(to: result.rx.text)
        .disposed(by: disposeBag)
        
        
        /// just
        Observable.just("🍎")
        .subscribe(onNext: { (event) in
            print(event)
        })
        .disposed(by: disposeBag)
        printStar(type: "just")
        
        /// of
        Observable.of("🐶","🐔","📚")
        .subscribe(onNext: {
                element in print(element)
            })
        .disposed(by: disposeBag)
        printStar(type: "of")
        /// from
        Observable.from(["1","2","3"])
        .subscribe(onNext:{print($0)})
        .disposed(by: disposeBag)
        printStar(type: "from")
        /// range
        Observable.range(start: 1, count: 10)
            .subscribe(onNext: {print($0)})
        .disposed(by: disposeBag)
        printStar(type: "range")
        /// repate
        Observable.repeatElement("🐩")
        .take(5)
        .subscribe(onNext: {print($0)})
        .disposed(by: disposeBag)
        printStar(type: "repate")
        /// generate
        Observable.generate(initialState: 0, condition: { $0 < 3 }, iterate: { $0 + 1})
        .subscribe(onNext: {print($0)})
        .disposed(by: disposeBag)
        printStar(type: "generate")
        /// startWith
        Observable.of("one","two","three")
        .startWith("1")
        .startWith("2")
        .startWith("3","4","5")
        .subscribe(onNext: {print($0)})
        .disposed(by: disposeBag)
        printStar(type: "stareWith")
        /// zip 将两个可观察序列按照顺序组合在一起,形成一个新的可观察序列,并一一对应。
        let stringSubject = PublishSubject<String>()
        let intSubject = PublishSubject<Int>()
        
        Observable.zip(stringSubject,intSubject){
            stringElement,intElement in "\(stringElement) \(intElement)"
        }
        .subscribe(onNext: {print($0)})
        .disposed(by: disposeBag)
        stringSubject.onNext("A")
        stringSubject.onNext("B")
        intSubject.onNext(1)
        intSubject.onNext(2)
        
        stringSubject.onNext("AB")
        intSubject.onNext(3)
        
        printStar(type: "Zip")
        
        /// combineLatest
        
        Observable.combineLatest(stringSubject,intSubject) {
            stringElement, intElement in "\(stringElement) \(intElement)"
        }
        .subscribe(onNext: {print($0)})
        .disposed(by: disposeBag)
        
        stringSubject.onNext("A")
        stringSubject.onNext("B")
        intSubject.onNext(1)
        intSubject.onNext(2)
        stringSubject.onNext("AB")
        printStar(type: "combineLatest")
        
        let stringObservable = Observable.just("💖")
        let fruitObservable = Observable.from(["apple","li","orange"])
        let animalObservable = Observable.of("dog","cat","mouse","fish")
        
       
       Observable.combineLatest([stringObservable,fruitObservable,animalObservable]) {
            "\($0[0]) \($0[1]) \($0[2])"
           }
        .subscribe(onNext: {print($0)})
        .disposed(by: disposeBag)
        
        /// switchLatest
        
        printStar(type: "switchLatest")
        
        let subject1 = BehaviorSubject(value: "bool")
        let subject2 = BehaviorSubject(value: "apple")
        
        let variable = Variable(subject1)
        
        variable.asObservable()
        .switchLatest()
        .subscribe(onNext: {print($0)})
        .disposed(by: disposeBag)
        
        subject1.onNext("🏈")
        subject1.onNext("🏀")
        
        variable.value = subject2
        
        subject1.onNext("⚽️")
        subject2.onNext("🍐")
        
        /// map

        printStar(type: "map")
        
        Observable.of(1,2,3)
        .map{ $0 * $0 }
        .subscribe(onNext: {print($0)})
        .disposed(by: disposeBag)
        
        /// flatMap and flatMapLatest
        
        printStar(type: "flatMap and flatMapLatest")
        
        struct Player {
            var score: Variable<Int>
        }
        
        let 👦 = Player(score: Variable(80))
        let 👧 = Player(score: Variable(90))
        
        let player = Variable(👦)
        
        player.asObservable()
            .flatMapLatest { $0.score.asObservable() }
            .subscribe(onNext: {print($0)})
            .disposed(by: disposeBag)
        
        👦.score.value = 85
        
        player.value = 👧
        
        👦.score.value = 95
        
        👧.score.value = 100
        
        /// scan
        
        printStar(type: "scan")
        
        Observable.of(10,100,1000)
        .scan(1) { aggregateValue, newValue in aggregateValue + newValue }
        .subscribe(onNext: {print($0)})
        .disposed(by: disposeBag)
        
        /// filter :只会让符合条件的元素通过
        
        printStar(type: "filter")
        
        Observable.of("1","2","3","4","5")
            .filter { $0 == "3" }
            .subscribe(onNext: {print($0)})
            .disposed(by: disposeBag)
        
        /// distinctUntilChanged : 抑制可观察序列发出的连续重复元素。
        
        printStar(type: "distinctUntilChanged")
        
        Observable.of("1","2","3","3","3","4","5")
            .distinctUntilChanged()
            .subscribe(onNext: {print($0)})
            .disposed(by: disposeBag)
        
        /// elementAt
        printStar(type: "elementAt")
        Observable.of("1","2","6","5")
        .elementAt(3)
        .subscribe(onNext: {print($0)})
        .disposed(by: disposeBag)
        
        /// single
        printStar(type: "single")
        Observable.of("1","2","3","4")
        .single()
        .subscribe(onNext: {print($0)})
        .disposed(by: disposeBag)
        
        /// single with conditions
        printStar(type: "single with conditions")
        Observable.of("1","2","3","4","5")
        .single() { $0 == "3"}
        .subscribe(onNext: {print($0)})
        .disposed(by: disposeBag)
        
        /// take 从可观察序列的开始仅释放指定数量的元素。
        printStar(type: "take")
        Observable.of("1","2","3","4")
        .take(4)
        .subscribe(onNext: {print($0)})
        .disposed(by: disposeBag)
        
        /// takeLast : 仅从可观察序列的结束处释放指定数量的元素。
        
        printStar(type: "takeLast")
        Observable.of("1","2","3","4","5")
        .takeLast(3)
        .subscribe(onNext: {print($0)})
        .disposed(by: disposeBag)
        
        /// takeWhile
        printStar(type: "takeWhile")
        Observable.of(1,2,3,4,5)
        .takeWhile { $0 < 4}
        .subscribe(onNext: {print($0)})
        .disposed(by: disposeBag)
        
        /// takeUntil : 接收事件消息，直到另一个可观察序列发出事件消息的时候。
        printStar(type: "takeUnitl")
        
        let sourceSequence = PublishSubject<String>()
        let referenceSequence = PublishSubject<String>()
        
        sourceSequence.takeUntil(referenceSequence)
            .subscribe(onNext: {print($0)})
        .disposed(by: disposeBag)
        
        sourceSequence.onNext("1")
        sourceSequence.onNext("2")
        sourceSequence.onNext("3")
        
        referenceSequence.onNext("10")

        sourceSequence.onNext("01")
        sourceSequence.onNext("02")
        sourceSequence.onNext("03")
        
        /// skip :禁止从可观察序列的开始发射指定数量的元素。
        printStar(type: "skip")
        Observable.of("1","2","3","4")
        .skip(3)
        .subscribe(onNext: {print($0)})
        .disposed(by: disposeBag)
        
        /// skipWhile : (条件跳过) 抑制从符合指定条件的可观察序列的开始发射元素。
        printStar(type: "skipWhile")
        Observable.of(1,2,3,4,5)
        .skipWhile {$0 < 4}
        .subscribe(onNext: {print($0)})
        .disposed(by: disposeBag)
        
        /// skipWhileWithIndex
        printStar(type: "skipWhileWithIndex")
        Observable.of("1","2","3","4","5")
        .skipWhileWithIndex {
         element, index in
                index < 3
         }
         .subscribe(onNext: {print($0)})
         .disposed(by: disposeBag)
    
        /// skipUntil : 直到某个可观察序列发出了事件消息，才开始接收当前序列发出的事件消息。
        printStar(type: "skipUntil")
        sourceSequence.skipUntil(referenceSequence)
        .subscribe(onNext: {print($0)})
        .disposed(by: disposeBag)
        
        sourceSequence.onNext("1")
        sourceSequence.onNext("2")
        sourceSequence.onNext("3")
        
        referenceSequence.onNext("10")
        
        sourceSequence.onNext("6")
        sourceSequence.onNext("7")
        sourceSequence.onNext("8")
        
        /// toArray : 将可观察的序列转换为数组，将该数组作为新的元素通过可观察序列发出，然后终止。
        printStar(type: "toArray")

        Observable.range(start: 1, count: 10)
        .toArray()
        .subscribe(onNext: {print($0)})
        .disposed(by: disposeBag)

        /// reduce : 从初始值开始，然后将累加器闭包应用于可观察序列发出的所有元素，并将聚合结果返回为单个元素可观察序列。
        printStar(type: "reduce")
        Observable.of(10,100,1000)
        .reduce(1, accumulator: *)
        .subscribe(onNext: {print($0)})
        .disposed(by: disposeBag)
        
        /// concat
        
//        let subject1 = BehaviorSubject(value: "apple")
//        let subject2 = BehaviorSubject(value : "dog")
        
//        let variable = Variable(subject1)
        printStar(type: "concat")
        
        variable.asObservable()
        .concat()
        .subscribe(onNext: {print($0)})
        .disposed(by: disposeBag)
        
        subject1.onNext("1")
        subject1.onNext("2")
        
        variable.value = subject2
        
        subject2.onNext("I would be ignored")
        subject2.onNext("3")
        
        subject1.onCompleted()
        
        subject2.onNext("4")
        
        /// connectable operators
        printStar(type: "connectable operators")
        
        /// Error Handling Operator
        printStar(type: "Error Handling Operator")
        
        let sequenceThatFails = PublishSubject<String>()
        
        sequenceThatFails.catchErrorJustReturn("🤯")
            .subscribe{print($0)}
        .disposed(by: disposeBag)
        
        sequenceThatFails.onNext("😩")
        sequenceThatFails.onNext("😇")
        sequenceThatFails.onNext("😝")
        sequenceThatFails.onNext("🤣")
        
        sequenceThatFails.onError(NSError(domain: "Test", code: -1, userInfo: nil))
        
        
        /// catchError
        
        printStar(type: "catchError")
        
        let recoverSequence = PublishSubject<String>()
        
        sequenceThatFails.catchError{
            print("Error:",$0)
            return recoverSequence
            }
            .subscribe{ print($0)}
        .disposed(by: disposeBag)
        
        sequenceThatFails.onNext("😩")
        sequenceThatFails.onNext("😇")
        sequenceThatFails.onNext("😝")
        sequenceThatFails.onNext("🤣")
        
        sequenceThatFails.onError(NSError(domain: "Test", code: -1, userInfo: nil))
        
        recoverSequence.onNext("😀")
        
        /// retry debug
        
        printStar(type: "retry and debug")
        var count = 1
        let sequenceThatErrors = Observable<String>.create {

            observer in

            observer.onNext("🍎")
            observer.onNext("🍏")
            observer.onNext("🍐")

            if count < 5 {
                observer.onError(NSError(domain: "Test", code: -1, userInfo: nil))
                print("Error encountered")
                count += 1
            }
            
            observer.onNext("🐶")
            observer.onNext("😅")
            observer.onNext("🤣")
            observer.onCompleted()
            
            return Disposables.create()

        }
        
        sequenceThatErrors.retry()
        .debug()
        .subscribe(onNext: {print($0)})
        .disposed(by: disposeBag)
        
        
        /// try Yourself
        
        _ = Observable.just("Hello, RxSwift!")
            .debug("observable")
            .subscribe()
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


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

let json = """
{
"nick_name": "job",
"point": 600,
"description": "this is a test about encodable"
}
""".data(using: .utf8)!

struct UserModle: Codable {
    var nickName: String
    var point: Int
    var description: String?
//    enum CodingKeys: String, CodingKey {
//        case nickName = "nick_name"
//        case point
//    }

}

class ViewController: UIViewController {

    var disposeBag = DisposeBag()

    lazy var fFld: UITextField = {
        let textFld = UITextField()
        textFld.font = UIFont.systemFont(ofSize: 16)
        textFld.placeholder = "enter a number"
        textFld.layer.cornerRadius = 3
        textFld.layer.borderWidth = 1
        textFld.layer.borderColor = UIColor.orange.cgColor
        textFld.keyboardType = .numberPad
        textFld.text = "1"
        textFld.textAlignment = NSTextAlignment.center
        return textFld
    }()

    lazy var sFld: UITextField = {
        let textFld = UITextField()
        textFld.font = UIFont.systemFont(ofSize: 16)
        textFld.placeholder = "enter a number"
        textFld.layer.cornerRadius = 3
        textFld.layer.borderWidth = 1
        textFld.layer.borderColor = UIColor.orange.cgColor
        textFld.keyboardType = .numberPad
        textFld.text = "2"
        textFld.textAlignment = NSTextAlignment.center
        return textFld
    }()

    lazy var result: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = UIColor.red
        label.layer.cornerRadius = 3
        label.layer.borderColor = UIColor.orange.cgColor
        label.layer.borderWidth = 1
        label.textAlignment = NSTextAlignment.center
        label.text = "3"
        return label
    }()

    override func viewDidLoad() {

        super.viewDidLoad()
        self.title = "RxSwift-Test"
        self.navigationController?.navigationBar.barTintColor = UIColor.purple
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]

        //第一个输入
        self.view.addSubview(fFld)
        self.view.addSubview(sFld)
        self.view.addSubview(result)

        fFld.snp.makeConstraints { (make) in
            make.top.equalTo(self.view).offset(100)
            make.left.equalTo(self.view).offset(60)
            make.right.equalTo(self.view).offset(-60)
            make.height.equalTo(40)
        }

        sFld.snp.makeConstraints { (make) in
            make.top.equalTo(fFld.snp.bottom).offset(20)
            make.left.right.height.equalTo(fFld)
        }

        result.snp.makeConstraints { (make) in
            make.top.equalTo(sFld.snp.bottom).offset(20)
            make.left.right.height.equalTo(sFld)
        }

        /// 订阅观察者
        Observable.combineLatest(fFld.rx.text.orEmpty, sFld.rx.text.orEmpty) { (fir, seco) -> Int in
            return (Int(fir) ?? 0) + (Int(seco) ?? 0)
        }
        .map { $0.description }
        .bind(to: result.rx.text)
        .disposed(by: self.disposeBag)

        let subject1 = BehaviorSubject(value: "A")
        let subject2 = BehaviorSubject(value: "B")

        let variable: Variable<String> = Variable("a")

        let subVariable = Variable(subject1)

        /// 测试自己绑定自己
        fFld.rx.text.orEmpty
            .map { String((Int($0) ?? 0) + 1) }
            .bind(to: fFld.rx.text)
            .disposed(by: disposeBag)

        fFld.rx.text.orEmpty
            .subscribe(onNext: { text in
                print("测试自己绑定自己之后还能绑定观察者么: \(text)")
            })
            .disposed(by: disposeBag)

        subVariable.asObservable()
            .flatMap { $0 }
            .materialize()
            .map({ (event) -> String in
                switch event {
                case .error(let error):
                    return error.localizedDescription
                case .next(let string):
                    return string
                case .completed:
                    return "completed"
                }
            })
            .subscribe(onNext: {
                print("@@@@@@@@@@\($0)")
            },onError: {
                print("########\($0)")
            })
            .disposed(by: disposeBag)

        subject1.asObservable()
            .flatMap { Observable.just($0)}
            .subscribe(onNext: {
                print("#####\($0)")
            }, onError: { error in
                print(error)
            })
            .disposed(by: disposeBag)

        subject1.onNext("C")
        variable.value = "b"
        variable.value = "c"
        variable.value = "d"
        subVariable.value = subject2
        subject2.onNext("D")
        subject1.onNext("E")
        subject1.onError(NSError(domain: "Test", code: -1, userInfo: nil))
        subject1.onNext("4")
        subject1.onNext("3")

//        /// Rx操作符
//        observableRefs()
        let deCoder = JSONDecoder()
        deCoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            let user = try deCoder.decode(UserModle.self, from: json)
            print("###########\(user.nickName)")
        } catch (let error) {
            print("@@@@@@@@\(error)")
        }
    }

    func returnUpper(with char: String) -> Observable<String> {
        return Observable.just(char.uppercased())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension ViewController {

    func testFlatMap() {

    }

    //swiftlint:disable function_body_length
    func observableRefs() {

        /// just
        Observable.just("🍎")
            .subscribe(onNext: { (event) in
                print(event)
            })
            .disposed(by: self.disposeBag)
        printStar(type: "just")

        /// of
        Observable.of("🐶","🐔","📚")
            .subscribe(onNext: {
                element in print(element)
            })
            .disposed(by: self.disposeBag)
        printStar(type: "of")
        /// from
        Observable.from(["1","2","3"])
            .subscribe(onNext: {print($0)})
            .disposed(by: self.disposeBag)
        printStar(type: "from")
        /// range
        Observable.range(start: 1, count: 10)
            .subscribe(onNext: {print($0)})
            .disposed(by: self.disposeBag)
        printStar(type: "range")
        /// repate
        Observable.repeatElement("🐩")
            .take(5)
            .subscribe(onNext: {print($0)})
            .disposed(by: self.disposeBag)
        printStar(type: "repate")
        /// generate
        Observable.generate(initialState: 0, condition: { $0 < 3 }, iterate: { $0 + 1})
            .subscribe(onNext: {print($0)})
            .disposed(by: self.disposeBag)
        printStar(type: "generate")
        /// startWith
        Observable.of("one","two","three")
            .startWith("1")
            .startWith("2")
            .startWith("3","4","5")
            .subscribe(onNext: {print($0)})
            .disposed(by: self.disposeBag)
        printStar(type: "stareWith")
        /// zip 将两个可观察序列按照顺序组合在一起,形成一个新的可观察序列,并一一对应。
        let stringSubject = PublishSubject<String>()
        let intSubject = PublishSubject<Int>()

        Observable.zip(stringSubject,intSubject) {
            stringElement,intElement in "\(stringElement) \(intElement)"
            }
            .subscribe(onNext: {print($0)})
            .disposed(by: self.disposeBag)
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
            .disposed(by: self.disposeBag)

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
            .disposed(by: self.disposeBag)

        /// switchLatest

        printStar(type: "switchLatest")

        let subject1 = BehaviorSubject(value: "bool")
        let subject2 = BehaviorSubject(value: "apple")

        let variable = Variable(subject1)

        variable.asObservable()
            .switchLatest()
            .subscribe(onNext: {print($0)})
            .disposed(by: self.disposeBag)

        subject1.onNext("🏈")
        subject1.onNext("🏀")

        variable.value = subject2

        subject1.onNext("⚽️")
        subject2.onNext("🍐")

        /// map

        printStar(type: "map")

        Observable.of(1,2,3)
            .map { $0 * $0 }
            .subscribe(onNext: {print($0)})
            .disposed(by: self.disposeBag)

        /// flatMap and flatMapLatest

        printStar(type: "flatMap and flatMapLatest")

        let boyPlayer = Player(score: Variable(80))
        let girlPlayer = Player(score: Variable(90))

        let player = Variable(boyPlayer)

        player.asObservable()
            .flatMapLatest { $0.score.asObservable() }
            .subscribe(onNext: {print($0)})
            .disposed(by: self.disposeBag)

        boyPlayer.score.value = 85

        player.value = girlPlayer

        boyPlayer.score.value = 95

        girlPlayer.score.value = 100

        /// scan

        printStar(type: "scan")

        Observable.of(10,100,1000)
            .scan(1) { aggregateValue, newValue in aggregateValue + newValue }
            .subscribe(onNext: {print($0)})
            .disposed(by: self.disposeBag)

        /// filter :只会让符合条件的元素通过

        printStar(type: "filter")

        Observable.of("1","2","3","4","5")
            .filter { $0 == "3" }
            .subscribe(onNext: {print($0)})
            .disposed(by: self.disposeBag)

        /// distinctUntilChanged : 抑制可观察序列发出的连续重复元素。

        printStar(type: "distinctUntilChanged")

        Observable.of("1","2","3","3","3","4","5")
            .distinctUntilChanged()
            .subscribe(onNext: {print($0)})
            .disposed(by: self.disposeBag)

        /// elementAt
        printStar(type: "elementAt")
        Observable.of("1","2","6","5")
            .elementAt(3)
            .subscribe(onNext: {print($0)})
            .disposed(by: self.disposeBag)

        /// single
        printStar(type: "single")
        Observable.of("1","2","3","4")
            .single()
            .subscribe(onNext: {print($0)})
            .disposed(by: self.disposeBag)

        /// single with conditions
        printStar(type: "single with conditions")
        Observable.of("1","2","3","4","5")
            .single { $0 == "3"}
            .subscribe(onNext: {print($0)})
            .disposed(by: self.disposeBag)

        /// take 从可观察序列的开始仅释放指定数量的元素。
        printStar(type: "take")
        Observable.of("1","2","3","4")
            .take(4)
            .subscribe(onNext: {print($0)})
            .disposed(by: self.disposeBag)

        /// takeLast : 仅从可观察序列的结束处释放指定数量的元素。

        printStar(type: "takeLast")
        Observable.of("1","2","3","4","5")
            .takeLast(3)
            .subscribe(onNext: {print($0)})
            .disposed(by: self.disposeBag)

        /// takeWhile
        printStar(type: "takeWhile")
        Observable.of(1,2,3,4,5)
            .takeWhile { $0 < 4}
            .subscribe(onNext: {print($0)})
            .disposed(by: self.disposeBag)

        /// takeUntil : 接收事件消息，直到另一个可观察序列发出事件消息的时候。
        printStar(type: "takeUnitl")

        let sourceSequence = PublishSubject<String>()
        let referenceSequence = PublishSubject<String>()

        sourceSequence.takeUntil(referenceSequence)
            .subscribe(onNext: {print($0)})
            .disposed(by: self.disposeBag)

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
            .disposed(by: self.disposeBag)

        /// skipWhile : (条件跳过) 抑制从符合指定条件的可观察序列的开始发射元素。
        printStar(type: "skipWhile")
        Observable.of(1,2,3,4,5)
            .skipWhile {$0 < 4}
            .subscribe(onNext: {print($0)})
            .disposed(by: self.disposeBag)

        /// skipWhileWithIndex
        printStar(type: "skipWhileWithIndex")
        Observable.of("1","2","3","4","5")
            .skipWhileWithIndex {
                element, index in
                index < 3
            }
            .subscribe(onNext: {print($0)})
            .disposed(by: self.disposeBag)

        /// skipUntil : 直到某个可观察序列发出了事件消息，才开始接收当前序列发出的事件消息。
        printStar(type: "skipUntil")
        sourceSequence.skipUntil(referenceSequence)
            .subscribe(onNext: {print($0)})
            .disposed(by: self.disposeBag)

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
            .disposed(by: self.disposeBag)

        /// reduce : 从初始值开始，然后将累加器闭包应用于可观察序列发出的所有元素，并将聚合结果返回为单个元素可观察序列。
        printStar(type: "reduce")
        Observable.of(10,100,1000)
            .reduce(1, accumulator: *)
            .subscribe(onNext: {print($0)})
            .disposed(by: self.disposeBag)

        /// concat

        //        let subject1 = BehaviorSubject(value: "apple")
        //        let subject2 = BehaviorSubject(value : "dog")

        //        let variable = Variable(subject1)
        printStar(type: "concat")

        variable.asObservable()
            .concat()
            .subscribe(onNext: {print($0)})
            .disposed(by: self.disposeBag)

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
            .subscribe {print($0)}
            .disposed(by: self.disposeBag)

        sequenceThatFails.onNext("😩")
        sequenceThatFails.onNext("😇")
        sequenceThatFails.onNext("😝")
        sequenceThatFails.onNext("🤣")

        sequenceThatFails.onError(NSError(domain: "Test", code: -1, userInfo: nil))

        /// catchError

        printStar(type: "catchError")

        let recoverSequence = PublishSubject<String>()

        sequenceThatFails.catchError {
            print("Error:",$0)
            return recoverSequence
            }
            .subscribe { print($0)}
            .disposed(by: self.disposeBag)

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
            .subscribe(onNext: {print($0)})
            .disposed(by: self.disposeBag)

        /// try Yourself

        _ = Observable.just("Hello, RxSwift!")
            .subscribe()
    }
    //swiftlint:enable function_body_length
    func printStar(type: String) {
        print("\(type):  *************************")
    }

}

struct Player {
    var score: Variable<Int>
}

//
//  ViewController.swift
//  test123
//
//  Created by 4A Labs on 21.07.2023.
//

import UIKit
import RxRelay
import RxSwift

class crashvm{
    
    static let shared = crashvm()
    
    var productList = BehaviorRelay<[Product]>(value: [Product(name: "name", price: 10, description: "asd")]) // products list. is expandable when lazy load is enabled.
    
}

struct Product {
    let name: String
    let price: Double
    let description: String
}

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var count = 0
    @IBAction func click(_ sender: Any) {
        count += 1
        //while(true){
        if(count % 2 == 0){
            DispatchQueue.global(qos: .background).async {
                crashvm.shared.productList.accept(
                    [Product(name: "2name", price: 10, description: "asd"),
                     Product(name: "name", price: 10, description: "asd"),
                     Product(name: "name", price: 10, description: "asd"),
                     Product(name: "name", price: 10, description: "asd"),
                     Product(name: "name", price: 10, description: "asd"),
                     Product(name: "name", price: 10, description: "asd"),
                     Product(name: "name", price: 10, description: "asd"),
                     Product(name: "name", price: 10, description: "asd"),
                     Product(name: "name", price: 10, description: "asd")]
                )
            }
            
        }else{
            DispatchQueue.global(qos: .background).async {
                
                crashvm.shared.productList.accept(
                    [Product(name: "2name", price: 10, description: "asd"),
                     Product(name: "name", price: 10, description: "asd"),
                     Product(name: "name", price: 10, description: "asd")]
                )
            }
            
        }
        
        //   }
        
    }
    let dataSource = MyCollectionViewDataSource()
    let disposebag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        crashvm.shared.productList.observe(on: MainScheduler.instance).subscribe(
            onNext: {[weak self]_ in
                // if (crashvm.shared.productList.value.count != 0) {
                self?.collectionView.reloadData()
                print("reload called")
            },
            onError: { error in
                // This block will execute on the main thread
                // print("Error: \(error)")
            })
        .disposed(by: disposebag)
        collectionView.dataSource = dataSource
        // Register the cell class with the collection view
        collectionView.register(MyCollectionViewCell.self, forCellWithReuseIdentifier: "CellReuseIdentifier")
    }
    
}


class MyCollectionViewCell: UICollectionViewCell {
    // Your custom cell implementation here
    var labelo: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLabel()
    }
    
    private func setupLabel() {
        labelo = UILabel()
        labelo.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(labelo)
        
        // Constraints to position the label within the cell's contentView
        NSLayoutConstraint.activate([
            labelo.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            labelo.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            labelo.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            labelo.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
}


class MyCollectionViewDataSource: NSObject, UICollectionViewDataSource {
    let data :[String]? = nil
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // print("point1")
        
        let count = crashvm.shared.productList.value.count
        //fix for this issue is >
        //DispatchQueue.main.async {
        //or
        //DispatchQueue.global(qos: .unspecified).asyncAfter(deadline: DispatchTime.now() + 2.6){
        //  }
        printMachineTimeInMicroseconds(inn:"numberofitems")
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        printMachineTimeInMicroseconds(inn:"cellForItemAt") //55225 - 54823 = 402 microsecond / 0.4ms in iphone 14 pro simulator
        DispatchQueue.global(qos: .background).asyncAfter(deadline: DispatchTime.now() + 1) {
            //this puts into the main queue so resolves the issue ->
            //DispatchQueue.main.async {
                crashvm.shared.productList.accept(
                    [Product(name: "2name", price: 10, description: "asd"),
                     Product(name: "name", price: 10, description: "asd"),
                     Product(name: "name", price: 10, description: "asd")]
                )
           // }
        }
        // Always use the correct method to dequeue the cell
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellReuseIdentifier", for: indexPath) as? MyCollectionViewCell, let data:Product = crashvm.shared.productList.value[safe: indexPath.row] else {
            return UICollectionViewCell()
        }
        //print("point2")
        
        cell.labelo.text = data.name
        
        // Configure the cell with data here
        return cell
        /*
         // Always use the correct method to dequeue the cell
         guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellReuseIdentifier", for: indexPath) as? MyCollectionViewCell else {
         return UICollectionViewCell()
         }
         let data:Product? = crashvm.shared.productList.value[safe: indexPath.row] ?? nil
         cell.labelo.text = data?.name
         // Configure the cell with data here
         return cell
         
         */
    }
    func printMachineTimeInMicroseconds(inn:String) {
        // Get the current date and time
        let currentTime = Date()
        
        // Get the current time in microseconds
        let microSeconds = Calendar.current.component(.nanosecond, from: currentTime) / 1000
        
        // Print the time in microseconds
        print("Machine time in microseconds: \(microSeconds) µs \(inn)")
    }
    
}

public extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}




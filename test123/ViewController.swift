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

    let dataSource = MyCollectionViewDataSource()
    let disposebag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
   
        
        DispatchQueue.global(qos: .unspecified).asyncAfter(deadline: DispatchTime.now() + 0.6){
            crashvm.shared.productList.accept(
                [Product(name: "name", price: 10, description: "asd"),
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
        
       
        crashvm.shared.productList.observe(on: MainScheduler.instance).subscribe(onNext: {[weak self]_ in
            self?.collectionView.reloadData()
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
        print("run1")
       
        let count = crashvm.shared.productList.value.count
            crashvm.shared.productList.accept(
                [Product(name: "name", price: 10, description: "asd"),
                 Product(name: "name1", price: 11, description: "asd1"),
                 Product(name: "name2", price: 12, description: "asd2"),
                 Product(name: "name3", price: 13, description: "asd3"),Product(name: "name33", price: 13, description: "asd3")]
            )
  
        return count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Always use the correct method to dequeue the cell
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellReuseIdentifier", for: indexPath) as? MyCollectionViewCell, let data:Product = crashvm.shared.productList.value[safe: indexPath.row] else {
            return UICollectionViewCell()
        }
        print("run2")

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
}

public extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}




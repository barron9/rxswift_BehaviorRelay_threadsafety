# rxswift_BehaviorRelay_threadsafety
reproduce the problem and fix
there is 0.4 ms latency between datasource delegate numberOfItemsInSection and itemsAtRow methods , so if any background thread changes the rxbehavioralrelay it will call ```collectionView.reloadData()```but it goes down continue executing if done for several times.

//55225 - 54823 = 402 microsecond / 0.4ms in iphone 14 pro simulator

```swift
class MyCollectionViewDataSource: NSObject, UICollectionViewDataSource {
    let data :[String]? = nil
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("point1")
        
        let count = crashvm.shared.productList.value.count
        //fix for this issue is >
        //DispatchQueue.main.async {
        crashvm.shared.productList.accept(
            [Product(name: "name", price: 10, description: "asd"),
             Product(name: "name1", price: 11, description: "asd1"),
             Product(name: "name2", price: 12, description: "asd2"),
             Product(name: "name3", price: 13, description: "asd3"),Product(name: "name33", price: 13, description: "asd3")]
        )
        //  }
        
        return count
    }
```

another way to crash
```swift
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
```

```
2023-07-22 17:44:47.944362+0300 test123[4206:4954563] *** Assertion failure in -[UICollectionView _createPreparedCellForItemAtIndexPath:withLayoutAttributes:applyAttributes:isFocused:notify:], UICollectionView.m:3390
2023-07-22 17:44:47.975588+0300 test123[4206:4954563] *** Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'the cell returned from -collectionView:cellForItemAtIndexPath: does not have a reuseIdentifier - cells must be retrieved by calling -dequeueReusableCellWithReuseIdentifier:forIndexPath:'
*** First throw call stack:
(
	0   CoreFoundation                      0x0000000180437330 __exceptionPreprocess + 172
	1   libobjc.A.dylib                     0x0000000180051274 objc_exception_throw + 56
	2   Foundation                          0x0000000180ae29b4 _userInfoForFileAndLine + 0
	3   UIKitCore                           0x00000001095077d0 -[UICollectionView _createPreparedCellForItemAtIndexPath:withLayoutAttributes:applyAttributes:isFocused:notify:] + 2292
	4   UIKitCore                           0x000000010950f7c4 -[UICollectionView _createVisibleViewsForSingleCategoryAttributes:limitCreation:fadeForBoundsChange:] + 1064
	5   UIKitCore                           0x000000010950fad4 -[UICollectionView _createVisibleViewsForAttributes:fadeForBoundsChange:notifyLayoutForVisibleCellsPass:] + 276
	6   UIKitCore                           0x000000010950e1d0 -[UICollectionView _updateVisibleCellsNow:] + 1612
	7   UIKitCore                           0x0000000109513134 -[UICollectionView layoutSubviews] + 300
	8   UIKitCore                           0x000000010a1bac00 -[UIView(CALayerDelegate) layoutSublayersOfLayer:] + 1860
	9   QuartzCore                          0x0000000187dfd528 _ZN2CA5Layer16layout_if_neededEPNS_11TransactionE + 440
	10  QuartzCore                          0x0000000187e08288 _ZN2CA5Layer28layout_and_display_if_neededEPNS_11TransactionE + 128
	11  QuartzCore                          0x0000000187d32130 _ZN2CA7Context18commit_transactionEPNS_11TransactionEdPd + 440
	12  QuartzCore                          0x0000000187d5d0f4 _ZN2CA11Transaction6commitEv + 636
	13  QuartzCore                          0x0000000187d5e518 _ZN2CA11Transaction25flush_as_runloop_observerEb + 68
	14  CoreFoundation                      0x0000000180399c10 __CFRUNLOOP_IS_CALLING_OUT_TO_AN_OBSERVER_CALLBACK_FUNCTION__ + 32
	15  CoreFoundation                      0x000000018039457c __CFRunLoopDoObservers + 512
	16  CoreFoundation                      0x0000000180394a20 __CFRunLoopRun + 948
	17  CoreFoundation                      0x0000000180394254 CFRunLoopRunSpecific + 584
	18  GraphicsServices                    0x0000000188eb7c9c GSEventRunModal + 160
	19  UIKitCore                           0x0000000109d16ff0 -[UIApplication _run] + 868
	20  UIKitCore                           0x0000000109d1af3c UIApplicationMain + 124
	21  libswiftUIKit.dylib                 0x0000000102d78454 $s5UIKit17UIApplicationMainys5Int32VAD_SpySpys4Int8VGGSgSSSgAJtF + 100
	22  test123                             0x0000000102213c50 $sSo21UIApplicationDelegateP5UIKitE4mainyyFZ + 120
	23  test123                             0x0000000102213bc8 $s7test12311AppDelegateC5$mainyyFZ + 44
	24  test123                             0x0000000102213ccc main + 28
	25  dyld                                0x00000001026a9514 start_sim + 20
	26  ???                                 0x0000000102775f28 0x0 + 4336344872
	27  ???                                 0x1750000000000000 0x0 + 1679842661009195008
)
libc++abi: terminating due to uncaught exception of type NSException

```

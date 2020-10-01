//
//  ViewController.swift
//  iOS14Photo
//
//  Created by Zedd on 2020/09/20.
//

import UIKit
import Photos
import PhotosUI

class ViewController: UIViewController, PHPhotoLibraryChangeObserver {
    
    var fetchResult = PHFetchResult<PHAsset>()
    var canAccessImages: [UIImage] = []
    var thumbnailSize: CGSize {
        let scale = UIScreen.main.scale
        return CGSize(width: (UIScreen.main.bounds.width / 3) * scale, height: 100 * scale)
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // PHPhotoLibrary.shared().register(self) // 여기서 호출하게 되면 앱 삭제 후 처음 실행시 Add버튼을 누르지 않아도 사진 접근 권한 alert이 뜨게 된다.
        self.setupCollectionView()
        self.setupNavigationItem()
    }
    
    func setupNavigationItem() {
        let add = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(self.addButtonDidTap))
        self.navigationItem.rightBarButtonItem = add
    }
    
    func setupCollectionView() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    @objc
    func addButtonDidTap() {
        self.requestPHPhotoLibraryAuthorization {
            self.getCanAccessImages()
        }
    }
    
    func requestPHPhotoLibraryAuthorization(completion: @escaping () -> Void) {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { (status) in
            switch status {
            case .limited:
                PHPhotoLibrary.shared().register(self)
                completion()
            default:
                break
            }
        }
    }
    
    func getCanAccessImages() {
        self.canAccessImages = []
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true

        let fetchOptions = PHFetchOptions()
        self.fetchResult = PHAsset.fetchAssets(with: fetchOptions)
        self.fetchResult.enumerateObjects { (asset, _, _) in
            PHImageManager().requestImage(for: asset, targetSize: self.thumbnailSize, contentMode: .aspectFill, options: requestOptions) { (image, info) in
                guard let image = image else { return }
                self.canAccessImages.append(image)
                DispatchQueue.main.async {
                    self.collectionView.insertItems(at: [IndexPath(item: self.canAccessImages.count - 1, section: 0)])
                }
            }
        }
    }
    // MARK: - PHPhotoLibraryChangeObserver
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        self.getCanAccessImages()
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.canAccessImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as! ImageCollectionViewCell
        cell.imageView.image = self.canAccessImages[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: self.view.frame.width / 3, height: 100)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            self.imageView.contentMode = .scaleAspectFill
        }
    }
}

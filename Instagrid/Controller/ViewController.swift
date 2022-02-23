//
//  ViewController.swift
//  Instagrid
//
//  Created by Kevin Bertrand on 22/02/2022.
//

import PhotosUI
import UIKit

class ViewController: UIViewController {
    // MARK: Outlets
    @IBOutlet var layoutSelectedImages: [UIImageView]!
    @IBOutlet var layoutButtons: [UIButton]!
    @IBOutlet weak var swipeLeftToShareView: UIView!
    @IBOutlet weak var swipeUpToShareView: UIView!
    @IBOutlet weak var pictureView: PicturesView!
    
    // MARK: Properties
    private var selectedImageButton: UIButton?
    
    // MARK: View methods
    override func viewDidLoad() {
        super.viewDidLoad()
        pictureView.resetGrid()
        checkSelectedLayout(.allFour)
        configureSwipeGesture()
    }
    
    // MARK: Actions
    @IBAction func selectLayoutButtonTouched(_ sender: UIButton) {
        switch sender {
        case layoutButtons[0]:
            checkSelectedLayout(.oneImageTop)
        case layoutButtons[1]:
            checkSelectedLayout(.oneImageBottom)
        case layoutButtons[2]:
            checkSelectedLayout(.allFour)
        default:
            break
        }
    }
    
    @IBAction func selectImageButtonTouched(_ sender: UIButton) {
        selectedImageButton = sender
        showImagePicker()
    }
    
    // MARK: Methods
    private func checkSelectedLayout(_ layout: Layout) {
        unselectAllLayoutButtons()
        pictureView.layout = layout
        switch layout {
        case .oneImageTop:
            layoutSelectedImages[0].isHidden = false
        case .oneImageBottom:
            layoutSelectedImages[1].isHidden = false
        case .allFour:
            layoutSelectedImages[2].isHidden = false
        }
    }
    
    private func unselectAllLayoutButtons() {
        layoutSelectedImages.forEach { $0.isHidden = true }
    }
    
    private func configureSwipeGesture() {
        let swipeGestureRecognizerUp = UISwipeGestureRecognizer(target: self, action: #selector(performSwipe(sender:)))
        swipeGestureRecognizerUp.direction = .up
        swipeUpToShareView.addGestureRecognizer(swipeGestureRecognizerUp)
        
        let swipeGestureRecognizerLeft = UISwipeGestureRecognizer(target: self, action: #selector(performSwipe(sender:)))
        swipeGestureRecognizerLeft.direction = .left
        swipeLeftToShareView.addGestureRecognizer(swipeGestureRecognizerLeft)
    }
    
    @objc private func performSwipe(sender: UIGestureRecognizer) {
        // TODO: Check direction (2 = left & 4 = up). Warning: The value(forKey) return an optional!
        print(sender.value(forKey: "direction"))
    }
}

extension ViewController: PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private func showImagePicker() {
        if #available(iOS 14.0, *) {
            var pickerConfiguration = PHPickerConfiguration()
            pickerConfiguration.filter = .images
            pickerConfiguration.selectionLimit = 1
            let imagePicker = PHPickerViewController(configuration: pickerConfiguration)
            imagePicker.delegate = self
            present(imagePicker, animated: true, completion: nil)
        } else {
            let imagePickerVC = UIImagePickerController()
            imagePickerVC.sourceType = .photoLibrary
            imagePickerVC.delegate = self
            present(imagePickerVC, animated: true, completion: nil)
        }
    }
    
    @available(iOS 14, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true, completion: nil)
        guard !results.isEmpty else { return }
        
        results[0].itemProvider.loadObject(ofClass: UIImage.self) { object, error in
            if let image = object as? UIImage,
               let imageButton = self.selectedImageButton {
                DispatchQueue.main.async {
                    imageButton.setImage(image, for: .normal)
                }
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage,
           let imageButton = selectedImageButton {
            imageButton.setImage(image, for: .normal)
        }
        dismiss(animated: true, completion: nil)
    }
}


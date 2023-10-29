//
//   Image++.swift
//  TextSight
//
//  Created by Kavindu Dissanayake on 2023-10-29.
//
import SwiftUI
import Mantis


extension Image {
    func centerCropped() -> some View {
        GeometryReader { geo in
            self
            .resizable()
            .scaledToFill()
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()
        }
    }
}

extension View {
    func imageCropperModifier(croppedImage: Binding<UIImage?>) -> some View {
        self.modifier(ImageCropperModifier(croppedImage: croppedImage))
    }
}

struct ImageCropperModifier: ViewModifier {
    @State var selectedImage: UIImage?
    @State var showImagePicker = false
    @State var showImageCroper = false
    @Binding var croppedImage: UIImage?

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: self.$showImageCroper) {
                ImageCropper(
                    image: $selectedImage,
                    cropShapeType: .constant(.rect),
                    presetFixedRatioType: .constant(.canUseMultiplePresetFixedRatio()),
                    type: .constant(.normal)
                ) { croppedImage in
                    self.croppedImage = croppedImage
                }
                .ignoresSafeArea()
            }
            .onChange(of: showImagePicker) { newValue in
                guard let _ = selectedImage, !newValue else { return }
                showImageCroper.toggle()
            }
            .modifier(ImagePickerButtonModifier(image: $selectedImage, showImagePicker: $showImagePicker))
    }
}


struct ImagePickerButtonModifier: ViewModifier {
    @Binding var image: UIImage?
    @State private var showSheet: Bool = false
    @Binding var showImagePicker: Bool
    @State var sourceType: UIImagePickerController.SourceType = .photoLibrary

    func body(content: Content) -> some View {
        content
            .onTapGesture {
                showSheet.toggle()
            }
            .actionSheet(isPresented: $showSheet) {
                ActionSheet(title: Text("Select Photo"), buttons: [
                    .default(Text("Photo Library")) {
                        showImagePicker = true
                        sourceType = .photoLibrary
                    },
                    .default(Text("Camera")) {
                        showImagePicker = true
                        sourceType = .camera
                    },
                    .cancel()
                ])
            }
            .sheet(isPresented: self.$showImagePicker) {
                ImagePicker(image: $image, isShown: self.$showImagePicker, sourceType: sourceType)
            }
    }
}


struct ImagePicker: UIViewControllerRepresentable {
   
    @Binding var image: UIImage?
    @Binding var isShown: Bool
    
    var sourceType: UIImagePickerController.SourceType
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        if sourceType == .camera {
            picker.showsCameraControls = true
        }
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(imagePicker: self)
    }
    
    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        
        let imagePicker: ImagePicker
        
        init(imagePicker: ImagePicker) {
            self.imagePicker = imagePicker
        }
        
        //Selected Image
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.editedImage] as? UIImage {
                imagePicker.image = image
                imagePicker.isShown = true
            } else {}
            picker.dismiss(animated: true)
        }
        
        //Image selection got cancel
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            imagePicker.isShown = false
        }
    }
}




enum ImageCropperType {
    case normal
    case noRotaionDial
    case noAttachedToolbar
}

struct ImageCropper: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var cropShapeType: Mantis.CropShapeType
    @Binding var presetFixedRatioType: Mantis.PresetFixedRatioType
    @Binding var type: ImageCropperType
    var onImageCropped: ((UIImage) -> Void)?  // Callback to return the cropped image

    @Environment(\.presentationMode) var presentationMode
    
    class Coordinator: CropViewControllerDelegate {
        var parent: ImageCropper
        
        init(_ parent: ImageCropper) {
            self.parent = parent
        }
        
        func cropViewControllerDidCrop(_ cropViewController: Mantis.CropViewController, cropped: UIImage, transformation: Transformation, cropInfo: CropInfo) {
            parent.onImageCropped?(cropped)
            print("transformation is \(transformation)")
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func cropViewControllerDidCancel(_ cropViewController: Mantis.CropViewController, original: UIImage) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        switch type {
        case .normal:
            return makeNormalImageCropper(context: context)
        case .noRotaionDial:
            return makeImageCropperHiddingRotationDial(context: context)
        case .noAttachedToolbar:
            return makeImageCropperWithoutAttachedToolbar(context: context)
        }
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
}

extension ImageCropper {
    func makeNormalImageCropper(context: Context) -> UIViewController {
        var config = Mantis.Config()
        config.cropViewConfig.cropShapeType = cropShapeType
        config.presetFixedRatioType = presetFixedRatioType
        let cropViewController = Mantis.cropViewController(image: image!,
                                                           config: config)
        cropViewController.delegate = context.coordinator
        return cropViewController
    }
    
    func makeImageCropperHiddingRotationDial(context: Context) -> UIViewController {
        var config = Mantis.Config()
        config.cropViewConfig.showRotationDial = false
        let cropViewController = Mantis.cropViewController(image: image!, config: config)
        cropViewController.delegate = context.coordinator

        return cropViewController
    }
    
    func makeImageCropperWithoutAttachedToolbar(context: Context) -> UIViewController {
        var config = Mantis.Config()
        config.showAttachedCropToolbar = false
        let cropViewController: CustomViewController = Mantis.cropViewController(image: image!, config: config)
        cropViewController.delegate = context.coordinator

        return UINavigationController(rootViewController: cropViewController)
    }
}


class CustomViewController: Mantis.CropViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Custom View Controller"

        let rotate = UIBarButtonItem(
            image: UIImage.init(systemName: "crop.rotate"),
            style: .plain,
            target: self,
            action: #selector(onRotateClicked)
        )

        let done = UIBarButtonItem(
            image: UIImage.init(systemName: "checkmark"),
            style: .plain,
            target: self,
            action: #selector(onDoneClicked)
        )

        navigationItem.rightBarButtonItems = [
            done,
            rotate
        ]
    }

    @objc private func onRotateClicked() {
        didSelectClockwiseRotate()
    }

    @objc private func onDoneClicked() {
        crop()
    }
}

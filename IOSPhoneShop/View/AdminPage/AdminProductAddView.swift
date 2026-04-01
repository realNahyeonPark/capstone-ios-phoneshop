/* AdminProductAddView.swift */
import SwiftUI
import PhotosUI

struct AdminProductAddView: View {
    @State private var name: String = ""
    @State private var brand: String = ""
    @State private var price: String = ""
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    @State private var isUploading: Bool = false
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @Environment(\.dismiss) var dismiss

    var body: some View {
        Form {
            Section(header: Text("상품 이미지")) {
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                    } else {
                        Label("사진 선택하기", systemImage: "photo.on.rectangle")
                    }
                }
                .onChange(of: selectedItem) { oldItem, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                            let image = UIImage(data: data) {
                            selectedImage = image
                        }
                    }
                }
            }
            
            Section(header: Text("상품 정보")) {
                TextField("모델명", text: $name)
                TextField("브랜드", text: $brand)
                TextField("가격", text: $price)
                    .keyboardType(.numberPad)
            }
            
            Button(action: uploadProduct) {
                if isUploading {
                    ProgressView()
                } else {
                    Text("등록하기")
                        .frame(maxWidth: .infinity)
                }
            }
            .disabled(name.isEmpty || brand.isEmpty || price.isEmpty || selectedImage == nil || isUploading)
        }
        .navigationTitle("상품 등록")
        .alert("알림", isPresented: $showAlert) {
                    Button("확인") {
                        if alertMessage == "상품 등록에 성공했습니다!" { dismiss() }
                    }
                } message: {
                    Text(alertMessage)
                }
    }
    
    func uploadProduct() {
            guard let image = selectedImage, let priceInt = Int(price) else { return }
            isUploading = true
            
            ProductService.shared.createProduct(name: name, brand: brand, price: priceInt, image: image) { success in
                isUploading = false
                if success {
                    alertMessage = "상품 등록에 성공했습니다!"
                    showAlert = true
                } else {
                    alertMessage = "등록에 실패했습니다. 다시 시도해 주세요."
                    showAlert = true
                }
            }
        }
}

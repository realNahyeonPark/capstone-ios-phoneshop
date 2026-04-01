import SwiftUI

struct FilterModalView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var config: FilterConfig
    let allProducts: [Product]
    let query: String
    
    let brands = ["Apple", "Samsung", "Xiaomi", "Google"]
    let maxLimit: Double = 5000000

    var filteredCount: Int {
        allProducts.filter { product in
            let matchesQuery = query.isEmpty || product.name.localizedCaseInsensitiveContains(query)
            
            let matchesBrand = config.selectedBrands.isEmpty || config.selectedBrands.contains(product.brand)
            
            let productPrice = Double(product.price)
            let matchesPrice = productPrice >= config.minPrice && productPrice <= config.maxPrice
            
            return matchesQuery && matchesBrand && matchesPrice
        }.count
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("브랜드").font(.headline)
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                                ForEach(brands, id: \.self) { brand in
                                    brandButton(brand)
                                }
                            }
                        }
                        
                        Divider()

                        VStack(alignment: .leading, spacing: 15) {
                            Text("가격 범위").font(.headline)
                            
                            HStack {
                                Text("\(Int(config.minPrice))원")
                                Spacer()
                                Text("\(Int(config.maxPrice))원")
                            }
                            .font(.subheadline).foregroundColor(.blue)

                            VStack(spacing: 0) {
                                Slider(value: $config.maxPrice, in: 0...maxLimit, step: 100000)
                                    .accentColor(.blue)
                                    .transaction { transaction in
                                        transaction.animation = nil
                                    }
                            }

                            HStack(spacing: 12) {
                                priceTextField("최소", value: $config.minPrice)
                                Text("~")
                                priceTextField("최대", value: $config.maxPrice)
                            }
                        }
                        
                        Color.clear.frame(height: 100)
                    }
                    .padding()
                }

                VStack(spacing: 0) {
                    Divider()
                    Button {
                        dismiss()
                    } label: {
                        Text("\(filteredCount)개 상품 보기")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                            .background(Color.blue)
                            .cornerRadius(10)
                            .padding()
                    }
                    .background(Color.white)
                }
            }
            .background(Color.white)
            .navigationTitle("필터 상세설정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("초기화") {
                        var transaction = Transaction()
                        transaction.animation = nil
                        withTransaction(transaction) {
                            config = FilterConfig()
                        }
                    }
                    .foregroundColor(.gray)
                }
            }
        }
    }

    private func brandButton(_ brand: String) -> some View {
        Button {
            var transaction = Transaction()
            transaction.animation = nil
            withTransaction(transaction) {
                if config.selectedBrands.contains(brand) {
                    config.selectedBrands.remove(brand)
                } else {
                    config.selectedBrands.insert(brand)
                }
            }
        } label: {
            Text(brand)
                .font(.subheadline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(config.selectedBrands.contains(brand) ? Color.blue.opacity(0.1) : Color(.systemGray6))
                .foregroundColor(config.selectedBrands.contains(brand) ? .blue : .primary)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(config.selectedBrands.contains(brand) ? Color.blue : Color.clear, lineWidth: 1)
                )
        }
        .cornerRadius(8)
    }

    private func priceTextField(_ title: String, value: Binding<Double>) -> some View {
        TextField(title, value: value, format: .number)
            .keyboardType(.numberPad)
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(8)
    }
}

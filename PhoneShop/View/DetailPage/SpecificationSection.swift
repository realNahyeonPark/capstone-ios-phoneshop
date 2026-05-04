import SwiftUI

struct SpecificationSection: View {
    let product: Product
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("상세 스펙")
                .font(.system(size: 18, weight: .bold))
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                specRow(title: "모델명", value: product.name)
                specRow(title: "브랜드", value: product.brand)
                
                if isExpanded {
                    specRow(title: "OS", value: product.brand)
                    specRow(title: "디스플레이", value: "")
                    specRow(title: "프로세서", value: "")
                    specRow(title: "RAM / 저장용량", value: "")
                    specRow(title: "배터리", value: "")
                    specRow(title: "카메라", value: "")
                }
                
                Button(action: {
                    withAnimation(.easeInOut) {
                        isExpanded.toggle()
                    }
                }) {
                    HStack {
                        Text(isExpanded ? "상세 스펙 접기" : "상세 스펙 더보기")
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                }
            }
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
    
    private func specRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
                .frame(width: 100, alignment: .leading)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .padding()
        .font(.system(size: 14))
        .overlay(Divider(), alignment: .bottom)
    }
}

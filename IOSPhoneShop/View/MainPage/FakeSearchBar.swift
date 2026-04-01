/* FakeSearchBar.swift */
import SwiftUI

struct FakeSearchBar: View {
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            Text("상품을 검색해보세요")
                .foregroundColor(.gray)
                .font(.system(size: 15))
            Spacer()
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        .padding(.vertical, 8)
    }
}

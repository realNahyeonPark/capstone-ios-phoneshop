/* BannerView.swift */
import SwiftUI

struct BannerView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 0)
            .fill(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.cyan]), startPoint: .leading, endPoint: .trailing))
            .frame(height: 150)
            .overlay(
                HStack {
                    VStack(alignment: .leading) {
                        Text("신규 가입 10% 할인")
                            .font(.title3).bold()
                    }
                    .foregroundColor(.white)
                    .padding()
                    Spacer()
                }
            )
            .padding(.bottom, 10)
    }
}

import SwiftUI

struct SectionCardView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title).font(.subheadline).fontWeight(.bold).foregroundColor(.secondary)
            content
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
    }
}

struct OrderHeaderView: View {
    let dismiss: DismissAction
    var body: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left").font(.title3).foregroundColor(.primary)
                    .padding(10).background(Circle().fill(Color.white))
            }
            Spacer()
            Text("주문/결제").font(.headline).fontWeight(.bold)
            Spacer()
            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal).padding(.vertical, 12).background(Color(.systemGray6))
    }
}

struct PricingRow: View {
    let title: String
    let amount: String
    var color: Color = .primary
    var body: some View {
        HStack {
            Text(title).foregroundColor(.secondary)
            Spacer()
            Text(amount).foregroundColor(color)
        }
    }
}

struct KakaoPayIconView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 6).fill(Color(hex: "FEE500"))
            .frame(width: 40, height: 40)
            .overlay(Text("P").fontWeight(.black).font(.system(size: 20)))
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

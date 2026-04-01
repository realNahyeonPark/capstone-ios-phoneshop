/* CouponRow.swift */
import SwiftUI

struct CouponRow: View {
    let coupon: CouponItem
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(coupon.discountString.replacingOccurrences(of: "원", with: ""))
                        .font(.system(size: 28, weight: .bold))
                    Text("원")
                        .font(.system(size: 18, weight: .bold))
                }
                .foregroundColor(Color(hex: "222930"))
                
                HStack(spacing: 4) {
                    Text("구매 금액 제한없음")
                        .font(.system(size: 14, weight: .bold))
                    Image(systemName: "info.circle")
                        .font(.system(size: 12))
                }
                .foregroundColor(Color(hex: "4A5568"))
                
            }
            .padding(.leading, 20)
            .padding(.vertical, 20)
            
            Spacer()
            
            Line()
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [4]))
                .frame(width: 1)
                .foregroundColor(Color.gray.opacity(0.4))
                .padding(.vertical, 15)
            
            ZStack {
                Rectangle()
                    .fill(Color(hex: "E57358"))
                    .frame(width: 40)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 12, height: 12)
                    .offset(x: -20)
            }
        }
        .background(Color.white)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }
}

struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        return path
    }
}

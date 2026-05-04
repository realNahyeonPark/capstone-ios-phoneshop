import SwiftUI

struct CartItemRow: View {
    @EnvironmentObject var cartService: CartService
    let item: CartItem

    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            AsyncImage(url: URL(string: item.imageUrl)) { phase in
                if let image = phase.image {
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Color.gray.opacity(0.1)
                }
            }
            .frame(width: 90, height: 90)
            .cornerRadius(4)
            .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color(.systemGray6), lineWidth: 1))

            VStack(alignment: .leading, spacing: 10) {
                Text(item.name)
                    .font(.system(size: 15, weight: .medium))
                    .lineLimit(2)
                    .foregroundColor(.primary)

                Text("\(item.formattedPrice)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)

                HStack(spacing: 0) {
                    Button(action: { cartService.decreaseQuantity(phoneId: item.phoneId) }) {
                        Image(systemName: "minus")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.gray)
                            .frame(width: 35, height: 35)
                    }
                    
                    Divider().frame(height: 20)
                    
                    Text("\(item.quantity)")
                        .font(.system(size: 14, weight: .medium))
                        .frame(width: 45)
                    
                    Divider().frame(height: 20)
                    
                    Button(action: { cartService.addToCart(phoneId: item.phoneId) }) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.blue)
                            .frame(width: 35, height: 35)
                    }
                }
                .background(Color.white)
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color(.systemGray4), lineWidth: 0.5))
            }
            Spacer()
        }
        .padding(.vertical, 20)
        .padding(.horizontal)
        .background(Color.white)
    }
}

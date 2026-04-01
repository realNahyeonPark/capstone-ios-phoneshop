/* CartItemRow.swift */
import SwiftUI

struct CartItemRow: View {
    @EnvironmentObject var cartManager: CartManager
    
    let item: CartItem

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: item.imageUrl)) { phase in
                if let image = phase.image {
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Image(systemName: "iphone")
                        .foregroundColor(.gray)
                }
            }
            .frame(width: 80, height: 80)
            .padding(8)
            .background(Color(.systemGray6))
            .cornerRadius(12)

            VStack(alignment: .leading, spacing: 8) {
                Text(item.name)
                    .font(.system(size: 16, weight: .bold))
                    .lineLimit(1)

                Text(item.formattedPrice)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)

                HStack(spacing: 15) {
                                    Button(action: {
                                        cartManager.decreaseQuantity(phoneId: item.phoneId)
                                    }) {
                                        Image(systemName: "minus")
                                            .padding(10)
                                    }
                                    .buttonStyle(.plain)

                                    Text("\(item.quantity)")
                                        .font(.system(size: 14, weight: .semibold))

                                    Button(action: {
                                        cartManager.addToCart(phoneId: item.phoneId)
                                    }) {
                                        Image(systemName: "plus")
                                            .padding(10)
                                    }
                                    .buttonStyle(.plain)
                                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Capsule().stroke(Color(.systemGray4), lineWidth: 1))
            }
            
            Spacer()
            
            Button(action: {
                cartManager.removeFromCart(phoneId: item.phoneId)
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .font(.system(size: 14))
            }.buttonStyle(.borderless)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 4)
        .listRowSeparator(.hidden)
    }
}

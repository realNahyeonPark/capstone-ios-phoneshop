import SwiftUI

struct CartListView: View {
    @EnvironmentObject var cartService: CartService

    var body: some View {
        List {
            ForEach(cartService.items) { item in
                CartItemRow(item: item)
            }
        }
        .listStyle(PlainListStyle())
    }
}

import SwiftUI

struct CartListView: View {
    @EnvironmentObject var cartManager: CartManager

    var body: some View {
        List {
            ForEach(cartManager.items) { item in
                CartItemRow(item: item)
            }
        }
        .listStyle(PlainListStyle())
    }
}

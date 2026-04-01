/* MyPageProductCard.swift */
import SwiftUI

struct MyPageProductCard: View {
    let product: Product
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AsyncImage(url: product.fullImageUrl) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: 150)
            } placeholder: {
                Color(.systemGray6)
                    .frame(height: 150)
            }
            .cornerRadius(8)
            .clipped()
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.brand)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
                
                Text(product.name)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .allowsTightening(true)
                    .minimumScaleFactor(0.5)
                
                Spacer(minLength: 0)
                
                Text(product.formattedPrice)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 75)
        }
        .contentShape(Rectangle())
    }
}

struct GridMenuItem: View {
    let destination: AnyView
    let icon: String
    let title: String
    var body: some View {
        NavigationLink(destination: destination) {
            VStack(spacing: 8) {
                Image(systemName: icon).font(.system(size: 24)).foregroundColor(.black)
                Text(title).font(.system(size: 13)).foregroundColor(.black)
            }.frame(maxWidth: .infinity)
        }
    }
}

struct MenuRow: View {
    let destination: AnyView
    let icon: String
    let title: String
    var body: some View {
        NavigationLink(destination: destination) {
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Image(systemName: icon).foregroundColor(.black).frame(width: 20)
                    Text(title).font(.system(size: 15)).foregroundColor(.black)
                    Spacer()
                    Image(systemName: "chevron.right").font(.system(size: 14)).foregroundColor(Color(.systemGray4))
                }.padding(.horizontal, 20).padding(.vertical, 15)
                Divider().padding(.leading, 52)
            }
        }
    }
}

import SwiftUI

struct DetailStickyHeaderView: View {
    @Binding var selectedTab: Int
    let proxy: ScrollViewProxy
    var animation: Namespace.ID
    let tabs = ["상세정보", "리뷰", "Q&A"]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs.indices, id: \.self) { index in
                Button(action: {
                    withAnimation {
                        selectedTab = index
                        proxy.scrollTo(index, anchor: .top)
                    }
                }) {
                    VStack(spacing: 12) {
                        Text(tabs[index])
                            .font(.system(size: 15, weight: selectedTab == index ? .bold : .regular))
                            .foregroundColor(selectedTab == index ? .primary : .secondary)
                        
                        ZStack {
                            Rectangle().fill(Color.clear).frame(height: 2)
                            if selectedTab == index {
                                Rectangle()
                                    .fill(Color.blue)
                                    .frame(height: 2)
                                    .matchedGeometryEffect(id: "tab", in: animation)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.top, 10)
        .background(Color.white)
        .overlay(Divider(), alignment: .bottom)
    }
}

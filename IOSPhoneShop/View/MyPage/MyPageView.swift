import SwiftUI

struct MyPageView: View {
    @Binding var isLoggedIn: Bool
    
    @AppStorage("userRole") var userRole: String = "USER"
    @AppStorage("userName") var userName: String = "사용자"
    
    @State private var recommendedProducts: [Product] = []
    @State private var isProductLoading = false
    
    let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    NavigationLink(destination: EditProfileView(userName: $userName)) {
                        HStack(spacing: 15) {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 55, height: 55)
                                .foregroundColor(Color(.systemGray4))
                                .background(Color.white)
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 3) {
                                HStack(spacing: 4) {
                                    Text(userName.isEmpty ? "사용자님" : "\(userName)님")
                                        .font(.system(size: 19, weight: .bold))
                                        .foregroundColor(.black)
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.gray)
                                }
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 25)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 3)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 15)
                    .padding(.bottom, 15)

                    HStack(spacing: 0) {
                        GridMenuItem(destination: AnyView(OrderListView()), icon: "list.clipboard", title: "주문목록")
                        GridMenuItem(destination: AnyView(WishlistView()), icon: "heart", title: "찜한상품")
                        GridMenuItem(destination: AnyView(CouponView()), icon: "tag", title: "쿠폰함")
                        GridMenuItem(destination: AnyView(MyReviewsView()), icon: "square.and.pencil", title: "리뷰관리")
                    }
                    .padding(.vertical, 20)
                    .background(Color.white)

                    Rectangle().fill(Color(.systemGray6)).frame(height: 10)

                    if userRole == "ADMIN" {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("관리자 메뉴")
                                .font(.system(size: 14, weight: .bold))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 15)
                            Divider().padding(.horizontal, 20)
                            MenuRow(destination: AnyView(AdminSalesChartView()), icon: "chart.bar.xaxis", title: "매출 현황")
                            MenuRow(destination: AnyView(AdminProductManagementView()), icon: "wrench.and.screwdriver", title: "상품 관리")
                            MenuRow(destination: AnyView(AdminCouponGrantView()), icon: "ticket.fill", title: "쿠폰 발급")
                        }
                        .background(Color.white)
                        Rectangle().fill(Color(.systemGray6)).frame(height: 10)
                    }

                    VStack(alignment: .leading, spacing: 0) {
                        Text("추천 상품")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 20)
                            .padding(.top, 25)
                            .padding(.bottom, 20)
                        
                        if isProductLoading {
                            ProgressView().frame(maxWidth: .infinity).padding(.vertical, 50)
                        } else if recommendedProducts.isEmpty {
                            Text("추천할 상품이 없습니다.").font(.system(size: 14)).foregroundColor(.secondary).frame(maxWidth: .infinity).padding(.vertical, 50)
                        } else {
                            LazyVGrid(columns: columns, spacing: 35) {
                                ForEach(recommendedProducts) { product in
                                    NavigationLink(destination: ProductDetailView(product: product)) {
                                        MyPageProductCard(product: product)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 60)
                        }
                    }
                    .background(Color.white)

                    Rectangle().fill(Color(.systemGray6)).frame(height: 10)

                    VStack(spacing: 0) {
                        NavigationLink(destination: WithdrawView(isLoggedIn: $isLoggedIn)) {
                            HStack {
                                Text("회원 탈퇴").font(.system(size: 15)).foregroundColor(.red)
                                Spacer()
                                Image(systemName: "chevron.right").font(.system(size: 14)).foregroundColor(Color(.systemGray4))
                            }
                            .padding(.horizontal, 20).padding(.vertical, 18)
                        }
                        Divider().padding(.horizontal, 20)
                        Button(action: { logout() }) {
                            HStack {
                                Text("로그아웃").font(.system(size: 15)).foregroundColor(.gray)
                                Spacer()
                            }
                            .padding(.horizontal, 20).padding(.vertical, 18)
                        }
                    }
                    .background(Color.white)
                }
            }
            .background(Color.white.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("마이페이지")
            .onAppear {
                Task {
                    await UserService.shared.fetchAndSaveUserInfo()
                }
                loadRandomRecommendations()
            }
        }
    }

    private func loadRandomRecommendations() {
        isProductLoading = true
        ProductService.shared.fetchAllPhones { products in
            if let products = products {
                self.recommendedProducts = Array(products.shuffled().prefix(4))
            }
            isProductLoading = false
        }
    }

    func logout() {
        UserDefaults.standard.removeObject(forKey: "userToken")
        UserDefaults.standard.removeObject(forKey: "userName")
        UserDefaults.standard.removeObject(forKey: "userRole")
        isLoggedIn = false
    }
}

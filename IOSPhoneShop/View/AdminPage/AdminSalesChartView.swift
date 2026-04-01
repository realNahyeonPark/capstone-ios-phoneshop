/* AdminSalesChartView.swift */
import SwiftUI

struct AdminSalesChartView: View {
    @State private var totalSales: Int = 0
    @State private var isLoading = false
    
    let formatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "KRW"
        f.locale = Locale(identifier: "ko_KR")
        return f
    }()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Image(systemName: "wonsign.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                        Text("누적 총 매출")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    
                    if isLoading {
                        ProgressView()
                            .scaleEffect(1.2)
                            .frame(maxWidth: .infinity, minHeight: 60)
                    } else {
                        Text(formatter.string(from: NSNumber(value: totalSales)) ?? "₩0")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.vertical, 5)
                    }
                    
                    Divider()
                    
                    HStack {
                        Image(systemName: "info.circle")
                        Text("관리자 전용 메뉴입니다. 실제 판매된 누적 금액입니다.")
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                }
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(16)
                .padding(.horizontal)
                
                Spacer(minLength: 50)
            }
            .padding(.top)
        }
        .navigationTitle("매출 현황")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: loadTotalSales)
        .refreshable {
            loadTotalSales()
        }
    }
    
    func loadTotalSales() {
        isLoading = true
        AdminService.shared.fetchTotalSales { sales in
            self.totalSales = sales ?? 0
            self.isLoading = false
        }
    }
}

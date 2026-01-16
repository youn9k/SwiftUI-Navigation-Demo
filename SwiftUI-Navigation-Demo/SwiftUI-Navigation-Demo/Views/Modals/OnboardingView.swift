import SwiftUI

struct OnboardingView: View {
  @Environment(\.dismiss) private var dismiss
  @State private var currentPage = 0

  private let pages = [
    OnboardingPage(
      title: "환영합니다",
      description: "SwiftUI Navigation Demo에 오신 것을 환영합니다",
      iconName: "hand.wave.fill"
    ),
    OnboardingPage(
      title: "다양한 네비게이션",
      description: "Push, Sheet, FullScreen 등 다양한 네비게이션 패턴을 경험하세요",
      iconName: "arrow.triangle.branch"
    ),
    OnboardingPage(
      title: "시작하기",
      description: "지금 바로 시작해보세요!",
      iconName: "checkmark.circle.fill"
    )
  ]

  var body: some View {
    VStack(spacing: 30) {
      // Skip 버튼
      HStack {
        Spacer()
        Button("건너뛰기") {
          dismiss()
        }
        .padding()
      }

      Spacer()

      // 현재 페이지 내용
      VStack(spacing: 20) {
        Image(systemName: pages[currentPage].iconName)
          .font(.system(size: 80))
          .foregroundStyle(.blue)

        Text(pages[currentPage].title)
          .font(.largeTitle)
          .fontWeight(.bold)

        Text(pages[currentPage].description)
          .font(.body)
          .foregroundStyle(.secondary)
          .multilineTextAlignment(.center)
          .padding(.horizontal, 40)
      }

      Spacer()

      // Page indicator
      HStack(spacing: 8) {
        ForEach(0 ..< pages.count, id: \.self) { index in
          Circle()
            .fill(index == currentPage ? Color.blue : Color.gray.opacity(0.3))
            .frame(width: 8, height: 8)
        }
      }
      .padding(.bottom, 20)

      // 다음/시작 버튼
      Button {
        if currentPage < pages.count - 1 {
          withAnimation {
            currentPage += 1
          }
        } else {
          dismiss()
        }
      } label: {
        Text(currentPage < pages.count - 1 ? "다음" : "시작하기")
          .font(.headline)
          .foregroundStyle(.white)
          .frame(maxWidth: .infinity)
          .padding()
          .background(Color.blue)
          .cornerRadius(12)
      }
      .padding(.horizontal, 40)
      .padding(.bottom, 40)
    }
  }
}

struct OnboardingPage {
  let title: String
  let description: String
  let iconName: String
}

#Preview {
  OnboardingView()
}

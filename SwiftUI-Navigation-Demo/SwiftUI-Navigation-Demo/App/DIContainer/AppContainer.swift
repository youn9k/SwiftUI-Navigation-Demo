import Swinject

/// Composition Root: 모든 의존성을 등록하고 관리
final class AppContainer {
    static let shared = AppContainer()
    private let container = Container()

    private init() {
        registerDependencies()
    }

    private func registerDependencies() {
        // ViewBuilder 등록 (AppViewFactory)
        container.register(ViewBuilder.self) { _ in
            AppViewFactory()
        }.inObjectScope(.container) // 싱글톤
    }

    func resolve<T>(_ type: T.Type) -> T {
        guard let resolved = container.resolve(type) else {
            fatalError("Failed to resolve \(type)")
        }
        return resolved
    }
}

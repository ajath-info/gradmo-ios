//
//  CustomTabBarController.swift
//  Gradmo
//

import UIKit

final class CustomTabBarController: UITabBarController {
    
    enum AppTab: Int, CaseIterable {
        case home
        case secondary
        case search
        case notifications
        case account
        
        func title(for role: UserRole) -> String {
            switch self {
            case .home:
                return "Home"
            case .secondary:
                switch role {
                case .student:
                    return "Institutes"
                case .teacher:
                    return "Course"
                case .institute:
                    return "Institutes"
                }
            case .search:
                return "Search"
            case .notifications:
                return "Notifications"
            case .account:
                return "Account"
            }
        }
        
        var symbolName: String {
            switch self {
            case .home:
                return "house"
            case .secondary:
                return "books.vertical"
            case .search:
                return "magnifyingglass"
            case .notifications:
                return "bell"
            case .account:
                return "person"
            }
        }
        
        var selectedSymbolName: String {
            switch self {
            case .home:
                return "house.fill"
            case .secondary:
                return "books.vertical.fill"
            case .search:
                return "magnifyingglass"
            case .notifications:
                return "bell.fill"
            case .account:
                return "person.fill"
            }
        }
    }
    
    var initialUserType: UserRole = .student
    
    private let themeBlue = UIColor(hex: "#3D82F2")
    private let inactiveGray = UIColor(hex: "#7A7A7A")
    private let searchBackground = UIColor(hex: "#F5F7FB")
    private var cachedBottomSafeAreaInset: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        styleTabBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutStandardTabBar()
    }
}

// MARK: - Setup

private extension CustomTabBarController {
    
    func setupTabs() {
        let role = initialUserType
        
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let homeViewController = storyboard
            .instantiateViewController(withIdentifier: "HomeViewController")
        let instituteViewController = storyboard
            .instantiateViewController(withIdentifier: "SearchInstituteViewController") as! SearchInstituteViewController
        instituteViewController.screenTitleText = "Institutes"
        instituteViewController.shouldShowBackButton = false
        let accountViewController = storyboard
            .instantiateViewController(withIdentifier: "UpdateProfileViewController")
        
        
        let controllers: [UIViewController] = [
            wrappedInNavigationController(
                homeViewController,
                tab: .home,
                role: role
            ),
            wrappedInNavigationController(
                instituteViewController,
                tab: .secondary,
                role: role
            ),
            wrappedInNavigationController(
                SectionPlaceholderViewController(
                    sectionTitle: AppTab.search.title(for: role),
                    detailText: "Under Development"
                ),
                tab: .search,
                role: role
            ),
            wrappedInNavigationController(
                storyboard.instantiateViewController(withIdentifier: "NotificationViewController"),
                tab: .notifications,
                role: role
            ),
            wrappedInNavigationController(
                    accountViewController,
                tab: .account,
                role: role
            )
        ]
        
        viewControllers = controllers
        selectedIndex = AppTab.home.rawValue
    }
    
    func wrappedInNavigationController(_ viewController: UIViewController,
                                       tab: AppTab,
                                       role: UserRole) -> UIViewController {
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.isNavigationBarHidden = true
        navigationController.tabBarItem = makeTabBarItem(for: tab, role: role)
        return navigationController
    }
    
    func styleTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.backgroundEffect = nil
        appearance.shadowColor = .clear
        
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.GilroyMedium(ofSize: 8),
            .foregroundColor: inactiveGray
        ]
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.GilroySemiBold(ofSize: 8),
            .foregroundColor: themeBlue
        ]
        
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttributes
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttributes
        appearance.stackedLayoutAppearance.normal.iconColor = inactiveGray
        appearance.stackedLayoutAppearance.selected.iconColor = themeBlue
        appearance.stackedLayoutAppearance.normal.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 1)
        appearance.stackedLayoutAppearance.selected.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 1)
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = themeBlue
        tabBar.unselectedItemTintColor = inactiveGray
        tabBar.itemPositioning = .fill
        tabBar.isTranslucent = false
        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()
        tabBar.backgroundColor = .white
        tabBar.barTintColor = .white
    }
    
    func layoutStandardTabBar() {
        let horizontalInset: CGFloat = 10
        let bottomInset: CGFloat = 8
        let tabBarHeight: CGFloat = 58
        let currentSafeAreaBottom = view.window?.safeAreaInsets.bottom ?? view.safeAreaInsets.bottom
        if cachedBottomSafeAreaInset == nil, currentSafeAreaBottom > 0 {
            cachedBottomSafeAreaInset = currentSafeAreaBottom
        }
        let safeAreaBottom = cachedBottomSafeAreaInset ?? currentSafeAreaBottom
        
        var updatedFrame = tabBar.frame
        updatedFrame.size.height = tabBarHeight + safeAreaBottom
        updatedFrame.origin.x = horizontalInset
        updatedFrame.size.width = view.bounds.width - (horizontalInset * 2)
        updatedFrame.origin.y = view.bounds.height - updatedFrame.size.height - bottomInset
        tabBar.frame = updatedFrame
        
        tabBar.layer.cornerRadius = 26
        tabBar.layer.masksToBounds = false
        tabBar.layer.shadowColor = UIColor(hex: "#C8D3EA").cgColor
        tabBar.layer.shadowOpacity = 1
        tabBar.layer.shadowRadius = 10
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -1)
    }
    
    func makeTabBarItem(for tab: AppTab, role: UserRole) -> UITabBarItem {
        let item = UITabBarItem(
            title: tab.title(for: role),
            image: makeIcon(for: tab, selected: false),
            selectedImage: makeIcon(for: tab, selected: true)
        )
        
        if tab == .search {
            item.imageInsets = UIEdgeInsets(top: -10, left: 0, bottom: 10, right: 0)
            item.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 8)
        }
        
        return item
    }
    
    func makeIcon(for tab: AppTab, selected: Bool) -> UIImage? {
        if tab == .search {
            return selected ? searchSelectedIcon() : searchUnselectedIcon()
        }
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        let name = selected ? tab.selectedSymbolName : tab.symbolName
        let color = selected ? themeBlue : inactiveGray
        return UIImage(systemName: name, withConfiguration: symbolConfig)?
            .withTintColor(color, renderingMode: .alwaysOriginal)
    }
    
    func searchSelectedIcon() -> UIImage? {
        let size = CGSize(width: 44, height: 44)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { _ in
            let circleRect = CGRect(origin: .zero, size: size)
            searchBackground.setFill()
            UIBezierPath(ovalIn: circleRect).fill()
            
            let lensConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
            let image = UIImage(systemName: "magnifyingglass", withConfiguration: lensConfig)?
                .withTintColor(themeBlue, renderingMode: .alwaysOriginal)
            
            let iconSize = CGSize(width: 18, height: 18)
            let iconOrigin = CGPoint(
                x: (size.width - iconSize.width) / 2,
                y: (size.height - iconSize.height) / 2
            )
            image?.draw(in: CGRect(origin: iconOrigin, size: iconSize))
        }.withRenderingMode(.alwaysOriginal)
    }
    
    func searchUnselectedIcon() -> UIImage? {
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        return UIImage(systemName: "magnifyingglass", withConfiguration: symbolConfig)?
            .withTintColor(inactiveGray, renderingMode: .alwaysOriginal)
    }
}

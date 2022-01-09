//
//  ZikrPagesViewModel.swift
//  Azkar
//
//  Created by Abdurahim Jauzee on 01.05.2020.
//  Copyright © 2020 Al Jawziyya. All rights reserved.
//

import UIKit
import Combine

final class ZikrPagesViewModel: ObservableObject, Equatable {

    static func == (lhs: ZikrPagesViewModel, rhs: ZikrPagesViewModel) -> Bool {
        lhs.category == rhs.category && lhs.title == rhs.title
    }

    unowned let router: RootRouter
    let category: ZikrCategory
    let title: String
    let azkar: [ZikrViewModel]
    let preferences: Preferences
    let selectedPage: AnyPublisher<Int, Never>
    @Published var page = 0

    init(router: RootRouter, category: ZikrCategory, title: String, azkar: [ZikrViewModel], preferences: Preferences, selectedPagePublisher: AnyPublisher<Int, Never>, page: Int = 0) {
        self.router = router
        self.category = category
        self.title = title
        self.preferences = preferences
        self.azkar = azkar
        self.selectedPage = selectedPagePublisher
        self.page = page
    }

    func navigateToZikr(_ vm: ZikrViewModel, index: Int) {
        if UIDevice.current.isIpadInterface {
            router.trigger(.zikr(vm.zikr, index: index))
        } else {
            router.trigger(.zikrPages(self, page: index))
        }
    }
    
    func navigateToSettings() {
        router.trigger(.modalSettings(.textAndAppearance))
    }

    func goToNextZikrIfNeeded() {
        let newIndex = page + 1
        guard preferences.enableGoToNextZikrOnCounterFinished, newIndex < azkar.count else {
            return
        }
        router.trigger(.goToPage(newIndex))
    }
    
    static var placeholder: ZikrPagesViewModel {
        AzkarListViewModel(
            router: RootCoordinator(
                preferences: Preferences.shared, deeplinker: Deeplinker(),
                player: Player(player: AppDelegate.shared.player)),
            category: .other,
            title: ZikrCategory.morning.title,
            azkar: [],
            preferences: Preferences.shared,
            selectedPagePublisher: PassthroughSubject<Int, Never>().eraseToAnyPublisher()
        )
    }

}

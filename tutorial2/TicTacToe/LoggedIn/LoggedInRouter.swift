//
//  LoggedInRouter.swift
//  TicTacToe
//
//  Created by A11548 on 2022/07/14.
//  Copyright © 2022 Uber. All rights reserved.
//

import RIBs

protocol LoggedInInteractable: Interactable, OffGameListener, TicTacToeListener {
    var router: LoggedInRouting? { get set }
    var listener: LoggedInListener? { get set }
}

protocol LoggedInViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy. Since
    // this RIB does not own its own view, this protocol is conformed to by one of this
    // RIB's ancestor RIBs' view.

    func present(viewController: ViewControllable)
    func dismiss(viewController: ViewControllable)
}

final class LoggedInRouter: Router<LoggedInInteractable>, LoggedInRouting {

    // TODO: Constructor inject child builder protocols to allow building children.
    init(interactor: LoggedInInteractable,
         viewController: LoggedInViewControllable,
         offgameBuilder: OffGameBuildable,
         tictactoeBuilder: TicTacToeBuildable) {
        self.viewController = viewController
        self.offGameBuilder = offgameBuilder
        self.ticTacToeBuilder = tictactoeBuilder

        super.init(interactor: interactor)
        interactor.router = self
    }

    func cleanupViews() {
        // TODO: Since this router does not own its view, it needs to cleanup the views
        // it may have added to the view hierarchy, when its interactor is deactivated.

        if let currentChild = currentChild {
            viewController.dismiss(viewController: currentChild.viewControllable)
        }
    }

    // MARK: - Private

    private let viewController: LoggedInViewControllable
    private let offGameBuilder: OffGameBuildable
    private let ticTacToeBuilder: TicTacToeBuildable

    private var currentChild: ViewableRouting?

    private func attachOffGame() {
        let offGame = offGameBuilder.build(withListener: interactor)
        self.currentChild = offGame
        attachChild(offGame)
        viewController.present(viewController: offGame.viewControllable)
    }

    override func didLoad() {
        super.didLoad()
        attachOffGame()
    }

    func routeToTicTacToe() {
        detachCurrentChild()
        attachTicTacToe()
    }

    private func attachTicTacToe() {
        let tictactoe = ticTacToeBuilder.build(withListener: interactor)
        self.currentChild = tictactoe
        attachChild(tictactoe)
        viewController.present(viewController: tictactoe.viewControllable)
    }

    private func detachCurrentChild() {
        if let currentChild = currentChild {
            detachChild(currentChild)
            viewController.dismiss(viewController: currentChild.viewControllable)
            self.currentChild = nil
        }
    }

    func routeToOffGame() {
        detachCurrentChild()
        attachOffGame()
    }
}

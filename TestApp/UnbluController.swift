//
//  UnbluController.swift
//  TestApp
//
//  Created by yin zhou on 2024-02-14.
//

//
//  UnbluController.swift
//  Unblu Test
//
//  Created by Chris Dong on 2024-01-25.
//

import UIKit
import UnbluCoreSDK
import UnbluMobileCoBrowsingModule

class UnbluController: UIViewController {
    private var client: UnbluVisitorClient?
    private let coBrowsingModule = UnbluMobileCoBrowsingModuleProvider.create()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray
        Task {
            do {
                var config = UnbluClientConfiguration(unbluBaseUrl: "https://central1.demo.unblu.com", apiKey: "E2bIWfYQQsaW7CVf5zCg_A",preferencesStorage: UserDefaultsPreferencesStorage(), fileDownloadHandler: UnbluDefaultFileDownloadHandler(), externalLinkHandler: UnbluDefaultExternalLinkHandler())
                try config.register(module: UnbluCallModuleProvider.create())
                coBrowsingModule.delegate = self
                try config.register(module: coBrowsingModule)
                client = Unblu.createVisitorClient(withConfiguration: config)
                client?.visitorDelegate = self
                try await initializeClient()
                showUnbluUI()
            } catch {
                print(error)
            }
        }
    }

    @IBAction func startLiveChat() {
        showUnbluUI()
    }
    
    private func initializeClient() async throws {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            client?.start({ result in
                switch result {
                case .success(_):
                    cont.resume()
                case .failure(let error):
                    cont.resume(throwing: error)
                }
            })
        }
    }
    
    private func showUnbluUI() {
        guard let view = client?.view else {return}
        if view.superview == nil {
            view.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(view)
            
            NSLayoutConstraint.activate([
                view.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor)
                , view.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
                , view.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor)
                , view.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor)
            ])
        }
    }
    
    fileprivate func closeMe() {
        view.removeFromSuperview()
        removeFromParent()
    }
}

extension UnbluController: UnbluVisitorClientDelegate {
    func unblu(didUpdatePersonActivityInfo personActivity: UnbluCoreSDK.PersonActivityInfo) {
        
    }
    
    func unblu(didRequestHideUi reason: UnbluUiHideRequestReason, conversationId: String?) {
        if reason == .requestedByUser {
            let confirm = UIAlertController(title: nil, message: "Are you sure you want to exit Unblu Live Chat?", preferredStyle: .alert)
            confirm.addAction(UIAlertAction(title: "Confirm", style: .destructive, handler: { _ in
                self.closeMe()
            }))
            confirm.addAction(UIAlertAction(title: "Cancel", style: .default))
            self.present(confirm, animated: true)
        }
    }
}

extension UnbluController: UnbluMobileCoBrowsingModuleDelegate {
    func unbluMobileCoBrowsingModuleDidStartCoBrowsing(_ unbluMobileCoBrowsingModuleApi: UnbluMobileCoBrowsingModuleApi) {
        client?.view.isHidden = true
        print("weiwei cobrowsing did start")
    }
    
    func unbluMobileCoBrowsingModuleDidStopCoBrowsing(_ unbluMobileCoBrowsingModuleApi: UnbluMobileCoBrowsingModuleApi) {
        client?.view.isHidden = false
        print("weiwei cobrowsing did stop")
    }
}


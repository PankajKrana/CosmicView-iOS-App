//
//  APODViewModel.swift
//  CosmicView
//
//  Created by Pankaj Kumar Rana on 22/12/25.
//


import Foundation
import Combine

@MainActor
final class APODViewModel: ObservableObject {

    @Published var apod: APOD?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service: APODService
    private var cancellable: AnyCancellable?

    /// Any earlier date would be invalid and should not trigger a request.
    private let apodStartDate = Calendar.current.date(
        from: DateComponents(year: 1995, month: 6, day: 16)
    )!

    init(service: APODService = APODService()) {
        self.service = service
    }

    
    /// Fetches the Astronomy Picture of the Day.
    func fetch(date: Date? = nil) {

        /// prevents unnecessary network calls
        if let date, date < apodStartDate {
            errorMessage = "Astronomy Picture of the Day is available only from June 16, 1995."
            isLoading = false
            return
        }

        errorMessage = nil
        isLoading = true

        // Cancel any existing request so only the latest one is active.
        cancellable?.cancel()

        cancellable = service.fetchAPOD(date: date)
            .receive(on: DispatchQueue.main)
            // Attach a sink to handle both completion and values
            .sink { [weak self] completion in
                guard let self else { return }
                // Stop the loading indicator regardless of success or failur
                self.isLoading = false

                if case let .failure(error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] apod in
                self?.apod = apod
            }
    }
}

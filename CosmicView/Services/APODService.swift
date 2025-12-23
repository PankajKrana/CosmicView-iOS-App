//
//  APODService.swift
//  CosmicView
//
//  Created by Pankaj Kumar Rana on 22/12/25.
//



import Foundation
import Combine

final class APODService {
    
    
    private let apiKey = "DEMO_KEY" // Enter your api key
    private let baseURL = "https://api.nasa.gov/planetary/apod"
    
    // Reused formatter
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    func fetchAPOD(date: Date?) -> AnyPublisher<APOD, APIError> {
        
        var components = URLComponents(string: baseURL)
        var queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "hd", value: "true")
        ]
        
        if let date {
            queryItems.append(
                URLQueryItem(
                    name: "date",
                    value: Self.dateFormatter.string(from: date)
                )
            )
        }
        
        components?.queryItems = queryItems
        
        guard let url = components?.url else {
            return Fail(error: .invalidURL)
                .eraseToAnyPublisher()
        }
        
        
        return URLSession.shared.dataTaskPublisher(for: url)
        // Validate the HTTP response and status code
        
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                
                guard 200..<300 ~= response.statusCode else {
                    let message = HTTPURLResponse.localizedString(
                        forStatusCode: response.statusCode
                    )
                    throw APIError.networkError(message)
                }
                
                return output.data
            }
        
        // Decode JSON data into the APOD model
            .decode(type: APOD.self, decoder: JSONDecoder())
        // Convert all errors into APIError
        
            .mapError { error in
                if let apiError = error as? APIError {
                    return apiError
                } else if error is DecodingError {
                    return .decodingError
                } else {
                    return .networkError(error.localizedDescription)
                }
            }
        // Hide the complexity of the publisher chain
            .eraseToAnyPublisher()
    }
}

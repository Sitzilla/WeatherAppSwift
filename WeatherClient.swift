//
//  WeatherClient.swift
//  WeatherApp
//
//  Created by Evan Sitzes on 9/18/16.
//  Copyright © 2016 Evan Sitzes. All rights reserved.
//

import Foundation

protocol WeatherClientDelegate {
    func didGetWeather(weather: Weather)
    func didNotGetWeather(error: NSError)
}

class WeatherClient {
    
    private let openWeatherMapBaseURL = "http://api.openweathermap.org/data/2.5/weather"
    private let openWeatherMapAPIKey = "1d4425ad88308217d31bcb075b2d8e1b"
    
    private var delegate: WeatherClientDelegate

    // MARK: -
    
    init(delegate: WeatherClientDelegate) {
        self.delegate = delegate
    }
    
    func getWeatherByCity(city: String) {
        let weatherRequestURL = URL(string: "\(openWeatherMapBaseURL)?APPID=\(openWeatherMapAPIKey)&q=\(city)")!
        getWeather(weatherRequestURL: weatherRequestURL)
    }
    
    func getWeather(weatherRequestURL: URL) {
        
        // This is a pretty simple networking task, so the shared session will do.
        // let session = NSURLSession.sharedSession()
        let session = URLSession.shared
        
        //let weatherRequestURL = Url(string: "\(openWeatherMapBaseURL)?APPID=\(openWeatherMapAPIKey)&q=\(city)")!
        var request = URLRequest(url:weatherRequestURL)
        request.httpMethod = "GET"
        
        // The data task retrieves the data.
        let client = session.dataTask(with: request as URLRequest)    {
            data, response, error in
            if let networkError = error {
                // Case 1: Error
                // An error occurred while trying to get data from the server.
                self.delegate.didNotGetWeather(error: networkError as NSError)
            }
            else {
                // Case 2: Success
                // We got a response from the server!
                do {
                    // Try to convert that data into a Swift dictionary
                    let weatherData = try JSONSerialization.jsonObject(
                        with: data!,
                        options: .mutableContainers) as! [String: AnyObject]
                    
                    // If we made it to this point, we've successfully converted the
                    // JSON-formatted weather data into a Swift dictionary.
                    // Let's now used that dictionary to initialize a Weather struct.
                    let weather = Weather(weatherData: weatherData)
                    
                    // Now that we have the Weather struct, let's notify the view controller,
                    // which will use it to display the weather to the user.
                    self.delegate.didGetWeather(weather: weather)
                }
                catch let jsonError as NSError {
                    // An error occurred while trying to convert the data into a Swift dictionary.
                    self.delegate.didNotGetWeather(error: jsonError)
                }
            }
        }
        
        // The data task is set up...launch it!
        client.resume()
    }
    
}

//
//  REST.swift
//  Carangas
//  Copyright © 2021 Eric Brito. All rights reserved.
//

import Foundation


enum CarError {
    case url
    case taskError(error: Error)
    case noResponse
    case noData
    case reponseStatus(code: Int)
    case invalidJason
    
}

enum RESTOperation {
    case save
    case update
    case delete
}

class REST {
    
    private static let basePath = "https://carangas.herokuapp.com/cars"
    
    private static let configuration: URLSessionConfiguration = {
        let config = URLSessionConfiguration.default
        config.allowsCellularAccess = false // n permite acesso via 3g ou celular
        config.httpAdditionalHeaders = ["Content-Type":"application/json"]
        config.timeoutIntervalForRequest = 30.0 // configura quanto temopo de espera
        config.httpMaximumConnectionsPerHost = 5 // quanta tarefas consigo fazer ao mesmo tempo
        return config
    }()
    
    
    private static let session = URLSession(configuration: configuration)
    
    //-------------------------
    
    class func loadBrand(onConplete: @escaping ([Brand]?) -> Void)  { // escaping faz o parametro continuar e náo ser destruido depois de usado
        
        guard let url = URL(string: "https://parallelum.com.br/fipe/api/v1/carros/marcas") else {
            onConplete(nil)
            return}
        
        let dataTask = session.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
        
            if error == nil{
                guard let response = response as? HTTPURLResponse else {
                    onConplete(nil)
                    return
                    } // se vez ser um response generico é uma HTTP te acesso ao codigo de statuas
                if response.statusCode == 200{
                    guard let data = data else {return}
                    
                   do{
                   
                    let  brands = try JSONDecoder().decode([Brand].self, from: data)
                   onConplete(brands)
                    
                    
                    } catch {
                        print(error)
                        onConplete(nil)
                    }
                    
                }else{
                    print("Alguem status invalido pelo servidor")
                    onConplete(nil)
                }
                
                
            }else{
                print(error!)
                onConplete(nil)
            }
        }
        dataTask.resume()
    }
    
    
    
    
    
     //-------------------------
    class func loadCars(onConplete: @escaping ([Car]) -> Void,onError: @escaping (CarError) -> Void)  { // escaping faz o parametro continuar e náo ser destruido depois de usado
        
        guard let url = URL(string: basePath) else {
            onError(.url)
            return}
        
        let dataTask = session.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
        
            if error == nil{
                guard let response = response as? HTTPURLResponse else {
                    onError(.noResponse)
                    return
                    } // se vez ser um response generico é uma HTTP te acesso ao codigo de statuas
                if response.statusCode == 200{
                    guard let data = data else {return}
                   do{
                   
                    let cars = try JSONDecoder().decode([Car].self, from: data)
                   onConplete(cars)
                    
                    
                    } catch {
                        print(error)
                        onError(.invalidJason)
                    }
                    
                }else{
                    print("Alguem status invalido pelo servidor")
                    onError(.reponseStatus(code: response.statusCode))
                }
                
                
            }else{
                print(error!)
                onError(.taskError(error: error!))
            }
        }
        dataTask.resume()
    }
    
    class func save(car: Car, onComplit: @escaping (Bool)-> Void ) {
        
        applyOperation(car: car, operation: .save, onComplit: onComplit)
        
        
        
    }
    
    
    class func update (car: Car, onComplit: @escaping (Bool)-> Void ) {
        
        applyOperation(car: car, operation: .update, onComplit: onComplit)
        
        
        
    }
    
    class func delete (car: Car, onComplit: @escaping (Bool)-> Void ) {
        
        applyOperation(car: car, operation: .delete, onComplit: onComplit)
        
        
        
    }

  
    
    private class func applyOperation (car: Car, operation: RESTOperation ,onComplit: @escaping (Bool)-> Void ){
        
        let urlString = basePath + "/" + (car._id ?? "")
        
        
        guard let url = URL(string: urlString) else {
            onComplit(false)
            return}
        
        var httpMethod: String = ""
        var resquest = URLRequest(url: url)
        
        switch operation {
        case .save:
            httpMethod = "POST"
        case .update:
            httpMethod = "PUT"
        case .delete:
            httpMethod = "DELETE"
        
        }
        
        resquest.httpMethod = httpMethod
        
        guard let json = try? JSONEncoder().encode(car) else {
            onComplit(false)
            return}
        resquest.httpBody = json
        
        let dataTask = session.dataTask(with: resquest) { (data, response, error) in
            if error == nil{
                //print(response)
                
                
                guard let response = response as? HTTPURLResponse, response.statusCode == 200, let _ = data
                else{
                    onComplit(false)
                    
                    print ("Deu ruim 44")
                   
                    return
                }
            onComplit(true)
            }else{
                onComplit(false)
                print ("Deu ruim 2")
            }
            
            
        }
        
        dataTask.resume()
        
    }
    
    
    
    
    
}

    
    


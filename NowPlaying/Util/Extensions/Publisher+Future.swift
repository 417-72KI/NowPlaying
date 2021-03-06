//
//  Publisher+Future.swift
//  NowPlaying
//
//  Created by 417.72KI on 2020/12/12.
//

import Foundation
import Combine

extension Publisher {
    func asFuture() -> Future<Output, Failure> {
         return Future { promise in
             var ticket: AnyCancellable? = nil
             ticket = self.sink(
                 receiveCompletion: {
                     ticket?.cancel()
                     ticket = nil
                     switch $0 {
                     case .failure(let error):
                         promise(.failure(error))
                     case .finished:
                        break
                     }
             },
                 receiveValue: {
                     ticket?.cancel()
                     ticket = nil
                     promise(.success($0))
             })
         }
     }
}

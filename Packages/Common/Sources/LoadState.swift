//
//  LoadState.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 30/01/2026.
//

public enum LoadState: Equatable {
    case idle
    case loading
    case loaded
    case failed(AppError)
}
// enum LoadState<T> { case idle, loading, loaded(T), failed(String) }

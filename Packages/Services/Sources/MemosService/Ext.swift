//
//  Types.swift
//
//
//  Created by Mudkip on 2023/11/18.
//

import Foundation
import Models

public typealias MemosUser = Components.Schemas.User
public typealias MemosMemo = Components.Schemas.Memo
public typealias MemosResource = Components.Schemas.Resource
public typealias MemosVisibility = Components.Schemas.Visibility
public typealias MemosStatus = Components.Schemas.SystemStatus

public extension MemosMemo {
    var createDate: Date {
        Date(timeIntervalSince1970: TimeInterval(createdTs))
    }
}

public extension MemosUser {
    var defaultMemoVisibility: MemosVisibility {
        guard let visibilityJson = self.userSettingList?.first(where: { $0.key == "memo-visibility" })?.value?.data(using: .utf8) else { return .PRIVATE }
        do {
            return try JSONDecoder().decode(MemosVisibility.self, from: visibilityJson)
        } catch {
            return .PRIVATE
        }
    }
}

extension MemosResource: Identifiable {}
extension MemosVisibility: CaseIterable {
    public static let allCases: [Components.Schemas.Visibility] = [.PRIVATE, .PROTECTED, .PUBLIC]
}

extension MemoVisibility {
    public init(_ memosVisibility: MemosVisibility) {
        switch memosVisibility {
        case .PUBLIC:
            self = .public
        case .PROTECTED:
            self = .protected
        case .PRIVATE:
            self = .private
        }
    }
}
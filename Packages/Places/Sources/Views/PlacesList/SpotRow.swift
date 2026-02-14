//
//  SpotRow.swift
//  ShredMate
//
//  Created by Marcin Obolewicz on 31/01/2026.
//

import SwiftUI
import Networking

// MARK: - Models

enum Sport: String, CaseIterable, Identifiable {
    case snowboard = "Snowboard"
    case narty = "Narty"
    case kitesurfing = "Kitesurfing"
    case wakeboard = "Wakeboard"

    var id: String { rawValue }
}

struct Spot: Identifiable, Equatable {
    let id: UUID = .init()
    let name: String
    let city: String
    let region: String
    let sport: Sport
    let description: String
    let rating: Double
    let riders: Int
    let mentors: Int
    let avatar: Avatar
    
    static func spot(with place: PlaceDto) -> Spot {
        Spot(
            name: place.name,
            city: "",
            region: "",
            sport: .kitesurfing,
            description: place.description ?? "",
            rating: 3.3,
            riders: 66,
            mentors: 2,
            avatar: .initials("AA")
        )
//        location
    }
}

// MARK: - Components

struct Chip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(.headline, design: .default))
                .foregroundStyle(isSelected ? Color.primary : Color.secondary)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background {
                    Capsule()
                        .fill(isSelected ? Color.accentColor.opacity(0.85) : Color(uiColor: .secondarySystemBackground))
                }
                .overlay {
                    Capsule()
                        .strokeBorder(Color.primary.opacity(isSelected ? 0.0 : 0.06), lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
    }
}

struct SpotRow: View {
    let viewData: SpotRowViewData

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            avatar

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(viewData.title)
                        .font(.headline)
                    Spacer()
                    Text(viewData.sportTag)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color(uiColor: .tertiarySystemFill)))
                }

                Text(viewData.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(viewData.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                HStack(spacing: 14) {
                    Text(viewData.ratingText).font(.subheadline.weight(.semibold))
                    Text(viewData.ridersText).font(.subheadline).foregroundStyle(.secondary)
                    Text(viewData.mentorsText).font(.subheadline).foregroundStyle(.secondary)
                }
            }

            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
                .padding(.top, 6)
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Color(uiColor: .secondarySystemBackground)))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).strokeBorder(Color.primary.opacity(0.06), lineWidth: 1))
    }

    @ViewBuilder
    private var avatar: some View {
        switch viewData.avatar {
        case .initials(let text):
            ZStack {
                Circle().fill(Color(uiColor: .tertiarySystemFill))
                Text(text).font(.headline.weight(.semibold))
            }
            .frame(width: 46, height: 46)
        case .imageRemote:
//            TODO: AsyncImage/Kingfisher
            Circle().fill(Color(uiColor: .tertiarySystemFill))
                .frame(width: 46, height: 46)
        case .image(_):
//            TODO: named image
            EmptyView()
        }
    }
}


private struct Tag: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background {
                Capsule()
                    .fill(Color(uiColor: .tertiarySystemFill))
            }
            .overlay {
                Capsule()
                    .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
            }
    }
}

private struct StatRating: View {
    let value: Double

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "star.fill")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary) // system-friendly
            Text(String(format: "%.1f", value))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
        }
    }
}

private struct StatText: View {
    let label: String
    let value: Int

    var body: some View {
        HStack(spacing: 6) {
            Text("\(label)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("\(value)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
        }
    }
}


//
//  CalendarGridView.swift.swift
//  CosmicView
//
//  Created by Pankaj Kumar Rana on 22/12/25.
//

import SwiftUI

struct CalendarGridView: View {

    @Binding var selectedDate: Date
    let onSelect: (Date) -> Void

    @Environment(\.dismiss) private var dismiss

    // APOD start date: June 16, 1995
    private let apodStartDate = Calendar.current.date(
        from: DateComponents(year: 1995, month: 6, day: 16)
    )!

    var body: some View {
        NavigationStack {
            VStack {
                // Graphical calendar picker
                DatePicker(
                    "Select APOD Date",
                    selection: $selectedDate,
                    in: apodStartDate...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding()
                .onChange(of: selectedDate) {
                    onSelect(selectedDate)
                    dismiss()
                }
            }
            .navigationTitle("Select Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        onSelect(selectedDate)
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    CalendarGridView(
        selectedDate: .constant(Date()),
        onSelect: { _ in }
    )
}

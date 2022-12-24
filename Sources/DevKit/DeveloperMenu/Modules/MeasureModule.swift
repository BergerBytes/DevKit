//
//  File.swift
//  
//
//  Created by Michael Berger on 12/23/22.
//

import Foundation
import SwiftUI
import Charts

@available(iOS 15, *)
public class MeasureModule: ObservableObject, Module {
    public var id: String = "Measure"
    
    @Published var records = [Measure.Record]()
    
    private var buffer: Dictionary<String, Measure.Record>.Values?
    
    required public init() {
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { timer in
            if let buffer = self.buffer {
                withAnimation {
                    self.records = buffer.sorted(by: { $0.lastUpdated > $1.lastUpdated })
                }
            }
            
            self.buffer = nil
        }
        
        Measure.moduleListener = {
            self.buffer = Measure.records.values
        }
    }
    
    @MainActor
    @ViewBuilder
    public var content: some View {
        MainView(module: self)
    }
}

@available(iOS 15, *)
extension MeasureModule {
    public struct MainView: View {
        @StateObject var module: MeasureModule
        
        public var body: some View {
            if #available(iOS 16.0, *) {
                List {
                    ForEach(module.records) { record in
                        Section(record.id) {
                            VStack {
                                Chart {
                                    ForEach(record.timeline) { entry in
                                        BarMark(
                                            x: .value("Timestamp", entry.timestamp),
                                            y: .value("Measured Time", entry.measuredTime * 1000.0)
                                        )
                                        .lineStyle(.init(lineJoin: .round))
                                        .foregroundStyle(.blue)
                                    }
                                }
                                
                                HStack(alignment: .lastTextBaseline, spacing: 16) {
                                    VStack {
                                        Text("Average")
                                        millisecondText(record.averageTime)
                                    }
                                    
                                    VStack {
                                        Text("Min")
                                        millisecondText(record.minTime)
                                    }
                                    
                                    VStack {
                                        Text("Max")
                                        millisecondText(record.maxTime)
                                    }
                                    
                                    Divider()
                                        .frame(maxHeight: 32)
                                    
                                    VStack {
                                        Text("Percentile Estimates")
                                        HStack(spacing: 16) {
                                            ForEach(record.percentiles.values.sorted(by: { $0.percentile > $1.percentile }), id: \.percentile) { percentile in
                                                VStack {
                                                    Text(percentile.percentile.formatted(.percent))
                                                    millisecondText(percentile.estimate)
                                                }
                                            }
                                        }
                                    }
                                }
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                            }
                            .padding(.vertical)
                        }
                    }
                }
            } else {
                Text("Only available on iOS 16")
                    .foregroundColor(.red)
                    .fontWeight(.bold)
            }
        }
        
        @ViewBuilder
        private func millisecondText(_ time: TimeInterval) -> some View {
            Text((time * 1000).formatted(.number.precision(.significantDigits(3))))
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            + Text("ms")
        }
    }
}

@available(iOS 15, *)
struct MeasureModule_Previews: PreviewProvider {
    static var previews: some View {
        MeasureModule().content
    }
}

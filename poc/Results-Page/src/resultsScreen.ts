import React from "react";
import { ScrollView, View, Text, TouchableOpacity } from "react-native";
import { AssessmentResult } from "./models";

export function ResultsScreen({ result }: { result: AssessmentResult | null }) {
  if (!result) return null;

  return (
    <ScrollView contentContainerStyle={{ padding: 16 }}>
      <Text style={{ fontSize: 28, fontWeight: "bold" }}>VESTA Results</Text>
      <Text style={{ fontSize: 20, marginTop: 6 }}>
        Overall Score: {result.overallScore ?? ""}
      </Text>

      <View style={{ marginTop: 12 }}>
        <Text style={{ fontSize: 18, fontWeight: "600" }}>MOCA Findings</Text>
        <Text>{result.moCA?.moCAraw ?? ""}</Text>
        <Text>{result.moCA?.moCAscore ?? ""}</Text>
        {result.moCA?.notes && <Text>Notes: {result.moCA.notes}</Text>}
      </View>

      {result.categories.map((c) => (
        <View key={c.id} style={{ borderWidth: 1, borderColor: "#ccc", padding: 12, marginTop: 12 }}>
          <Text style={{ fontSize: 16, fontWeight: "600" }}>
            {c.name} — {c.score ?? ""}
          </Text>
          {c.details.map((d, idx) => (
            <Text key={idx} style={{ fontSize: 14 }}>
              {d.item}: {d.chosen ?? ""} {d.note ? `(${d.note})` : ""}
            </Text>
          ))}
        </View>
      ))}

      <View style={{ flexDirection: "row", marginTop: 16, justifyContent: "space-between" }}>
        <TouchableOpacity accessibilityLabel="Email Results" style={{ padding: 12, backgroundColor: "#2e8b57" }}>
          <Text style={{ color: "#fff" }}>Email Results</Text>
        </TouchableOpacity>
        <TouchableOpacity accessibilityLabel="Export Sponsor Report" style={{ padding: 12, backgroundColor: "#1e90ff" }}>
          <Text style={{ color: "#fff" }}>Export Sponsor Report</Text>
        </TouchableOpacity>
      </View>
    </ScrollView>
  );
}

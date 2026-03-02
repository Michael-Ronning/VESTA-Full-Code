import React from "react";
import { SafeAreaView, StyleSheet } from "react-native";
import { ResultsScreen } from "./ResultsScreen";
import { mockAssessment } from "./mocks";
import type { AssessmentResult } from "./models";

export default function AppShell() {
  const result: AssessmentResult = mockAssessment();

  return (
    <SafeAreaView style={styles.container}>
      <ResultsScreen result={result} />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
});

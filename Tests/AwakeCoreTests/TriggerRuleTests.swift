import XCTest

@testable import AwakeCore

final class TriggerRuleTests: XCTestCase {
    private struct Row {
        let name: String
        let displays: [DisplayInfo]
        let lid: Bool?
        let externalWithBuiltinOff: Bool
        let lidClosed: Bool
        let anyExternal: Bool
    }

    private let rows: [Row] = [
        Row(
            name: "external only, lid closed", displays: [Fixtures.external()], lid: true,
            externalWithBuiltinOff: true, lidClosed: true, anyExternal: true),
        Row(
            name: "external only, lid open", displays: [Fixtures.external()], lid: false,
            externalWithBuiltinOff: true, lidClosed: false, anyExternal: true),
        Row(
            name: "external + active built-in", displays: [Fixtures.builtin(), Fixtures.external()],
            lid: false, externalWithBuiltinOff: false, lidClosed: false, anyExternal: true),
        Row(
            name: "external + asleep built-in",
            displays: [Fixtures.builtin(asleep: true), Fixtures.external()], lid: false,
            externalWithBuiltinOff: true, lidClosed: false, anyExternal: true),
        Row(
            name: "external + inactive built-in",
            displays: [Fixtures.builtin(active: false), Fixtures.external()], lid: false,
            externalWithBuiltinOff: true, lidClosed: false, anyExternal: true),
        Row(
            name: "no external", displays: [Fixtures.builtin()], lid: false,
            externalWithBuiltinOff: false, lidClosed: false, anyExternal: false),
        Row(
            name: "no displays at all", displays: [], lid: true,
            externalWithBuiltinOff: false, lidClosed: false, anyExternal: false),
        Row(
            name: "external asleep only", displays: [Fixtures.external(asleep: true)], lid: true,
            externalWithBuiltinOff: false, lidClosed: false, anyExternal: false),
        Row(
            name: "external inactive only", displays: [Fixtures.external(active: false)], lid: true,
            externalWithBuiltinOff: false, lidClosed: false, anyExternal: false),
        Row(
            name: "unknown lid with external", displays: [Fixtures.external()], lid: nil,
            externalWithBuiltinOff: true, lidClosed: false, anyExternal: true),
        Row(
            name: "closed lid, external + asleep built-in",
            displays: [Fixtures.builtin(asleep: true), Fixtures.external()], lid: true,
            externalWithBuiltinOff: true, lidClosed: true, anyExternal: true),
    ]

    func testRulesAgainstTable() {
        let catalog = TriggerCatalog.standard
        for row in rows {
            let snapshot = SystemSnapshot(displays: row.displays, lidClosed: row.lid)
            XCTAssertEqual(
                catalog.rule(for: ExternalWithBuiltinOffRule.ruleID).shouldKeepAwake(snapshot),
                row.externalWithBuiltinOff, "externalWithBuiltinOff: \(row.name)")
            XCTAssertEqual(
                catalog.rule(for: LidClosedRule.ruleID).shouldKeepAwake(snapshot),
                row.lidClosed, "lidClosed: \(row.name)")
            XCTAssertEqual(
                catalog.rule(for: AnyExternalRule.ruleID).shouldKeepAwake(snapshot),
                row.anyExternal, "anyExternal: \(row.name)")
        }
    }

    func testCatalogOrderAndDefault() {
        let catalog = TriggerCatalog.standard
        XCTAssertEqual(
            catalog.all.map(\.id),
            [ExternalWithBuiltinOffRule.ruleID, LidClosedRule.ruleID, AnyExternalRule.ruleID])
        XCTAssertEqual(catalog.default.id, ExternalWithBuiltinOffRule.ruleID)
    }

    func testUnknownIDFallsBackToDefault() {
        XCTAssertEqual(TriggerCatalog.standard.rule(for: "nope").id, ExternalWithBuiltinOffRule.ruleID)
    }

    func testRuleMetadataIsFilledIn() {
        for rule in TriggerCatalog.standard.all {
            XCTAssertFalse(rule.title.isEmpty)
            XCTAssertFalse(rule.summary.isEmpty)
            XCTAssertFalse(rule.waitingReason.isEmpty)
        }
    }
}

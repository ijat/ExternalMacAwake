import XCTest

@testable import AwakeCore

@MainActor
final class AwakeControllerTests: XCTestCase {
    private var displays: FakeDisplayProvider!
    private var lid: FakeLidProvider!
    private var assertion: FakeAssertion!
    private var settings: FakeSettings!

    override func setUp() async throws {
        displays = FakeDisplayProvider()
        lid = FakeLidProvider()
        assertion = FakeAssertion()
        settings = FakeSettings()
    }

    private func makeController() -> AwakeController {
        AwakeController(
            displayProvider: displays, lidProvider: lid, assertion: assertion, settings: settings,
            pollInterval: nil)
    }

    func testHoldsAssertionWhenRuleHolds() {
        displays.displays = [Fixtures.external()]
        let controller = makeController()
        controller.start()
        XCTAssertTrue(assertion.isHeld)
        XCTAssertEqual(controller.state, .active)
    }

    func testWaitsWhenRuleDoesNotHold() {
        displays.displays = [Fixtures.builtin()]
        let controller = makeController()
        controller.start()
        XCTAssertFalse(assertion.isHeld)
        XCTAssertEqual(controller.state, .waiting(reason: controller.selectedRule.waitingReason))
    }

    func testDisplayChangeNotificationReevaluates() {
        displays.displays = [Fixtures.builtin()]
        let controller = makeController()
        controller.start()
        XCTAssertFalse(assertion.isHeld)

        displays.displays = [Fixtures.builtin(asleep: true), Fixtures.external()]
        displays.handler?()
        XCTAssertTrue(assertion.isHeld)
        XCTAssertEqual(controller.snapshot.externals.count, 1)
    }

    func testDisablingReleasesImmediately() {
        displays.displays = [Fixtures.external()]
        let controller = makeController()
        controller.start()
        XCTAssertTrue(assertion.isHeld)

        controller.setEnabled(false)
        XCTAssertFalse(assertion.isHeld)
        XCTAssertEqual(controller.state, .disabled)
        XCTAssertFalse(settings.isEnabled)

        controller.setEnabled(true)
        XCTAssertTrue(assertion.isHeld)
        XCTAssertEqual(controller.state, .active)
    }

    func testStartsDisabledWhenSettingSaysSo() {
        settings.isEnabled = false
        displays.displays = [Fixtures.external()]
        let controller = makeController()
        controller.start()
        XCTAssertFalse(assertion.isHeld)
        XCTAssertEqual(controller.state, .disabled)
    }

    func testSwitchingRulesReevaluates() {
        displays.displays = [Fixtures.builtin(), Fixtures.external()]
        lid.lidClosed = false
        let controller = makeController()
        controller.start()
        XCTAssertFalse(assertion.isHeld, "default rule needs the built-in off")

        controller.selectRule(id: AnyExternalRule.ruleID)
        XCTAssertTrue(assertion.isHeld)
        XCTAssertEqual(settings.triggerID, AnyExternalRule.ruleID)

        controller.selectRule(id: LidClosedRule.ruleID)
        XCTAssertFalse(assertion.isHeld, "lid is open")
        XCTAssertEqual(controller.selectedRule.id, LidClosedRule.ruleID)
    }

    func testPersistedRuleIsRestored() {
        settings.triggerID = AnyExternalRule.ruleID
        XCTAssertEqual(makeController().selectedRule.id, AnyExternalRule.ruleID)
        settings.triggerID = "garbage"
        XCTAssertEqual(makeController().selectedRule.id, ExternalWithBuiltinOffRule.ruleID)
    }

    func testShutdownReleasesAndIsIdempotent() {
        displays.displays = [Fixtures.external()]
        let controller = makeController()
        controller.start()
        XCTAssertTrue(assertion.isHeld)

        controller.shutdown()
        controller.shutdown()
        XCTAssertFalse(assertion.isHeld)
        XCTAssertEqual(displays.stopCount, 1)

        controller.refresh()
        XCTAssertFalse(assertion.isHeld, "refresh after shutdown must not re-acquire")
    }

    func testAcquireIsNotCalledAgainWhileHeld() {
        displays.displays = [Fixtures.external()]
        let controller = makeController()
        controller.start()
        controller.refresh()
        controller.refresh()
        displays.handler?()
        XCTAssertEqual(assertion.acquireCount, 1)
    }

    func testAcquireErrorSurfacesAsErrorState() {
        struct Boom: LocalizedError { var errorDescription: String? { "boom" } }
        assertion.failure = Boom()
        displays.displays = [Fixtures.external()]
        let controller = makeController()
        controller.start()
        XCTAssertEqual(controller.state, .error("boom"))
        XCTAssertFalse(assertion.isHeld)

        assertion.failure = nil
        controller.refresh()
        XCTAssertEqual(controller.state, .active)
        XCTAssertTrue(assertion.isHeld)
    }

    func testInvariantHoldsAcrossTransitions() {
        let controller = makeController()
        controller.start()
        let scenarios: [[DisplayInfo]] = [
            [], [Fixtures.external()], [Fixtures.builtin(), Fixtures.external()],
            [Fixtures.builtin(asleep: true), Fixtures.external()], [Fixtures.builtin()],
        ]
        for enabled in [true, false] {
            controller.setEnabled(enabled)
            for scenario in scenarios {
                displays.displays = scenario
                controller.refresh()
                let expected =
                    enabled && controller.selectedRule.shouldKeepAwake(controller.snapshot)
                XCTAssertEqual(assertion.isHeld, expected)
            }
        }
    }
}

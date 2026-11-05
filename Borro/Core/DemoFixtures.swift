import Foundation

extension AppState {
    /// Puts the state where the story would be when a frame is opened directly
    /// (demo menu, `-startScreen`, previews). Side branches (sections 9–11) keep the live state.
    func prepareForDemo(_ screen: Screen) {
        guard let step = Self.storyOrder.firstIndex(of: screen) else { return }
        reset()
        func reached(_ s: Screen) -> Bool { step >= (Self.storyOrder.firstIndex(of: s) ?? .max) }

        if reached(.s3_8) { setStatus(.handoverPending) }
        if reached(.s4_7) { chooseMeetUpSpot(.blockA) }
        if reached(.s4_14) {
            chooseMeetUpSpot(.blockA)
            choosePickUp(MockData.defaultPickUpOffers[1])
            chooseReturn(Scenario.defaultReturnTime)
        }
        if reached(.s5_2d) { depositPaid() }
        if reached(.s6_4) { addPhoto(.front, to: .dropOff) }
        if [.s6_5a, .s6_6, .s6_6a, .s6_9, .s6_10, .s6_10a].contains(screen) || reached(.s6_10) {
            addPhoto(.back, to: .dropOff)
        }
        if screen == .s6_6a { addPhoto(.extra, to: .dropOff) }
        if reached(.s6_10) { saveDropOff() }
        if reached(.s6_14) { markCollected() }
        if reached(.s6_14a) { addPhoto(.front, to: .collection) }
        if [.s6_14c, .s6_14d, .s6_15, .s6_16, .s6_18].contains(screen) || reached(.s6_19) {
            addPhoto(.back, to: .collection)
        }
        if [.s6_15, .s6_16, .s6_18].contains(screen) || reached(.s6_19) { addPhoto(.extra, to: .collection) }
        if reached(.s6_19) { setStatus(.onLoan) }
        if reached(.s7_1) { setStatus(.returnPending) }
        if reached(.s7_2a) {
            _ = submitBorrowerCode(Scenario.borrowerCode)
            addPhoto(.front, to: .returned)
        }
        if [.s7_2c, .s7_2d, .s7_3, .s7_4].contains(screen) || reached(.s7_5) { addPhoto(.back, to: .returned) }
        if [.s7_3, .s7_4].contains(screen) || reached(.s7_5) { addPhoto(.extra, to: .returned) }
        if reached(.s7_5) { setStatus(.returned) }
        if reached(.s8_3) { rateThomas(5) }
        if reached(.s8_8) { depositRefunded() }
        if reached(.s8_6) { rateJames(5) }
        if reached(.s8_7) { submitThomasReview() }
        switchRole(to: screen.role)
        clearRoleBanner()
    }

    /// Main story path, in Figma order, with the variants slotted where they happen.
    static let storyOrder: [Screen] = [
        .s1_1, .s1_2, .s1_3, .s1_4, .s1_5,
        .s2_1, .s2_2, .s2_3, .s2_4,
        .s3_1, .s3_2, .s3_3, .s3_4, .s3_5, .s3_6, .s3_7, .s3_8, .s3_9,
        .s4_1, .s4_2, .s4_3, .s4_4, .s4_5, .s4_6, .s4_7, .s4_8, .s4_9, .s4_10, .s4_11, .s4_12, .s4_13, .s4_14,
        .s5_1, .s5_2, .s5_2e, .s5_3, .s5_4, .s5_2a, .s5_2f, .s5_2b, .s5_2c, .s5_2d, .s5_5, .s5_6, .s5_7,
        .s6_1, .s6_2, .s6_3, .s6_4, .s6_7, .s6_8, .s6_5, .s6_3a, .s6_5a, .s6_6, .s6_3b, .s6_6a, .s6_9,
        .s6_10, .s6_10a, .s6_11, .s6_12, .s6_13, .s6_14, .s6_17, .s6_14a, .s6_14b, .s6_14c, .s6_14d,
        .s6_15, .s6_16, .s6_18, .s6_19, .s6_20,
        .s7_1, .s7_2, .s7_2a, .s7_2b, .s7_2c, .s7_2d, .s7_3, .s7_4, .s7_5, .s7_6,
        .s8_1, .s8_2, .s8_3, .s8_4, .s8_5, .s8_6, .s8_7, .s8_8, .s8_9,
    ]
}

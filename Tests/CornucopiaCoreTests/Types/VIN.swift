import XCTest

import CornucopiaCore

class VIN: XCTestCase {

    func testValid() {

        let valid = [
            "1FMEE5DH5NLA77159",
            "1G6DU57V190152065",
            "MMBJJKL10LH016787",
            "JN1TFNT32A0041590",
            "WP1ZZZ9PZ8LA33027",
            "WBAJA9105KB304806",
            "WF0AXXWPMAEA04617",
            "2BCCE8140HB506017",
            "WAUZZZ4L78D067850",
            "1FTYR14C2YTA84254",
            "MNTBB7A96E6014216",
            "1FADP3F20DL237413",
        ]

        for string in valid {
            let vin = Cornucopia.Core.VIN(stringLiteral: string)
            XCTAssertTrue(vin.isValid)
        }
    }

    func testInvalid() {

        let invalid = [
            "FMEE5DH5NLA77159",         // too short
            "21G6DU57V190152065",       // too long
            "MMBJJKL1OLH016787",        // contains 'O'
            "JN1TFNT3IA0041590",        // contains 'I'
            "WP1ZZZ9PQ8LA33027",        // contains 'Q'
        ]

        for string in invalid {
            let vin = Cornucopia.Core.VIN(stringLiteral: string)
            XCTAssertFalse(vin.isValid)
        }
    }

    func testDescription() {

        let string = "MMBJJKL10LH016787"
        let vin: Cornucopia.Core.VIN = "MMBJJKL10LH016787"
        XCTAssertEqual("\(vin)", string)
    }

    func testEquality() {

        let vin1: Cornucopia.Core.VIN = "1FADP3F20DL237413"
        let vin2: Cornucopia.Core.VIN = "1FADP3F20DL237413"

        XCTAssertEqual(vin1, vin2)
    }

    func testInequality() {

        let vin1: Cornucopia.Core.VIN = "WP1ZZZ9PZ8LA33027"
        let vin2: Cornucopia.Core.VIN = "1FADP3F20DL237413"

        XCTAssertNotEqual(vin1, vin2)
    }
}
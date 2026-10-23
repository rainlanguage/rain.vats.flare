// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {OracleTest} from "test/abstract/OracleTest.sol";
import {SceptreStakedFlrOracle} from "src/concrete/oracle/SceptreStakedFlrOracle.sol";
import {LibSceptreStakedFlare, SFLR_CONTRACT} from "rain-flare-0.1.5/src/lib/sflr/LibSceptreStakedFlare.sol";
import {IStakedFlr} from "rain-flare-0.1.5/src/interface/IStakedFlr.sol";
import {ZeroSFLRRate} from "rain-flare-0.1.5/src/err/ErrFtso.sol";

contract SceptreStakedFlrOracleTest is OracleTest {
    function testSceptreStakedFlrOracle() external {
        SceptreStakedFlrOracle oracle = new SceptreStakedFlrOracle();

        vm.prank(ALICE);
        uint256 price = oracle.price();
        assertEq(price, 0.877817269857026198e18);
        assertEq(price, LibSceptreStakedFlare.getSFLRPerFLR18());
    }

    function testSceptreStakedFlrOracleRefund(uint128 fee, uint128 extra) external {
        SceptreStakedFlrOracle oracle = new SceptreStakedFlrOracle();

        uint256 total = uint256(fee) + uint256(extra);
        vm.deal(ALICE, total);
        assertEq(ALICE.balance, total);
        vm.prank(ALICE);
        oracle.price{value: fee}();
        assertEq(ALICE.balance, total);
    }

    function testSceptreStakedFlrOracleZeroRateReverts() external {
        SceptreStakedFlrOracle oracle = new SceptreStakedFlrOracle();

        vm.mockCall(
            address(SFLR_CONTRACT),
            abi.encodeWithSelector(IStakedFlr.getSharesByPooledFlr.selector, 1e18),
            abi.encode(uint256(0))
        );
        vm.prank(ALICE);
        vm.expectRevert(abi.encodeWithSelector(ZeroSFLRRate.selector));
        oracle.price();
    }
}

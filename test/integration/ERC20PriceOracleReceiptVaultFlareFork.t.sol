// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test} from "forge-std-1.16.1/src/Test.sol";
import {ERC20PriceOracleReceiptVault} from "rain-vats-0.1.7/src/concrete/vault/ERC20PriceOracleReceiptVault.sol";
import {LibERC20PriceOracleReceiptVaultFork} from "../lib/LibERC20PriceOracleReceiptVaultFork.sol";
import {SFLR_CONTRACT} from "rain-flare-0.1.2/src/lib/sflr/LibSceptreStakedFlare.sol";
import {
    LibFixedPointDecimalArithmeticOpenZeppelin,
    Math
} from "rain-math-fixedpoint-0.2.0/src/lib/LibFixedPointDecimalArithmeticOpenZeppelin.sol";

/// @title ERC20PriceOracleReceiptVaultFlareForkTest
/// @notice Fork tests exercising rain.vats's ERC20PriceOracleReceiptVault
/// against real Flare price sources (sFLR + FTSOv2). The vault contract lives in
/// rain.vats and is chain-agnostic; these tests live here because they depend on
/// Flare, so rain.vats itself carries no Flare dependency.
contract ERC20PriceOracleReceiptVaultFlareForkTest is Test {
    using LibFixedPointDecimalArithmeticOpenZeppelin for uint256;

    function testRedeemFlareFork(uint256 deposit) public {
        deposit = bound(deposit, 1, type(uint128).max);
        (ERC20PriceOracleReceiptVault vault, address alice) = LibERC20PriceOracleReceiptVaultFork.setup(vm, deposit);

        deal(address(SFLR_CONTRACT), alice, deposit);

        vm.startPrank(alice);
        uint256 rate = LibERC20PriceOracleReceiptVaultFork.getRate();
        vm.assume(vault.previewDeposit(deposit, 0) > 0);
        vault.deposit(deposit, alice, 0, hex"00");

        uint256 shareBalance = vault.balanceOf(alice);
        uint256 shares = shareBalance.fixedPointMul(rate, Math.Rounding.Ceil);

        // Call redeem function
        vault.redeem(shares, alice, alice, rate, hex"00");

        uint256 shareBalanceAft = vault.balanceOf(alice);
        assertEqUint(shareBalanceAft, shareBalance - shares);
        vm.stopPrank();
    }

    function testWithdrawFlareFork(uint256 deposit) public {
        deposit = bound(deposit, 1, type(uint128).max);
        (ERC20PriceOracleReceiptVault vault, address alice) = LibERC20PriceOracleReceiptVaultFork.setup(vm, deposit);

        deal(address(SFLR_CONTRACT), alice, deposit);

        vm.startPrank(alice);
        vm.assume(vault.previewDeposit(deposit, 0) > 0);
        vault.deposit(deposit, alice, 0, hex"00");

        uint256 shareBalance = vault.balanceOf(alice);
        uint256 rate = LibERC20PriceOracleReceiptVaultFork.getRate();

        // Call withdraw function
        vault.withdraw(shareBalance, alice, alice, rate, hex"00");

        uint256 shares = shareBalance.fixedPointMul(rate, Math.Rounding.Ceil);
        uint256 shareBalanceAft = vault.balanceOf(alice);

        assertEqUint(shareBalanceAft, shareBalance - shares);

        vm.stopPrank();
    }
}

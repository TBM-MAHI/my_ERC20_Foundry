// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

// this import does not error out
//import {Test} from "lib/forge-std/src/Test.sol";

import {Test} from "forge-std/Test.sol";
import {console2} from "lib/forge-std/src/console2.sol";
import {StdStyle} from "lib/forge-std/src/StdStyle.sol";
import {ERC20} from "../src/ERC20.sol";

contract BaseSetUp is Test, ERC20 {
    constructor() ERC20("MAHI", "MAH") {}

    address internal eva;
    address internal adrian;

    function setUp() public virtual {
        eva = makeAddr("eva");
        adrian = makeAddr("adrian");
        console2.log("address 1", StdStyle.blue(eva) );
        console2.log("address 2 ", StdStyle.blue (adrian));
        //_mint(eva, 10e18);
        console2.log( "This contract addrs:",StdStyle.green( StdStyle.underline(address(this))));
        deal(address(this), eva, 10 ether);
        //console2.log("Initial balanceOf eva ", eva.balance);
        console2.log("Initial balanceOf eva under the ERC20Contract", StdStyle.bold(balanceOf[eva]));
    }
}

contract ERC20_Transfer_Test is BaseSetUp {

    function setUp() public override{
        console2.log("runnin setUp() from ERC20_Transfer_Test");
        BaseSetUp.setUp();
    }

     function testTranserTokenCorrectly() public {
        vm.prank(eva);
        /* this is goind to call the subsequsnt call as eva
        as the msg.sender or function calller */
        bool result = this.transfer(adrian, 5e18);
        console2.log("transacton", result, "/n after transfer");
        console2.log("balanceOf eva ", balanceOf[eva]);
        console2.log("balanceOf adrian ", balanceOf[adrian]);
        assertTrue(result);

        assertEqDecimal(balanceOf[adrian], 5e18, decimals);
        assertEqDecimal(balanceOf[eva], 495e16, decimals);
    }

    function testTranserToken_Incorrectly() public {
        vm.prank(eva);
        vm.expectRevert("ERC20: INSUFFCIENT SENDER BALANCE");
        bool revertsAsExpected = this.transfer(adrian, 500e18);
        console2.log(revertsAsExpected);
        assertFalse(revertsAsExpected, "expectRevert: call did not revert");
      }
}

contract ERC20_TransferFrom_Test is BaseSetUp {

}
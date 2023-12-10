//SPDX-License-Identifier: MIT
pragma solidity 0.8.23;
import {console} from "lib/forge-std/src/console.sol";

contract ERC20 {
    string public symbol;
    string public name;
    //1 FULL Token = 1*10^18 = 1000000000000000000  gewi
    uint8 public immutable decimals = 18;
    uint256 public totalSupply;
    address public feeReceivingAccount = 0xdD870fA1b7C4700F2BD7f44238821C26f7392148;
    uint256 feePersentage = 1;
    bytes public data; 
    
    mapping(address => uint256) public balanceOf;
    // owner account is the  account used as from account in transferFrom functions
    /* the Owner account is approving  some allowance of tokens to another 
    account that account can transfer from the owner accounts Funds*/
    mapping(address => mapping(address => uint256)) public allowance;

    constructor(
        string memory _name,
        string memory _symbol
      
    ) {
        name = _name;
        symbol = _symbol;
       
    }

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );

 
    function _mint(address to, uint256 value) internal {
        balanceOf[to] += value;
        totalSupply += value;
        //Not an ERC-20 Standard to emit an Event when burning or minig tokens
        emit Transfer(address(0), to, value);
    }
   
    function _burn(address from, uint256 value) private {
        balanceOf[from] -= value;
        totalSupply -= value;
        emit Transfer(address(0), from, value);
    }

    function minNewToken(address to, uint256 value) external {
        //cheking that only The contract owner is able to mint new tokens To any address
        _mint(to, value);
    }

   
    function burnTokens(address from, uint256 value) external {
        //cheking that only The contract owner is able to mint new tokens To any address
        _burn(from, value);
    }
    function deposit() external payable {
      
        _mint(msg.sender, msg.value);
    }

    
    function giveMe1Token() external {
        balanceOf[msg.sender] += 1 * 10**18;
     }

    //transfer to the address from the address who calling the function
    function transfer(address to, uint256 value) external returns (bool) {
        return _transfer(msg.sender, to, value);
    }

    // THE ADDRESS CALLING THE *transferFrom* Function is using the Funds From the *from* address
    function transferFrom(
        address from,
        address recipient,
        uint256 amount
    ) external  returns (bool) {
        /* msg.sender of this functon is the spender of approve function() 
           from is the Owner account that is approving the allowance of tokens
        */
        console.log("msg.sender in transferFrom() ", msg.sender);
        require(
            allowance[from][msg.sender] >= amount,
            "ERC20: INSUFFCIENT ALLOWANCE BALANCE"
        );

        allowance[from][msg.sender] = allowance[from][msg.sender] - amount;
        emit Approval(from, msg.sender, allowance[from][msg.sender]);
        //decrease token value from "from" account and credit to recipient
        return _transfer(from, recipient, amount);
    }
    
    function redeem(uint amount) external {
        //STEP -1 trasfer amount to Smart Contract
        require(balanceOf[msg.sender]>amount,"ERC20: INSUFFCIENT SENDER BALANCE");
        //check that the smart con has allowance
        require(
            allowance[msg.sender][address(this)] >= amount,
            "ERC20: INSUFFCIENT ALLOWANCE BALANCE"
        );

        allowance[msg.sender][address(this)] -= amount;
        require(  _transfer(msg.sender, address(this), amount),  "Transaction failed" );
        //STEP -2 burn the tokens from SMART CONTARCT
        _burn(address(this), amount);

        // Calculate Ether value to be sent back to the sender
        uint256 ethValue = amount / (10e18); 
        //STEP -3 Send Ether back to the sender
        (bool success,bytes memory returndata) = msg.sender.call{value:ethValue}("");
        //console.log("ether sent back- ",success);
        data = returndata;
        require(success, "Failed to send Ether back to user");
    }

    function _transfer(
        address from,
        address recipient,
        uint256 amount
    ) private returns (bool) {
        uint256 feeAmount = (amount * feePersentage) / 100;

        require(
            balanceOf[from] > amount + feeAmount,
            "ERC20: INSUFFCIENT SENDER BALANCE"
        );

        balanceOf[feeReceivingAccount] += feeAmount;
        balanceOf[from] = balanceOf[from] - amount - feeAmount;

        balanceOf[recipient] = balanceOf[recipient] + amount;
        emit Transfer(from, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        //msg.sender is the ownerAccount in mapping
        //omly owner account can set the spending allowance
      
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);
        return true;
    }
}

// SPDX-License-Identifier: GPL-3.0
import "./Ownable.sol";
import "../../chainlink/evm-contracts/src/v0.6/VRFConsumerBase.sol";
pragma solidity >=0.6.0 <0.7.0;
//Helloworld.deployed().then(function(instance){helloworld=instance})
contract Cointoss is Ownable,VRFConsumerBase {
    
    bytes32 internal keyHash;
    uint256 internal fee;
    
    uint balance;

	//Defining structure  
    struct wager { 
        //Declaring different  
        // structure elements 
        address payable sender; 
        uint value; 
        bool guess; 
    }

    // Creating mapping 
    mapping (bytes32 => wager) private openRequests;
    mapping (address => uint) public claims;  
  
  	event RequestedRandomNumber(bytes32 _queryId, address _address, uint _value, bool _guess);
	event InitiateCoinToss(address player, uint amount, bool guess);
	event ThanksForPlaying(address player, bool win);
    event ClaimCollateral(address player, uint amount);

	 constructor() 
        VRFConsumerBase(
            0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9, // VRF Coordinator
            0xa36085F69e2889c224210F603D836748e7dC0088  // LINK Token
        ) public
    {
        keyHash = 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4;
        fee = 0.1 * 10 ** 18; // 0.1 LINK
        owner = msg.sender;
        balance = 0;
    }

    modifier costs(uint cost){
        require(msg.value >= cost, "Not enough ether was sent on the function call");
        _;
    }

     /** 
     * Requests randomness from a user-provided seed
     */
    function getRandomNumber(uint256 userProvidedSeed) internal returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
        return requestRandomness(keyHash, fee, userProvidedSeed);
    }

    /**
     * Callback function used by VRF Coordinator
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        wager memory currentWager = openRequests[requestId];
        bool randomResult = ((randomness % 2) > 0 ? true : false);
        bool win = (currentWager.guess == randomResult ? true : false);
        if (win) {
            uint currentBalance = claims[currentWager.sender];
        	claims[currentWager.sender] = currentBalance + currentWager.value * 2;
        }
        emit ThanksForPlaying(currentWager.sender, win);
        delete openRequests[requestId];
    }


    function getPriceBalance() public view returns (uint){
        return claims[msg.sender];
    }

    function claim() public {
        uint claimableCollateral = claims[msg.sender];
        require(balance >= claimableCollateral, "Cannot payout because pot has not enough money");
        balance = balance - claimableCollateral;
        msg.sender.transfer(claimableCollateral);
        delete claims[msg.sender];
        emit ClaimCollateral(msg.sender, claimableCollateral);
    }

	function flip(bool _guess) public payable costs(0.1 ether) {
		emit InitiateCoinToss(msg.sender, msg.value, _guess);
		balance += msg.value;
		uint256 seed = uint256(msg.sender);
		bytes32  queryId = getRandomNumber(seed);
		wager memory currentWager;
		currentWager.sender = msg.sender;
		currentWager.value = msg.value;
		currentWager.guess = _guess;
		openRequests[queryId] = currentWager;
		emit RequestedRandomNumber(queryId,currentWager.sender,currentWager.value,currentWager.guess);
	}


    function getBalance() public view returns (uint){
        return balance;
    }

    function withdrawAll() public onlyOwner returns (uint){
        uint toTransfer = balance;
        balance = 0;
        msg.sender.transfer(toTransfer);
        assert(balance == 0);
        return toTransfer;
    }    
}
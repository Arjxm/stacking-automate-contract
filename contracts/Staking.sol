// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.18;
import "./Automate/AutomateTaskCreator.sol";

contract Staking is AutomateTaskCreator {

    uint256 public lastExecuted;
    uint256 public constant INTERVAL = 2 minutes; //change interval as per your need

    struct Staker {
        uint256 amount;
        uint256 timestamp;
        bool isLocked;
    }
    struct StakerTaskId{
        bytes32 taskId;
        address stakerAddress;
    }
    mapping(address => Staker) public stakes;
    mapping(address => StakerTaskId) public stakerTaskId;

    event Stake(address indexed owner, uint256 amount, uint256 time);
    event UnStake(address indexed owner, uint256 amount, uint256 time, uint256 rewardTokens);
    event Withdraw(address indexed owner, uint256 amount, uint256 time);

    constructor(address payable _automate, address _fundsOwner)
    AutomateTaskCreator(_automate, _fundsOwner)
    {}

    receive() external payable {}

    function createTaskUnStake(address _stackOwner) external {

        bytes memory execData = abi.encodeWithSelector(this.unStake.selector, _stackOwner);

        ModuleData memory moduleData = ModuleData({
            modules: new Module[](2),
            args: new bytes[](2)
        });
        moduleData.modules[0] = Module.TIME;
        moduleData.modules[1] = Module.PROXY;

        moduleData.args[0] = _timeModuleArg(block.timestamp, INTERVAL);
        moduleData.args[1] = _proxyModuleArg();

        bytes32 id = _createTask(address(this), execData, moduleData, ETH);

        stakerTaskId[_stackOwner] = StakerTaskId(id, _stackOwner);
    }

    function createTaskWithdraw(address _stackOwner) external {

        bytes memory execData = abi.encodeWithSelector(this.withdraw.selector, _stackOwner);

        ModuleData memory moduleData = ModuleData({
            modules: new Module[](2),
            args: new bytes[](2)
        });
        moduleData.modules[0] = Module.PROXY;
        moduleData.modules[1] = Module.SINGLE_EXEC;

        moduleData.args[0] = _proxyModuleArg();
        moduleData.args[1] = _singleExecModuleArg();

        bytes32 id = _createTask(
            address(this),
            execData,
            moduleData,
            ETH
        );
        stakerTaskId[_stackOwner] = StakerTaskId(id, _stackOwner);
    }


    function stake() public payable {
        require(msg.value > 0, 'Must send Ether to stake');
        stakes[msg.sender] = Staker(msg.value, block.timestamp, true);
        emit Stake(msg.sender, msg.value, block.timestamp);
    }


    function unStake(address payable _stackOwner) public {
        require(stakes[_stackOwner].amount > 0, 'No staked Ether');
        uint256 amount = stakes[_stackOwner].amount;
        uint256 balance = address(this).balance;
        require(balance >= amount, "Not enough balance");
        stakes[_stackOwner].isLocked = false;
        bytes32 taskId = stakerTaskId[_stackOwner].taskId;
        _cancelTask(taskId);
    }

    // Function to withdraw any remaining Ether in the contract (only callable by the owner)
    function withdraw(address _stackOwner) public  {
        require(address(this).balance > 0, 'No Ether to withdraw');
        require(stakes[_stackOwner].isLocked != true, "Wait Still Locked");
        uint256 amount = stakes[_stackOwner].amount;
        payable(_stackOwner).transfer(amount);
        stakes[_stackOwner].amount = 0;
        emit Withdraw(_stackOwner, address(this).balance, block.timestamp);
    }

}
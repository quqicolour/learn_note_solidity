pragma solidity ^0.4.19;

import "./20220218_3.sol";
// ZombieHelper 

// 我们有决定函数何时和被谁调用的可见性修饰符: private 意味着它只能被合约内部调用；
// internal 就像 private 但是也能被继承的合约调用； external 只能从合约外部调用；
// 最后 public 可以在任何地方调用，不管是内部还是外部。

// 我们也有状态修饰符， 告诉我们函数如何和区块链交互: view 告诉我们运行这个函数不会更改和保存任何数据；
// pure 告诉我们这个函数不但不会往区块链写数据，它甚至不从区块链读取数据。
// 这两种在被从合约外部调用的时候都不花费任何gas（但是它们在被内部其他函数调用的时候将会耗费gas）。

contract ZombieHelper is ZombieFeeding {
    
// 定义一个 uint ，命名为 levelUpFee, 将值设定为 0.001 ether。
  uint levelUpFee = 0.001 ether;

  modifier aboveLevel(uint _level, uint _zombieId) {
    require(zombies[_zombieId].level >= _level);
    _;
  }
// 可以通过 transfer 函数向一个地址发送以太， 然后 this.balance 将返回当前合约存储了多少以太
// 创建一个 withdraw 函数
  function withdraw() external onlyOwner {
    owner.transfer(this.balance);
  }
// 创建一个函数，名为 setLevelUpFee， 其接收一个参数 uint _fee，是 external 并使用修饰符 onlyOwner
// 这个函数应该设置 levelUpFee 等于 _fee。
  function setLevelUpFee(uint _fee) external onlyOwner {
    levelUpFee = _fee;
  }
// payable 方法是一种可以接收以太的特殊函数
// msg.value 是一种可以查看向合约发送了多少以太的方法，另外 ether 是一个內建单元
// 定义一个名为 levelUp 的函数。 它将接收一个 uint 参数 _zombieId。 函数应该修饰为 external 以及 payable。
  function levelUp(uint _zombieId) external payable {
    //   这个函数首先应该 require 确保 msg.value 等于 levelUpFee
    require(msg.value == levelUpFee);
    // 增加僵尸的 level: zombies[_zombieId].level++
    zombies[_zombieId].level++;
  }
// 修改 changeName() 使其使用 ownerOf
  function changeName(uint _zombieId, string _newName) external aboveLevel(2, _zombieId) ownerOf(_zombieId) {
    require(msg.sender == zombieToOwner[_zombieId]);
    zombies[_zombieId].name = _newName;
  }
// 修改 changeDna() 使其使用 ownerOf
   function changeDna(uint _zombieId, uint _newDna) external aboveLevel(20, _zombieId) ownerOf(_zombieId) {
    require(msg.sender == zombieToOwner[_zombieId]);
    zombies[_zombieId].dna = _newDna;
  }

  function getZombiesByOwner(address _owner) external view returns(uint[]) {
    uint[] memory result = new uint[](ownerZombieCount[_owner]);
    uint counter = 0;
    for (uint i = 0; i < zombies.length; i++) {
      if (zombieToOwner[i] == _owner) {
        result[counter] = i;
        counter++;
      }
    }
    return result;
  }

}

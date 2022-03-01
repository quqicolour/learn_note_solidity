pragma solidity ^0.4.19;

import "./20220217_2.sol";

contract ZombieHelper is ZombieFeeding {
// 在ZombieHelper 中，创建一个名为 aboveLevel 的modifier，它接收2个参数， _level (uint类型) 以及 _zombieId (uint类型)
  modifier aboveLevel(uint _level, uint _zombieId) {
    // 运用函数逻辑确保僵尸 zombies[_zombieId].level 大于或等于 _level。
    require(zombies[_zombieId].level >= _level);
    _;//修饰符的最后一行为 _;，表示修饰符调用结束后返回，并执行调用函数余下的部分。
  }

// 创建一个名为 changeName 的函数。它接收2个参数：_zombieId（uint类型）以及 _newName（string类型），
// 可见性为 external。它带有一个 aboveLevel 修饰符，调用的时候通过 _level 参数传入2, _zombieId 参数。
  function changeName(uint _zombieId, string _newName) external aboveLevel(2, _zombieId) {
    // 用 require 语句，验证 msg.sender 是否就是 zombieToOwner [_zombieId]。
    require(msg.sender == zombieToOwner[_zombieId]);
    // 函数将 zombies[_zombieId] .name 设置为 _newName。
    zombies[_zombieId].name = _newName;
  }

// 在 changeName 下创建另一个名为 changeDna 的函数。它的定义和内容几乎和 changeName 相同，
// 不过它第二个参数是 _newDna（uint类型），在修饰符 aboveLevel 的 _level 参数中传递 20 。把僵尸的 dna 设置为 _newDna 。
  function changeDna(uint _zombieId, uint _newDna) external aboveLevel(20, _zombieId) {
    require(msg.sender == zombieToOwner[_zombieId]);
    zombies[_zombieId].dna = _newDna;
  }

// 创建一个名为 getZombiesByOwner 的新函数。它有一个名为 _owner 的 address 类型的参数,
// 将其申明为external view函数,这样当玩家从web3.js中调用它时,不需要花费任何gas(调用view不花gas),函数需要返回一个uint [](uint数组)。
  function getZombiesByOwner(address _owner) external view returns(uint[]) {
    
// 在数组后面加上 memory关键字,表明这个数组是仅仅在内存中创建,不需要写入外部存储,并且在函数调用结束时它就解散了
// 声明一个名为result的uint [] memory' （内存变量数组）,将其设置为一个新的 uint 类型数组。
// 数组的长度为该 _owner 所拥有的僵尸数量，这可通过调用 ownerZombieCount [_ owner] 来获取 
    uint[] memory result = new uint[](ownerZombieCount[_owner]);
  
    // 声明一个变量 counter，属性为 uint，设其值为 0 。我们用这个变量作为 result 数组的索引
     uint counter = 0;
    // 声明一个 for 循环， 从 uint i = 0 到 i <zombies.length。它将遍历数组中的每一头僵尸
    for (uint i = 0; i < zombies.length; i++) {
      // 在每一轮for循环中,用一个if语句来检查zombieToOwner[i]是否等于_owner。这会比较两个地址是否匹配
      if (zombieToOwner[i] == _owner) {
      // 在 if 语句中：通过将 result [counter] 设置为 i，将僵尸ID添加到 result 数组中。将counter加1
        result[counter] = i;
        counter++;
      }
    } 
    // 能返回 _owner 所拥有的僵尸数组，不花一分钱 gas
    return result;
  }

}
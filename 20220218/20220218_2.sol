pragma solidity ^0.4.19;

import "./20220218_1.sol";
// ZombieBattle
contract ZombieBattle is ZombieHelper {
// 给我们合约一个名为 randNonce 的 uint，将其值设置为 0。
  uint randNonce = 0;

// 给我们合约一个 uint 类型的变量，命名为 attackVictoryProbability, 将其值设定为 70。
  uint attackVictoryProbability = 70;

// 建立一个函数，命名为 randMod (random-modulus)。它将作为internal 函数，
// 传入一个名为 _modulus的 uint，并 returns 一个 uint。
  function randMod(uint _modulus) internal returns(uint) {
    // 首先将为 randNonce加一， (使用 randNonce++ 语句)。
    randNonce++;
    // 最后，它应该 (在一行代码中) 计算 now, msg.sender, 
    // 以及 randNonce 的 keccak256 哈希值并转换为 uint—— 最后 return % _modulus 的值。
    return uint(keccak256(now, msg.sender, randNonce)) % _modulus;
  }

// 创建一个名为 attack的函数。它将传入两个参数: _zombieId (uint 类型) 以及 _targetId (也是 uint)。它将是一个 external 函数。
// 将 ownerOf 修饰符添加到 attack 来确保调用者拥有_zombieId.
   function attack(uint _zombieId, uint _targetId) external ownerOf(_zombieId) {

    //定义一个 Zombie storage 命名为 myZombie，使其值等于 zombies[_zombieId]。
    Zombie storage myZombie = zombies[_zombieId];
    //定义一个 Zombie storage 命名为 enemyZombie， 使其值等于 zombies[_targetId]
    Zombie storage enemyZombie = zombies[_targetId];
// 我们将用一个0到100的随机数来确定我们的战斗结果。 定义一个 uint，命名为 rand， 设定其值等于 randMod 函数的返回值，此函数传入 100作为参数
    uint rand = randMod(100);

// 创建一个 if 语句来检查 rand 是不是小于或者等于 attackVictoryProbability
// 如果以上条件为 true， 我们的僵尸就赢了！所以：
// a. 增加 myZombie 的 winCount。b. 增加 myZombie 的 level。 (升级了啦!!!!!!!)
// c. 增加 enemyZombie 的 lossCount. (输家!!!!!! )
// d. 运行 feedAndMultiply 函数。 在 zombiefeeding.sol 里查看调用它的语句。 对于第三个参数 (_species)，传入字符串 "zombie". 
    if (rand <= attackVictoryProbability) {
      myZombie.winCount++;
      myZombie.level++;
      enemyZombie.lossCount++;
      feedAndMultiply(_zombieId, enemyZombie.dna, "zombie");
    } 
// 添加一个 else 语句。 若我们的僵尸输了：
// a. 增加 myZombie 的 lossCount。b. 增加 enemyZombie 的 winCount。
// 在 else 最后， 对 myZombie 运行 _triggerCooldown 方法。这让每个僵尸每天只能参战一次
     else {
      myZombie.lossCount++;
      enemyZombie.winCount++;
      _triggerCooldown(myZombie);
    }
  }
}
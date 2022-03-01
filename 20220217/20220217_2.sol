pragma solidity ^0.4.19;

import "./20220217_1.sol";

contract KittyInterface {
  function getKitty(uint256 _id) external view returns (
    bool isGestating,
    bool isReady,
    uint256 cooldownIndex,
    uint256 nextActionAt,
    uint256 siringWithId,
    uint256 birthTime,
    uint256 matronId,
    uint256 sireId,
    uint256 generation,
    uint256 genes
  );
}

contract ZombieFeeding is ZombieFactory {

  KittyInterface kittyContract;

// 函数修饰符看起来跟函数没什么不同，不过关键字modifier 告诉编译器，这是个modifier(修饰符)，
// 而不是个function(函数)。它不能像函数那样被直接调用，只能被添加到函数定义的末尾，用以改变函数的行为。
// 尽管函数修饰符也可以应用到各种场合，但最常见的还是放在函数执行之前添加快速的 require检查。
// 将 onlyOwner 函数修饰符添加到 setKittyContractAddress 中

  function setKittyContractAddress(address _address) external onlyOwner {
    kittyContract = KittyInterface(_address);
  }
// 定义一个 _triggerCooldown 函数。它要求一个参数，_zombie，表示一某个僵尸的存储指针。
// 这个函数可见性设置为 internal。
   function _triggerCooldown(Zombie storage _zombie) internal {
// 在函数中，把 _zombie.readyTime 设置为 uint32（now + cooldownTime）
    _zombie.readyTime = uint32(now + cooldownTime);
  }

// 创建一个名为 _isReady 的函数。这个函数的参数也是名为 _zombie 的 Zombie storage。
// 这个功能只具有 internal 可见性，并返回一个 bool 值。
  function _isReady(Zombie storage _zombie) internal view returns (bool) {
// 函数计算返回(_zombie.readyTime <= now)，值为 true 或 false。这个功能的目的是判断下次允许猎食的时间是否已经到了
      return (_zombie.readyTime <= now);
  }

  function feedAndMultiply(uint _zombieId, uint _targetDna, string species) internal {
    require(msg.sender == zombieToOwner[_zombieId]);
    Zombie storage myZombie = zombies[_zombieId];
// 在找到 myZombie 之后，添加一个 require 语句来检查 _isReady() 并将 myZombie 传递给它。这样用户必须等到僵尸的 冷却周期 结束后才能执行 feedAndMultiply 功能。
    require(_isReady(myZombie));
    _targetDna = _targetDna % dnaModulus;
    uint newDna = (myZombie.dna + _targetDna) / 2;
    if (keccak256(species) == keccak256("kitty")) {
      newDna = newDna - newDna % 100 + 99;
    }
    
    _createZombie("NoName", newDna);
    // 在函数结束时，调用 _triggerCooldown(myZombie)，标明捕猎行为触发了僵尸新的冷却周期。
    _triggerCooldown(myZombie);
  }

  function feedOnKitty(uint _zombieId, uint _kittyId) public {
    uint kittyDna;
    (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId);
    feedAndMultiply(_zombieId, kittyDna, "kitty");
  }

}

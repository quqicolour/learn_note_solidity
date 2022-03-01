pragma solidity ^0.4.19;
// 导入另一个文件20220216_2.sol， （./ 就是同一目录）
import "./20220216_2.sol";
// 父类
//定义一个名为 KittyInterface 的接口。并没有使用大括号（{ 和 }）定义函数体，我们单单用分号（;）结束了函数声明
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
// 子类继承父类contract 子类名称 is 父类名称
// 在 ZombieFactory 下创建一个叫 ZombieFeeding 的合约，它是继承自 `ZombieFactory 合约的。
contract ZombieFeeding is ZombieFactory {

// 将代码中 CryptoKitties 合约的地址保存在一个名为 ckAddress 的变量中。
  address ckAddress = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;
//  创建一个名为 kittyContract 的 KittyInterface， 并用 ckAddress 为它初始化。
  KittyInterface kittyContract = KittyInterface(ckAddress);

  // 创建一个名为 feedAndMultiply 的函数。 
  // 使用两个参数：_zombieId（ uint类型 ）和_targetDna （也是 uint 类型）。 设置属性为 public 的
  // 我们修改下 feedAndMultiply 函数的定义，给它传入第三个参数：一条名为 _species 的字符串
  function feedAndMultiply(uint _zombieId, uint _targetDna, string _species) public {
  // 添加一个require 语句来确保 msg.sender 只能是这个僵尸的主人（类似于我们在 createRandomZombie 函数中做过的那样）
    require(msg.sender == zombieToOwner[_zombieId]);
    
    // Storage 变量是指永久存储在区块链中的变量。
    // Memory 变量则是临时的，当外部函数对某合约调用完成时，内存型变量即被移除。

  // 为了获取这个僵尸的DNA，我们的函数需要声明一个名为 myZombie 数据类型为Zombie的本地变量
  // （这是一个 storage 型的指针）。 将其值设定为在 zombies 数组中索引为_zombieId所指向的值
    Zombie storage myZombie = zombies[_zombieId];

    // 确保 _targetDna 不长于16位。要做到这一点，
    // 我们可以设置 _targetDna 为 _targetDna ％ dnaModulus ，并且只取其最后16位数字
    _targetDna = _targetDna % dnaModulus;

    // 声明一个名叫 newDna 的 uint类型的变量，并将其值设置为 myZombie的 DNA 和 _targetDna 的平均值
    uint newDna = (myZombie.dna + _targetDna) / 2;

    // 在我们计算出新的僵尸的DNA之后，添加一个 if 语句来比较 _species 和字符串 "kitty" 的 keccak256 哈希值。
      if (keccak256(_species) == keccak256("kitty")) {
      // 在 if 语句中，我们用 99 替换了新僵尸DNA的最后两位数字。可以这么做：newDna = newDna - newDna % 100 + 99
      newDna = newDna - newDna % 100 + 99;
    }

    // 调用 _createZombie 就可以生成新的僵尸
    _createZombie("NoName", newDna);
  }

// 这样来做批量赋值，或者如果我们只想返回其中一个变量，可以对其他字段留空:
// 创建一个名为 feedOnKitty 的函数。它需要2个 uint 类型的参数，_zombieId 和_kittyId ，这是一个 public 类型的函数。
  function feedOnKitty(uint _zombieId, uint _kittyId) public {
    // 声明一个名为 kittyDna 的 uint
    uint kittyDna; 

    // 这个函数接下来调用 kittyContract.getKitty函数, 传入 _kittyId ，
    // 将返回的 genes 存储在 kittyDna 中。记住 —— getKitty 会返回10个变量
    (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId);

    // 函数调用了 feedAndMultiply ，并传入了 _zombieId 和 kittyDna 两个参数
    // 最后，我们修改了 feedOnKitty 中的函数调用。当它调用 feedAndMultiply 时，增加 “kitty” 作为最后一个参数。
   feedAndMultiply(_zombieId, kittyDna, "kitty");
  }

}

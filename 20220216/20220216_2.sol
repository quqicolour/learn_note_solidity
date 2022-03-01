pragma solidity ^0.4.19;
// 父类
contract ZombieFactory {

    event NewZombie(uint zombieId, string name, uint dna);

    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;

    struct Zombie {
        string name;
        uint dna;
    }

    Zombie[] public zombies;
// 映射本质上是存储和查找数据所用的键-值对。
// 第一个记录僵尸拥有者的地址，另一个记录某地址所拥有僵尸的数量。
// 创建一个叫做 zombieToOwner 的映射。其键是一个uint（我们将根据它的 id 存储和查找僵尸），值为 address。映射属性为public
    mapping (uint => address) public zombieToOwner;
// 创建一个名为 ownerZombieCount 的映射，其中键是 address，值是 uint。
    mapping (address => uint) ownerZombieCount;

// external 与public 类似，只不过这些函数只能在合约之外调用 - 它们不能被合约内的其他函数调用
// internal 和 private 类似，不过， 如果某个合约继承自其父合约，
// 这个合约即可以访问父合约中定义的“内部”函数。
    function _createZombie(string _name, uint _dna) internal {
        uint id = zombies.push(Zombie(_name, _dna)) - 1;
        // msg.sender，它指的是当前调用者（或智能合约）的 address。
        // 得到新的僵尸 id 后，更新 zombieToOwner 映射，在 id 下面存入 msg.sender。
        zombieToOwner[id] = msg.sender;
        // 为这个 msg.sender 名下的 ownerZombieCount 加 1。
        ownerZombieCount[msg.sender]++;
        NewZombie(id, _name, _dna);
    }

    function _generateRandomDna(string _str) private view returns (uint) {
        uint rand = uint(keccak256(_str));
        return rand % dnaModulus;
    }

    function createRandomZombie(string _name) public {
        // require在调用一个函数之前，用 require 验证前置条件是非常有必要的。
        // require使得函数在执行过程中，当不满足某些条件时抛出错误，并停止执行（每个玩家只能调用一次这个函数）

        // 在 createRandomZombie 的前面放置 require 语句。 
        // 使得函数先检查 ownerZombieCount [msg.sender] 的值为 0 ，不然就抛出一个错误
        require(ownerZombieCount[msg.sender] == 0);
        uint randDna = _generateRandomDna(_name);
        randDna = randDna - randDna % 100;
        _createZombie(_name, randDna);
    }

}
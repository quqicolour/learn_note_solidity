pragma solidity ^0.4.19;

// 导入 ownable.sol
import "./ownable.sol";

// 构造函数：function Ownable()是一个 _ constructor_ (构造函数)，
// 构造函数不是必须的，它与合约同名，构造函数一生中唯一的一次执行，就是在合约最初被创建的时候。

// 函数修饰符：modifier onlyOwner()。修饰符跟函数很类似,不过是用来修饰其他已有函数用的,在其他语句执行前，
// 为它检查下先验条件。我们就可以写个修饰符 onlyOwner 检查下调用者，确保只有合约的主人才能运行本函数。

/** Ownable 合约基本都会这么干：
*1合约创建，构造函数先行，将其 owner 设置为msg.sender（其部署者）
*2为它加上一个修饰符 onlyOwner，它会限制陌生人的访问，将访问某些函数的权限锁定在 owner 上。
*3允许将合约所有权转让给他人
*/

// 修改 ZombieFactory 合约， 让它继承自 Ownable
contract ZombieFactory is Ownable {

    event NewZombie(uint zombieId, string name, uint dna);

    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;
    // 声明一个名为 cooldownTime 的uint，并将其设置为 1 days
    uint cooldownTime = 1 days;

// 省 gas 的招数：结构封装 （Struct packing）
    struct Zombie {
      string name;
      uint dna;
// 当 uint 定义在一个 struct 中的时候，尽量使用最小的整数子类型以节约空间。 并且把同样类型的变量放一起
      uint32 level;
      uint32 readyTime;
    }

    Zombie[] public zombies;

    mapping (uint => address) public zombieToOwner;
    mapping (address => uint) ownerZombieCount;

// 变量 now 将返回当前的unix时间戳（自1970年1月1日以来经过的秒数）Unix时间传统用一个32位的整数进行存储。
// Solidity 还包含秒(seconds)，分钟(minutes)，小时(hours)，天(days)，周(weeks) 和 年(years) 等时间单位。它们都会转换成对应的秒数放入 uint 中
    function _createZombie(string _name, uint _dna) internal {
    // 添加加2个参数：1（表示当前的 level ）和uint32（now + cooldownTime）（现在+冷却时间，表示下次允许攻击的时间 readyTime）
    // 必须使用 uint32（...） 进行强制类型转换，因为 now 返回类型 uint256
        uint id = zombies.push(Zombie(_name, _dna, 1, uint32(now + cooldownTime))) - 1;
        zombieToOwner[id] = msg.sender;
        ownerZombieCount[msg.sender]++;
        NewZombie(id, _name, _dna);
    }

    function _generateRandomDna(string _str) private view returns (uint) {
        uint rand = uint(keccak256(_str));
        return rand % dnaModulus;
    }

    function createRandomZombie(string _name) public {
        require(ownerZombieCount[msg.sender] == 0);
        uint randDna = _generateRandomDna(_name);
        randDna = randDna - randDna % 100;
        _createZombie(_name, randDna);
    }

}

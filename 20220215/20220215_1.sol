pragma solidity >=0.4.19<0.9.0;
//solidity版本号在0.4.19到0.9.0（包括0.4.19，不包括0.9。0）
// 创建一个合约，名称为ZombieFactory
contract ZombieFactory {
    // 这里建立事件
    // 事件是能方便地调用以太坊虚拟机日志功能的接口。
    event NewZombie(uint zombieId, string name, uint dna);
// int / uint ：分别表示有符号和无符号的不同位数的整型变量。 支持关键字 uint8 到 uint256 （无符号，从 8 位到 256 位）以及 int8 到 int256，以 8 位为步长递增。 uint 和 int 分别是 uint256 和 int256 的别名。
    uint dnaDigits = 16; // 状态变量dnaDigits为16
    uint dnaModulus = 10 ** dnaDigits; // 状态变量dnaModulus为10^16

// 结构是可以将几个变量分组的自定义类型
// 创建一个结构Zombie
    struct Zombie {
        string name;
        uint dna;
    }

    Zombie[] public zombies;
    //定义一个私有的的函数_createZombie
    function _createZombie(string _name, uint _dna) private {  
        // 这里触发事件
        uint id = zombies.push(Zombie(_name, _dna)) - 1;
        NewZombie(id, _name, _dna);
    }

    // 函数是合约中代码的可执行单元。
    // 函数调用 可发生在合约内部或外部，且函数对其他合约有不同程度的可见性（ 可见性和 getter 函数）。
    //定义一个私有的可见的的函数_generateRandomDna，返回类型为uint
    function _generateRandomDna(string _str) private view returns (uint) {  
        uint rand = uint(keccak256(_str));
        return rand % dnaModulus;
    }
//定义一个公共的函数createRandomZombie
    function createRandomZombie(string _name) public {
        uint randDna = _generateRandomDna(_name);
        _createZombie(_name, randDna);
    }

}
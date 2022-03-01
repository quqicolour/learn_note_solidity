pragma solidity ^0.4.19;
// 导入文件
import "./zombieattack.sol";
import "./erc721.sol";
import "./safemath.sol";
  /// @title 一个简单的基础运算合约
  /// @author H4XF13LD MORRIS 💯💯😎💯💯
  /// @notice 现在，这个合约只添加一个乘法
  /// @notice 两个数相乘
  /// @param x 第一个 uint
  /// @param y  第二个 uint
  /// @return z  (x * y) 的结果
  /// @dev 现在这个方法不检查溢出

// 导入safemath以增强合约的安全性，防止溢出和下溢
// safeMath 的 add， sub， mul， 和 div 方法只做简单的四则运算，然后在发生溢出或下溢的时候抛出错误。


// 继承ZombieAttack，ERC721（合约可以继承自多个合约）
contract ZombieOwnership is ZombieAttack, ERC721 {

  using SafeMath for uint256;
// 定义一个映射 zombieApprovals。它将一个 uint 映射到一个 address。（当有人用一个 _tokenId 调用 takeOwnership 时，我们可以用这个映射来快速查找谁被批准获取那个代币。）
  mapping (uint => address) zombieApprovals;

// 这个函数只需要一个传入 address 参数，然后返回这个 address 拥有多少代币。
  function balanceOf(address _owner) public view returns (uint256 _balance) {
    // 实现 balanceOf 来返回 _owner 拥有的僵尸数量
    return ownerZombieCount[_owner];
  }

// 这个函数需要传入一个代币 ID 作为参数 (我们的情况就是一个僵尸 ID)，然后返回该代币拥有者的 address。
  function ownerOf(uint256 _tokenId) public view returns (address _owner) {
    // 实现 ownerOf 来返回拥有 ID 为 _tokenId 僵尸的所有者的地址
    return zombieToOwner[_tokenId];
  }

// 定义一个名为 _transfer的函数。它会需要3个参数：address _from、address _to和uint256 _tokenId。它应该是一个 私有 函数。
  function _transfer(address _from, address _to, uint256 _tokenId) private {
 // ownerZombieCount（记录一个所有者有多少只僵尸）和zombieToOwner （记录什么人拥有什么）。
// 为接收僵尸的人（address _to）增 加ownerZombieCount。使用 ++ 来增加。
    ownerZombieCount[_to] = ownerZombieCount[_to].add(1);
// 为发送僵尸的人（address _from）减少ownerZombieCount。使用 -- 来扣减。
    ownerZombieCount[msg.sender] = ownerZombieCount[msg.sender].sub(1);
// 改变这个 _tokenId 的 zombieToOwner 映射，它现在就会指向 _to
    zombieToOwner[_tokenId] = _to;
// 用正确的参数触发Transfer ——查看 erc721.sol 看它期望传入的参数并在这里实现。
    Transfer(_from, _to, _tokenId);
  }

// 只有代币或僵尸的所有者可以转移它，需要添加修饰符 onlyOwnerOf
  function transfer(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {
    //  调用 _transfer，把 msg.sender 作为参数传递进 address _from
    _transfer(msg.sender, _to, _tokenId);
  }

// 在函数 approve 上， 我们想要确保只有代币所有者可以批准某人来获取代币。所以我们需要添加修饰符 onlyOwnerOf 到 approve。
  function approve(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {
// 将 _tokenId 的 zombieApprovals 设置为和 _to 相等。
    zombieApprovals[_tokenId] = _to;
    // 调用Approval，把 msg.sender 作为参数传递进 Approval
    Approval(msg.sender, _to, _tokenId);
  }

// 最后一个函数 takeOwnership， 应该只是简单地检查以确保 msg.sender 已经被批准来提取这个代币或者僵尸。若确认，就调用 _transfer；
  function takeOwnership(uint256 _tokenId) public {
    //   用一个 require 句式来检查 _tokenId 的 zombieApprovals 和 msg.sender 相等。
    require(zombieApprovals[_tokenId] == msg.sender);
    // 定义一个名为 owner 的 address 变量，并使其等于 ownerOf(_tokenId)。
    address owner = ownerOf(_tokenId);
    // 最后，调用 _transfer, 并传入所有必须的参数。（在这里你可以用 msg.sender 作为 _to， 因为代币正是要发送给调用这个函数的人）。
    _transfer(owner, msg.sender, _tokenId);
  }
}
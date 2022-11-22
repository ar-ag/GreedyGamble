pragma solidity ^0.8.0;

contract PKCoin {
    int balance;

    constructor() public {
        balance = 0;

    }

    function getBalance() view public returns(int) {
        return balance;
    }

    function deposit(int amt) public {
        balance = balance + amt;
    }

     function withdraw(int amt) public {
        balance = balance - amt;
    }


}

contract Game {
    PKCoin public player1;
    PKCoin public player2;
    int f;

    function init(address _player1, address _player2, int _f) public {
        player1 = PKCoin(_player1);
        player2 = PKCoin(_player2);
        f = _f;
    }

    function wins() public {
        if(f == 1) {
            player1.deposit(player2.getBalance());
            player2.withdraw(player2.getBalance());

        } else if( f==2 ){

            player2.deposit(player1.getBalance());
            player1.withdraw(player1.getBalance());
     
        }
    }   
}

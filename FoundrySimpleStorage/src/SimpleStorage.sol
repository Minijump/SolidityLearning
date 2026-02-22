// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

contract SimpleSorage {
    struct Person {
        uint256 myFavouriteNumber;
        string name;
    }

    bool hasFavoriteNumber = true;
    uint256 public favoriteNumber = 88;
    uint256[] listOfFavouriteNumbers = [1, 2, 3, 4, 5];
    string favoriteNumberInText = "eighty-eight";
    int256 favoriteInt = -88;
    address myAddress = 0xCc78E8a3515072277A46f940E5762D7e00669e47;
    bytes32 favoriteBytes32 = "cat";
    Person public myFriend = Person({ myFavouriteNumber: 7, name: 'Pat' });
    Person[] public listOfPeople;
    mapping (string => uint256) public nameToFavoriteNumber;


    function store(uint256 _favoriteNumber) public {
        favoriteNumber = _favoriteNumber;
    }

    function retrieveVar() public view returns(uint256){
        return favoriteNumber;
    }

    function retreiveCst() public pure returns(uint256){
        return 7;
    }

    function addPerson(string memory _name, uint256 _favoriteNumber) public {
        listOfPeople.push(Person({ myFavouriteNumber: _favoriteNumber, name: _name }));
        nameToFavoriteNumber[_name] = _favoriteNumber;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

contract SimpleStorage {
    struct Person {
        uint256 my_favorite_number;
        string name;
    }

    bool hasFavoriteNumber = true;
    uint256 public favoriteNumber = 88;
    uint256[] list_of_favorite_numbers = [1, 2, 3, 4, 5];
    string favoriteNumberInText = "eighty-eight";
    int256 favoriteInt = -88;
    address myAddress = 0xCc78E8a3515072277A46f940E5762D7e00669e47;
    bytes32 favoriteBytes32 = "cat";
    Person public my_friend = Person(7, 'Pat');
    Person[] public list_of_people;
    mapping (string => uint256) public nameToFavoriteNumber;


    function store(uint256 _favoriteNumber) public virtual{
        // virtual keyword necessary to make the function overridable in AddFiveStorage
        favoriteNumber = _favoriteNumber;
    }

    function retrieve_var() public view returns(uint256){
        return favoriteNumber;
    }

    function retrieve_cst() public pure returns(uint256){
        return 7;
    }

    function add_person(string memory _name, uint256 _favorite_number) public {
        list_of_people.push(Person(_favorite_number, _name));
        nameToFavoriteNumber[_name] = _favorite_number;
    }
}

contract SimpleStorage2 {}

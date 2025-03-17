// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract CarRental {
    struct Car {
        uint id;
        string model;
        uint256 pricePerDay;
        address owner;
        bool isAvailable;
    }

    struct Rental {
        uint carId;
        address renter;
        uint256 rentalStart;
        uint256 rentalEnd;
        bool isActive;
    }

    string public projectTitle;
    string public projectDescription;
    address public contractOwner;
    uint public carCount;
    uint public rentalCount;
    
    mapping(uint => Car) public cars;
    mapping(uint => Rental) public rentals;
    
    event CarListed(uint carId, string model, uint256 pricePerDay, address owner);
    event CarRented(uint carId, address renter, uint256 rentalStart, uint256 rentalEnd);
    event RentalCompleted(uint carId, address renter);

    constructor() {
        projectTitle = "Blockchain for Car Rentals";
        projectDescription = "Develop a blockchain platform to rent cars directly between individuals without intermediaries.";
        contractOwner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == contractOwner, "Only contract owner can perform this action");
        _;
    }

    function listCar(string memory _model, uint256 _pricePerDay) public {
        carCount++;
        cars[carCount] = Car(carCount, _model, _pricePerDay, msg.sender, true);
        emit CarListed(carCount, _model, _pricePerDay, msg.sender);
    }
    
    function rentCar(uint _carId, uint256 _rentalDays) public payable {
        Car storage car = cars[_carId];
        require(car.isAvailable, "Car is not available");
        require(msg.value >= car.pricePerDay * _rentalDays, "Insufficient payment");
        
        rentalCount++;
        rentals[rentalCount] = Rental(_carId, msg.sender, block.timestamp, block.timestamp + (_rentalDays * 1 days), true);
        car.isAvailable = false;
        payable(car.owner).transfer(msg.value);

        emit CarRented(_carId, msg.sender, block.timestamp, block.timestamp + (_rentalDays * 1 days));
    }
    
    function completeRental(uint _rentalId) public {
        Rental storage rental = rentals[_rentalId];
        require(rental.isActive, "Rental is not active");
        require(msg.sender == rental.renter, "Only the renter can complete the rental");
        
        rental.isActive = false;
        cars[rental.carId].isAvailable = true;
        
        emit RentalCompleted(rental.carId, msg.sender);
    }
    
    function getProjectDetails() public view returns (string memory, string memory) {
        return (projectTitle, projectDescription);
    }
    
    function updateProjectDetails(string memory _title, string memory _description) public onlyOwner {
        projectTitle = _title;
        projectDescription = _description;
    }
}


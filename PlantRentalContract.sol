// SPDX-License-Identifier: MIT

pragma solidity 0.8.29;

contract PlantRentalContract {

    enum Status {Available, Rented, Expired}
    enum Type {Cactus, Bamboo, Monstera}

    struct Plant {
        Status status;
        Type plantType;
        uint256 dailyFee;
        uint256 endOfContract;
        address tenant;
    }

    Plant[] public availablePlants;
    address public lessor;
    uint8 maxDaysToRent = 4;

    constructor() {
        lessor = msg.sender;
    }

    modifier onlyLessor() {
        require(msg.sender == lessor, "Only lessor can perform this action");
        _;
    }

    modifier checkAvailability(Type plantType) {
        require(_isAvailable(plantType), "No plants of this type are available for rent. Try again later...");
        _;
    }

    modifier withInMaxDays(uint8 daysToRent) {
        require(daysToRent <= maxDaysToRent, "Plants can't be rented for that long");
        _;
    }

    event Rented (Type plantType, uint256 indexed plantId, address indexed tenant);

    function addPlant (Type plantType, uint256 dailyFee) public onlyLessor() {
        Plant memory newPlant = Plant({
            status: Status.Available,
            plantType: plantType,
            dailyFee: dailyFee,
            endOfContract: 0,
            tenant: address(0)
        });
        availablePlants.push(newPlant);
    }

    function rentPlant(Type plantType, uint8 daysToRent) 
        public 
        checkAvailability(plantType)
        withInMaxDays(daysToRent){
        uint256 id = _findPlant(plantType);
        address tenant = msg.sender;
        Plant storage plantToRent  = availablePlants[id];
        plantToRent.tenant = tenant;
        plantToRent.status = Status.Rented;
        plantToRent.endOfContract = block.timestamp + (daysToRent * 1 days);
        availablePlants.push(plantToRent);

        emit Rented(plantType, id, tenant);
    }

    function checkAndExpire(uint256 plantId) public {
        Plant storage plant = availablePlants[plantId];
        require(plant.status == Status.Rented, "Plant is not rented");
        require(block.timestamp >= plant.endOfContract, "Rental period not yet ended");

        plant.status = Status.Available;
        plant.tenant = address(0);
        plant.endOfContract = 0;
    }

    function _findPlant(Type plantType) internal view checkAvailability(plantType) returns (uint256) {
        for (uint256 i = 0; i < availablePlants.length; i++) {
            if (
                availablePlants[i].plantType == plantType && 
                availablePlants[i].status == Status.Available
            ) {
                return i;
            }
        }
        revert("No available plant of the requested type");
    }

    function _isAvailable (Type plantType) internal view returns(bool) {
        for (uint256 i  = 0; i < availablePlants.length; i++) {
            if (
                availablePlants[i].plantType == plantType && 
                availablePlants[i].status == Status.Available
            ) {
                return true;
            }
        }
        revert();
    }
}
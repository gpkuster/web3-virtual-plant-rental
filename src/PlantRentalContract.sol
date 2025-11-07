// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

/**
 * @title PlantRentalContract
 * @dev A simple contract for renting plants for a limited period of time.
 * The contract allows a lessor (owner) to add plants for rent,
 * and tenants can rent available plants for up to a fixed number of days.
 */
contract PlantRentalContract {
    // --- ENUMS ---

    /// @notice Represents the current status of a plant.
    enum Status {
        Available, // The plant can be rented.
        Rented, // The plant is currently rented out.
        Expired // The rental period has ended (not used directly in current logic).

    }

    /// @notice Represents the type/species of a plant.
    enum Type {
        Cactus,
        Bamboo,
        Monstera
    }

    // --- STRUCTS ---

    /**
     * @notice Represents a plant's rental-related data.
     * @param status The current rental status.
     * @param plantType The type/species of the plant.
     * @param dailyFee Rental fee per day (not charged in this version).
     * @param endOfContract Timestamp indicating when the rental period ends.
     * @param tenant The address of the tenant renting the plant.
     */
    struct Plant {
        Status status;
        Type plantType;
        uint256 dailyFee;
        uint256 endOfContract;
        address tenant;
    }

    // --- STATE VARIABLES ---

    /// @notice List of all plants managed by the contract.
    Plant[] public availablePlants;

    /// @notice The address of the lessor (contract owner).
    address public lessor;

    /// @notice Maximum number of days a plant can be rented for.
    uint8 public maxDaysToRent = 4;

    // --- CONSTRUCTOR ---

    /**
     * @dev Sets the deployer of the contract as the lessor (owner).
     */
    constructor() {
        lessor = msg.sender;
    }

    // --- MODIFIERS ---

    /// @dev Restricts access to only the lessor (owner).
    modifier onlyLessor() {
        require(msg.sender == lessor, "Only lessor can perform this action");
        _;
    }

    /// @dev Ensures that there is at least one available plant of the given type.
    modifier checkAvailability(Type plantType) {
        require(_isAvailable(plantType), "No plants of this type are available for rent. Try again later...");
        _;
    }

    /// @dev Ensures that the requested rental duration does not exceed the maximum allowed.
    modifier withInMaxDays(uint8 daysToRent) {
        require(daysToRent <= maxDaysToRent, "Plants can't be rented for that long");
        _;
    }

    // --- EVENTS ---

    /**
     * @notice Emitted when a plant is rented by a tenant.
     * @param plantType The type of plant rented.
     * @param plantId The index of the plant in the array.
     * @param tenant The address of the tenant renting the plant.
     */
    event Rented(Type plantType, uint256 indexed plantId, address indexed tenant);

    // --- PUBLIC FUNCTIONS ---

    /**
     * @notice Allows the lessor to add a new plant available for rent.
     * @param plantType The type of plant to add.
     * @param dailyFee The rental fee per day (for informational purposes).
     */
    function addPlant(Type plantType, uint256 dailyFee) public onlyLessor {
        Plant memory newPlant = Plant({
            status: Status.Available,
            plantType: plantType,
            dailyFee: dailyFee,
            endOfContract: 0,
            tenant: address(0)
        });
        availablePlants.push(newPlant);
    }

    /**
     * @notice Allows a user to rent a plant of a specific type.
     * @param plantType The desired type of plant.
     * @param daysToRent Number of days to rent the plant (must be <= maxDaysToRent).
     */
    function rentPlant(Type plantType, uint8 daysToRent)
        public
        checkAvailability(plantType)
        withInMaxDays(daysToRent)
    {
        uint256 id = _findPlant(plantType);
        address tenant = msg.sender;

        Plant storage plantToRent = availablePlants[id];
        plantToRent.tenant = tenant;
        plantToRent.status = Status.Rented;
        plantToRent.endOfContract = block.timestamp + (daysToRent * 1 days);

        // ⚠️ Note: The next line pushes a duplicate plant into the array.
        // This likely isn't intended — it copies the rented plant to the end of the list.
        // Consider removing it to avoid state inconsistency.
        availablePlants.push(plantToRent);

        emit Rented(plantType, id, tenant);
    }

    /**
     * @notice Checks if a rented plant’s contract period has expired and resets it to available.
     * @param plantId The index of the plant to check.
     */
    function checkAndExpire(uint256 plantId) public {
        Plant storage plant = availablePlants[plantId];
        require(plant.status == Status.Rented, "Plant is not rented");
        require(block.timestamp >= plant.endOfContract, "Rental period not yet ended");

        // Reset the plant's data to make it available again.
        plant.status = Status.Available;
        plant.tenant = address(0);
        plant.endOfContract = 0;
    }

    // --- INTERNAL FUNCTIONS ---

    /**
     * @dev Finds an available plant of the given type and returns its index.
     * @param plantType The type of plant to find.
     * @return The index of the available plant in the array.
     */
    function _findPlant(Type plantType) internal view checkAvailability(plantType) returns (uint256) {
        for (uint256 i = 0; i < availablePlants.length; i++) {
            if (availablePlants[i].plantType == plantType && availablePlants[i].status == Status.Available) {
                return i;
            }
        }
        revert("No available plant of the requested type");
    }

    /**
     * @dev Checks if there is any available plant of a given type.
     * @param plantType The type of plant to check.
     * @return True if an available plant exists, otherwise reverts.
     */
    function _isAvailable(Type plantType) internal view returns (bool) {
        for (uint256 i = 0; i < availablePlants.length; i++) {
            if (availablePlants[i].plantType == plantType && availablePlants[i].status == Status.Available) {
                return true;
            }
        }
        revert("No available plants");
    }
}

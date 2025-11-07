// SPDX-License-Identifier: MIT
pragma solidity 0.8.29;

import "forge-std/Test.sol";
import "../src/PlantRentalContract.sol";

/**
 * @title PlantRentalContractTest
 * @dev Foundry test suite for PlantRentalContract
 */
contract PlantRentalContractTest is Test {
    PlantRentalContract public rental;
    address public lessor;
    address public tenant1;
    address public tenant2;

    // --- SETUP ---

    function setUp() public {
        lessor = address(this); // The test contract is the lessor
        tenant1 = address(0xAAA1);
        tenant2 = address(0xAAA2);

        rental = new PlantRentalContract();
    }

    // --- DEPLOYMENT TESTS ---

    function testInitialLessorIsDeployer() public view {
        assertEq(rental.lessor(), lessor);
    }

    function testMaxDaysToRentIsSet() public view {
        assertEq(rental.maxDaysToRent(), 4);
    }

    // --- ADD PLANT TESTS ---

    function testAddPlantAsLessor() public {
        rental.addPlant(PlantRentalContract.Type.Cactus, 0.01 ether);
        (PlantRentalContract.Status status, PlantRentalContract.Type plantType,,,) = getPlant(0);

        assertEq(uint256(status), uint256(PlantRentalContract.Status.Available));
        assertEq(uint256(plantType), uint256(PlantRentalContract.Type.Cactus));
    }

    function testCannotAddPlantAsNonLessor() public {
        vm.prank(tenant1);
        vm.expectRevert("Only lessor can perform this action");
        rental.addPlant(PlantRentalContract.Type.Bamboo, 0.01 ether);
    }

    // --- RENT PLANT TESTS ---

    function testRentPlantSuccess() public {
        rental.addPlant(PlantRentalContract.Type.Cactus, 0.01 ether);

        vm.startPrank(tenant1);
        rental.rentPlant(PlantRentalContract.Type.Cactus, 2);
        vm.stopPrank();

        (,,, uint256 endOfContract, address tenant) = getPlant(0);

        assertEq(tenant, tenant1);
        assertGt(endOfContract, block.timestamp);
    }

    function testRentPlantEmitsEvent() public {
        rental.addPlant(PlantRentalContract.Type.Cactus, 0.01 ether);

        vm.startPrank(tenant1);
        vm.expectEmit(true, true, false, false);
        emit PlantRentalContract.Rented(PlantRentalContract.Type.Cactus, 0, tenant1);
        rental.rentPlant(PlantRentalContract.Type.Cactus, 2);
        vm.stopPrank();
    }

    function testRentPlantExceedsMaxDaysReverts() public {
        rental.addPlant(PlantRentalContract.Type.Cactus, 0.01 ether);

        vm.startPrank(tenant1);
        vm.expectRevert("Plants can't be rented for that long");
        rental.rentPlant(PlantRentalContract.Type.Cactus, 10);
        vm.stopPrank();
    }

    function testRentUnavailablePlantReverts() public {
        vm.startPrank(tenant1);
        vm.expectRevert("No available plants");
        rental.rentPlant(PlantRentalContract.Type.Monstera, 1);
        vm.stopPrank();
    }

    // --- EXPIRATION TESTS ---

    function testCheckAndExpireSuccess() public {
        rental.addPlant(PlantRentalContract.Type.Cactus, 0.01 ether);

        vm.startPrank(tenant1);
        rental.rentPlant(PlantRentalContract.Type.Cactus, 1);
        vm.stopPrank();

        // Fast-forward time past rental period
        vm.warp(block.timestamp + 2 days);

        rental.checkAndExpire(0);

        (,,, uint256 endOfContract, address tenant) = getPlant(0);
        (PlantRentalContract.Status status,,,,) = rental.availablePlants(0);

        assertEq(uint256(status), uint256(PlantRentalContract.Status.Available));
        assertEq(tenant, address(0));
        assertEq(endOfContract, 0);
    }

    function testCheckAndExpireTooEarlyReverts() public {
        rental.addPlant(PlantRentalContract.Type.Cactus, 0.01 ether);

        vm.startPrank(tenant1);
        rental.rentPlant(PlantRentalContract.Type.Cactus, 1);
        vm.stopPrank();

        // Not yet expired
        vm.expectRevert("Rental period not yet ended");
        rental.checkAndExpire(0);
    }

    function testCheckAndExpireNonRentedPlantReverts() public {
        rental.addPlant(PlantRentalContract.Type.Cactus, 0.01 ether);
        vm.expectRevert("Plant is not rented");
        rental.checkAndExpire(0);
    }

    // --- HELPER FUNCTION ---

    function getPlant(uint256 index)
        internal
        view
        returns (
            PlantRentalContract.Status status,
            PlantRentalContract.Type plantType,
            uint256 dailyFee,
            uint256 endOfContract,
            address tenant
        )
    {
        (status, plantType, dailyFee, endOfContract, tenant) = rental.availablePlants(index);
    }
}

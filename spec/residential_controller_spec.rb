require 'residential_controller'
require 'duplicate'



def scenario(column, requestedFloor, direction, destination)
    tempColumn = duplicate(column)
    selectedElevator = tempColumn.requestElevator(requestedFloor, direction)
    pickedUpUser = false
    if selectedElevator.currentFloor == requestedFloor
        pickedUpUser = true
    end
    selectedElevator.requestFloor(destination)
    moveAllElevators(tempColumn)

    for i in 0..tempColumn.elevatorList.length-1
        if tempColumn.elevatorList[i].id == selectedElevator.id
            tempColumn.elevatorList[i].currentFloor = selectedElevator.currentFloor
        end
    end

    result = {
        'tempColumn' => tempColumn,
        'selectedElevator' => selectedElevator,
        'pickedUpUser' => pickedUpUser
    }
    return result
end

def moveAllElevators(column)
    column.elevatorList.each do |elevator|
        while elevator.floorRequestList.length != 0 do
            elevator.move()
        end
    end
end

describe 'ResidentialController:' do
    column = Column.new(1, 10, 2)

    describe "Column's attributes and methods" do

        it 'Instantiates a Column with valid attributes' do
            expect(column).to be_a Column
            expect(column.id).to eq(1)
            expect(column.status).not_to be_nil
            expect(column.elevatorList.length).to eq(2)
            expect(column.elevatorList[0]).to be_a Elevator
            expect(column.callButtonList.length).to eq(18)
            expect(column.callButtonList[0]).to be_a CallButton
        end

        it 'Has a requestElevator method' do
            expect(column.requestElevator(1, 'up')).not_to be_nil
        end

        it 'Can find and return an elevator' do
            elevator = column.requestElevator(1, 'up')
            expect(elevator).to be_a Elevator 
        end
    end

    describe "Elevator's attributes and methods" do
        elevator = Elevator.new(1, 10)

        it 'Instantiates an Elevator with valid attributes' do
            expect(elevator).to be_a Elevator
            expect(elevator.id).to eq(1)
            expect(elevator.status).not_to be_nil
            expect(elevator.door).to be_a Door
            expect(elevator.floorRequestButtonList.length).to eq(10)
            expect(elevator.floorRequestList).to match_array([])
        end

        it 'Has a requestFloor method' do
            expect(elevator.requestFloor(1)).not_to be_a NoMethodError
        end

        it 'Has a move method' do
            expect(elevator.move()).not_to be_a NoMethodError
        end
    end

    describe "CallButton's attributes" do

        callButton = CallButton.new(1, 1, 'up')

        it 'Instantiates a CallButton with valid attributes' do
            expect(callButton).to be_a CallButton
            expect(callButton.id).to eq(1)
            expect(callButton.status).not_to be_nil
            expect(callButton.floor).to eq(1)
            expect(callButton.direction).to eq('up') 
        end

    end

    describe "FloorRequestButton's attributes" do

        floorRequestButton = FloorRequestButton.new(1, 1)
        
        it 'Instantiates a FloorRequestButton with valid attributes' do
            expect(floorRequestButton).to be_a FloorRequestButton
            expect(floorRequestButton.id).to eq(1)
            expect(floorRequestButton.status).not_to be_nil
            expect(floorRequestButton.floor).to eq(1)
        end
    end

    describe "Door's attributes" do
        door = Door.new(1)

        it 'Instantiates a Door with valid attributes' do
            expect(door).to be_a Door
            expect(door.id).to eq(1)
            expect(door.status).not_to be_nil
        end
    end

    #--------------------------------Scenario 1--------------------------------
  
    describe "Functional Scenario 1 reaches the expected outcome" do
        column.elevatorList[0].currentFloor = 2
        column.elevatorList[0].status = 'idle'
        column.elevatorList[1].currentFloor = 6
        column.elevatorList[1].status = 'idle'

        results = scenario(column, 3, 'up', 7)

        it 'Part 1 of scenario 1 chooses the best elevator' do
            expect(results['selectedElevator'].id).to eq(1)
        end
        it 'Part 1 of scenario 1 picks up the user' do
            expect(results['pickedUpUser']).to be true
        end
        it 'Part 1 of scenario 1 brings the user to destination' do
            expect(results['selectedElevator'].currentFloor).to eq(7)
        end
        it 'Part 1 of scenario 1 ends with all the elevators at the right position' do
            expect(results['tempColumn'].elevatorList[0].currentFloor).to eq(7)
            expect(results['tempColumn'].elevatorList[1].currentFloor).to eq(6)
        end
    end
    #-------------------------Scenario 2-----------------------------<('-'<)
    describe "Functional Scenario 2 reaches the expected outcome" do
        
        column.elevatorList[0].currentFloor = 10
        column.elevatorList[0].status = 'idle'
        column.elevatorList[1].currentFloor = 3
        column.elevatorList[1].status = 'idle'

        results1 = scenario(column, 1, 'up', 6)
        column = duplicate(results1['tempColumn']) 

        results2 = scenario(column, 3, 'up', 5)
        column = duplicate(results2['tempColumn']) 

        results3 = scenario(column, 9, 'down', 2)
        column = duplicate(results3['tempColumn'])  

        describe "Part 1 of scenario 2" do
            it "Part 1 of scenario 2 chooses the best elevator" do
                expect(results1['selectedElevator'].id).to eq(2)
            end
            it "Part 1 of scenario 2 picks up the user" do
                expect(results1["pickedUpUser"]).to be true
            end
            it "Part 1 of scenario 2 brings the user to destination" do
                expect(results1['selectedElevator'].currentFloor).to eq(6)
            end
            it 'Part 1 of scenario 2 ends with all the elevators at the right position' do
                expect(results1['tempColumn'].elevatorList[0].currentFloor).to eq(10)
                expect(results1['tempColumn'].elevatorList[1].currentFloor).to eq(6)
            end
        end

        describe "Part 2 of scenario 2" do
            it "Part 2 of scenario 2 chooses the best elevator" do
                expect(results2['selectedElevator'].id).to eq(2)
            end
            it "Part 2 of scenario 2 picks up the user" do
                expect(results2["pickedUpUser"]).to be true
            end
            it "Part 2 of scenario 2 brings the user to destination" do
                expect(results2['selectedElevator'].currentFloor).to eq(5)
            end
            it 'Part 2 of scenario 2 ends with all the elevators at the right position' do
                expect(results2['tempColumn'].elevatorList[0].currentFloor).to eq(10)
                expect(results2['tempColumn'].elevatorList[1].currentFloor).to eq(5)
            end
        end

        describe "Part 3 of scenario 2" do
            it "Part 3 of scenario 2 chooses the best elevator" do
                expect(results3['selectedElevator'].id).to eq(1)
            end
            it "Part 3 of scenario 2 picks up the user" do
                expect(results3["pickedUpUser"]).to be true
            end
            it "Part 3 of scenario 2 brings the user to destination" do
                expect(results3['selectedElevator'].currentFloor).to eq(2)
            end
            it 'Part 3 of scenario 2 ends with all the elevators at the right position' do
                expect(results3['tempColumn'].elevatorList[0].currentFloor).to eq(2)
                expect(results3['tempColumn'].elevatorList[1].currentFloor).to eq(5)
            end
        end
    end
    #----------------------------Scenario 3-------------------------------------
    describe 'Functional Scenario 3 reaches the expected outcome' do
        column.elevatorList[0].currentFloor = 10
        column.elevatorList[0].status = 'idle'
        column.elevatorList[1].currentFloor = 3
        column.elevatorList[1].direction = 'up'
        column.elevatorList[1].status = 'moving'
        column.elevatorList[1].floorRequestList.push(6)

        results4 = scenario(column, 3, 'down', 2)

        column = duplicate(results4['tempColumn']) 

        results5 = scenario(column, 10, 'down', 3)
        column = duplicate(results5['tempColumn'])

        describe "Part 1 of scenario 3" do
            it "Part 1 of scenario 3 chooses the best elevator" do
                expect(results4['selectedElevator'].id).to eq(1)
            end
            it "Part 1 of scenario 3 picks up the user" do
                expect(results4["pickedUpUser"]).to be true
            end
            it "Part 1 of scenario 3 brings the user to destination" do
                expect(results4['selectedElevator'].currentFloor).to eq(2)
            end
            it 'Part 1 of scenario 3 ends with all the elevators at the right position' do
                expect(results4['tempColumn'].elevatorList[0].currentFloor).to eq(2)
                expect(results4['tempColumn'].elevatorList[1].currentFloor).to eq(6)
            end
        end

        describe "Part 2 of scenario 3" do
            it "Part 2 of scenario 3 chooses the best elevator" do
                expect(results5['selectedElevator'].id).to eq(2)
            end
            it "Part 2 of scenario 3 picks up the user" do
                expect(results5["pickedUpUser"]).to be true
            end
            it "Part 2 of scenario 3 brings the user to destination" do
                expect(results5['selectedElevator'].currentFloor).to eq(3)
            end
            it 'Part 2 of scenario 3 ends with all the elevators at the right position' do
                expect(results5['tempColumn'].elevatorList[0].currentFloor).to eq(2)
                expect(results5['tempColumn'].elevatorList[1].currentFloor).to eq(3)
            end
        end
    end
end

class Column

    attr_accessor  :status, :elevatorList, :callButtonList
    attr_reader :id, :amountOfElevators, :amountOfFloors, :bottomFloor, :topFloor

    def initialize(_id, _amountOfFloors, _amountOfElevators, _status='online', _bottomFloor = 1)
        @id = _id
        @status = _status
        @amountOfElevators = _amountOfElevators
        @amountOfFloors = _amountOfFloors
        @bottomFloor = _bottomFloor
        @topFloor = @bottomFloor + @amountOfFloors - 1
        @elevatorList = []
        @callButtonList = []
        self.buildElevatorList()
        self.buildCallButtonList()
    end

    def buildCallButtonList() 
        id = 1
        for floor in @bottomFloor..@topFloor-1 do
            @callButtonList.push(CallButton.new(id, floor, 'up'))
            id += 1
        end
        for floor in @bottomFloor+1..@topFloor do
            @callButtonList.push(CallButton.new(id, floor, 'down'))
            id += 1
        end
    end

    def buildElevatorList()
        for id in 1..amountOfElevators do
            @elevatorList.push(Elevator.new(id, @amountOfFloors))
        end
    end

    def requestElevator(requestedFloor, direction)
        bestElevator = self.findElevator(requestedFloor, direction)
        bestElevator.floorRequestList.push(requestedFloor)
        bestElevator.move()
        bestElevator.operateDoors()
        return bestElevator
    end

    def findElevator(requestedFloor, requestedDirection)

        comparedElevator = {
            'elevator' => nil,
            'score' => 5,
            'referenceGap' => 10000000
        }
        @elevatorList.each do |elevator|
            score = 4
            if requestedFloor == elevator.currentFloor and elevator.status == 'stop' and requestedDirection == elevator.direction
                score = 1
            elsif requestedFloor > elevator.currentFloor and elevator.direction == 'up' and requestedDirection == elevator.direction
                score = 2
            elsif requestedFloor < elevator.currentFloor and elevator.direction == 'down' and requestedDirection == elevator.direction
                score = 2
            elsif elevator.status == 'idle'
                score = 3
            end
            bestElevator = elevator.compareElevator(score, comparedElevator, requestedFloor) 
            comparedElevator = bestElevator   
        end
        return comparedElevator['elevator']    
    end

end

class Elevator

    attr_accessor :status, :currentFloor, :direction, :overweightSensor, :floorRequestList, :floorRequestButtonList
    attr_reader :id, :amountOfFloors, :door

    def initialize(_id, _amountOfFloors, _status='idle', _currentFloor=1)
        @id = _id
        @amountOfFloors = _amountOfFloors
        @status = _status
        @currentFloor = _currentFloor
        @direction = nil
        @screenDisplay = @currentFloor
        @overweightAlarm = 'OFF'
        @door = Door.new(@id, 'closed')
        @overweightSensor = 'OFF'
        @floorRequestButtonList = []
        @floorRequestList = []
        self.createFloorRequestButtons()
    end

    def createFloorRequestButtons()
        for idAndFloor in 1..@amountOfFloors do
            @floorRequestButtonList.push(FloorRequestButton.new(idAndFloor, idAndFloor))
        end
    end

    def compareElevator(scoreToCheck, comparedElevator, floor)
        bestElevator = comparedElevator
        if scoreToCheck < bestElevator['score']
            bestElevator['score'] = scoreToCheck
            bestElevator['elevator'] = self
            bestElevator['referenceGap'] = (@currentFloor - floor).abs
        elsif scoreToCheck == bestElevator['score']
            gap = (@currentFloor - floor).abs
            if bestElevator['referenceGap'] > gap
                bestElevator['elevator'] = self
                bestElevator['referenceGap'] = gap
            end
        end
        return bestElevator
    end

    def requestFloor(requestedFloor)
        @floorRequestList.push(requestedFloor)
        puts @floorRequestList.to_s + 'added to floorRequestList'
        self.move()
        self.operateDoors()
    end

    def move()
        while @floorRequestList.length > 0 do
            destination = @floorRequestList.shift
            puts @id.to_s + ' ' + destination.to_s 
            @status = 'moving'
            if @currentFloor < destination
                @direction = 'up'
                self.sortFloorList()
                while @currentFloor < destination do
                    puts @currentFloor
                    @currentFloor += 1
                    @screenDisplay = @currentFloor
                end
            elsif @currentFloor > destination
                @direction = 'down'
                self.sortFloorList()
                while @currentFloor > destination do
                    puts @currentFloor
                    @currentFloor -= 1
                    @screenDisplay = @currentFloor
                end
            end
            @status = 'stop'
        end 
        @status = 'idle'
    end

    def sortFloorList()
        if @direction == 'up'
            @floorRequestList.sort! {|a, b| a <=> b }    
        else
            @floorRequestList.sort! {|a, b| b <=> a }
        end
        
    end

    def operateDoors()
        @door.status = 'opened'
        #sleep(5)
        if not self.isOverweight()
            @door.status = 'closing'
            if not self.door.isObstructed()
                @door.status = 'closed'
            else
                self.operateDoors()
            end
        else
            while self.isOverweight() do @overweightAlarm = 'ON'
            end
            @overweightAlarm = 'OFF'
            self.operateDoors()
        end
    end

    def isOverweight()
        return @overweightSensor == 'ON'
    end
end

class CallButton

    attr_reader :id, :floor, :direction
    attr_accessor :status

    def initialize(_id, _floor, _direction, _status='OFF')
        @id = _id
        @floor = _floor
        @direction = _direction
        @status = _status
    end
end

class FloorRequestButton

    attr_reader :id, :floor
    attr_accessor :status

    def initialize(_id, _floor, _status='OFF')
        @id = _id
        @floor = _floor
        @status = _status
    end
end

class Door

    attr_reader :id
    attr_accessor :status

    def initialize(_id, _status='OFF')
        @id = _id
        @status = _status
        @sensorState = 'OFF'
    end

    def isObstructed()
        return @sensorState == 'ON'
    end
end












classdef Person
    %PERSON Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        healthStatus
        isSusceptible
        spreadLatency
        spreadPeriod
        sympLatency
        symptomLength
    end
    
    methods
        function obj = Person()
            obj.healthStatus = 0;
            obj.isSusceptible = 0;
            obj.spreadLatency = 0;
            obj.spreadPeriod = 0;
            obj.sympLatency = 0;
            obj.symptomLength = 0;
        end
        
        
        function obj = infect(obj,latency,spread,sympLatency,sympLength)
            obj.healthStatus = 1;
            obj.spreadLatency = latency;
            obj.spreadPeriod = spread;
            obj.sympLatency = sympLatency;
            obj.symptomLength = sympLength;
        end
    end
    
end


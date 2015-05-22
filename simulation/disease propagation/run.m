function [] = run()
%RUN COMP 3950 Assignment 2
%   Kimberly Bridglal 811000371
%   Warren O'Connell 811000293
%   Aaron Yuk Low 811003468
    
    popSize = input('input population size: ');
    pop(popSize) = Person();
    t = 0;
    firstInfected = input('input number of people first infected: ');
    susT(1) = popSize - firstInfected;
    infT(1) = 0;
    nonT(1) = firstInfected;
    immT(1) = 0;
    symT(1) = 0;
    
    %contacts
    n = 5;
    p = 0.2;
    
    %infection probability
    ip = input('input probability of infection(between 0 and 1): ');
    ip = ip * 100;
    
    %non infectious period
    infLatn = input('input number of trials for infectious latency binomial random variable: ');
    infLatp = input('input probability of trial success for binomial random variable for infectious latency length: ');
    
    %infectious period
    infPern = input('input number of trials for infectious period binomial random variable: ');
    infPerp = input('input probability of trial success for binomial random variable for infectious period length: ');
    
    %symptom onset latency
    symLatn = input('input number of trials for symptom latency binomial random variable: ');
    symLatp = input('input probability of trial success for binomial random variable for symptom latency length: ');
    
    %symptom expression period
    symPern = input('input number of trials for symptomatic period binomial random variable: ');
    symPerp = input('input probability of trial success for binomial random variable for symptomatic period length: ');
    
    % determines when charts are to be plotted
    pieInterval = 500;
    fprintf('simulation has commenced');
    
    for i = 1:popSize-1
        pop(i) = Person();
    end

   
     %infect first people because there location in 
     %the array does not matter as their proximity is not a factor for 
     %transmission of the dissease

    for pp = 1:firstInfected
         pop(pp) = infect(pop(pp),binornd(infLatn,infLatp)+1,binornd(infPern,infPerp)+1,binornd(symLatn,symLatp)+1,binornd(symPern,symPerp)+1);
    end
    
    
    %clean = 0;
    while popSize ~= (numSusceptible(pop,popSize)+numImmune(pop,popSize))
        %clean = 0;
        t = t+1;
        susT(t) = numSusceptible(pop,popSize);
        infT(t) = numInfectious(pop,popSize);
        nonT(t) = numNonInfectious(pop,popSize);
        immT(t) = numImmune(pop,popSize);
        symT(t) = numSymptomatic(pop,popSize);
        
        
        for  i = 1:popSize %each person making contacts
            %person = pop(i);
            
            contacts = binornd(n,p);


            if pop(i).healthStatus == 0 %no disease
                %didInfect = 0;
                for x = 1:contacts
                    meet = randi([1 popSize]);
                    meet = pop(meet);

                    if meet.healthStatus == 1 && meet.spreadPeriod >0 && meet.spreadLatency == 0
                       if(randi([1 100])<ip) 
                           pop(i) = infect(pop(i),binornd(infLatn,infLatp)+1,binornd(infPern,infPerp)+1,binornd(symLatn,symLatp)+1,binornd(symPern,symPerp)+1); %get disease
                           
                           break;
                       end
                    end
                end
               

            elseif pop(i).healthStatus == 1 %has disease
                if pop(i).spreadLatency >0 %not infectious
                   pop(i).spreadLatency = pop(i).spreadLatency - 1;
                  
                elseif pop(i).spreadPeriod>0 %infectious
                   pop(i).spreadPeriod = pop(i).spreadPeriod -1;
                  
                   
                   for x = 1:contacts
                        meet = randi([1 popSize]);
                        if randi([1 100])<ip && pop(meet).healthStatus == 0
                           pop(meet) = infect(pop(meet),binornd(infLatn,infLatp)+1,binornd(infPern,infPerp)+1,binornd(symLatn,symLatp)+1,binornd(symPern,symPerp)+1); 
                        end
                   end
                   
                    
                end

                if pop(i).sympLatency>0
                    pop(i).sympLatency = pop(i).sympLatency - 1;
                elseif pop(i).symptomLength > 0
                    pop(i).symptomLength = pop(i).symptomLength - 1;
                end
                
                if pop(i).symptomLength == 0 && pop(i).spreadPeriod == 0
                    pop(i).healthStatus = 2;
                end
            elseif  pop(i).healthStatus == 2  %already had disease and is now immune, nothing happens  
               
            end

            
        end
        
        if(mod(t,pieInterval)==0)
            makePie(t,pop,popSize,pieInterval);

        end

    end
    

    
    len = 1:t;
    
    plot(len,susT,len,immT,len,nonT,len,infT,len,symT);
    title('Graph of population state');
    ylabel('Population Size/People');
    xlabel('Time/units');
    legend('Susceptible','Immune','Non Infectious','Infectious','Symptomatic');
    
    figure();
    title('Histogram of Units before disease is eradicated');
    gram = floor(infT+nonT);
   
    hist(gram,t);
    title('Histogram of time taken to eradicate disease');
    xlabel('Time/units');
    ylabel('Infected population/people');
end

function num = numSymptomatic(pop,size)
   num = 0;
    
    for a = 1:size
        if(pop(a).healthStatus == 1 && pop(a).sympLatency == 0)
            num = num + 1;
        end
    end
end


function num = numSusceptible(pop,size)
    num = 0;
  
    for a = 1:size
        if(pop(a).healthStatus == 0)
            num = num + 1;
        end
    end
end

function num = numImmune(pop,size)
    num = 0;
    for a = 1:size
        if(pop(a).healthStatus == 2)
            num = num + 1;
        end
    end
end

function num = numInfectious(pop,size)
    num = 0;
    
    for a = 1:size
        if(pop(a).healthStatus == 1)
            if pop(a).spreadPeriod > 0 && pop(a).spreadLatency == 0
                num = num + 1;
            end
        end
    end
end

function num = numNonInfectious(pop,size)
    num = 0;
    
    for a = 1:size
        if(pop(a).healthStatus == 1)
            if pop(a).spreadLatency > 0
                num = num + 1;
            end
        end
    end
end

function [] = makePie(t,pop,popSize,pieInterval)
    fields = 0;
    vec(1) = 1;
    labels(1) = {'Nothing'};
    var = numSusceptible(pop,popSize);
    if(var > 0)
        fields = fields +1;
        vec(fields) = var;
        labels(fields) = {'Susceptible'};
    end
    
    var = numInfectious(pop,popSize);
    if(var > 0)
        fields = fields +1;
        vec(fields) = var;
        labels(fields) = {'Infectious'};
    end
    
    var = numNonInfectious(pop,popSize);
    if(var > 0)
        fields = fields +1;
        vec(fields) = var;
        labels(fields) = {'Non Infectious'};
    end

    var = numImmune(pop,popSize);
    if(var > 0)
        fields = fields +1;
        vec(fields) = var;
        labels(fields) = {'Immune'};
    end
     
    v = subplot(1,1,1);
    pie(v,vec,labels);
    figure();
   
end


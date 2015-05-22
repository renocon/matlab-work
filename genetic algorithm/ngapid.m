
%The objective of this code is to find optimum values for variables 'lv'
%and 'jitse' in the fitness functin presented in the chapter. The range of 
%values being considered for lv is 0:500 and jitse -500:+500. 'Jitse' is an
%erro and this it would be desirable to get this as close to zero as
%possible. As well, 'lv' is the numerator so maximizing the value of it is
%desirable beacause the result of the fitness function quantifies the
%efficiency of output of the system. For simplicity, integers only were
%used as inputs for the function. 'Jitse' on its own is a function that
%calulates error using some integral of the function made by the difference
%between the expected and actual results of the system. As opposed to
%calulating jiste, a section of the chromosome was used to represent the
%result of the function as opposed to the input. The suggested range for
%variables in the chapter was -500:+500 so each value is represented by 10
%bits giving a chromosome that is 20 genes long. Further contraints were
%included in the fitness function to cater for obviously nonsensical input
%like a negative 'lv' and when 'jitse' is zero(fitness will be infinity/undefined)
%run multiple times to see drastic difference in results


function ngapid ()      %main()
    clc
    maxGen = 100;       %max number of allowed generations
    
    gen = 0;            %current generation
    psize = 200;        %population size:100
    csize = 20;         %chromosome size:40
    genBestF = [];      %best fitnesses found from each generation
    avgGenF = [];      %average fitness of each population
    chros = randi([0,1],psize,csize); %chromosome pool
    optF = 500;         %optimum fitness (if one is attainable)
    optSol = zeros(1,csize); %initialize array that will eventually hold best chromosome so far
    maxF = Inf * -1;    %best fitness so far
    consF = 0;          %consecutive generations fitness plateau
    pm = 0.09;          %probability of mutation
    mutations = 0;      %number of times mutation occur in run
    while(maxGen > gen)
        
        if maxF == optF, break;end; %break if target fitness has been achieved
        if consF == 50, break;end;  %break if plateau in best result has been reached
        [s,~] = size(chros);        %get number of chromosomes in current population
        F = zeros(1,s);             %initialize Fitnesses of current generation
        gen = gen + 1;              %increment current generation number
        elite = [];                 %holds most fit chromosome of generation to clone to new generation
        fit = 0;                    %most fit chromosome in current genration
        avg = 0;                    %total fitness of population to find average
        count = 0;                  %size of population to find average fitness of
        for n = 1:size(chros)
            f = fitness(chros(n,:));%calculate fitness of chromosome
            avg = avg + f;          %add to total
            count  = count + 1;     %add to population size
            if fit<f                %if fitness of current chromosome is better that chromosomes before, store it
                fit = f;
                elite = chros(n,:);
            end
              
            if f == maxF            %if best fitness of this generation conforms to a plateau
                consF = consF + 1;
            end 
            
            if f > maxF             %if chromosome fitness is better than all previous chromosomes from all previous genrations, store it
                optSol = chros(n,:);
                consF = 1;
                maxF = f;
            end    
            
            F (1,n) = f;            %add fitness of current chromosome to list for this generation
        end
        genBestF(gen) = fit;        %add best fitnes of this generation to a list for plotting
        avg = avg/count;            %find average
        avgGenF(gen) = avg;         %add average to list of all averages
        
        no = 0;                     %switch to limit mutation to one per generation
        tryM = 0;                   %only try to mutate once per genration
        comp = getComp(F(:,:));     %sums fitness for ranges on roulette wheel 
        while size(elite) < psize   %populate new generation
            
            [pa,pb,m,tryM] = getParents(comp,pm,tryM);    %get parents for crossover and mutation
            if m<0,Dips('getParents Error'); continue;end;    %if error in getParents()
            [ca,cb] = crossOver(chros(pa,:),chros(pb,:));
            elite = [elite;ca;cb];
            if m>0 && no == 0       %if a chromosome is to be mutated and no chromosome has been mutated in this generation
                sup = mutate(chros(m,:));
                elite = [elite;sup];
                mutations = mutations + 1;    %increment total number of mutations
                no = 1;             %prevent further mutations in this generation
            end
        end    
        
        chros = elite;              %assign new population just generated
    end  
    
    shw(optSol,maxF,gen,mutations); %display results
    
    figure('Name','PID Tuner Performance');
    [~,len] = size(genBestF);
    plot(1:len,genBestF,1:len,avgGenF,'LineWidth',1.4);                 %display graph of best solutions for each generation. this is to see overall performance
    axis([0,100,0,500]);
    title('Best and Average Fitness Attained for each Generation');
    xlabel('Generation');
    ylabel('Fitness');
    legend('Best Fitness per Generation','Average Fitness per Generation','Location','southeast');
    
end

function[child1,child2] = crossOver(parent1, parent2) %single point crossover
    
    [~,z] = size(parent1);  %get length of chromosome
    child1 = parent1;
    child2 = parent2;

    for n = round((z*0.7)):z %swap last 30 persent of bits
       t = child1(n);
       child1(n) = child2(n);
       child2(n) = t;
    end    %end swap
end

function chrom = mutate(chrom)      %mutates selected chromosome
     [~,z] = size(chrom);           %get length of chromosome
     z = randi([1,z],1,1);          %pick a gene
     chrom(z) = mod(chrom(z)+1,2);  %flip bit of switched gene
end     
         
function [fit] = fitness(genes)     %calculates fitness of supplied chromosome
      lv = getIntFromBin(genes(1:10));
      jitse = getIntFromBin(genes(11:20));
      if jitse == -1 || abs(lv)>500 || abs(jitse)>500 || lv<1 %prevents fitness of infinity and jitse from being outside -500:500
          fit = 1;
      else    
          fit = lv/(1 + jitse);
          fit = abs(fit);
          if fit > 500
              fit = 500;        %prevents fitness from going over 500
          end    
      end    
end       
       
function shw(genes, optF, gen, mutations)   %display results of most optimal solution
      lv = getIntFromBin(genes(1:10));
      jitse = getIntFromBin(genes(11:20));
      jitse
      lv
      optF
      gen
      mutations
end          

function num = getIntFromBin(binNum)        %convert binary numbers to decimal from chromosome
    num = 0;
    b = 1;
    n  = 10;
    while n > 0
        num = num + b*binNum(n);
        b = b * 2;
        n = n - 1;
    end
    num = num - 512;
end

function comp = getComp(fits)               %populates array for ranges to use in roulette wheel selection
    comp(1) = 0;
    [~,s] = size(fits);
    for n = 2:s
        comp(n) = fits(1,n-1) +comp(1,n-1);
    end
end

function [parent1,parent2,mute,tryM] = getParents(comp,pm,tryM) %get parent chromosomes for crossover and mutation candidate

    [~,s2] = size(comp);
    upper = comp(1,s2);
    if upper == Inf
        mute = -1;
    else 
        parent1 = 0;
        while parent1 < 1       %ensure parent is never out of bound of array
            parent1 = roulette(comp(:,:),randi([0,floor(upper)],1,1)); %select parent
        end   
        
        parent2 = 0;
        while parent2 < 1       %ensure parent is never out of bound of array
            parent2 = roulette(comp(:,:),floor(randi([0,floor(upper)],1,1))); %select parent
        end    
        if rand()<pm && tryM == 0 %if no mutation has been attempted, attempt
            mute = roulette(comp(:,:),floor(randi([0,floor(upper)],1,1)));
        else mute = 0; %perform no mutation
        end; 
        tryM = 1;       %this says that a mutation has been attempted for this generation whether it failed or not
    end    
end

function index = roulette(fits,point) %returns index of chromosome selected
    [~,s] = size(fits);
    index = 0;
    for n = 2:s
       if point >= fits(n-1) && point < fits(n)
          index = n-1;
          break;
       end    
    end
end
          
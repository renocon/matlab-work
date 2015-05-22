function mge ()
    clc
    
    characteristics = input('input number of characteristics: ');
    alleles = zeros(characteristics);
    
    for n = 1:characteristics
       fprintf('input number of alleles for characteristic %d: ',n);
       alleles(n) = input('');
    end  
    filgen = input('input number of filial generations: ');
    if(filgen<0)
        fprintf('enter non-negative value for number of generations');
        return;
    end    
    %gametes = zeros(alleles,alleles);
    results = ones(1,1);
    for n = 1:characteristics
        k = ((1 +alleles(n))*alleles(n))/2;
        l = 1;
        distributionVector = zeros(1,k);
        tot = alleles(n)*alleles(n);
        gametes = zeros(2,k);
        for i = 1:alleles(n)
            for j = i:alleles(n)
                if(i==j) 
                    distributionVector(1,l) = 1/(tot);    
                else
                    distributionVector(1,l) = 2/(tot);
                end 
                gametes(1,l)=i;
                gametes(2,l)=j;
                l=l+1;    
            end    
        end 
        
        %gametes;
        %distributionVector;
        repMat = zeros(k,k);
        
        for x =1:k
           for y=1:k
                %if either gamete pure
                if(gametes(1,x) == gametes(2,x) || gametes(1,y)==gametes(2,y))
                    %if both same pure gamete
                    if(gametes(1,x) == gametes(1,y) && gametes(2,x) == gametes(2,y))
                        repMat(x,y) = 1;
                    %if 2nd one is a cross    
                    %elseif(gametes(1,x)==gametes(1,y) || gametes(1,x)==gametes(2,y))    
                    %else if both different pure gametes 
                    %    repMat(x,y) = 1/4;
                    else
                        repMat(x,y) = 0;
                    end    
                end 

                %if either is a cross
                if(gametes(1,x)~=gametes(2,x))
                    %if cross by itself
                    if(gametes(1,x) == gametes(1,y) && gametes(2,x) == gametes(2,y))
                        repMat(x,y) = 1/2;
                    %if 2 crosses
                    elseif(gametes(1,x)~=gametes(2,x) && gametes(1,y)~=gametes(2,y)) 
                        repMat(x,y)=0;
                    %if cross by matching parent    
                    elseif(gametes(1,x) == gametes(1,y) || gametes(1,x) == gametes(2,y) || gametes(2,x) == gametes(1,y) || gametes(2,x) == gametes(2,y))
                        repMat(x,y) = 1/4;    
                    else   
                        repMat(x,y)=0;
                    end    
                end    
           end    
        end  
        
        for q = 1:filgen
           distributionVector = distributionVector*repMat; 
        end
        [~,s]=size(results);
        [~,r]=size(distributionVector);
        newLen = s*r;
        newDistVec = zeros(1,newLen);
        loc = 1;
        for t = 1:s
            for u = 1:r
                %results(1,t)
                %distributionVector(1,u)
                newDistVec(1,loc) = results(1,t) * distributionVector(1,u); 
                loc = loc+1;
            end
        end
        %if(filgen > 0)
            results = newDistVec;
        %else
        %    results = distributionVector;
        %end
    end
    
    results
    
    [~,lengthOfdistV] = size(results);
    sum = 0;
    for e = 1:lengthOfdistV
        sum = sum+results(1,e);
    end
    sum
    return;
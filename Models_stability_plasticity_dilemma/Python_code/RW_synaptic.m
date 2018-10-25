%% Defining amount of loops
Rep=10;                     % amount of replications
Tr=240;                      % amount of trials
betas=11;                   % beta iterations
Beta=0:1/(betas-1):1;       %learning rate values

%% other variables
POT_1=Tr/3;                 %point of switch to task rule 2 (trial 20)
POT_2=2*Tr/3;               %switch again to task rule 1    (trial 40)
part1=1:POT_1;              %first part
part2=POT_1+1:POT_2;        %second part
part3=POT_2+1:Tr;           %third part
nUnits=4;                   %model units
threshold=10;              %response threshold

%Input patterns
Activation=zeros(nUnits,2);
Activation(:,1)=[1,0,0,0];
Activation(:,2)=[0,1,0,0];

%% learning objectives
objective=zeros(nUnits,nUnits,Tr); 
objective(1,3,part1)=1;
objective(2,4,part1)=1;
objective(2,3,part2)=1;     
objective(1,4,part2)=1;
objective(1,3,part3)=1;  
objective(2,4,part3)=1; 

%% simulation loops
for b=1:betas                     %gradual change of beta 
    for r=1:Rep             %replication loop
%% model build-up
%processing layer
Rate=zeros(nUnits,Tr);    %rate neurons (matrix definieren)

%weights
W=zeros(nUnits,nUnits,Tr);  %matrix met gewichten definieren
W(1:2,3:4,1)=rand(2,2);       %initial weigth strengths (in het begin zijn alle stimuli (rij 1 en 2) gelijk verbonden met alle responsen (kolom 3 en 4)

%% Input
%randomization of input patterns
In=repmat(1:2,3,(POT_1));
Input=zeros(1,Tr);
Input(1,part1)=In(1,randperm(POT_1));
Input(1,part2)=In(2,randperm(POT_1));
Input(1,part3)=In(3,randperm(POT_1));

%% Other
Z=zeros(nUnits,Tr);             %input matrix
response=zeros(nUnits/2,Tr);    %response record
rew=zeros(1,Tr);                %reward or accuracy

%% the model

    for trial=1:Tr          %trial loop
        
        Z(:,trial)=Activation(:,Input(1,trial));

        %updating rate code units
        Rate(1:2,trial)=Z(1:2,trial);   
        Rate(3:4,trial)=max(0,Rate(1:2,trial)'*squeeze(W(1:2,3:4,trial))); 
            
        %response determination:
        if Rate(3,trial)>Rate(4,trial)    %response 1
            response(1,trial)= 1;
            response(2,trial)= 0;    
        else
            response(1,trial)= 0;
            response(2,trial)= 1;
        end;
        
        %reward value determination
        if squeeze(objective(Input(1,trial),3:4,trial))'==response(:,trial)
            rew(1,trial)=1;
        else
            rew(1,trial)=0;
        end; 
        
        %RW learning
        for p=1:2
            for q=3:4
                %weight updating (only for weights different than zero)
                W(p,q,trial+1)=W(p,q,trial)+Beta(1,b)*(objective(p,q,trial)-Rate(q,trial))*Rate(p,trial);
            end;
        end;
    prog=trial
    end;
    save(['Beta',num2str(b),'Rep',num2str(r),'_RWonly']); %write data to file with beta iteration, epsilon iteration and replication as name
    end; 
end;

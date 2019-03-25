%{
    Script for running the synaptic RW model
%}

%% Defining amount of loops
Rep=10;                     % amount of replications
Tr=360;                     % amount of trials
betas=11;                   % beta iterations
Beta=0:1/(betas-1):1;       %learning rate values

POT=Tr/6:Tr/6:Tr;                 %point of switch to task rule 2 (trial 20)
part1=1:POT(1);                   %first part
part2=POT(1)+1:POT(2);            %second part
part3=POT(2)+1:POT(3);            %third part
part4=POT(3)+1:POT(4);
part5=POT(4)+1:POT(5);
part6=POT(5)+1:POT(6);

%% other variables
nUnits=6;                   %model nodes

%Input patterns
Activation=zeros(nUnits,3);
Activation(1,1)=1;
Activation(2,2)=1;
Activation(3,3)=1;

objective=zeros(nUnits,nUnits,Tr);

objective(1,4,[part1,part4])=1;
objective(2,5,[part1,part4])=1;
objective(3,6,[part1,part4])=1;
objective(1,5,[part2,part5])=1;
objective(2,6,[part2,part5])=1;
objective(3,4,[part2,part5])=1;
objective(1,6,[part3,part6])=1;
objective(2,4,[part3,part6])=1;
objective(3,5,[part3,part6])=1;

%% simulation loops
for b=1:betas
    for r=1:Rep             %replication loop

%%Processing unit
Rate=zeros(nUnits,Tr);    %rate neurons

%weights
W=zeros(nUnits,nUnits,Tr);
W(1:3,4:6,1)=rand(3,3);       %initial weigth strengths

%% Input
%randomization of input patterns
In=repmat(1:3,6,(POT(1)));
Input=zeros(1,Tr);
Input(1,part1)=In(1,randperm(POT(1)));
Input(1,part2)=In(2,randperm(POT(1)));
Input(1,part3)=In(3,randperm(POT(1)));
Input(1,part4)=In(1,randperm(POT(1)));
Input(1,part5)=In(2,randperm(POT(1)));
Input(1,part6)=In(3,randperm(POT(1)));

%% Other
Z=zeros(nUnits,Tr);             %input matrix
response=zeros(nUnits/2,Tr);    %response record
rew=zeros(1,Tr);                %reward or accuracy

%% the model

    for trial=1:Tr          %trial loop
        
        Z(:,trial)=Activation(:,Input(1,trial));

        %updating rate code units
        Rate(1:3,trial)=Z(1:3,trial);   
        Rate(4:6,trial)=max(0,Rate(1:3,trial)'*squeeze(W(1:3,4:6,trial))); 
            
        %response determination:
        [re,rid]=max(Rate(4:6,trial));
        if rid==1
            response(1,trial)= 1;  
        elseif rid==2
            response(2,trial)= 1;
        elseif rid==3
            response(3,trial)= 1;    
        end;
        
        %reward value determination
        if squeeze(objective(Input(1,trial),4:6,trial))'==response(:,trial)
            rew(1,trial)=1;
        else
            rew(1,trial)=0;
        end; 
        
        %RW learning
        for p=1:3
            for q=4:6
                %weight updating (only for weights different than zero)
                W(p,q,trial+1)=W(p,q,trial)+Beta(1,b)*(objective(p,q,trial)-Rate(q,trial))*Rate(p,trial);
            end;
        end;
    prog=trial
    end;
    save(['Beta',num2str(b),'Rep',num2str(r),'_RWonly']); %write data to file with beta iteration and replication as name
    end; 
end;

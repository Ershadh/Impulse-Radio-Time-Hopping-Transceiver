function [ Normz_Interferer, Code, Distance, Distance_Index, Time_Asynchronism ] = Interferer_Frame_Generate( Sample_Time, Desired_Signal, No_of_Active_Users, SIR_dB, Frame_Duration, No_of_Monocycles, Time_Asynchronism_Flag, Pulse_Distort_Flag, BPSK_Flag )
%TIME-HOPPING FRAMES GENERATION FOR A DATA BIT
%   Detailed explanation goes here
% Sample_Time=0.01;      
Chip_Duration=0.86;


% Template Signal Generation
Pulse_Time=-0.35:Sample_Time:0.35-Sample_Time;  tm=0.2877;
Template_Signal=(1-4*pi*(Pulse_Time/tm).^2).*exp(-2*pi*(Pulse_Time/tm).^2); % Signal interval [0,0.7] ns

% Chip Time and Signal Offset Computation
Chip_Time=0:Sample_Time:Chip_Duration-Sample_Time; % .16 ns offset
Delta= length(Chip_Time)-length(Template_Signal); % 16 samples offset

No_of_Hops=floor(Frame_Duration/Chip_Duration);

Single_Frame_Time=0:Sample_Time:Frame_Duration-Sample_Time;

Code=zeros(No_of_Active_Users-1,No_of_Monocycles); 

Single_Frame=zeros(size(Single_Frame_Time));

Data_Frame=zeros(1,length(Single_Frame)*No_of_Monocycles);

Interferers=zeros(No_of_Active_Users-1,length(Data_Frame));

if(Time_Asynchronism_Flag==1)
    
    Time_Asynchronism=randi([100,length(Data_Frame)/8],[1,No_of_Active_Users-1]); % Number of samples to offset for Time Asynchronism between users.
    
else
    Time_Asynchronism=0;
end



if(Pulse_Distort_Flag==1)    
      
% Pulse Distortion Effects

Number_of_Distance_Points=10;

% Distorted Pulses at all distances for data bit 0
Data_Bit_0=0;
RPPM=[Template_Signal*~Data_Bit_0, zeros(1,Delta)]; 
RPPM=RPPM+[zeros(1,Delta), Template_Signal*Data_Bit_0];  % Sample Length = 86
       [SPulse_Distort_0]=Distance_Pulse_Distort_Loop(RPPM,0,[],Number_of_Distance_Points);
  
% Distorted Pulse at all distances for data bit 1 
Data_Bit_1=1;
RPPM=[Template_Signal*~Data_Bit_1, zeros(1,Delta)]; 
RPPM=RPPM+[zeros(1,Delta), Template_Signal*Data_Bit_1];  % Sample Length = 86     
        [SPulse_Distort_1,~, Distance]=Distance_Pulse_Distort_Loop(RPPM,0,[],Number_of_Distance_Points);
        
Distance_Index=zeros(1,Number_of_Distance_Points);  
       
for k=1:No_of_Active_Users-1
    
         if(rand>0.5)
             
            SPulse_Distort=SPulse_Distort_0;            
         else
             
            SPulse_Distort=SPulse_Distort_1;            
         end
         
Distance_Index(k)=randi([1,Number_of_Distance_Points]);

    for i=1:No_of_Monocycles      
    
    Code(k,i)=randi([0,No_of_Hops-1]);
    
    Single_Frame((length(RPPM)*Code(k,i))+ 1 : (length(RPPM)*Code(k,i))+ length(RPPM))=SPulse_Distort(:,Distance_Index(k));
    
    Data_Frame(length(Single_Frame)*(i-1)+ 1 : length(Single_Frame)*(i-1)+ length(Single_Frame)) = Single_Frame;    
        
    Single_Frame=Single_Frame*0; 
    
    end
    
    if(Time_Asynchronism_Flag==1)
        
        TAS_Data_Frame=[zeros(1,Time_Asynchronism(k)), Data_Frame];
        
        Interferers(k,:)=TAS_Data_Frame(1:length(Data_Frame));
       
    else
        
Interferers(k,:)=Data_Frame;

    end

Data_Frame=Data_Frame*0;

end

Interferers_Sum=sum(Interferers); % Disctance Pulse Distort Loop takes care of attenuation with respect to distance.

Normz_Interferer=Interferer_Signal_Normalization(Desired_Signal,Interferers_Sum,SIR_dB); % Normalized Interferer

else

% Ideal Pulses with no channel effects

for k=1:No_of_Active_Users-1
    
Random_Data_Bit=round(rand);
     
% Random PPM Signal Generation
if BPSK_Flag == 1

    RPPM=[Template_Signal*(2*Random_Data_Bit-1), zeros(1,Delta)];    % Just to keep the same sample length to avoid confusion.
else
    
RPPM=[Template_Signal*~Random_Data_Bit, zeros(1,Delta)]; 

RPPM=RPPM+[zeros(1,Delta), Template_Signal*Random_Data_Bit];  % Sample Length = 86
end

    for i=1:No_of_Monocycles      
    
    Code(k,i)=randi([0,No_of_Hops-1]);
    
    Single_Frame((length(RPPM)*Code(k,i))+ 1 : (length(RPPM)*Code(k,i))+ length(RPPM))=RPPM;
    
    Data_Frame(length(Single_Frame)*(i-1)+ 1 : length(Single_Frame)*(i-1)+ length(Single_Frame)) = Single_Frame;    
        
    Single_Frame=Single_Frame*0; 
    
    end

 if(Time_Asynchronism_Flag==1)
        
        TAS_Data_Frame=[zeros(1,Time_Asynchronism(k)), Data_Frame];
        
        Interferers(k,:)=TAS_Data_Frame(1:length(Data_Frame));
       
 else
        
Interferers(k,:)=Data_Frame;

 end

Data_Frame=Data_Frame*0;

end

% Altering Interferers Channel Gain.
% Assuming desired user's signal to be the strongest.

Altered_Interferers=repmat(rand(No_of_Active_Users-1,1),1,length(Interferers)).*Interferers; % Altered Interferer_Channel_Gain

Interferers_Sum=sum(Altered_Interferers);

Normz_Interferer=Interferer_Signal_Normalization(Desired_Signal,Interferers_Sum,SIR_dB); % Normalized Interferer

Distance=0;
Distance_Index=0;
end

end
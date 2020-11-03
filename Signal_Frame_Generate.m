function [ Data_Frame, Correlator_Frame, PPM, Correlation_Template, Code, No_of_Hops] = Signal_Frame_Generate(Sample_Time,Frame_Duration, No_of_Monocycles, Data_Bit, Pulse_Distort_Flag, Distance)
%TIME-HOPPING FRAMES GENERATION FOR A DATA BIT
%   Detailed explanation goes here
% Sample_Time=0.01;
Chip_Duration=0.86; %  Time in nanoseconds.

% Template Signal Generation
Pulse_Time=-0.35:Sample_Time:0.35-Sample_Time;  tm=0.2877;

Template_Signal=(1-4*pi*(Pulse_Time/tm).^2).*exp(-2*pi*(Pulse_Time/tm).^2); % Signal interval [0,0.7] ns

% Chip Time and Signal Offset Computation
Chip_Time=0:Sample_Time:Chip_Duration-Sample_Time; % .16 ns offset
Delta= length(Chip_Time)-length(Template_Signal); % 16 samples offset

% PPM Signal Generation
PPM=[Template_Signal*~Data_Bit, zeros(1,Delta)]; 
PPM=PPM+[zeros(1,Delta), Template_Signal*Data_Bit];  % Sample Length = 86

% Correlation Template Generation
Correlation_Template=[Template_Signal, zeros(1,Delta)];
Correlation_Template=Correlation_Template+[zeros(1,Delta), -1*Template_Signal]; % Sample Length = 86

% If Pulse Distortion Flag set to 1, distance dependent channel distorted templates will be the further processed ones from this line of code.
if(Pulse_Distort_Flag==1)
    [PPM , Correlation_Template]= Distance_Pulse_Distort(PPM, Correlation_Template, Distance);
end

No_of_Hops=floor(Frame_Duration/Chip_Duration);

Single_Frame_Time=0:Sample_Time:Frame_Duration-Sample_Time;

Code=zeros(1,No_of_Monocycles); 

Single_Frame=zeros(size(Single_Frame_Time));

Data_Frame=zeros(1,length(Single_Frame)*No_of_Monocycles);

Correlator_Frame=zeros(1,length(Single_Frame)*No_of_Monocycles);

% Data_Time= 0:Sample_Time:(Frame_Duration*No_of_Monocycles)-Sample_Time;

for i=1:No_of_Monocycles
    
    Code(i)=randi([0,No_of_Hops-1]);
    
    Single_Frame((length(PPM)*Code(i))+ 1 : (length(PPM)*Code(i))+ length(PPM))=PPM;
    
    Data_Frame(length(Single_Frame)*(i-1)+ 1 : length(Single_Frame)*(i-1)+ length(Single_Frame)) = Single_Frame;
    
    Single_Frame=Single_Frame*0; 
    
    Single_Frame((length(Correlation_Template)*Code(i))+ 1 : (length(Correlation_Template)*Code(i))+ length(Correlation_Template))=Correlation_Template;
    
    Correlator_Frame(length(Single_Frame)*(i-1)+ 1 : length(Single_Frame)*(i-1)+ length(Single_Frame)) = Single_Frame;
    
    Single_Frame=Single_Frame*0;
end

end


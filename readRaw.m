function [data] = readRaw
%run this function to connect and plot raw EEG data
%make sure to change portnum1 to the appropriate COM port
clear all
close all

data = zeros(30720,14); %preallocate buffer

portnum1 =      3;      %COM port#
comPortName1 =  sprintf('\\\\.\\COM%d', portnum1);

TG_BAUD_57600 = 57600;
TG_STREAM_PACKETS =       0;

%data type that can be requested from TG_GetValue().
TG_DATA_RAW =             4;
TG_DATA_POOR_SIGNAL =     1;
TG_DATA_ATTENTION =       2;
TG_DATA_MEDITATION =      3;
TG_DATA_DELTA =           5;
TG_DATA_THETA =           6;
TG_DATA_ALPHA1 =          7;
TG_DATA_ALPHA2 =          8;
TG_DATA_BETA1 =           9;
TG_DATA_BETA2 =          10;
TG_DATA_GAMMA1 =         11;
TG_DATA_GAMMA2 =         12;
TG_DATA_BLINK_STRENGTH = 37;

%load thinkgear dll
loadlibrary('Thinkgear.dll');
fprintf('Thinkgear.dll loaded\n');

%get dll version
dllVersion = calllib('Thinkgear', 'TG_GetDriverVersion');
fprintf('ThinkGear DLL version: %d\n', dllVersion );

%%
%get a connection ID handle to ThinkGear
connectionId1 = calllib('Thinkgear', 'TG_GetNewConnectionId');
if ( connectionId1 < 0 )
    error( sprintf( 'ERROR: TG_GetNewConnectionId() returned %d.\n', connectionId1 ) );
end;

%set/open stream (raw bytes) log file for connection
errCode = calllib('Thinkgear', 'TG_SetStreamLog', connectionId1, 'streamLog.txt' );
if( errCode < 0 )
    error( sprintf( 'ERROR: TG_SetStreamLog() returned %d.\n', errCode ) );
end;

%set/open data (ThinkGear values) log file for connection
errCode = calllib('Thinkgear', 'TG_SetDataLog', connectionId1, 'dataLog.txt' );
if( errCode < 0 )
    error( sprintf( 'ERROR: TG_SetDataLog() returned %d.\n', errCode ) );
end;

%enable Blink Detection
errCode = calllib('Thinkgear', 'TG_EnableBlinkDetection', connectionId1, 1);
if( errCode < 0 )
    error( sprintf( 'ERROR: TG_EnableBlinkDetection() returned %d.\n', errCode ) );
end;

%attempt to connect the connection ID handle to serial port "COM3"
errCode = calllib('Thinkgear', 'TG_Connect',  connectionId1,comPortName1,TG_BAUD_57600,TG_STREAM_PACKETS );
if ( errCode < 0 )
    error( sprintf( 'ERROR: TG_Connect() returned %d.\n', errCode ) );
end

fprintf( 'Connected.  Reading Packets...\n' );

%%
%record data
j = 0;
i = 0;
while (i < 46080)
    if (calllib('Thinkgear','TG_ReadPackets',connectionId1,1) == 1) 
        
        if (calllib('Thinkgear','TG_GetValueStatus',connectionId1,TG_DATA_RAW) ~= 0) 
            j = j + 1;
            i = i + 1;
            
            if(i == 1)
                tic;
                data(i,1) = 0;   %output time as 0 when first started
            else
                data(i,1) = toc; %output time since tic
            end
            
            %raw data
            data(i,2) = calllib('Thinkgear','TG_GetValue',connectionId1,TG_DATA_RAW);
            %signal clarity
            data(i,3) = calllib('Thinkgear','TG_GetValue',connectionId1,TG_DATA_POOR_SIGNAL);
            %attention level
            data(i,4) = calllib('Thinkgear','TG_GetValue',connectionId1,TG_DATA_ATTENTION);
            %mediditation level
            data(i,5) = calllib('Thinkgear','TG_GetValue',connectionId1,TG_DATA_MEDITATION);
            %delta
            data(i,6) = calllib('Thinkgear','TG_GetValue',connectionId1,TG_DATA_DELTA);
            %theta
            data(i,7) = calllib('Thinkgear','TG_GetValue',connectionId1,TG_DATA_THETA);
            %low alpha
            data(i,8) = calllib('Thinkgear','TG_GetValue',connectionId1,TG_DATA_ALPHA1);
            %high alpha
            data(i,9) = calllib('Thinkgear','TG_GetValue',connectionId1,TG_DATA_ALPHA2);
            %low beta
            data(i,10) = calllib('Thinkgear','TG_GetValue',connectionId1,TG_DATA_BETA1);
            %high beta
            data(i,11) = calllib('Thinkgear','TG_GetValue',connectionId1,TG_DATA_BETA2);
            %low gamma
            data(i,12) = calllib('Thinkgear','TG_GetValue',connectionId1,TG_DATA_GAMMA1);
            %high gamma
            data(i,13) = calllib('Thinkgear','TG_GetValue',connectionId1,TG_DATA_GAMMA2);
            %blink strength
            data(i,14) = calllib('Thinkgear','TG_GetValue',connectionId1,TG_DATA_BLINK_STRENGTH);
        end
    end
end

%disconnect             
calllib('Thinkgear', 'TG_FreeConnection', connectionId1 );

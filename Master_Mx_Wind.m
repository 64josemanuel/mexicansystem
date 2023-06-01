clc; clear all; close all; clear memory; close all;

ftsize = 30;
lwi = 2;

load Steady_CFEFull_April2023

datamexwpp20_pst;

% dfile = 'd16mt3setg_14machines_origin_rpi.m'; % 2 Area System 1ith 2pu WGT in middle
% dfile='data16m_4o_Wind_AZM.m';
% dfile='d46_mex_wind.m';

% fpath = '/Users/mi mac/Downloads/Papers/PSTV_WT';
%fpath = 'C:\Users\fz2co\Dropbox\Alex_MSc_Thesis\Programas_Tesis\PST_WT_MRAP'
fpath='/Users/powersystemunam/Dropbox/Tesis_MSc_Manuel/work/PST_WT';
namTfile = 'Steady_Blanca_CFEFull_Ene2011.mat';

cd(fpath);

% dfilex = dfile(1:end-2);
% run(dfilex)

%% bus matrix
bus_nw=zeros(257,10);

bus_nw(1:190,:)=bus_sol;

bus_nw(1:46,11:12)=[999*ones(46,1) -999*ones(46,1)];
bus_nw(1:257,13:15)=[ones(257,1) 1.2*ones(257,1) 0.8*ones(257,1)];

bus_nw(2:46,4)=PV.con(1:45,4);
v4=PQ.con(:,1);
v5=PQ.con(:,4:5);
bus_nw(v4,6:7)=v5;

v1=[1 3 4];
bus_nw(191:257,1:3)=Bus.con(191:257,v1);

v2=PV.con(46:78,1);
lv2=length(v2);
bus_nw(v2,4)=PV.con(46:78,4);
bus_nw(v2,10)=2*ones(lv2,1);
bus_nw(v2,11:12)=[999*ones(33,1) -999*ones(33,1)];
%% line matrix

line_nw=zeros(336,7);

line_nw(1:265,:)=line;

line_nw(266:336,4)=Line.con(266:336,9);

line_nw(266:336,1:2)=Line.con(266:336,1:2);


%%
load_con=[];

Efdi=0.33; % assumed.
S_Efdi=0.0039*exp(1.555*Efdi);

%% Exciters
% col1 type
% col2 machine number
% col3 Tr
% col4 Ka
% col5 Ta
% col6 Tb
% col7 Tc
% col8 Vrmax
% col9 Vrmin
% col10 Ke
% col11 Te
% col12 E1, assumed Efd=0.33
% col13 Se(E1), S_Efd(Efd)=0.0039*exp(1.555*Efd)
% col14 E2
% col15 Se(E2)
% col16 Kf
% col17 Tf
% cols 18 to 20 required for exc_st3 only

exc_con1=[...
1 1   0   20 0.2  0   0 20 0  1.0 0.314 Efdi S_Efdi 0 0 0.063 0.35 zeros(1,3)];
% 1 2   0   20 0.2  0   0 20 0  1.0 0.314 Efdi S_Efdi 0 0 0.063 0.35 zeros(1,3);
% 1 3   0   20 0.2  0   0 20 0  1.0 0.314 Efdi S_Efdi 0 0 0.063 0.35 zeros(1,3)];

exc_con2=[0  1 0  100.000    0.050 0 0   20.000   -20.000];

for m=1:46
    exc_con(m,1:20)=exc_con1;  
end

exc_con(:,2)=1:46;
exc_con(:,8:9)=[3.5*ones(46,1) -2.5*ones(46,1)];
exc_con(:,4)=75; exc_con(:,5)=0.015;

mac_con(6,:)=mac_con(5,:);

v6=[1 2 19];

mac_con(6,v6)=[6 6 6];

% exc_con=[];
% Wind farms and Wind

% ################## Add WTG ###########################

load_con_nw=zeros(lv2,5);
load_con_nw(:,1)=v2;
%load_con = [load_con; 101, 0, 0 ,0 ,0;];

wtg_con1 = [...
    1      10   3   500.0367   1       1.12   0.10    1  -1  56.6...
    0.00159  2     1.5   4.33  0.62    1.11   125.66  25     150     30 ...
    3.0      0.6   3.0   0.3   0.05    27     0       10     -10     0.45...
    -0.45    0     0.80  60    0.01    0      10      0.90   0.5     0.1...
    40       1.1   1.1   0.9   0.4     -0.5   nan     nan    nan     nan...
    nan      -1    1     0.02  0.05    18     5       0.15   1.0     5.0...
    0.0      -0.1  0.1   0.7   0.05    1      0       10     0.0025  1.0...
    5.5      0.1   -1    0.1   0.0     ];
%          x1       x2    x3    x4    x5       x6     x7    x8     x9      2x0

wtg_con1([8 9]) = [1.0 -1.0];
wtg_con1([43 44 45 46]) = [1.5   0.5   0.8   -0.9];

v3=Dfig.con(:,3);
wtg_con_nw=zeros(33,75);

vwr08 = 10.276;
tfin = 6;
vw_wtg1 = [1 -1    13    0    3   0    5    nan  nan  nan   tfin   0.01];

for m=1:33
    wtg_con_nw(m,:)=wtg_con1;
    vw_wtg_nw(m,:)=vw_wtg1;
end

wtg_con_nw(:,1)=1:33;
wtg_con_nw(:,2)=v2;
wtg_con_nw(:,4)=v3;

%% final matrices
bus=bus_nw;
line=line_nw;
load_con=load_con_nw;
wtg_con=wtg_con_nw;
vw_wtg=vw_wtg_nw;
%%



tfin=6;

tao = 1/60;
sw_con = [...
0     0    0    0    0    0    tao;%sets intitial time step
1   144    143  0    0    0    tao; %3 ph fault fault at bus 3
1.05  0    0    0    0    0    tao; %
% 0.41 0    0    0    0    0    0.01; %clear remote end
tfin  0    0    0    0    0    0]; % end simulation

 save(namTfile,'bus','line','exc_con','load_con','mac_con',...
     'sw_con');%,'vw_wtg','wtg_con');

     sstr = s_simuf(namTfile, fpath, 60, 100);
% % % sstr = s_simuf(dfile, fpath, 60, 100);
 
tMAP=sstr.t;
spdMAP=sstr.mac_spd;
plot(tMAP,spdMAP,'DisplayName','tMAP')


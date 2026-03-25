%% =========================================================
%  Fuzzy Logic System: Washing Machine Cycle Time
%  Course  : Introduction to Intelligent Systems
%  Tool    : MATLAB Fuzzy Logic Toolbox (Mamdani FIS)
%  Inputs  : Dirt Level (0-10), Load Size (0-10)
%  Output  : Wash Time (15-95 minutes)
%% =========================================================

clear; clc; close all;

%% ---- 1. BUILD THE FIS ----------------------------------------
fis = mamfis('Name', 'WashingMachineSystem');

% ---- Input 1: Dirt Level --------------------------------------
fis = addInput(fis, [0 10], 'Name', 'DirtLevel');

fis = addMF(fis, 'DirtLevel', 'trapmf', [0 0 2.5 5],   'Name', 'Low');
fis = addMF(fis, 'DirtLevel', 'trimf',  [2.5 5 7.5],   'Name', 'Medium');
fis = addMF(fis, 'DirtLevel', 'trapmf', [5 7.5 10 10], 'Name', 'High');

% ---- Input 2: Load Size ---------------------------------------
fis = addInput(fis, [0 10], 'Name', 'LoadSize');

fis = addMF(fis, 'LoadSize', 'trapmf', [0 0 2.5 5],    'Name', 'Small');
fis = addMF(fis, 'LoadSize', 'trimf',  [2.5 5 7.5],    'Name', 'Medium');
fis = addMF(fis, 'LoadSize', 'trapmf', [5 7.5 10 10],  'Name', 'Large');

% ---- Output: Wash Time ----------------------------------------
fis = addOutput(fis, [15 95], 'Name', 'WashTime');

fis = addMF(fis, 'WashTime', 'trapmf', [15 15 35 55], 'Name', 'Short');
fis = addMF(fis, 'WashTime', 'trimf',  [35 55 75],    'Name', 'Medium');
fis = addMF(fis, 'WashTime', 'trapmf', [60 75 95 95], 'Name', 'Long');

%% ---- 2. RULE BASE (9 Rules) ----------------------------------
% Format: [DirtLevel LoadSize WashTime Weight Connection]
% Connection: 1 = AND

ruleList = [
    1 1 1  1 1;   % Low  + Small  -> Short
    1 2 1  1 1;   % Low  + Medium -> Short
    1 3 2  1 1;   % Low  + Large  -> Medium

    2 1 2  1 1;   % Medium + Small  -> Medium
    2 2 2  1 1;   % Medium + Medium -> Medium
    2 3 3  1 1;   % Medium + Large  -> Long

    3 1 2  1 1;   % High + Small  -> Medium
    3 2 3  1 1;   % High + Medium -> Long
    3 3 3  1 1;   % High + Large  -> Long
];

fis = addRule(fis, ruleList);

%% ---- 3. SAVE THE FIS FILE ------------------------------------
writeFIS(fis, 'washing_machine');
fprintf('FIS saved as washing_machine.fis\n\n');

%% ---- 4. PLOT MEMBERSHIP FUNCTIONS -----------------------------
figure('Name', 'Membership Functions', 'NumberTitle', 'off', ...
       'Position', [100 100 1100 320]);

% Dirt Level
subplot(1,3,1);
plotmf(fis, 'input', 1);
title('Dirt Level Membership Functions', 'FontWeight', 'bold');
xlabel('Dirt Level (0 = Clean, 10 = Very Dirty)');
ylabel('Membership');
legend('Low','Medium','High');
grid on;

% Load Size
subplot(1,3,2);
plotmf(fis, 'input', 2);
title('Load Size Membership Functions', 'FontWeight', 'bold');
xlabel('Load Size (0 = Empty, 10 = Full)');
ylabel('Membership');
legend('Small','Medium','Large');
grid on;

% Wash Time
subplot(1,3,3);
plotmf(fis, 'output', 1);
title('Wash Time Membership Functions', 'FontWeight', 'bold');
xlabel('Time (minutes)');
ylabel('Membership');
legend('Short','Medium','Long');
grid on;

sgtitle('Fuzzy Logic Washing Machine System', ...
        'FontSize', 13, 'FontWeight', 'bold');

%% ---- 5. SURFACE VIEW -----------------------------------------
figure('Name', 'Control Surface', 'NumberTitle', 'off');
gensurf(fis);
title('Wash Time vs Dirt Level and Load Size');
xlabel('Dirt Level');
ylabel('Load Size');
zlabel('Wash Time (min)');
colorbar;
grid on;

%% ---- 6. SAMPLE TEST CASES -------------------------------------
fprintf('%-15s %-15s %-15s\n', 'Dirt', 'Load', 'Wash Time');
fprintf('%s\n', repmat('-',1,45));

testCases = [
    2 2;
    5 5;
    8 8;
    3 7;
    7 3;
    5 9;
];

for i = 1:size(testCases,1)
    result = evalfis(fis, testCases(i,:));
    fprintf('%-15.1f %-15.1f %-15.2f\n', ...
            testCases(i,1), testCases(i,2), result);
end

%% ---- 7. RULE VIEWER ------------------------------------------
ruleview(fis);
fprintf('\nRule Viewer opened.\n');
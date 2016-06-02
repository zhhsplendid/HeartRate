function [ mean_bpm, predicted_bpm_sensor] = waveletExpr(EXPR_ID, USE_WAVELET, wavelet_r, wavelet_order, wavelet_method )
% This function is just used by Huihuang Zheng to do experiments.
% It shouldn't be in the published src code...

  %EXPR_ID = 6;
  %USE_WAVELET = true;
  
  %DATA_PATH = 'C:/Users/zhhsp/Documents/HeartRate/wearable-raw-data/new_experiment_1/';
  DATA_PATH = 'C:/Users/zhhsp/Documents/HeartRate/wearable-raw-data/';
  OUT_FILE_NAME = 'C:/Users/zhhsp/Documents/HeartRate/output/myExpr.txt';
  
  %{
  DATA_FILES = {[DATA_PATH, 'watch1_samsung_data/', int2str(EXPR_ID), '_watch_acc.txt'], ...
               [DATA_PATH, 'watch2_moto_data/', int2str(EXPR_ID), '_watch_acc.txt'], ...
               [DATA_PATH, 'watch1_samsung_data/', int2str(EXPR_ID), '_watch_gyro.txt'], ...
               [DATA_PATH, 'watch2_moto_data/', int2str(EXPR_ID), '_watch_gyro.txt'], ...
               [DATA_PATH, 'heart_data_rename/rawBeatData-', int2str(EXPR_ID), '.csv'], ...
               [DATA_PATH, 'heart_data_rename/rawHRData-', int2str(EXPR_ID), '.csv'], ...
              };
  %}
  DATA_FILES = {[DATA_PATH, 'watch1_samsung/', int2str(EXPR_ID), '_watch_acc.txt'], ...
               [DATA_PATH, 'watch2_moto/', int2str(EXPR_ID), '_watch_acc.txt'], ...
               [DATA_PATH, 'watch1_samsung/', int2str(EXPR_ID), '_watch_gyro.txt'], ...
               [DATA_PATH, 'watch2_moto/', int2str(EXPR_ID), '_watch_gyro.txt'], ...
               [DATA_PATH, 'heartrate/rawBeatData-', int2str(EXPR_ID), '.csv'], ...
               [DATA_PATH, 'heartrate/rawHRData-', int2str(EXPR_ID), '.csv'], ...
              };
  
  % DATA_FILES will be like:
  % DATA_FILES{i} where i from 1 to ACC_INDEX are accelerometer data
  ACC_INDEX = 2; 
  % DATA_FILES{i} where i from 1 to ACC_GYRO_INDEX are accelerometer or gyroscope data
  ACC_GYRO_INDEX = 4; 
  % Then followed by heart beat data and hear rate data
  
  % Sample time used for drawing figure
  SAMPLE_BEGIN = 0;
  SAMPLE_DURATION = 30000;
  SAMPLE_END = SAMPLE_BEGIN + SAMPLE_DURATION;

  numData = length(DATA_FILES);
  
  for i = 1: numData
    %DATA_FILES{i}
    data{i} = importdata(DATA_FILES{i}, ':');
  end
  
  fout = fopen(OUT_FILE_NAME, 'w');
  
  rawBeatData = data{ACC_GYRO_INDEX + 1};
  mean_bpm = mean(rawBeatData(:,2));
  fprintf(fout, [num2str(mean_bpm), '\t']);
  
  
  predicted_bpm_sensor = zeros(ACC_GYRO_INDEX, 1);
  peaks = zeros(ACC_GYRO_INDEX, 1);
 
  finalTimedData{ACC_GYRO_INDEX} = [];
  
  for i = 1: ACC_GYRO_INDEX
    rawData = data{i};
    waveletData = zeros(size(rawData));
    if USE_WAVELET %use wavelet to raw data
        waveletData(:,1) = rawData(:,1);
        for j = 2:4 %3 dimensions for acceleromation and gyroscope 
            waveletData(:,j) = wavelet_process(rawData(:,j), wavelet_r, wavelet_order, wavelet_method);
        end
    else
        waveletData = rawData;
    end
    [predicted_bpm_sensor(i), peaks(i), finalTimedData{i}] = bioWatchInterface(waveletData);
    predicted_bpm_sensor(i);
    fprintf(fout, [num2str(predicted_bpm_sensor(i)), '\t']);
    %finalData = finalTimedData{i};
    %predicted_hr = waveletInterface(finalData(:,2));
  end

  
end


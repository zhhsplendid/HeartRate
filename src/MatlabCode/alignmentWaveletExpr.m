function [ mean_bpm, predicted_bpm_sensor] = alignmentWaveletExpr(EXPR_ID, USE_CANCEL, USE_WAVELET, wavelet_r, wavelet_order, wavelet_method, data )
% This function is just used by Huihuang Zheng to do experiments.
% It shouldn't be in the published src code...

  %EXPR_ID = 6;
  %USE_WAVELET = true;
  
  if nargin == 0 % used for debug
    EXPR_ID = 6;
    USE_WAVELET = false;
    USE_CANCEL = true;
    wavelet_r = 0.1;
    wavelet_order = 7;
    wavelet_method = 'db1';
  end
 
  
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
  if nargin < 7 % doesn't have data
      %DATA_PATH = 'C:/Users/zhhsp/Documents/HeartRate/wearable-raw-data/new_experiment_1/';
      DATA_PATH = 'C:/Users/zhhsp/Documents/HeartRate/wearable-raw-data/';
      DATA_FILES = {[DATA_PATH, 'watch1_samsung/', int2str(EXPR_ID), '_watch_acc.txt'], ...
                   [DATA_PATH, 'watch2_moto/', int2str(EXPR_ID), '_watch_acc.txt'], ...
                   [DATA_PATH, 'watch1_samsung/', int2str(EXPR_ID), '_watch_gyro.txt'], ...
                   [DATA_PATH, 'watch2_moto/', int2str(EXPR_ID), '_watch_gyro.txt'], ...
                   [DATA_PATH, 'heartrate/rawBeatData-', int2str(EXPR_ID), '.csv'], ...
                   [DATA_PATH, 'heartrate/rawHRData-', int2str(EXPR_ID), '.csv'], ...
                  };
      numData = length(DATA_FILES);
      for i = 1: numData
        %DATA_FILES{i}
        data{i} = importdata(DATA_FILES{i}, ':');
      end
  end
          
          
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

  
  
  
  
  if USE_CANCEL
    data_pairs = [1, 2; 3, 4];
    oriData = data;
    data = alignCancel(data, data_pairs);
    ACC_INDEX = 1;
    ACC_GYRO_INDEX = 2;
  end
  
  % Draw figures
  if nargin == 0
    for i = 1: 4
      [time_ret{i}, norm_ret{i}] = sampleDataWithinTime( oriData{i}, SAMPLE_BEGIN, SAMPLE_END);
    end
    
    for i = 1:2
      [time_ret{4+i}, norm_ret{4+i}] = sampleDataWithinTime( data{i}, SAMPLE_BEGIN, SAMPLE_END);
    end
    
    figure;
    for i = 1:6
      subplot(3,2,i);
      plot(time_ret{i}, norm_ret{i}, 'k');
      %xlabel('Frequency (Hz)')
      xlabel('Time');
      ylabel('Amplitude');
      titleStr = sprintf('Data %d', i);
      title(titleStr);
    end
  end
  
  %fout = fopen(OUT_FILE_NAME, 'w');
  
  rawBeatData = data{ACC_GYRO_INDEX + 1};
  mean_bpm = mean(rawBeatData(:,2));
  %fprintf(fout, [num2str(mean_bpm), '\t']);
  
  
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
    %fprintf(fout, [num2str(predicted_bpm_sensor(i)), '\t']);
    %finalData = finalTimedData{i};
    %predicted_hr = waveletInterface(finalData(:,2));
  end

  
end


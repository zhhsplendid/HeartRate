function [  ] = bioWatchExperiment( )

  EXPR_ID = 4;
  %DATA_PATH = 'C:/Users/zhhsp/Documents/HeartRate/wearable-raw-data/new_experiment_1/';
  DATA_PATH = 'C:/Users/zhhsp/Documents/HeartRate/wearable-raw-data/';
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
  SAMPLE_DURATION = 30000;
  
  numData = length(DATA_FILES);
  
  for i = 1: numData
    data{i} = importdata(DATA_FILES{i}, ':');
  end
  
  rawBeatData = data{ACC_GYRO_INDEX + 1};
  mean_bpm = mean(rawBeatData(:,2))
  
  predicted_bpm_sensor = zeros(ACC_GYRO_INDEX, 1);
  peaks = zeros(ACC_GYRO_INDEX, 1);
  
  for i = 1: ACC_GYRO_INDEX
    [predicted_bpm_sensor(i), peaks(i)] = bioWatchInterface(data{i});
  end
  
  predicted_bpm_acc = bioWatchSensorCombination(predicted_bpm_sensor(1:ACC_INDEX), peaks(1:ACC_INDEX))
  predicted_bpm = bioWatchSensorCombination(predicted_bpm_sensor(1:ACC_GYRO_INDEX), peaks(1:ACC_GYRO_INDEX))
  
  for i = 1: numData
    [time_ret{i}, norm_ret{i}] = sampleDataWithinTime( data{i}, SAMPLE_DURATION);
  end
  
  %time_new1 = time_ret{1}
  %data_new1 = norm_ret{1}
  subplot(3,2,1)
  plot(time_ret{1}, norm_ret{1}, ':r*')
  %xlabel('Frequency (Hz)')
  xlabel('Time')
  ylabel('Amplitude')
  title('{\bf Accelerometer of Watch 1}')

  subplot(3,2,2)
  %plot(fnew1,pnew1, '--kx')
  plot(time_ret{2}, norm_ret{2}, '--kx')
  %xlabel('Frequency (Hz)')
  xlabel('Time')
  ylabel('Amplitude')
  title('{\bf Accelerometer of Watch 2}')

  subplot(3,2,3)
  %plot(fnew1,pnew1, ':bo')
  plot(time_ret{3}, norm_ret{3}, ':bo')
  %xlabel('Frequency (Hz)')
  xlabel('Time')
  ylabel('Amplitude')
  title('{\bf Gyroscope of Watch 1}')

  subplot(3,2,4)
  %plot(fnew1,pnew1, '--go')
  plot(time_ret{4}, norm_ret{4}, '--go')
  %xlabel('Frequency (Hz)')
  xlabel('Time')
  ylabel('Amplitude')
  title('{\bf Gyroscope of Watch 2}')

  subplot(3,2,5)
  plot(time_ret{5}, norm_ret{5}, 'k')
  xlabel('Time')
  ylabel('Amplitude')
  title('{\bf Hear rate Raw Data of PPG Sensor}')

  subplot(3,2,6)
  plot(time_ret{6}, norm_ret{6}, 'k')
  xlabel('Time')
  ylabel('BPM')
  title('{\bf Calculated BPM on PPG Sensor in Real Time}')
  
end


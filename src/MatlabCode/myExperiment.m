function [  ] = myExperiment( )
% This function is just used by Huihuang Zheng to do experiments.
% It shouldn't be in the published src code...

  EXPR_ID = 5;
  DATA_PATH = 'C:/Users/zhhsp/Documents/HeartRate/wearable-raw-data/new_experiment_1/';
  %DATA_PATH = 'C:/Users/zhhsp/Documents/HeartRate/wearable-raw-data/';
  OUT_FILE_NAME = 'C:/Users/zhhsp/Documents/HeartRate/output/myExpr.txt';
  
  
  DATA_FILES = {[DATA_PATH, 'watch1_samsung_data/', int2str(EXPR_ID), '_watch_acc.txt'], ...
               [DATA_PATH, 'watch2_moto_data/', int2str(EXPR_ID), '_watch_acc.txt'], ...
               [DATA_PATH, 'watch1_samsung_data/', int2str(EXPR_ID), '_watch_gyro.txt'], ...
               [DATA_PATH, 'watch2_moto_data/', int2str(EXPR_ID), '_watch_gyro.txt'], ...
               [DATA_PATH, 'heart_data_rename/rawBeatData-', int2str(EXPR_ID), '.csv'], ...
               [DATA_PATH, 'heart_data_rename/rawHRData-', int2str(EXPR_ID), '.csv'], ...
              };
  %{
  DATA_FILES = {[DATA_PATH, 'watch1_samsung/', int2str(EXPR_ID), '_watch_acc.txt'], ...
               [DATA_PATH, 'watch2_moto/', int2str(EXPR_ID), '_watch_acc.txt'], ...
               [DATA_PATH, 'watch1_samsung/', int2str(EXPR_ID), '_watch_gyro.txt'], ...
               [DATA_PATH, 'watch2_moto/', int2str(EXPR_ID), '_watch_gyro.txt'], ...
               [DATA_PATH, 'heartrate/rawBeatData-', int2str(EXPR_ID), '.csv'], ...
               [DATA_PATH, 'heartrate/rawHRData-', int2str(EXPR_ID), '.csv'], ...
              };
  %}
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
  fout = fopen(OUT_FILE_NAME, 'w');
  
  
  for i = 1: numData
    %DATA_FILES{i}
    data{i} = importdata(DATA_FILES{i}, ':');
  end
  data{2} = data{1};
  data{4} = data{3};
  
  rawBeatData = data{ACC_GYRO_INDEX + 1};
  mean_bpm = mean(rawBeatData(:,2))
  fprintf(fout, [num2str(mean_bpm), '\t']);
  
  predicted_bpm_sensor = zeros(ACC_GYRO_INDEX, 1);
  peaks = zeros(ACC_GYRO_INDEX, 1);
  
  finalTimedData{ACC_GYRO_INDEX} = [];
  for i = 1: ACC_GYRO_INDEX
    [predicted_bpm_sensor(i), peaks(i), finalTimedData{i}] = bioWatchInterface(data{i});
    predicted_bpm_sensor(i)
    fprintf(fout, [num2str(predicted_bpm_sensor(i)), '\t']);
    %finalData = finalTimedData{i};
    %predicted_hr = waveletInterface(finalData(:,2));
  end
  
  
  finalSampledData = cell(ACC_GYRO_INDEX);
  finalTime = cell(ACC_GYRO_INDEX);
  
  waveletSampledData = cell(ACC_GYRO_INDEX);
  waveletTime = cell(ACC_GYRO_INDEX);
  
  for i = 1: ACC_GYRO_INDEX

    %finalData = finalTimedData{i};
    %size(finalData);
    %dataTmp = data{i};
    %lenData = size(data{i}, 1);
    %maxTime = dataTmp(lenData, 1) + 1;
    %[timeTmp, dataTmp] = sampleDataWithinTime(dataTmp, 0, maxTime);
    
    %waveletData = abs(fft(wavelet_process(dataTmp, 0.1)));
    %waveletData = abs(fft(wavelet_process(finalData(:,2), 0.1)));
    %waveletTimedData = [finalData(:,1), waveletData];
    %size(waveletData)
    [time_ret{i}, norm_ret{i}] = sampleDataWithinTime( data{i}, SAMPLE_BEGIN, SAMPLE_END);
    %[time_ret{i}, norm_ret{i}] = sampleDataWithinTime( finalTimedData{i}, SAMPLE_BEGIN, SAMPLE_END);
    %[finalTime{i}, finalSampledData{i}] = sampleDataWithinTime( finalTimedData{i}, SAMPLE_BEGIN, SAMPLE_END);
    %[waveletTime{i}, waveletSampledData{i}] = sampleDataWithinTime( waveletTimedData, SAMPLE_BEGIN, SAMPLE_END);
  end
  
  for i = ACC_GYRO_INDEX + 1: numData
    [time_ret{i}, norm_ret{i}] = sampleDataWithinTime( data{i}, SAMPLE_BEGIN, SAMPLE_END);
  end
  
  
  subplot(3,2,1)
  plot(time_ret{1}, norm_ret{1}, 'k')
  %xlabel('Frequency (Hz)')
  xlabel('Time')
  ylabel('Amplitude')
  title('{\bf Accelerometer of Watch 1}')

  subplot(3,2,2)
  %plot(fnew1,pnew1, '--kx')
  plot(time_ret{2}, norm_ret{2}, 'k')
  %xlabel('Frequency (Hz)')
  xlabel('Time')
  ylabel('Amplitude')
  title('{\bf Accelerometer of Watch 2}')

  subplot(3,2,3)
  %plot(fnew1,pnew1, ':bo')
  plot(time_ret{3}, norm_ret{3}, 'k')
  %xlabel('Frequency (Hz)')
  xlabel('Time')
  ylabel('Amplitude')
  title('{\bf Gyroscope of Watch 1}')

  subplot(3,2,4)
  %plot(fnew1,pnew1, '--go')
  plot(time_ret{4}, norm_ret{4}, 'k')
  %xlabel('Frequency (Hz)')
  xlabel('Time')
  ylabel('Amplitude')
  title('{\bf Gyroscope of Watch 2}')
  
  subplot(3,2,5)
  plot(time_ret{6}, norm_ret{6}, 'k')
  xlabel('Time')
  ylabel('BPM')
  title('{\bf Heart rate Raw Data of PPG Sensor}')
  
  subplot(3,2,6)
  plot(time_ret{5}, norm_ret{5}, 'k')
  xlabel('Time')
  ylabel('Amplitude')
  title('{\bf Calculated BPM on PPG Sensor in Real Time}')
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % compute BPM curve
  
  WINSTEP = 500;
  
  throwPeak = [0];
  throwData = [];
  for i = 1: ACC_GYRO_INDEX
    rawData = data{i};
    maxLen = length(rawData);
    predicted_bpm = zeros(maxLen, 1);
    for j = WINSTEP: WINSTEP: maxLen
      [bpm, throwPeak, throwData] = bioWatchInterface(rawData(j - WINSTEP + 1: j,:));
      predicted_bpm(j - WINSTEP + 1: j, 1) = ones( WINSTEP, 1) * bpm;
    end
    timedBpmPred = [rawData(:,1), predicted_bpm];
    [timePred{i}, bpmPred{i}] = sampleDataWithinTime(timedBpmPred, SAMPLE_BEGIN, SAMPLE_END);
  end
  
  figure;
  subplot(3,2,1)
  plot(timePred{1}, bpmPred{1}, 'k')
  %xlabel('Frequency (Hz)')
  xlabel('Time')
  ylabel('Amplitude')
  title('{\bf BPM of Accelerometer of Watch 1}')

  subplot(3,2,2)
  %plot(fnew1,pnew1, '--kx')
  plot(timePred{2}, bpmPred{2}, 'k')
  %xlabel('Frequency (Hz)')
  xlabel('Time')
  ylabel('Amplitude')
  title('{\bf BPM of Accelerometer of Watch 2}')

  subplot(3,2,3)
  %plot(fnew1,pnew1, ':bo')
  plot(timePred{3}, bpmPred{3}, 'k')
  %xlabel('Frequency (Hz)')
  xlabel('Time')
  ylabel('Amplitude')
  title('{\bf BPM of Gyroscope of Watch 1}')

  subplot(3,2,4)
  %plot(fnew1,pnew1, '--go')
  plot(timePred{4}, bpmPred{4}, 'k')
  %xlabel('Frequency (Hz)')
  xlabel('Time')
  ylabel('Amplitude')
  title('{\bf BPM of Gyroscope of Watch 2}')
  
  subplot(3,2,5)
  plot(time_ret{6}, norm_ret{6}, 'k')
  xlabel('Time')
  ylabel('BPM')
  title('{\bf Heart rate Raw Data of PPG Sensor}')
  
  subplot(3,2,6)
  plot(time_ret{5}, norm_ret{5}, 'k')
  xlabel('Time')
  ylabel('Amplitude')
  title('{\bf Calculated BPM on PPG Sensor in Real Time}')
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  throwPeak = [0];
  throwData = [];
  for i = 1: ACC_GYRO_INDEX
    rawData = data{i};
    maxLen = length(rawData);
    predicted_bpm = zeros(maxLen, 1);
    for j = 1:maxLen
      [bpm, throwPeak, throwData] = bioWatchInterface(rawData(1:j,:));
      predicted_bpm(j) = bpm;
    end
    timedBpmPred = [rawData(:,1), predicted_bpm];
    [timePred{i}, bpmPred{i}] = sampleDataWithinTime(timedBpmPred, SAMPLE_BEGIN, SAMPLE_END);
  end
  
  figure;
  subplot(3,2,1)
  plot(timePred{1}, bpmPred{1}, 'k')
  %xlabel('Frequency (Hz)')
  xlabel('Time')
  ylabel('Amplitude')
  title('{\bf BPM of Accelerometer of Watch 1}')

  subplot(3,2,2)
  %plot(fnew1,pnew1, '--kx')
  plot(timePred{2}, bpmPred{2}, 'k')
  %xlabel('Frequency (Hz)')
  xlabel('Time')
  ylabel('Amplitude')
  title('{\bf BPM of Accelerometer of Watch 2}')

  subplot(3,2,3)
  %plot(fnew1,pnew1, ':bo')
  plot(timePred{3}, bpmPred{3}, 'k')
  %xlabel('Frequency (Hz)')
  xlabel('Time')
  ylabel('Amplitude')
  title('{\bf BPM of Gyroscope of Watch 1}')

  subplot(3,2,4)
  %plot(fnew1,pnew1, '--go')
  plot(timePred{4}, bpmPred{4}, 'k')
  %xlabel('Frequency (Hz)')
  xlabel('Time')
  ylabel('Amplitude')
  title('{\bf BPM of Gyroscope of Watch 2}')
  
  subplot(3,2,5)
  plot(time_ret{6}, norm_ret{6}, 'k')
  xlabel('Time')
  ylabel('BPM')
  title('{\bf Heart rate Raw Data of PPG Sensor}')
  
  subplot(3,2,6)
  plot(time_ret{5}, norm_ret{5}, 'k')
  xlabel('Time')
  ylabel('Amplitude')
  title('{\bf Calculated BPM on PPG Sensor in Real Time}')
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %{
  DATA_ID = 1;
  
  figure;
  subplot(4,1,1)
  plot(time_ret{DATA_ID}, norm_ret{DATA_ID}, ':r*')
  xlabel('Time')
  ylabel('Amplitude')
  title('{\bf Raw Accelerometer Data of Watch 1}')

  subplot(4,1,2)
  plot(finalTime{DATA_ID}, finalSampledData{DATA_ID}, '--kx')
  xlabel('Time')
  ylabel('Amplitude')
  title('{\bf Data After BioWatch of Watch 1}')

  subplot(4,1,3)
  plot(waveletTime{DATA_ID}, waveletSampledData{DATA_ID}, 'k')
  xlabel('Time')
  ylabel('Amplitude')
  title('{\bf Data After Wavelet of Watch 1}')
  
  subplot(4,1,4)
  plot(time_ret{6}, norm_ret{6}, ':bo')
  xlabel('Time')
  ylabel('Amplitude')
  title('{\bf Heart rate Raw Data of PPG Sensor}')
  
  DATA_ID = 1;
  ORDER_BEGIN = 7;
  ORDER_END = 7;
  TRY_ORDER = ORDER_END - ORDER_BEGIN + 1;
  tryTimedData = data{DATA_ID};
  %tryTimedData = finalTimedData{DATA_ID};
  
  lenData = size(tryTimedData, 1);
  maxTime = tryTimedData(lenData, 1) + 1;
  [timeTmp, dataTmp] = sampleDataWithinTime(tryTimedData, 0, maxTime);
  [oriTime, oriData] = sampleDataWithinTime(tryTimedData, SAMPLE_BEGIN, SAMPLE_END);
  figure;
  
  subplot(TRY_ORDER + 2, 1, 1)
  plot(oriTime, oriData, 'k');
  xlabel('Time')
  ylabel('Amplitude')
  title('Original Data');
  
  for order = 1:TRY_ORDER
    %wavelet_hr = waveletInterface(tryTimedData, order - 1 + ORDER_BEGIN)
    waveletData = abs(fft(wavelet_process(dataTmp, 0.1, order - 1 + ORDER_BEGIN)));
   
    waveletTimedData = [tryTimedData(:,1), waveletData];
    [waveletTimeOrder{i}, waveletSampledDataOrder{i}] = sampleDataWithinTime(waveletTimedData, SAMPLE_BEGIN, SAMPLE_END);
    
    
    subplot(TRY_ORDER + 2, 1, order + 1)
    plot(waveletTimeOrder{i}, waveletSampledDataOrder{i}, 'k');
    xlabel('Time')
    ylabel('Amplitude')
    title(['Wavelet of Order ', num2str(order - 1 + ORDER_BEGIN)]);
  
  end
  
  subplot(TRY_ORDER + 2, 1, TRY_ORDER + 2)
  plot(time_ret{6}, norm_ret{6}, 'k')
  xlabel('Time')
  ylabel('Amplitude')
  title('{\bf Heart rate Raw Data of PPG Sensor}')
  %}
end


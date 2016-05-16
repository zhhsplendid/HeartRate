function [ predicted_bpm ] = bioWatchSensorCombination(predicted_bpm_sensor, peaks )
% This function re-implemented the sensor combination of BioWatch
% Paper reference: http://affect.media.mit.edu/pdfs/15.Hernandez-McDuff-Picard-PervasiveHealth.pdf
% Input:
%   predicted_bpm_sensor: n * 1 matrix. predicted BPM from each sensor
%   peaks: n * 1 matrix. the maximum amplitude from each sensor
% Output:
%    predicted_bpm: 1 real value. Predicted heart beat per minute
  numSensors = size(peaks, 1);
  if numSensors ~= size(predicted_bpm_sensor, 1)
    fprintf('ERROR: number of sensors not equal for bpm and peaks \n');
    predicted_bpm = -1;
    return;
  end
  
  psum = 0;
  for i = 1:numSensors
    psum = psum + peaks(i);
  end
  
  predicted_bpm = 0;
  if psum == 0 % check, no division of zero
    return;
  end
  
  for i = 1:numSensors
    predicted_bpm = (peaks(i) * 1.0) / psum * predicted_bpm_sensor(i);
  end
end


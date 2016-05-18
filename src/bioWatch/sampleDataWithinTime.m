function [time_ret, norm_ret] = sampleDataWithinTime( data, sample_begin, sample_end)
% This function draw figure for data within certain time.
% The figure x-axis is time and y-axis is L-2 norm for 
%
% input:
%   data: n * k matrix. the data we are going to draw.
%         first column of data is timestamp. We will draw L2 norm
%                            
%   sample_duration: a real value. We draw data with timestamp in [0, sample_duration)
%   title_str: string for title
% output:
%   time_ret: size n * 1, timestamps of data we sampled
%   norm_ret: size n * 1, the norm values of sampled data

  relative_time = data(:,1) - data(1,1);
  indices = find(relative_time < sample_end & relative_time >= sample_begin);
  n = length(indices);
  norm_ret = zeros(n, 1);
  time_ret = zeros(n, 1);
  
  for i = 1:n
    index = indices(i);
    time_ret(index, 1) = relative_time(index);
    norm_ret(index, 1) = norm(data(index, 2:end));
  end
end


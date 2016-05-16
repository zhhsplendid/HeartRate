
clear all;

str_acc1 = strcat('/Users/swadhin/UT_Spring2016/Emotion_Sense/Dataset/watch1_samsung/', int2str(7),'_watch_acc.txt');
str_acc2 = strcat('/Users/swadhin/UT_Spring2016/Emotion_Sense/Dataset/watch2_moto/', int2str(7),'_watch_acc.txt');

str_gyro1 = strcat('/Users/swadhin/UT_Spring2016/Emotion_Sense/Dataset/watch1_samsung/', int2str(7),'_watch_gyro.txt');
str_gyro2 = strcat('/Users/swadhin/UT_Spring2016/Emotion_Sense/Dataset/watch2_moto/', int2str(7),'_watch_gyro.txt');

str_heart = strcat('/Users/swadhin/UT_Spring2016/Emotion_Sense/Dataset/heartrate/', 'rawBeatData-',int2str(4),'.csv');
str_heart1 = strcat('/Users/swadhin/UT_Spring2016/Emotion_Sense/Dataset/heartrate/', 'rawHRData-',int2str(4),'.csv');


data1 = importdata(str_acc1, ':');
data2 = importdata(str_acc2, ':');
data3 = importdata(str_gyro1, ':');
data4 = importdata(str_gyro2, ':');
heart = importdata(str_heart, ':');
heart1 = importdata(str_heart1, ':');

mean_bpm = mean(heart(:,2))

w1Acc = zscore([data1(:,2) data1(:,3) data1(:,4)]);
w2Acc = zscore([data2(:,2) data2(:,3) data2(:,4)]);
w1Gyro = zscore([data3(:,2) data3(:,3) data3(:,4)]);
w2Gyro = zscore([data4(:,2) data4(:,3) data4(:,4)]);

%1/7th of Second ~10 point moving average for 100Hz Data
B = 1/14*ones(14,1);
w1OutAcc = [filter(B,1,w1Acc(:,1)) filter(B,1,w1Acc(:,2)) filter(B,1,w1Acc(:,3))];
w2OutAcc = [filter(B,1,w2Acc(:,1)) filter(B,1,w2Acc(:,2)) filter(B,1,w2Acc(:,3))];
w1OutGyro = [filter(B,1,w1Gyro(:,1)) filter(B,1,w1Gyro(:,2)) filter(B,1,w1Gyro(:,3))];
w2OutGyro = [filter(B,1,w2Gyro(:,1)) filter(B,1,w2Gyro(:,2)) filter(B,1,w2Gyro(:,3))];

[b,a] = butter(2, [4 11]/(100/2), 'bandpass');
w1ButAcc = [filter(b,a,w1OutAcc(:,1)) filter(b,a,w1OutAcc(:,2)) filter(b,a,w1OutAcc(:,3))];
w2ButAcc = [filter(b,a,w2OutAcc(:,1)) filter(b,a,w2OutAcc(:,2)) filter(b,a,w2OutAcc(:,3))];
w1ButGyro = [filter(b,a,w1OutGyro(:,1)) filter(b,a,w1OutGyro(:,2)) filter(b,a,w1OutGyro(:,3))];
w2ButGyro = [filter(b,a,w2OutGyro(:,1));filter(b,a,w2OutGyro(:,2));filter(b,a,w2OutGyro(:,3))];

w1AccSum = sqrt(w1ButAcc(:,1).^2 + w1ButAcc(:,2).^2 + w1ButAcc(:,3).^2);
w2AccSum = sqrt(w2ButAcc(:,1).^2 + w2ButAcc(:,1).^2 + w2ButAcc(:,1).^2);
w1GyroSum = sqrt(w1ButGyro(:,1).^2 + w1ButGyro(:,2).^2 + w1ButGyro(:,3).^2);
w2GyroSum = sqrt(w2ButGyro(:,1).^2 + w2ButGyro(:,1).^2 + w2ButGyro(:,1).^2);

[b1,a1] = butter(2, [0.66 2.5]/(100/2), 'bandpass');
w1FinalAcc = filter(b1,a1,w1AccSum);
w2FinalAcc = filter(b1,a1,w2AccSum);
w1FinalGyro = filter(b1,a1,w1GyroSum);
w2FinalGyro = filter(b1,a1,w2GyroSum);

w1Final = [ (data1(:,1) - data1(1,1))/1000 w1FinalAcc];
%Calculating FFT
fs =100;

m = length(w1FinalAcc);          % Window length
n = pow2(nextpow2(m));           % Transform length
y = fft(w1FinalAcc,n);           % DFT
f = (0:n-1)*(fs/n);              % Frequency range
power = y.*conj(y)/n;           % Power of the DFT

fnew1 = f(f >= 0.66 & f <= 2.5 );

pnew1 = [];
for k=1:1:size(f,2)
    if (f(1,k) >=0.66 & f(1,k) <= 2.5)
        pnew1 = [pnew1 power(k,1)];
    end
end


%Finding Maximum Amplitude Frequency Index
ix=find(pnew1==max(pnew1));

p1 = max(pnew1);

%Printing the Frequency
predicted_bpm1_acc = 60*fnew1(1,ix)

m = length(w2FinalAcc);          % Window length
n = pow2(nextpow2(m));           % Transform length
y = fft(w2FinalAcc,n);           % DFT
f = (0:n-1)*(fs/n);              % Frequency range
power = y.*conj(y)/n;           % Power of the DFT

fnew2 = f(f >= 0.66 & f <= 2.5 );

pnew2 = [];
for k=1:1:size(f,2)
    if (f(1,k) >=0.66 & f(1,k) <= 2.5)
        pnew2 = [pnew2 power(k,1)];
    end
end

%Finding Maximum Amplitude Frequency Index
ix=find(pnew2==max(pnew2));
p2=max(pnew2);

%Printing the Frequency
predicted_bpm2_acc = 60*fnew2(1,ix)

predicted_bpm_acc = ((p1*1.0)/((p1+p2)*1.0))*predicted_bpm1_acc + ((p2*1.0)/((p1+p2)*1.0))*predicted_bpm2_acc

m = length(w1FinalGyro);          % Window length
n = pow2(nextpow2(m));           % Transform length
y = fft(w1FinalGyro,n);           % DFT
f = (0:n-1)*(fs/n);              % Frequency range
power = y.*conj(y)/n;           % Power of the DFT

fnew3 = f(f >= 0.66 & f <= 2.5 );

pnew3 = [];
for k=1:1:size(f,2)
    if (f(1,k) >=0.66 & f(1,k) <= 2.5)
        pnew3 = [pnew3 power(k,1)];
    end
end

%Finding Maximum Amplitude Frequency Index
ix=find(pnew3==max(pnew3));
p3=max(pnew3);

%Printing the Frequency
predicted_bpm3_gyro = 60*fnew3(1,ix)

m = length(w2FinalGyro);          % Window length
n = pow2(nextpow2(m));           % Transform length
y = fft(w2FinalGyro,n);           % DFT
f = (0:n-1)*(fs/n);              % Frequency range
power = y.*conj(y)/n;           % Power of the DFT

fnew4 = f(f >= 0.66 & f <= 2.5 );

pnew4 = [];
for k=1:1:size(f,2)
    if (f(1,k) >=0.66 & f(1,k) <= 2.5)
        pnew4 = [pnew4 power(k,1)];
    end
end

%Finding Maximum Amplitude Frequency Index
ix=find(pnew4==max(pnew4));
p4=max(pnew4);

%Printing the Frequency
predicted_bpm4_gyro = 60*fnew4(1,ix)

predicted_bpm = ((p1*1.0)/((p1+p2+p3+p4)*1.0))*predicted_bpm1_acc + ((p2*1.0)/((p1+p2+p3+p4)*1.0))*predicted_bpm2_acc + ((p3*1.0)/((p1+p2+p3+p4)*1.0))*predicted_bpm3_gyro + ((p4*1.0)/((p1+p2+p3+p4)*1.0))*predicted_bpm4_gyro

figure
set(gca,'fontsize',24);
hold on;

sample_duration = 30000;
time_diff = 0;

data1_new = [];
time1_new = [];

i=1;
while time_diff < sample_duration
    time_diff = data1(i,1)-data1(1,1);
    time1_new = [time1_new; time_diff];
    data1_new = [ data1_new ; data1(i,2) data1(i,3) data1(i,4) ];
    i = i + 1;
end

data2_new = [];
time2_new = [];
i=1;
time_diff = 0;

while time_diff < sample_duration
    time_diff = data2(i,1)-data2(1,1);
    time2_new = [time2_new; time_diff];
    
    data2_new = [ data2_new ; data2(i,2) data2(i,3) data2(i,4) ];
    i = i + 1;
end

data3_new = [];
time3_new = [];
i=1;
time_diff = 0;

while time_diff < sample_duration
    time_diff = data3(i,1)-data3(1,1);
    time3_new = [time3_new; time_diff];
    
    data3_new = [ data3_new ; data3(i,2) data3(i,3) data3(i,4) ];
    i = i + 1;
end

data4_new = [];
time4_new = [];
i=1;
time_diff = 0;

while time_diff < sample_duration
    time_diff = data4(i,1)-data4(1,1);
    time4_new = [time4_new; time_diff];
    
    data4_new = [ data4_new ; data4(i,2) data4(i,3) data4(i,4) ];
    i = i + 1;
end

heart1_new = [];
time5_new = [];
i=1;
time_diff = 0;

while time_diff < sample_duration
    time_diff = heart1(i,1)-heart1(1,1);
    time5_new = [time5_new; time_diff];
    
    heart1_new = [ heart1_new ; heart1(i,2) ];
    i = i + 1;
end

heart_new = [];
time6_new = [];
i=1;
time_diff = 0;

while time_diff < sample_duration
    time_diff = heart(i,1)-heart(1,1);
    time6_new = [time6_new; time_diff];
    
    heart_new = [ heart_new ; heart(i,2) ];
    i = i + 1;
end

subplot(3,2,1)
plot(time1_new(:,1), sqrt(data1_new(:,1).^2 + data1_new(:,2).^2 + data1_new(:,3).^2), ':r*')
%xlabel('Frequency (Hz)')
xlabel('Time')
ylabel('Amplitude')
title('{\bf Accelerometer of Watch 1}')

subplot(3,2,2)
%plot(fnew1,pnew1, '--kx')
plot(time2_new(:,1), sqrt(data2_new(:,1).^2 + data2_new(:,2).^2 + data2_new(:,3).^2), '--kx')
%xlabel('Frequency (Hz)')
xlabel('Time')
ylabel('Amplitude')
title('{\bf Accelerometer of Watch 2}')

subplot(3,2,3)
%plot(fnew1,pnew1, ':bo')
plot(time3_new(:,1), sqrt(data3_new(:,1).^2 + data3_new(:,2).^2 + data3_new(:,3).^2), ':bo')
%xlabel('Frequency (Hz)')
xlabel('Time')
ylabel('Amplitude')
title('{\bf Gyroscope of Watch 1}')

subplot(3,2,4)
%plot(fnew1,pnew1, '--go')
plot(time4_new(:,1), sqrt(data4_new(:,1).^2 + data4_new(:,2).^2 + data4_new(:,3).^2), '--go')
%xlabel('Frequency (Hz)')
xlabel('Time')
ylabel('Amplitude')
title('{\bf Gyroscope of Watch 2}')

subplot(3,2,5)
plot(time5_new(:,1),heart1_new(:,1), 'k')
xlabel('Time')
ylabel('Amplitude')
title('{\bf Hear rate Raw Data of PPG Sensor}')

subplot(3,2,6)
plot(time6_new(:,1),heart_new(:,1), 'k')
xlabel('Time')
ylabel('BPM')
title('{\bf Calculated BPM on PPG Sensor in Real Time}')


%y0 = fftshift(y);          % Rearrange y values
%f0 = (-n/2:n/2-1)*(fs/n);  % 0-centered frequency range
%power0 = y0.*conj(y0)/n;   % 0-centered power

%plot(f0,power0)
%xlabel('Frequency (Hz)')
%ylabel('Power')
%title('{\bf 0-Centered Periodogram}')

%phase = unwrap(angle(y0));

%plot(f0,phase*180/pi)
%xlabel('Frequency (Hz)')
%ylabel('Phase (Degrees)')
%grid on

%
%plot(data1(:,1), sqrt(zscore(data1(:,4)).^2 + zscore(data1(:,3)).^2 + zscore(data1(:,2)).^2));
%hold on;
%plot(data2(:,1), sqrt(zscore(data2(:,4)).^2 + zscore(data2(:,3)).^2 + zscore(data2(:,2)).^2), 'r');


%plot(data1(:,1), sqrt(w1ButAcc(:,1).^2 + w1ButAcc(:,2).^2 + w1ButAcc(:,3).^2));
%hold on;
%plot(data2(:,1), sqrt(w2ButAcc(:,1).^2 + w2ButAcc(:,1).^2 + w2ButAcc(:,1).^2), 'r')

%plot(data1(:,1), w1FinalAcc)
%hold on;
%plot(data2(:,1), w2FinalAcc);

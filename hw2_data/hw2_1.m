close all; clear; clc;

%% INITIALS AND COLOR TRANSFORMATION (5 PTS)

% Load the video file into Matlab,
v = VideoReader('baby2.mp4');

% extract its frames, and convert them to double-precision in the range[0,
% 1]. Then, convert each of the frames to the YIQ color space.
numFrames = 0;
while hasFrame(v)
    V(:,:,:,numFrames+1)=rgb2ntsc(im2double(readFrame(v)));
%     V(:,:,:,numFrames+1)=rgb2ntsc(readFrame(v));
%     V(:,:,:,numFrames+1)=im2double(readFrame(v));
%     V(:,:,:,numFrames+1)=readFrame(v);
    numFrames = numFrames + 1;
end
w = v.Width;
h = v.Height;


%% LAPLACIAN PYRAMID (20 PTS)

% Initialization of Laplacian Pyramids
N = 5; % N-1 levels
lprpyr = cell(N, 1);
temp = V(:,:,:,1);
for i = 1:N
   lprpyr{i} = zeros(size(temp,1), size(temp,2), 3 , numFrames);
   temp = impyramid(temp, 'reduce');
end

% Getting Laplacian Pyramids
for i = 1: numFrames
    frame1 = V(:,:,:,i);
    for j = 1:N
        frame2 = impyramid(frame1, 'reduce');
        framed = frame1 - imresize(impyramid(frame2, 'expand'), [size(frame1, 1), size(frame1, 2)]);
        lprpyr{j}(:,:,:,i) = framed;

        frame1 = frame2;
    end
end


%% TEMPORAL FILTERING (30 PTS)
 
fs = v.FrameRate; % sampling frequency
% BPF = butterworthBandpassFilter(fs, 6, 1, 5); % baby2_1
% BPF = butterworthBandpassFilter(fs, 6, 2.33, 2.67); % baby2_2
BPF = butterworthBandpassFilter(fs, 6, 0.8, 1.2); % baby2_3
% freqz(BPF, numFrames);
% fvtool(BPF);

lprpyr_tf = lprpyr; % temporal filtered Laplacian Pyramid
for i = 1:N
    I = size(lprpyr{i}, 1);
    J = size(lprpyr{i}, 2);
    for j = 1:I
        for k = 1:J
%             lprpyr_tf{i}(j, k, 1, :) = reshape(filter(BPF, reshape(lprpyr{i}(j, k, 1, :) , [], 1)), 1, 1, 1, []);
%             lprpyr_tf{i}(j, k, 2, :) = reshape(filter(BPF, reshape(lprpyr{i}(j, k, 2, :) , [], 1)), 1, 1, 1, []);
%             lprpyr_tf{i}(j, k, 3, :) = reshape(filter(BPF, reshape(lprpyr{i}(j, k, 3, :) , [], 1)), 1, 1, 1, []);
            lprpyr_tf{i}(j, k, 1, :) = ifft(freqz(BPF, numFrames, 'whole') .* fft(reshape(lprpyr{i}(j, k, 1, :) , [], 1), numFrames));
            lprpyr_tf{i}(j, k, 2, :) = ifft(freqz(BPF, numFrames, 'whole') .* fft(reshape(lprpyr{i}(j, k, 2, :) , [], 1), numFrames));
            lprpyr_tf{i}(j, k, 3, :) = ifft(freqz(BPF, numFrames, 'whole') .* fft(reshape(lprpyr{i}(j, k, 3, :) , [], 1), numFrames));
        end
    end
end

%% EXTRACTING THE FREQUENCY BAND OF INTEREST (30 PTS)

% freq_Y_hist = zeros(w*h*numFrames,1);
% for i = 1:w
%     for j = 1:h
%        freq_Y_hist(i:+ numFrames,1) = 
%     end
% end


%% IMAGE RECONSTRUCTION (20 PTS)
% alpha1 = [100 80 50 30 10 5 3]; % alpha for face.mp4
% alpha2 = [100 80 50 30 10 5 3];
% alpha3 = [100 80 50 30 10 5 3];
alpha = [0 0 3 5 15]; 

V2 = V;
% temp = cell(N, 1);
% Reconstruction
for i = 1:N
    for j = 1:numFrames
        temp = lprpyr_tf{i}(:,:,:,j);
        for k = 1:i
            temp = impyramid(temp, 'expand');
        end
        temp = imresize(temp, [h w]);
%         V2(:,:,1,j) = V2(:,:,1,j) + alpha1(i)*temp(:,:,1);
%         V2(:,:,2,j) = V2(:,:,2,j) + alpha2(i)*temp(:,:,2);
%         V2(:,:,3,j) = V2(:,:,3,j) + alpha3(i)*temp(:,:,3);
        V2(:,:,:,j) = V2(:,:,:,j) + alpha(i)*temp;
    end
end

V3 = V2;
for j = 1:numFrames
    V3(:,:,:,j) = ntsc2rgb(V2(:,:,:,j));
end

implay(V3, 30);
 
% Export the video
myVideo = VideoWriter('baby2_60812_003515.AVI', 'uncompressed AVI');
myVideo.FrameRate = 30;
myVideo.Quality = 10;
open(myVideo);
writeVideo(myVideo, V3);
close(myVideo);



%% EXTRA CREDIT: CAPTURE AND MOTION-MAGNIFY YOUR OWN VIDEO(S)
 
 
 
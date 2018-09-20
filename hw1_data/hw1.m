close all;
clear;
clc;

%% INITIALS (5 POINTS)
img = imread('banana_slug.tiff');
[imgX, imgY] = size(img);

imgType = class(img);
imgtypeS = ['The type of input image is ', imgType, '.'];
disp(imgtypeS);

img = double(img);
imgType = class(img);
imgtypeS = ['The type of input image is ', imgType, '.'];
disp(imgtypeS);


%% LINEARIZATION (5 POINTS)
% [max, ia] = max(img)
% [min. ii] = min(img)
% img  = (img - 2047) / 15000;
img(img - 2047  < 0) = 0;
img(img / 15000 > 1) = 1;
img = img/max(max(img));
figure, imshow(img);

%% IDENTIFYING THE CORRECT BAYER PATTERN
% img1 = zeros(size(img,1), size(img,2));
% img2 = zeros(size(img,1), size(img,2));
% img3 = zeros(size(img,1), size(img,2));
% img4 = zeros(size(img,1), size(img,2));

img_rgb = zeros(size(img,1), size(img,2), 3);
img_rgb(1:2:end, 1:2:end,1) = img(1:2:end, 1:2:end);
img_rgb(1:2:end, 2:2:end,2) = img(1:2:end, 2:2:end);
% img_rgb(2:2:end, 1:2:end,2) = img(2:2:end, 1:2:end);
img_rgb(2:2:end, 2:2:end,3) = img(2:2:end, 2:2:end);
% img_rggb = zeros(size(img,1), size(img,2), 3);
% img_rgb(2:2:end,1:2:end,1) = img(2:2:end,1:2:end);
% img_rgb(1:2:end,1:2:end,2) = img(1:2:end,1:2:end);
% img_rgb(2:2:end,2:2:end,2) = img(2:2:end,2:2:end);
% img_rgb(1:2:end,2:2:end,3) = img(1:2:end,2:2:end);

% figure, imshow(img_rgb);

% img1 = img(1:2:end, 1:2:end);
% img2 = img(1:2:end, 2:2:end);
% img3 = img(2:2:end, 1:2:end);
% img4 = img(2:2:end, 2:2:end);
% 
% img_rggb = cat(3, img1, (img2+img3)/2, img4);
% img_bggr = cat(3, img4, (img2+img3)/2, img1);
% img_gbrg = cat(3, img3, (img1+img4)/2, img2);
% img_grbg = cat(3, img2, (img1+img4)/2, img3);
% 
% figure,
% subplot(2,2,1), imshow(img_grbg);
% subplot(2,2,2), imshow(img_rggb);
% subplot(2,2,3), imshow(img_bggr);
% subplot(2,2,4), imshow(img_gbrg);
% 
% figure,
% subplot(2,2,1), imshow(min(1, 5*img_grbg));
% subplot(2,2,2), imshow(min(1, 5*img_rggb));
% subplot(2,2,3), imshow(min(1, 5*img_bggr));
% subplot(2,2,4), imshow(min(1, 5*img_gbrg));

%% trash1
% temp = zeros(size(img,1)+2, size(img,2)+2);
% temp(2:1+size(img,1), 2:1+size(img,2)) = img;

% grbg = zeros(2,2,3);
% grbg(1,1,2) = 1;
% grbg(1,2,1) = 1;
% grbg(2,1,3) = 1;
% grbg(2,2,2) = 1;
% rggb = zeros(2,2,3);
% rggb(1,1,1) = 1;
% rggb(1,2,2) = 1;
% rggb(2,1,2) = 1;
% rggb(2,2,3) = 1;
% bggr = zeros(2,2,3);
% bggr(1,1,3) = 1;
% bggr(1,2,2) = 1;
% bggr(2,1,2) = 1;
% bggr(2,1,1) = 1;
% gbrg = zeros(2,2,3);
% gbrg(1,1,2) = 1;
% gbrg(1,2,3) = 1;
% gbrg(2,1,1) = 1;
% gbrg(2,2,2) = 1;

% img_r = img

%% WHITE BALANCING (20 POINTS)
% white world
img_w = img_rgb;
img_w(:,:,1) = mean(mean(img_w(:,:,2)))/mean(mean(img_w(:,:,1)))*img_w(:,:,1);
img_w(:,:,3) = mean(mean(img_w(:,:,2)))/mean(mean(img_w(:,:,3)))*img_w(:,:,3);
figure, imshow(img_w);

% gray world
img_g = img_rgb;
img_g(:,:,1) = max(max(img_g(:,:,2)))/max(max(img_g(:,:,1)))*img_g(:,:,1);
img_g(:,:,3) = max(max(img_g(:,:,2)))/max(max(img_g(:,:,3)))*img_g(:,:,3);
figure, imshow(img_g);

%% DEMOSAICING(25POINTS)

% X = 1:2:size(img,1);
% Y = 1:2:size(img,2);
% [X, Y] = meshgrid(X, Y);
% Xq = 1:size(img,1);
% Yq = 1:size(img,2);
% [Xq, Yq] = meshgrid(Xq, Yq);
% 
% img1q = interp2(X,Y,img1',Xq,Yq,'bilinear');
% img1q = img1q';
% img2q = interp2(X,Y,img2',Xq,Yq,'bilinear');
% img2q = img2q';
% img3q = interp2(X,Y,img3',Xq,Yq,'bilinear');
% img3q = img3q';
% 
% imgq = cat(3, img1q, img2q, img3q);
% % close all;
% figure, imshow(imgq);

X = 1:2:size(img,1);
Y = 1:2:size(img,2);
[X, Y] = meshgrid(X, Y);
Xq = 1:size(img,1);
Yq = 1:size(img,2);
[Xq, Yq] = meshgrid(Xq, Yq);

img_rgb(:,:,1) = interp2(X,Y,img_w(1:2:size(img,1),1:2:size(img,2),1)',Xq,Yq)';
img_rgb(:,:,2) = interp2(X,Y,img_w(1:2:size(img,1),2:2:size(img,2),2)',Xq,Yq)';
img_rgb(:,:,3) = interp2(X,Y,img_w(2:2:size(img,1),2:2:size(img,2),3)',Xq,Yq)';

% figure, imshow((img_rgb));
% x = img_rgb;
% a = x(:,:,1);
% b = x(:,:,2);
% c = x(:,:,3);

% figure, imshow(im2uint8(img_rgb));
% x = img_rgb;
% a = x(:,:,1);

img_w(:,:,1) = interp2(X,Y,img_w(1:2:size(img,1),1:2:size(img,2),1)',Xq,Yq)';
img_w(:,:,2) = interp2(X,Y,img_w(1:2:size(img,1),2:2:size(img,2),2)',Xq,Yq)';
img_w(:,:,3) = interp2(X,Y,img_w(2:2:size(img,1),2:2:size(img,2),3)',Xq,Yq)';


% x = img_w;
% a = x(:,:,1);
% b = x(:,:,2);
% c = x(:,:,3);

% figure, imshow(im2uint8(img_w));
% x = img_w;
% a = x(:,:,1);

img_g(:,:,1) = interp2(X,Y,img_w(1:2:size(img,1),1:2:size(img,2),1)',Xq,Yq)';
img_g(:,:,2) = interp2(X,Y,img_w(1:2:size(img,1),2:2:size(img,2),2)',Xq,Yq)';
img_g(:,:,3) = interp2(X,Y,img_w(2:2:size(img,1),2:2:size(img,2),3)',Xq,Yq)';

% figure, imshow((img_g));
% x = img_g;
% a = x(:,:,1);
% b = x(:,:,2);
% c = x(:,:,3);

% figure, imshow(im2uint8(img_g));
% x = img_g;
% a = x(:,:,1);

%% BRIGHTNESS ADJUSTMENT AND GAMMA CORRECTION (20POINTS)

% img_rgb(:,:,:) = img_rgb(:,:,:)*0.5;
% img_rgb(img_rgb<0.0031308) = img_rgb(img_rgb<0.0031308)*12.92;
% img_rgb(img_rgb>=0.0031308) = (1+0.055)*img_rgb(img_rgb>=0.0031308).^(1/2.4) - 0.055;

img_w(:,:,:) = img_w(:,:,:)*1.2;
img_w(img_w<0.0031308) = img_w(img_w<0.0031308)*12.92;
img_w(img_w>=0.0031308) = (1+0.055)*img_w(img_w>=0.0031308).^(1/2.4) - 0.055;
figure, imshow((img_w));

img_g(:,:,:) = img_g(:,:,:)*1.2;
img_g(img_g<0.0031308) = img_g(img_g<0.0031308)*12.92;
img_g(img_g>=0.0031308) = (1+0.055)*img_g(img_g>=0.0031308).^(1/2.4) - 0.055;
figure, imshow((img_g));

%% COMPRESSION (5PTS)

imwrite(img_w, 'white_img.png');
imwrite(img_g, 'gray_img.png');

imwrite(img_w, 'white_img95.jpeg', 'Quality', 95);
imwrite(img_w, 'gray_img95.jpeg', 'Quality', 95);
imwrite(img_w, 'white_img80.jpeg', 'Quality', 80);
imwrite(img_w, 'gray_img80.jpeg', 'Quality', 80);
imwrite(img_w, 'white_img60.jpeg', 'Quality', 60);
imwrite(img_w, 'gray_img60.jpeg', 'Quality', 60);
imwrite(img_w, 'white_img40.jpeg', 'Quality', 40);
imwrite(img_w, 'gray_img40.jpeg', 'Quality', 40);
imwrite(img_w, 'white_img20.jpeg', 'Quality', 20);
imwrite(img_w, 'gray_img20.jpeg', 'Quality', 20);
imwrite(img_w, 'white_img10.jpeg', 'Quality', 10);
imwrite(img_w, 'gray_img10.jpeg', 'Quality', 10);
imwrite(img_w, 'white_img5.jpeg', 'Quality', 5);
imwrite(img_w, 'gray_img5.jpeg', 'Quality', 5);
imwrite(img_w, 'white_img4.jpeg', 'Quality', 4);
imwrite(img_w, 'gray_img4.jpeg', 'Quality', 4);
imwrite(img_w, 'white_img3.jpeg', 'Quality', 3);
imwrite(img_w, 'gray_img3.jpeg', 'Quality', 3);
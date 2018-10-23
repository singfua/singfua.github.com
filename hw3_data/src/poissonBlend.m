close all; clear; clc;

im_bgr = imresize(im2double(imread('../hw3_data/31.jpg')), 0.5, 'bilinear');
im_obj = imresize(im2double(imread('../hw3_data/32.jpg')), 0.25, 'bilinear');

% get source region mask from the user
objmask = getMask(im_obj);
% align im_s and mask_s with im_background
[im_s, mask_s, mask_offset] = alignSource(im_obj, objmask, im_bgr);

% get offset from background(left-top)
offset_y = round(mask_offset(1)) - round(size(im_obj,2)/2);
offset_x = round(mask_offset(2)) - round(size(im_obj,1));

% get object width, height, nn and Im2var
[imh_obj, imw_obj, nn_obj] = size(im_obj);
Im2var = zeros(imh_obj, imw_obj);
Im2var(1:imh_obj*imw_obj) = 1:imh_obj*imw_obj;

% get cropped image from background
im_src = im_bgr(offset_x:offset_x+imh_obj, offset_y:offset_y+imw_obj, :);

P = imh_obj*imw_obj; % The number of pixels
M = P; % The number of equations
N = P; % The number of variables


K = 4; % how many pixels are accessed when dealing with one pixel
v = zeros(M, nn_obj); % result image
b_r = zeros(M, 1);
b_g = zeros(M, 1);
b_b = zeros(M, 1);
e = 1; % The counter of equation
A_i = []; % for sparse matrix i
A_j = []; % for sparse matrix j
A_k = []; % for sparse matrix k
for x = 1:imh_obj
    for y = 1:imw_obj
        if objmask(x,y)  % Inside mask
            % at (x, y)
            A_i = [A_i e e e e e];
            A_j = [A_j Im2var(x, y) Im2var(x+1, y) Im2var(x-1, y) Im2var(x, y+1) Im2var(x, y-1)];
            A_k = [A_k K -1 -1 -1 -1];
            
            b_r(e) = 4*im_obj(x, y, 1) - im_obj(x+1, y, 1) - im_obj(x-1, y, 1) ...
                - im_obj(x, y+1, 1) - im_obj(x, y-1, 1);
            b_g(e) = 4*im_obj(x, y, 2) - im_obj(x+1, y, 2) - im_obj(x-1, y, 2) ...
                - im_obj(x, y+1, 2) - im_obj(x, y-1, 2);
            b_b(e) = 4*im_obj(x, y, 3) - im_obj(x+1, y, 3) - im_obj(x-1, y, 3) ...
                - im_obj(x, y+1, 3) - im_obj(x, y-1, 3);
        else  %% outside mask
            A_i = [A_i e];
            A_j = [A_j Im2var(x, y)];
            A_k = [A_k 1];
            b_r(e) = im_src(x, y, 1);
            b_g(e) = im_src(x, y, 2);
            b_b(e) = im_src(x, y, 3);
        end
        e = e + 1;
    end
end
A = sparse(A_i, A_j, A_k, M, N);
v(:, 1) = A\b_r;
v(:, 2) = A\b_g;
v(:, 3) = A\b_b;
V = v;
V = reshape(V, imh_obj, imw_obj, nn_obj);

im_result = im_bgr;
for x = 1:imh_obj
    for y = 1:imw_obj
        if objmask(x,y)
            im_result(x + offset_x, y + offset_y, :) = V(x, y, :);
        end
    end
end
figure, imshow(im_result);
imwrite(im_result, '../PB_3.jpg');

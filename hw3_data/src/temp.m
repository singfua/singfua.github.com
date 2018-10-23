im_bgr = imresize(im2double(imread('../data/hiking.jpg')), 0.5, 'bilinear');
im_obj = imresize(im2double(imread('../data/penguin-chick.jpeg')), 0.5, 'bilinear');

% get source region mask from the user
objmask = getMask(im_obj);
% align im_s and mask_s with im_background
[im_s, mask_s] = alignSource(im_obj, objmask, im_bgr);

[imh_bgr, imw_bgr, nn_bgr] = size(im_bgr);
Im2var = zeros(imh_bgr, imw_bgr);
Im2var(1:imh_bgr*imw_bgr) = 1:imh_bgr*imw_bgr;

P = imh_bgr*imw_bgr; % The number of pixels
M = P; % The number of equations
N = P; % The number of variables

% A_r = sparse([], [], [], M, N);
% A_g = sparse([], [], [], M, N);
% A_b = sparse([], [], [], M, N);
% b_r = zeros(M, 1);
% b_g = zeros(M, 1);
% b_b = zeros(M, 1);



% for i = 1:nn_bgr % for R, G, B
%     A = sparse([], [], [], M, N);
% %     A_temp = zeros(M, N);
%     b = zeros(M, 1);
%     
%     for x = 2:imh_bgr-1
%         for y = 2:imw_bgr-1
%             if mask_s(x,y)  % Inside mask
%                 if mask_s(x+1, y) == 1
%                     A(e, Im2var(x, y)) = A(e, Im2var(x, y)) + 1;
%                     A(e, Im2var(x+1, y)) = -1;
%                     b(e) = b(e) + im_s(x+1, y, i) - im_s(x, y, i);
%                 else
%                     A(e, Im2var(x, y)) = A(e, Im2var(x, y)) + 1;
%                     A(e, Im2var(x+1, y)) = -1;
%                     b(e) = b(e) + im_bgr(x+1, y, i) - im_s(x, y, i);
%                 end
%                 if mask_s(x-1, y) == 1
%                     A(e, Im2var(x, y)) = A(e, Im2var(x, y)) + 1;
%                     A(e, Im2var(x-1, y)) = -1;
%                     b(e) = b(e) + im_s(x-1, y, i) - im_s(x, y, i);
%                 else
%                     A(e, Im2var(x, y)) = A(e, Im2var(x, y)) + 1;
%                     A(e, Im2var(x-1, y)) = -1;
%                     b(e) = b(e) + im_bgr(x-1, y, i) - im_s(x, y, i);
%                 end
%                 if mask_s(x, y+1) == 1
%                     A(e, Im2var(x, y)) = A(e, Im2var(x, y)) + 1;
%                     A(e, Im2var(x, y+1)) = -1;
%                     b(e) = b(e) + im_s(x, y+1, i) - im_s(x, y, i);                    
%                 else
%                     A(e, Im2var(x, y)) = A(e, Im2var(x, y)) + 1;
%                     A(e, Im2var(x, y+1)) = -1;
%                     b(e) = b(e) + im_bgr(x, y+1, i) - im_s(x, y, i);                
%                 end
%                 if mask_s(x, y-1) == 1
%                     A(e, Im2var(x, y)) = A(e, Im2var(x, y)) + 1;
%                     A(e, Im2var(x, y+1)) = -1;
%                     b(e) = b(e) + im_s(x, y-1, i) - im_s(x, y, i);                                
%                 else
%                     A(e, Im2var(x, y)) = A(e, Im2var(x, y)) + 1;
%                     A(e, Im2var(x, y-1)) = -1;
%                     b(e) = b(e) + im_bgr(x, y-1, i) - im_s(x, y, i);                        
%                 end
%             else  %% outside mask
%                     A(e, Im2var(x, y)) = A(e, Im2var(x, y)) + 1;
%                     A(e, Im2var(x+1, y)) = -1;
%                     b(e) = b(e) + im_bgr(x+1, y, i) - im_bgr(x, y, i);       
%                     
%                     A(e, Im2var(x, y)) = A(e, Im2var(x, y)) + 1;
%                     A(e, Im2var(x-1, y)) = -1;
%                     b(e) = b(e) + im_bgr(x-1, y, i) - im_bgr(x, y, i);
%                     
%                     A(e, Im2var(x, y)) = A(e, Im2var(x, y)) + 1;
%                     A(e, Im2var(x, y+1)) = -1;
%                     b(e) = b(e) + im_bgr(x, y+1, i) - im_bgr(x, y, i);   
%                     
%                     A(e, Im2var(x, y)) = A(e, Im2var(x, y)) + 1;
%                     A(e, Im2var(x, y+1)) = -1;
%                     b(e) = b(e) + im_bgr(x, y+1, i) - im_bgr(x, y, i);                          
%             end
%             e = e + 1;0
%             
%         end
%     end
%     e = 1;
% end

K = 4; % how many pixels are accessed when dealing with one pixel
v = zeros(M, nn_bgr); % result image
for n = 1:nn_bgr % for R, G, B
%     A = sparse([], [], [], M, N);
%     A_temp = zeros(M, N);
    b = zeros(M, 1);
    e = 1; % The counter of equation
%     A_h = 1; % The counter of size of A
    
    A_i = [];
    A_j = [];
    A_k = [];
    for x = 1:imh_bgr
        for y = 1:imw_bgr
            if mask_s(x,y)  % Inside mask
                % at (x, y)
                A_i = [A_i e]; 
                A_j = [A_j Im2var(x, y)];
                A_k = [A_k K];
%                 A_h = A_h + 1;
                
                if mask_s(x+1, y) == 1
                    A_i = [A_i e];
                    A_j = [A_j Im2var(x+1, y)];
                    A_k = [A_k -1];
                    b(e) = b(e) + im_s(x, y, n) - im_s(x+1, y, n);
%                     A_h = A_h + 1;
                else
                    A_i = [A_i e];
                    A_j = [A_j Im2var(x+1, y)];
                    A_k = [A_k -1];
                    b(e) = b(e) + im_s(x, y, n) - im_bgr(x+1, y, n);
%                     A_h = A_h + 1;
                end
                if mask_s(x-1, y) == 1
                    A_i = [A_i e];
                    A_j = [A_j Im2var(x-1, y)];
                    A_k = [A_k -1];
                    b(e) = b(e) + im_s(x, y, n) - im_s(x-1, y, n);
%                     A_h = A_h + 1;
                else
                    A_i = [A_i e];
                    A_j = [A_j Im2var(x-1, y)];
                    A_k = [A_k -1];
                    b(e) = b(e) + im_s(x, y, n) - im_bgr(x-1, y, n);     
                end
                if mask_s(x, y+1) == 1
                    A_i = [A_i e];
                    A_j = [A_j Im2var(x, y+1)];
                    A_k = [A_k -1];
                    b(e) = b(e) + im_s(x, y, n) - im_s(x, y+1, n);
%                     A_h = A_h + 1;
                else
                    A_i = [A_i e];
                    A_j = [A_j Im2var(x, y+1)];
                    A_k = [A_k -1];
                    b(e) = b(e) + im_s(x, y, n) - im_bgr(x, y+1, n);
%                     A_h = A_h + 1;
                end
                if mask_s(x, y-1) == 1
                    A_i = [A_i e];
                    A_j = [A_j Im2var(x, y-1)];
                    A_k = [A_k -1];
                    b(e) = b(e) + im_s(x, y, n) - im_s(x, y-1, n);                                
                else
                    A_i = [A_i e];
                    A_j = [A_j Im2var(x, y-1)];
                    A_k = [A_k -1];
                    b(e) = b(e) + im_s(x, y, n) - im_s(x, y-1, n) ;
%                     A_h = A_h + 1;
                end
            else  %% outside mask
                 A_i = [A_i e];
                 A_j = [A_j Im2var(x, y)];
                 A_k = [A_k 1];
                 b(e) = b(e) + im_bgr(x, y, n);
%                  A_h = A_h + 1;
            end
            e = e + 1; 
        end
    end
%     A_h = A_h + 1;
    A = sparse(A_i, A_j, A_k, M, N);
    v(:, n) = A\b;
    e = 1;
%     A_h = 1;
end
    W = v;
    W = reshape(W, imh_bgr, imw_bgr, nn_bgr);
    figure, imshow(W);
    imwrite(W, '../1_result.bmp');
    
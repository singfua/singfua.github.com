function im_out = toy_reconstruct(im)

    % im = im2double(imread('data/toy_problem.png'));

    [imh, imw, nn] = size(im);
    Im2var = zeros(imh, imw);
    Im2var(1:imh*imw) = 1:imh*imw;

    P = imh*imw; % The number of pixels
    M = 2*P + 1; % The number of equations
    N = P; % The number of variables 
    A = sparse([], [], [], M, N);
    b = zeros(M, 1);

    % e =e+1; 
    % A(e, im2var(y,x+1))=1; 
    % A(e, im2var(y,x))=-1; 
    % b(2) = s(y,x+1) ? s(y,x);

    e = 1; % The counter of equation

    % objective 1
    for x = 1:imw-1
        for y = 1:imh
            A(e, Im2var(y, x+1)) = 1;
            A(e, Im2var(y, x)) = -1;
            b(e) = im(y, x+1) - im(y, x);
            e = e+1;
        end
    end

    % objective 2
    for x = 1:imw
        for y = 1:imh-1
            A(e, Im2var(y+1, x)) = 1;
            A(e, Im2var(y, x)) = -1;
            b(e) = im(y+1,x) - im(y, x);
            e = e+1;
        end
    end

    % objective 3
    A(e, Im2var(1, 1)) = 1;
    b(e) = im(1, 1);

    % Least square method
    v = A\b;
    v = reshape(v, [imh imw]);
    imshow(v);

    im_out = v;
%     % im is equal to v
%     result = isequal(round(im, 4), round(v, 4)); % round at decimal points at 4
%     if result == 1
%         display('The reconstructed image(v) is equal to the original image(im) (round at decimal points at 4).');
%     else
%         display('The reconstructed image(v) is not equal to the original image(im). (round at decimal points at 4)');
%     end
%     imwrite(im_out, '../toy_reconstructed.png');
end

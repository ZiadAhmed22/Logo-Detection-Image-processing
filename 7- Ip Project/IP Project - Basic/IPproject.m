case1 = 'TestCases\Case1\Case1-Front1.bmp';   %% OPEL Logo
case2_1 = 'TestCases\Case2\Case2-Front2.jpg'; %% KIA Logo
case2_2 = 'TestCases\Case2\Case2-Rear1.jpg';  %% Hyundai Logo
case2_3 = 'TestCases\Case2\Case2-Rear2.jpg';  %% Hyundai Logo

img = case1;
c = imread(img);
c = imresize(c,[300,300]);
logo = logoDetection(imageEdit(c),c);

function image = imageEdit(rawImage)

%%.Read and Resize the Image
I  = rawImage;
figure,imshow(I),title ('Original Image');

%%.Sharpen the Image
 for j = 0:2
     I = imsharpen(I);
 end
 figure,imshow(I),title ('sharped Image');
 
%%.Convert the Image to GrayScale 
x = rgb2gray(I);
figure,imshow(x),title ('GrayScale Image');

%%.Enhance Contrast of the Image
for j = 0:2
    x = imadjust(x);
 end
figure,imshow(x),title ('Contrast Enhanced Image');

%%.Delete Low Contrast Parts of the Image
 for i = 1:300
     for j = 1:300
       if (x(i,j)>200)
           x(i,j) = 255;
       end
     end
 end
figure,imshow(x),title ('High Contrast Parts Image');

%%.Get the Edges from the Image 
BW = edge(x,'sobel');
figure,imshow(BW),title ('Edges Of Image');

%%.Get Rid Of Vey Small or Large Shapes from the Image 
BW = bwareafilt(BW, [10, 150]);
figure,imshow(BW),title ('Cleaner Image');

%%.Enhance the Remaining Shapes in the Image 
se = strel('square', 2);
BW = imdilate(BW,se);
figure,imshow(BW),title ('More Visible Image');

%%.Get Rid of the shapes at very edge of the Image using Centroid property
Centroid_property = regionprops(BW, 'Centroid');
Centroid = cat(1,Centroid_property.Centroid);
disp('Centroid');
disp(Centroid);

z = find(Centroid > 60 & Centroid < 200);
labeledImage = bwlabel(BW);
x1 = ismember(labeledImage, z);
figure,imshow(x1),title ('Cleaner Image 2');

%%.Get Rid Of Vey Large Shapes from the Image Using BoundingBox
BoundingBox_property = regionprops(x1, 'BoundingBox');
BoundingBox = cat(1,BoundingBox_property.BoundingBox);
disp('BoundingBox');
disp(BoundingBox);

zz = find(BoundingBox < 170 );
labeledImage = bwlabel(x1);
x2 = ismember(labeledImage, zz);
figure,imshow(x2),title ('Cleaner Image 3');

%%.Return of the Function
image = x2;
end

function logo = logoDetection(preparedImage,c)

PI = preparedImage;

%%.pic the logo process 1 ->Eccentricity
Eccentricity_property = regionprops(PI, 'Eccentricity');
Eccentricity = cat(1,Eccentricity_property.Eccentricity);
disp('Eccentricity');
disp(Eccentricity);

logoName = '';
if (find(Eccentricity > 0.40 & Eccentricity < 0.45))
   E = find(Eccentricity > 0.40 & Eccentricity < 0.45);
   logoName = 'KIA Car';
   labeledImage = bwlabel(PI);
   the_logo = ismember(labeledImage, E);
   figure,imshow(the_logo),title ('logo In processing Eccentricity');
elseif(find(Eccentricity > 0.45 & Eccentricity < 0.50))
   E = find(Eccentricity > 0.45 & Eccentricity < 0.50);
   logoName = 'OPEL Car';
   labeledImage = bwlabel(PI);
   the_logo = ismember(labeledImage, E);
   figure,imshow(the_logo),title ('logo In processing Eccentricity');
elseif(find(Eccentricity > 0.60 & Eccentricity < 0.80) )
   E = find(Eccentricity > 0.60 & Eccentricity < 0.80);
   labeledImage = bwlabel(PI);
   the_logo = ismember(labeledImage, E);
   
   %%.pic the logo process 2 - circularity
   props = regionprops(the_logo, 'Area', 'Perimeter');
   allAreas = [props.Area];
   allPerimeters = [props.Perimeter];
   circularity = (allPerimeters .^ 2) ./ (4 * pi * allAreas); 
   disp('circularity');
   disp(circularity);
   if(find(circularity < 1.6 & circularity > 1.3 ))
   E = find(circularity < 1.6 & circularity > 1.3 );
   labeledImage = bwlabel(the_logo);
   the_logo = ismember(labeledImage, E);  
   figure,imshow(the_logo),title ('logo In processing circularity');
   logoName = 'Hyundai Car';
   end
else
   logoName = 'Invalid';
end

%%.detect the bounding Box of the logo
BoundingBox_property = regionprops(the_logo, 'BoundingBox');
Bou = [BoundingBox_property.BoundingBox];
disp('BoundingBox');
disp(Bou);

%%.the logo indices (x1,x2,y1,y2) -> +10 , -10 
x1 = Bou(1) -2;
x2 = Bou(2) -2;
x3 = Bou(3) +4;
x4 = Bou(4) +4;

%%.crop the original image using the logo indices 
I2 = imcrop(c,[ x1 x2 x3 x4]);
I2 = imresize(I2,[250,250]);
figure,imshow(I2),title (logoName);

end

case4_1 = 'TestCases\Bounses\Case4\Case 4-1.jpg';  %% 2 cars (Hyundai)
case4_2 = 'TestCases\Bounses\Case4\Case 4-2.jpg';  %% 2 cars (1 Hyundai - 1 Renault)
case4_3 = 'TestCases\Bounses\Case4\Case 4-3.jpg';  %% 2 cars (1Hyundai - 1 Chery)

%%.preper image for functions
img = case4_3;
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
for j = 0:1
    x = imadjust(x);
 end
figure,imshow(x),title ('Contrast Enhanced Image');

%%.Get the Edges from the Image 
BW = edge(x,'sobel');
figure,imshow(BW),title ('Edges Of Image');

%%.Get Rid Of Vey Small or Large Shapes from the Image 
BW = bwareafilt(BW, [5, 100]);
figure,imshow(BW),title ('Cleaner Image');

%%.Enhance the Remaining Shapes in the Image 
se = strel('square', 2);
BW = imdilate(BW,se);
figure,imshow(BW),title ('More Visible Image');

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
I2 = imresize(I2,[200,200]);
figure,imshow(I2),title (logoName);

end

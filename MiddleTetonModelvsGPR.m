clear; close all

% set file path
fdata = '/Users/elizabeth/Documents/2021/tetons/glaciers/data/';

%% load outlines

load('GRTE_glacier_outlines.mat')
MiddleTeton = GRTE_glacier_outlines(62);
clear GRTE_glacier_outlines

%% load GPR bed depths
table = readtable('Middle_Teton_ice_thickness_June2021.csv');
MTGPRDepths = table2struct(table);
clear table

%% load DEMs

LidarDEM = GRIDobj([fdata 'LIDAR_DEM_Mountains.tif']);
LidarDEM.name = '2014LidarMountainsDEM';

%% reduce DEM resolution to make it more manageable to work with
res = 5;
LidarDEM = resample(LidarDEM,res);
[Z,X,Y] = GRIDobj2mat(LidarDEM);
[mX,mY] = meshgrid(X,Y);
Z = cast(Z,'double'); %Z is single

%% get aspect and slope of DEM at all locations

slp = arcslope(LidarDEM,'radian');
asp = aspect(LidarDEM);

[Zslope,Xs,Ys] = GRIDobj2mat(slp);
clear vars Xs Ys
[Zasp,Xs,Ys] = GRIDobj2mat(asp);
clear vars Xs Ys


%% extract slope data at glaciers & calc ice thickness/volume
taub = 100000; %Pa
rhoI = 900; %kg m-3
g = 9.81; %m s-2

%finds indices within glacier polygon
in = inpolygon(mX,mY,[MiddleTeton.X],[MiddleTeton.Y]);

%finds slope within polygon
s = double(Zslope);
s(~in) = NaN;
s(s<0.035) = NaN;

%finds elev within polygon
Zt = Z; 
Zt(~in) = NaN;    

%finds aspect within polygon
a = double(Zasp);
a(~in) = NaN;

%calculate thickness using simple slab
tht = taub./(rhoI*g*sin(s));

th = tht;
th(tht > 50) = NaN;

%calculate volume
dX = unique(diff(X));
dY = -unique(diff(Y));
vol = dX*dY*sum(Zt(~isnan(Zt)));

%saves attrs to MiddleTeton
MiddleTeton.thickness = th;
MiddleTeton.volume = vol;
MiddleTeton.slope = s;
MiddleTeton.elev = Zt;    
MiddleTeton.aspect = a;
MiddleTeton.avgslope = mean(s(in));
MiddleTeton.avgaspect = mean(a(in));
MiddleTeton.avgelev = mean(Z(in));
MiddleTeton.Xth = mX;
MiddleTeton.Xth(~in) = NaN;
MiddleTeton.Yth = mY;
MiddleTeton.Yth(~in) = NaN;
MiddleTeton.minGlacierSize = MiddleTeton.ShapeArea > 1e5; %is area > 0.1 km^2 (1e5 m^2)?
MiddleTeton.dem = LidarDEM.name;

%%
figure()
%t = tiledlayout(3,2,'TileSpacing','Tight','Padding','Compact');
title('Middle Teton Glacier: GPR overlayed on model','FontWeight','normal')

Xx = MiddleTeton.Xth;
Yy = MiddleTeton.Yth;    
Zz = MiddleTeton.elev;
Th = MiddleTeton.thickness;
MTG = crop(LidarDEM,[515186 515966],[4841660 4842500]);

% nexttile(1,[2,2])
imageschs(MTG,[],'colormap', (ttscm('oslo')),'ticklabels','nice','colorbarylabel','Elevation (m)')
hold on;
[cx, cy] = contour(MTG,10); 
plot(cx, cy, 'Color','w','LineWidth',0.5)
sp = pcolor(Xx,Yy,Th);
%set(sp,'Facealpha',0.7)

caxis([0 40])
scatter([MTGPRDepths.Easting_m],[MTGPRDepths.Northing_m],10,[MTGPRDepths.IceThickness_m],'^')

c = colorbar;
c.Label.String = 'thickness (m)';
colormap parula
caxis([0 40])
sp.EdgeColor = 'None';
sp.FaceColor = 'interp';

ylim([4841660 4842500])
xlim([515186 515966])

% nexttile
% imageschs(MTG,[],'colormap', (ttscm('oslo')),'ticklabels','nice','colorbarylabel','Elevation (m)')
% hold on;
% plot(cx, cy, 'Color','w','LineWidth',0.5)
% sp = pcolor(Xx,Yy,Th);
% caxis([0 40])
% 
% c = colorbar;
% c.Label.String = 'thickness (m)';
% colormap parula
% caxis([0 40])
% sp.EdgeColor = 'None';
% sp.FaceColor = 'interp';
% 
% ylim([4841660 4842500])
% xlim([515186 515966])
% title('Model')
% 
% nexttile
% 
% imageschs(MTG,[],'colormap', (ttscm('oslo')),'ticklabels','nice','colorbarylabel','Elevation (m)')
% hold on;
% plot(cx, cy, 'Color','w','LineWidth',0.5)
% scatter([MTGPRDepths.Easting_m],[MTGPRDepths.Northing_m],10,[MTGPRDepths.IceThickness_m],'+')
% 
% c = colorbar;
% c.Label.String = 'thickness (m)';
% colormap parula
% caxis([0 40])
% 
% ylim([4841660 4842500])
% xlim([515186 515966])
% 
% title('GPR')

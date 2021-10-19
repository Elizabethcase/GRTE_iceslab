clear; close all

%% load outlines

load('GRTE_glacier_outlines.mat')

%% load DEMs

LidarDEM = GRIDobj('LIDAR_DEM_Mountains.tif');
LidarDEM.name = '2014LidarMountainsDEM';

%% reduce DEM resolution to make it more manageable to work with
res = 20;
LidarDEM = resample(LidarDEM,res);
[Z,X,Y] = GRIDobj2mat(LidarDEM);
[mX,mY] = meshgrid(X,Y);
Z = cast(Z,'double'); %Z is single

%% plot DEM w/ contours & glacier outlines

f1=figure(1)
imageschs(LidarDEM,[],'colormap', (ttscm('oslo')),'ticklabels','nice','colorbarylabel','Elevation (m)')
hold on;
[cx, cy] = contour(LidarDEM,20); 
plot(cx, cy, 'Color','w','LineWidth',0.5)

uyrs = unique([GRTE_glacier_outlines.year]); %colors outlines by year
colormap = parula(length(uyrs));

hold on;
for i=1:length(GRTE_glacier_outlines)
    [v,j] = min(abs(uyrs-[GRTE_glacier_outlines(i).year]));
    plot([GRTE_glacier_outlines(i).X],[GRTE_glacier_outlines(i).Y],'Color',colormap(j,:,:),'linewidth',1.5)
end

ylim([4840000 4862000])
xlim([508800 520518])
camroll(-90)

%need to add legend for year-outlinecolor

%% get aspect and slope of DEM at all locations

slp = arcslope(LidarDEM,'radian');
asp = aspect(LidarDEM);

figure()
subplot(121)
imageschs(LidarDEM,slp)
title('slope')
c = colorbar;
c.Label.String = 'slope (radians)';
ylim([4840000 4862000])
xlim([508800 520518])
hold on;
for i=67:77
    plot([GRTE_glacier_outlines(i).X],[GRTE_glacier_outlines(i).Y],'Color','w','linewidth',1.2)
end

subplot(122)
imageschs(LidarDEM,asp)
title('aspect')
c = colorbar;
c.Label.String = 'aspect (degrees)';
ylim([4840000 4862000])
xlim([508800 520518])
hold on;
for i=67:77
    [v,j] = min(abs(uyrs-[GRTE_glacier_outlines(i).year]));
    plot([GRTE_glacier_outlines(i).X],[GRTE_glacier_outlines(i).Y],'Color','w','linewidth',1.2)
end

[Zslope,Xs,Ys] = GRIDobj2mat(slp);
clear vars Xs Ys
[Zasp,Xs,Ys] = GRIDobj2mat(asp);
clear vars Xs Ys


%% extract slope data at glaciers & calc ice thickness/volume
taub = 100000; %Pa
rhoI = 900; %kg m-3
g = 9.81; %m s-2

for i=1:length(GRTE_glacier_outlines)
    disp(i)
    %finds indices within glacier polygon
    in = inpolygon(mX,mY,[GRTE_glacier_outlines(i).X],[GRTE_glacier_outlines(i).Y]);
    
    %finds slope within polygon
    s = double(Zslope);
    s(~in) = NaN;
    
    %finds elev within polygon
    Zt = Z; 
    Zt(~in) = NaN;    
    
    %finds aspect within polygon
    a = double(Zasp);
    a(~in) = NaN;
    
    %
    
    %calculate thickness using simple slab
    th = taub./(rhoI*g*sin(s));
    
    %calculate volume
    dX = unique(diff(X));
    dY = -unique(diff(Y));
    vol = dX*dY*sum(Zt(~isnan(Zt)));
    %[cv,vol] = convhull(mX(in),mY(in),th(in)); 
    
    %saves attrs to GRTE_glacier_outlines
    GRTE_glacier_outlines(i).thickness = th;
    GRTE_glacier_outlines(i).volume = vol;
    GRTE_glacier_outlines(i).slope = s;
    GRTE_glacier_outlines(i).elev = Zt;    
    GRTE_glacier_outlines(i).aspect = a;
    GRTE_glacier_outlines(i).avgslope = mean(s(in));
    GRTE_glacier_outlines(i).avgaspect = mean(a(in));
    GRTE_glacier_outlines(i).avgelev = mean(Z(in));
    GRTE_glacier_outlines(i).Xth = mX;
    GRTE_glacier_outlines(i).Xth(~in) = NaN;
    GRTE_glacier_outlines(i).Yth = mY;
    GRTE_glacier_outlines(i).Yth(~in) = NaN;
    GRTE_glacier_outlines(i).minGlacierSize = GRTE_glacier_outlines(i).ShapeArea > 1e5; %is area > 0.1 km^2 (1e5 m^2)?
    GRTE_glacier_outlines(i).dem = LidarDEM.name;

end

%%
figure(f1)

for i = 56:66
    Xx = GRTE_glacier_outlines(i).Xth;
    Yy = GRTE_glacier_outlines(i).Yth;    Zz = GRTE_glacier_outlines(i).elev;
    Th = GRTE_glacier_outlines(i).thickness;
    
    sp = pcolor(Xx,Yy,Th);
    
    c = colorbar;
    c.Label.String = 'thickness (m)';
    colormap parula
    caxis([0 50])
    sp.EdgeColor = 'None';
    sp.FaceColor = 'interp';
    

end

%% plots results from 2015 (since closest date to 2014 LiDAR DEM)

figure('Position',[200,2000,1000,420])
t = tiledlayout(3,4,'TileSpacing','Tight','Padding','Compact');
title(t,'2015 outlines, 2014 LiDAR','FontWeight','normal')

for i = 56:66
    Xx = GRTE_glacier_outlines(i).Xth;
    Yy = GRTE_glacier_outlines(i).Yth;
    Zz = GRTE_glacier_outlines(i).elev;
    Th = GRTE_glacier_outlines(i).thickness;
    
    nexttile()
    s = surf(Xx/10^5,Yy/10^5,Zz,Th);
    c = colorbar;
    c.Label.String = 'thickness (m)';
    caxis([0 50])
    zlabel('Elevation')
    title(GRTE_glacier_outlines(i).GlacierName)
    %title([GRTE_glacier_outlines(i).GlacierName ' ' num2str(GRTE_glacier_outlines(i).year)])
    view([150 30])
    if strcmp(GRTE_glacier_outlines(i).GlacierName,'Teepe')
        view([70 30])
    end
    %drawnow
end


%% save data
save(['GRTE_glacier_outlines_extended'],'GRTE_glacier_outlines')

%% misc plots

%create size matrix
uyrs = unique([GRTE_glacier_outlines(1:77).year]); %size by year
sz = linspace(10,35,length(uyrs));
for i=1:length(uyrs)
    cyplot(i).year = uyrs(i);
    cyplot(i).sz = sz(i);
end

%create color matrix
unm = unique({GRTE_glacier_outlines(1:77).GlacierName});
cols = ['#8c510a';'#fc8d59';'#d8b365';'#f6e8c3';'#4d4d4d';'#c7eae5';'#5ab4ac';'#01665e';'#4575b4';'#4d9221';'#c51b7d';'#762a83';'#b2182b'];
for i=1:length(unm)
    cnplot(i).name = unm{i};
    cnplot(i).color = cols(i,:);
end

figure('Position',[452,377,807,420])
t = tiledlayout(2,2,'TileSpacing','Tight','Padding','Compact');
n=1;

for ind=1:77
    
    nexttile(1)
    hold on;
    if strcmp(GRTE_glacier_outlines(ind).GlacierName,'Middle Triple')
        disp(num2str(ind))
        p1(n) = scatter([GRTE_glacier_outlines(ind).volume],[GRTE_glacier_outlines(ind).avgelev],cyplot([cyplot.year]==GRTE_glacier_outlines(ind).year).sz,'MarkerFaceColor',cnplot(matches({cnplot.name},GRTE_glacier_outlines(ind).GlacierName)).color,'MarkerEdgeColor',cnplot(matches({cnplot.name},GRTE_glacier_outlines(ind).GlacierName)).color,'DisplayName',num2str(cyplot(n).year));
        n=n+1;
    end
    scatter([GRTE_glacier_outlines(ind).volume],[GRTE_glacier_outlines(ind).avgelev],cyplot([cyplot.year]==GRTE_glacier_outlines(ind).year).sz,'MarkerFaceColor',cnplot(matches({cnplot.name},GRTE_glacier_outlines(ind).GlacierName)).color,'MarkerEdgeColor',cnplot(matches({cnplot.name},GRTE_glacier_outlines(ind).GlacierName)).color)
    xlabel('volume (m3)')
    ylabel('avg elevation (m)')
    if ind==77
        [lg1,obj]=legend(p1,'Orientation','Horizontal');
    end

    nexttile(2)
    scatter([GRTE_glacier_outlines(ind).avgaspect],[GRTE_glacier_outlines(ind).avgelev],cyplot([cyplot.year]==GRTE_glacier_outlines(ind).year).sz,'MarkerFaceColor',cnplot(matches({cnplot.name},GRTE_glacier_outlines(ind).GlacierName)).color,'MarkerEdgeColor',cnplot(matches({cnplot.name},GRTE_glacier_outlines(ind).GlacierName)).color)
    xlabel('avg aspect (degrees)')
    ylabel('avg elevation (m)')
    hold on;
    
    nexttile(3)
    scatter([GRTE_glacier_outlines(ind).avgaspect],[GRTE_glacier_outlines(ind).volume],cyplot([cyplot.year]==GRTE_glacier_outlines(ind).year).sz,'MarkerFaceColor',cnplot(matches({cnplot.name},GRTE_glacier_outlines(ind).GlacierName)).color,'MarkerEdgeColor',cnplot(matches({cnplot.name},GRTE_glacier_outlines(ind).GlacierName)).color)
    xlabel('avg aspect (degrees)')
    ylabel('volume (m3)')
    hold on;
    
    nexttile(4)
    if ind < 12
        p = scatter([GRTE_glacier_outlines(ind).ShapeArea],[GRTE_glacier_outlines(ind).avgelev],cyplot([cyplot.year]==GRTE_glacier_outlines(ind).year).sz,'MarkerFaceColor',cnplot(matches({cnplot.name},GRTE_glacier_outlines(ind).GlacierName)).color,'MarkerEdgeColor',cnplot(matches({cnplot.name},GRTE_glacier_outlines(ind).GlacierName)).color,'DisplayName',GRTE_glacier_outlines(ind).GlacierName); 
    else
        lg2 = legend('Orientation','Horizontal','NumColumns',6,'AutoUpdate','off');
        scatter([GRTE_glacier_outlines(ind).ShapeArea],[GRTE_glacier_outlines(ind).avgelev],cyplot([cyplot.year]==GRTE_glacier_outlines(ind).year).sz,'MarkerFaceColor',cnplot(matches({cnplot.name},GRTE_glacier_outlines(ind).GlacierName)).color,'MarkerEdgeColor',cnplot(matches({cnplot.name},GRTE_glacier_outlines(ind).GlacierName)).color);
    end
    xlabel('avg area (m2)')
    ylabel('avg elevation (m)')
    hold on;

end

objhl = findobj(obj, 'type', 'patch'); % objects of legend of type Line
for i = 1:length(objhl)
    set(objhl(i), 'Markersize', sqrt(cyplot(i).sz)); % set marker size as desired
end

lg1.Layout.Tile = 'North';
lg2.Layout.Tile = 'South';
title(t,'Elev, vol, and aspect comparison across GRTE glaciers','FontWeight','normal')

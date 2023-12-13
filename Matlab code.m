function cameraGUI()

% إنشاء نافذة الواجهة الرسومية وتخصيصها
fig = figure('Name', 'Camera GUI', 'Position', [0, 0, 1500,700], 'Color', [0 0 0]);



% اضافة الصورة (1)

icon = imread('bb.png');
iconAxes = axes('Parent', fig, 'Units', 'pixels', 'Position',[ 690, -3, 620, 620]);
iconImage = image(icon, 'Parent', iconAxes);
set(iconAxes, 'Visible', 'off');



%ااضافة الصورة (2)

icon2 = imread('llo.png');
iconAxes2 = axes('Parent', fig, 'Units', 'pixels', 'Position',[130, 100, 190, 190]);
iconImage2= image(icon2, 'Parent', iconAxes2);
set(iconAxes2, 'Visible', 'off');

% نعين عناصر واجة المستخدم

uicontrol('Style', 'text', 'String', 'Observation System', 'Position', [62, 545, 1100, 100], 'FontWeight', 'bold', 'FontSize', 55, 'BackgroundColor', [0 0 0], 'ForegroundColor', [179/255, 19/255, 18/255]);
Name1 = uicontrol('Style', 'text', 'String', 'User Name','Position', [20, 500, 400, 40], 'FontWeight', 'bold', 'FontSize', 25, 'BackgroundColor', [0 0 0], 'ForegroundColor', [1 1 1]);
Name = uicontrol('Style', 'edit', 'Position',  [20, 450, 400, 30], 'FontWeight', 'bold', 'FontSize', 20, 'BackgroundColor', [1 1 1]);
password1 = uicontrol('Style', 'text', 'String', ' Password ','Position',  [-55, 400, 560, 40], 'FontWeight', 'bold', 'FontSize', 25, 'BackgroundColor', [0 0 0], 'ForegroundColor', [1 1 1]);
password = uicontrol('Style', 'edit', 'Position', [20, 350, 400, 30], 'FontSize', 20, 'BackgroundColor', [1 1 1] );

sign = uicontrol('Style', 'pushbutton', 'String', 'Sign in', 'Position', [160, 270, 120, 30], 'Callback', @signButtonCallback, 'FontSize', 15, 'FontWeight', 'bold', 'BackgroundColor',  [179/255, 19/255, 18/255], 'ForegroundColor', 'white');

%تابع الاستجابة لزر الادخال

    function signButtonCallback(~, ~)

% الحصول على قيمة اسم المستخدم وكلمة المرور المدخلة
        enteredName = Name.String;
        enteredPassword = password.String;

        if strcmp(enteredName, 'Mohammed Almostfa') && strcmp(enteredPassword, '123456789')
% يتم تنفيذ إجراءات إذا كانت القيمة المدخلة صحيحة
            delete(password);
            delete(password1);
            delete(sign);
            delete(Name);
            delete(Name1);
            delete(iconAxes2)



%مكونات الواجهة الجديدة
            closeButton = uicontrol('Style', 'pushbutton', 'String', 'close', 'Position', [160,270, 290, 40], 'Callback', @closeButtonCallback,'FontSize', 22, 'FontWeight', 'bold', 'BackgroundColor',  [179/255, 19/255, 18/255], 'ForegroundColor', 'black');
            restart = uicontrol('Style', 'pushbutton', 'String', 'Restart','Position', [160,330, 290, 40], 'Callback', @processVideo, 'FontSize', 22, 'FontWeight', 'bold', 'BackgroundColor', 'white', 'ForegroundColor', 'black');
            start = uicontrol('Style', 'pushbutton', 'String', 'Start','Position', [160,390, 290, 40], 'Callback', @processVideo, 'FontSize', 22, 'FontWeight', 'bold', 'BackgroundColor', 'white', 'ForegroundColor', 'black');

        else
            msgbox('you have entered an  incorrect value');
        end
    end

%تابع العمل
    function processVideo(~, ~)
%تعين اطار العمل
        frameSize = [500 800];

%انشاء كأن التعرف والتتبع

        faceDetector = vision.CascadeObjectDetector();
        pointTracker = vision.PointTracker('MaxBidirectionalError', 3);
%انشاء كان عرض الفيديو

        videoPlayer = vision.VideoPlayer('Position', [480, 10, frameSize(2), frameSize(1)]+10);
        runLoop = true;
        numPts = 0;

        frameCount = 0;

% تخزين  ip الكميرا
        url = 'http://192.168.43.1:8080/shot.jpg';
%قراءة الملف الصوتي وتخزينه في متغير
        [y, Fs] = audioread('sound.mp3');
        player = audioplayer(y, Fs);

        
%قتح الكميرا
        while runLoop && frameCount < 1000
            try
                videoFrame = imread(url);
            catch
                msgbox('Failed to read the video frame. Check the URL or network connection.');
                break;
            end
%تحويل اطار الفيديو الى الللون الرمادي
            videoFrameGray = rgb2gray(videoFrame);
            frameCount = frameCount + 1;

%كتشاف الووجوه في الفيدو وتخزينها في متغيرات
            bboxes = step(faceDetector, videoFrameGray);
            numFaces = size(bboxes, 1);

% يتم تحديد النقاط البارزة في الفيديو
            if numFaces > 0
                xyPoints = [];
                for i = 1:numFaces
                    points = detectMinEigenFeatures(videoFrameGray, 'ROI', bboxes(i, :));
                    xyPoints = [xyPoints; points.Location];
                end
%تتبع نقاط الاهتمام التي تم تحديدها سايقأ وانشاء نقاط تتبع جديدة
             %if  xyPoints >250
                numPts = size(xyPoints, 1);
                release(pointTracker);
                initialize(pointTracker, xyPoints, videoFrameGray);
                

                for i = 1:numFaces
%تحدديد الزايا لرسم المربعات على الوجه
                    bboxPoints = bbox2points(bboxes(i, :));
                    bboxPolygon = reshape(bboxPoints', 1, []);

%التحقق من عدد الوجوه وتغير الشروط حسبب ما تحقق

                    if numFaces > 2 
% تعين اطار احمر على الوجه
                        videoFrame = insertShape(videoFrame, 'Polygon', bboxPolygon, 'LineWidth', 3, 'Color', 'red');
% تشغيل الصوت
                        if ~isplaying(player)
                            play(player);
                        end
                    else
%تعين اطار اصفر على الوجه
                        videoFrame = insertShape(videoFrame, 'Polygon', bboxPolygon, 'LineWidth', 3);
%ايقاف تشغيل الصوت
                        if isplaying(player)
                            stop(player);

                        end

                    end
              end
           
% نعين نقاط على الوجه
                videoFrame = insertMarker(videoFrame, xyPoints, '+', 'Color', 'white');
              end
            %end

            step(videoPlayer,videoFrame);

            runLoop = isOpen(videoPlayer);
        end
%تحرير المساحة من الاطار السابق
        release(videoPlayer);
        release(pointTracker);

    end

%تابع الاغلاق والخروج

    function closeButtonCallback(~, ~)

% تسكير الواجه والكميرا
        close(fig);
        close(videoPlayer)


    end
end
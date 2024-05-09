/*
MIT License

Copyright (c) 2023-2024 Douglas Robertson (douglas@edgeoftheearth.com)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

Author: Douglas Robertson (GitHub: douglasr; Garmin Connect: dbrobert)
*/

import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Time;
import Toybox.WatchUi;

//! TODO - describe module here
module CIQToolsGraphing {

    //! TODO - describe enumeration uses here
    enum {
        LINE_STYLE_DOTTED,
        LINE_STYLE_SOLID
    }

    //! TODO - describe module here
    (:LineGraph)
    module Line {

        //! TODO - describe class here
        class Generic extends WatchUi.Drawable {
            private var _columnWidth as Number;
            private var _rowHeight as Number;
            private var _graphLineWidth as Number;
            private var _dataPoints as [Numeric];
            private var _textColor as ColorType;
            private var _textFont as FontType;
            private var _bgColor as ColorType;
            private var _graphColor as ColorType;
            private var _pointColor as ColorType;
            private var _useBorder as Boolean;
            private var _graphMinValue as Numeric;
            private var _graphMaxValue as Numeric;
            private var _lineStyle as Number = CIQToolsGraphing.LINE_STYLE_DOTTED;

            protected var _useXAxisLabels as Boolean;
            protected var _useYAxisLabels as Boolean;
            protected var _yAxisLabels as Array<String or Null> or Null;
            protected var _xAxisLabels as Array<String or Null> or Null;

            //! Constructor
            function initialize(params as { :identifier as Lang.Object, :locX as Lang.Numeric, :locY as Lang.Numeric, :width as Lang.Numeric, :height as Lang.Numeric, :visible as Lang.Boolean }) {
                Drawable.initialize(params);
                setLocation(params[:x] as Number, params[:y] as Number);
                setSize(params[:width] as Number, params[:height] as Number);
                setVisible(params[:visible] == null || params[:visible] != false);
                _textColor = params[:textColor] as ColorType;
                _textFont = params[:textFont] as FontType;
                _bgColor = params[:bgColor] as ColorType;
                _graphColor = params[:graphColor] as ColorType;
                _pointColor = params[:pointColor] as ColorType;
                _useXAxisLabels = ((params[:xAxisLabels] as Boolean) != false);
                _useYAxisLabels = ((params[:yAxisLabels] as Boolean) != false);
                _useBorder = ((params[:useBorder] as Boolean) == true);

                _columnWidth = width;    // default to one column, full width
                _rowHeight = Math.round(height/5.5).toNumber();
                _graphLineWidth = Math.round(System.getDeviceSettings().screenWidth * 0.005).toNumber();

                _dataPoints = [] as [Numeric];
                _graphMinValue = 0;
                _graphMaxValue = 0;
            }

            //! TODO - describe function here
            function setDataPoints(points as Array<Numeric>) as Void {
                // slice the data points if there are too many and assign to instance variable
                if (points.size() > 0) {
                    var tmpSlice = points.slice(0,7) as [Numeric];
                    if (tmpSlice != null) {
                        _dataPoints = tmpSlice;
                    }
                }

                // go through the data points and determine min/max
                if (_dataPoints.size() > 0) {
                    var minValue = 0;
                    var maxValue = 0;
                    // calculate the y-axis values, converting to printable strings (ie. 15,000 => "15k"), as required
                    for (var i=0; i < _dataPoints.size(); i++) {
                        if (_dataPoints[i] == null) {
                            continue;
                        }
                        if (_dataPoints[i] < minValue) {
                            minValue = _dataPoints[i];
                        } else if (_dataPoints[i] > maxValue) {
                            maxValue = _dataPoints[i];
                        }
                    }
                    _graphMinValue = minValue;
                    _graphMaxValue = maxValue;

                    // determine how many columns to show (will be the greater of data points size or x-axis label size)
                    var numCols = _dataPoints.size();
                    if (_xAxisLabels != null && _xAxisLabels.size() > numCols) {
                        numCols = _xAxisLabels.size();
                    }
                    _columnWidth = Math.round(width/numCols).toNumber();

                } else {
                    _graphMinValue = 0;
                    _graphMaxValue = 0;
                }

                // calculate the axis values to display (based on min/max values of data points)
                if (_graphMinValue == 0 && _graphMaxValue == 0) {
                    _graphMaxValue = 1;
                    _yAxisLabels = [_graphMinValue.toString(), null, null, null, _graphMaxValue.toString()];
                } else {
                    var midValue = _graphMaxValue - ((_graphMaxValue-_graphMinValue)/2.0);
                    var fracVal = midValue - (Math.floor(midValue).toNumber());
                    var midValueStr = "";
                    if (fracVal == 0.0) {
                        midValueStr = midValue.format("%0d");
                    } else {
                        midValueStr = midValue.format("%0.1f");
                    }
                    _yAxisLabels = [null, null, midValueStr, null, _graphMaxValue.toString()];
                }
            }

            //! TODO - describe function here
            function setXAxisLabels(labels as Array<String>) as Void {
                _xAxisLabels = labels;
            }

            //! TODO - describe function here
            //! @param dc Device context
            function draw(dc as Graphics.Dc) as Void {
                if (!isVisible) {
                    return;
                }

                // draw the 5 horizontal lines of the graph (and, Y-axis values)
                dc.setColor(_graphColor, Graphics.COLOR_TRANSPARENT);
                dc.setPenWidth(_graphLineWidth);
                for (var i=0; i < 5; i++) {
                    var rowY = locY+(_rowHeight*i)+(_rowHeight/2);
                    if (_lineStyle == CIQToolsGraphing.LINE_STYLE_SOLID) {
                        dc.drawLine(locX, rowY, locX+width, rowY);
                    } else {
                        // default for line style, if param is unrecognized, is dotted
                        for (var j=0; j < width; j=j+(_graphLineWidth*2)) {
                            dc.drawPoint(locX+j, rowY);
                        }
                    }
                }

                // draw the Y-axis labels, if configured
                if (_useYAxisLabels && _yAxisLabels != null) {
                    var axisValuesXOffset = dc.getTextWidthInPixels(" ", _textFont);
                    dc.setColor(_textColor, Graphics.COLOR_TRANSPARENT);
                    for (var i=0; i < 5; i++) {
                        if (_yAxisLabels[i] != null) {
                            var rowY = locY+height-(_rowHeight*(i+1));
                            dc.drawText(locX+width+axisValuesXOffset, rowY, _textFont, _yAxisLabels[i], Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER);
                        }
                    }
                }

                // draw the X-axis labels
                if (_useXAxisLabels && _xAxisLabels != null) {
                    dc.setColor(_textColor, Graphics.COLOR_TRANSPARENT);
                    var textY = locY + height - (_rowHeight/2);
                    for (var i=0; i < _xAxisLabels.size(); i++) {
                        dc.drawText(locX+(_columnWidth*i)+(_columnWidth/2), textY, Graphics.FONT_SYSTEM_XTINY, _xAxisLabels[i], Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
                    }
                }

                // draw the data points
                if (_dataPoints != null) {
                    var valuePerPixel = (_graphMaxValue-_graphMinValue).toFloat()/(_rowHeight*4).toFloat();
                    var previousPoint = null as [Numeric, Numeric]?;
                    var pointRadius = 3;    // FIXME: this should be dynamicly calculated based on device width/height
                    dc.setColor(_pointColor, _bgColor);
                    for (var i=0; i < _dataPoints.size(); i++) {
                        if (_dataPoints[i] == null) {
                            continue;
                        }
                        var dataPointX = locX+(_columnWidth*i)+(_columnWidth/2);
                        var dataPointY = locY + (_rowHeight*4.5) - Math.round(_dataPoints[i].toFloat()/valuePerPixel).toNumber();
                        dc.setColor(_pointColor, _bgColor);
                        dc.fillCircle(dataPointX, dataPointY, pointRadius);
                        // if
                        if (previousPoint != null) {
                            dc.setPenWidth(2);
                            dc.drawLine(previousPoint[0], previousPoint[1], dataPointX, dataPointY);
                            dc.setColor(_bgColor, _bgColor);
                            dc.setPenWidth(1);
                            dc.drawCircle(previousPoint[0], previousPoint[1], pointRadius+1);
                            dc.drawCircle(dataPointX, dataPointY, pointRadius+1);
                        }
                        previousPoint = [dataPointX, dataPointY];
                    }
                }

                // draw the border
                if (_useBorder) {
                    // carve out a 1 pixel blank area around the border
                    dc.setPenWidth(1);
                    dc.setColor(_bgColor, _bgColor);
                    dc.drawRectangle(locX-1, locY-1, width+2, height+2);
                    // draw border
                    dc.setColor(_graphColor, Graphics.COLOR_TRANSPARENT);
                    dc.drawRectangle(locX, locY, width, height);
                }
            }
        }

        //! TODO - describe class here
        class Weekly extends Line.Generic {

            function initialize(params as { :identifier as Lang.Object, :locX as Lang.Numeric, :locY as Lang.Numeric, :width as Lang.Numeric, :height as Lang.Numeric, :visible as Lang.Boolean }) {
                Line.Generic.initialize(params);

                if (_useXAxisLabels) {
                    // the "daysOfWeekAbbr" param can be one of the following:
                    //   - null (will default to English/default string resource named "DaysOfWeekAbbr")
                    //   - an array of strings (eg. ["M","T","W","T","F","S","S"])
                    //   - a single string of comma separated values (eg. "M,T,W,T,F,S,S")
                    var xLabels = null;
                    var tmpDays = params[:daysOfWeekAbbr] as String or [String];
                    if (tmpDays != null && tmpDays instanceof Lang.Array) {
                        if (tmpDays.size() >= 7) {
                            xLabels = tmpDays.slice(0,7) as [String];
                        }
                    }
                    if (xLabels == null) {
                        // we will treat the value param as a single string of comma-separated values
                        if (tmpDays == null) {
                            // if not yet assigned (due to missing param or invalid data),
                            //   then default to abbreviations for English days of the week
                            tmpDays = WatchUi.loadResource(Rez.Strings.DaysOfWeekAbbr) as String;
                        }
                        // parse out the values within the string and assign to an array
                        xLabels = parseDaysOfWeekAbbrs(tmpDays as String);
                    }

                    // now set the x-axis labels shifted based on today's day of week
                    if (xLabels.size() == 7) {
                        var currentDOW = Gregorian.info(Time.now(), Time.FORMAT_SHORT).day_of_week + 5; // add 5 to start week at Monday (dow % 7 == 0);
                        var startDOW = currentDOW + 1;  // start on the next day of the week (as the oldest, most left value)
                        var tmpDOW = new [7];
                        for (var i=0; i < 7; i++) {
                            tmpDOW[i] = xLabels[(startDOW+i)%7];
                        }
                        xLabels = tmpDOW;

                    } else {
                        // if the parsing didn't work out, then don't display anything
                        xLabels = [];
                    }

                    _xAxisLabels = xLabels;
                }
            }

            private

            //! TODO - describe function here
            function parseDaysOfWeekAbbrs(abbrStr as String) as [String] {
                if (abbrStr == null || abbrStr.equals("")) {
                    return ([] as [String]);
                }
                var daysOfWeekAbbrs = [] as [String];
                var tmpStr = abbrStr as String;
                var commaIdx = tmpStr.find(",");
                while (commaIdx != null) {
                    daysOfWeekAbbrs.add(tmpStr.substring(0,commaIdx) as String);
                    tmpStr = tmpStr.substring(commaIdx+1,99) as String;
                    commaIdx = tmpStr.find(",");
                }
                daysOfWeekAbbrs.add(tmpStr as String);

                return (daysOfWeekAbbrs as [String]);
            }

        }

    }
}
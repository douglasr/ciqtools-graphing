# CIQ Tools Graphing
(c)2023-2024 Douglas Robertson

Author: Douglas Robertson (GitHub: [douglasr](https://github.com/douglasr); Garmin Connect: dbrobert)

## Overview
For the best user experience and minial friction, it is usually ideal to try and keep the interface and flow on apps similar to the native Garmin functionality. As such, the CIQ Tools Graphic barrel is a clone of the graphing functionality present within Garmin devices natively.

## License
This Connect IQ barrel is licensed under the "MIT License", which essentially means that while the original author retains the copyright to the original code, you are free to do whatever you'd like with this code (or any derivative of it). See the LICENSE.txt file for complete details.

## Graph Types
The following graph types are currently available:
- Line Graph (generic and 7-day weekly)

More graphs will be made available as time permits. If you want/need a graph type not yet available, consider helping out. See the CONTRIBUTING.md file for details.

## Using the Barrel
This project cannot be used on it's own; it is designed to be included in existing projects.

### Include the Barrel
Download the barrel file (and associated debug.xml) and include it in your project.
See [Shareable Libraries](https://developer.garmin.com/connect-iq/core-topics/shareable-libraries/) on the Connect IQ Developer site for more details.

### Displaying the Graph
The graphing module contains classes that extend the ```Toybox.WatchUi.Drawable``` object, which then render the actual graph. As such, you can display graphs within your app by either adding the drawable to a layout or by creating a graph drawable object and calling the ```draw()``` function on it.

Regardless of the method used to render you graph, you will still need to pass the data points (and, optionally, labels for the X-axis); see below for details on that.

#### Add Graph to a Layout
To add a graph to a layout simply include a ```<drawable>``` tag:
```
<drawable id="LineGraph" class="CIQToolsGraphing.Line.Generic">
    <param name="x">40</param>
    <param name="y">100</param>
    <param name="width">180</param>
    <param name="height">100</param>
    <param name="visible">true</param>
    <param name="bgColor">0x000000</param>
    <param name="graphColor">0xAAAAAA</param>
    <param name="pointColor">0x00AAFF</param>
    <param name="textColor">0xFFFFFF</param>
    <param name="textFont">Graphics.FONT_SYSTEM_XTINY</param>
    <param name="lineStyle">@CIQToolsGraphing.LINE_STYLE_DOTTED</param>
    <param name="border">false</param>
</drawable>
```

#### Display the Graph Directly (via code)
```
var lineGraph = new CIQToolsGraphing.Line.Generic({
    :identifier => "LineGraph"
    :locX => 40,
    :locY => 100,
    :width => 180,
    :height => 100,
    :visible => true,
    :bgColor => 0x000000,
    :graphColor => 0xAAAAAA,
    :pointColor => 0x00AAFF,
    :textColor => 0xFFFFFF,
    :textFont => Graphics.FONT_SYSTEM_XTINY,
    :lineStyle => CIQToolsGraphing.LINE_STYLE_DOTTED,
    :border => false
});
lineGraph.draw();
```

### Adding/Updating Data for the Graph
Data for the graph must be added dynamically, by calling the ```setDataPoints()``` function on the appropriate graphic object.

```
var dataPoints = [5,8,2,12,11,14,10];
var lineGraph = View.findDrawableById("LineGraph") as CIQToolsGraphing.Line.Weekly;
lineGraph.setDataPoints(dataPoints);
```

## Contributing
Please see the CONTRIBUTING.md file for details on how contribute.

### Contributors
* [Douglas Robertson](https://github.com/douglasr)
